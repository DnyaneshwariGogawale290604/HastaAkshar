import AVFoundation
import SwiftUI

final class CameraSession: NSObject, ObservableObject, @unchecked Sendable {

    let session = AVCaptureSession()

    private var processor: PoseProcessorActor?
    private var onUpdate: (@MainActor (PoseUpdate) -> Void)?

    private let outputQueue = DispatchQueue(
        label: "hastaakshar.camera.output", qos: .userInteractive)

    func configure(
        processor: PoseProcessorActor,
        onUpdate: @escaping @MainActor (PoseUpdate) -> Void
    ) {
        self.processor = processor
        self.onUpdate  = onUpdate

        session.sessionPreset = .high

        guard
            let device = AVCaptureDevice.default(
                .builtInWideAngleCamera, for: .video, position: .front),
            let input  = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else { return }

        session.addInput(input)

        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String:
                kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
        ]
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: outputQueue)

        guard session.canAddOutput(output) else { return }
        session.addOutput(output)

        if let conn = output.connection(with: .video) {
            conn.videoOrientation = .portrait
            conn.isVideoMirrored  = true
        }
    }

    func start() {
        guard !session.isRunning else { return }
        outputQueue.async { self.session.startRunning() }
    }

    func stop() {
        guard session.isRunning else { return }
        outputQueue.async { self.session.stopRunning() }
    }
}

extension CameraSession: AVCaptureVideoDataOutputSampleBufferDelegate {

    nonisolated func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let processor, let onUpdate else { return }

        struct SendableBuffer: @unchecked Sendable { let buffer: CMSampleBuffer }
        let safe = SendableBuffer(buffer: sampleBuffer)

        Task {
            let update = await processor.process(sampleBuffer: safe.buffer)
            await onUpdate(update)
        }
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewUIView {
        let v = PreviewUIView()
        v.previewLayer.session      = session
        v.previewLayer.videoGravity = .resizeAspectFill
        return v
    }
    func updateUIView(_ uiView: PreviewUIView, context: Context) {}

    class PreviewUIView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var previewLayer: AVCaptureVideoPreviewLayer {
            layer as! AVCaptureVideoPreviewLayer
        }
    }
}
