import Foundation


enum MudraLibrary {

    static let asamyuktaMudras: [Mudra] = [
        pataka,
        tripataka,
        ardhapataka,
        kartarimukha,
        mayura,
        ardhachandra
    ]

    static let samyuktaMudras: [Mudra] = [
        anjali,
        kapotha,
        karkata,
        swastika
    ]

    static var allMudras: [Mudra] {
        asamyuktaMudras + samyuktaMudras
    }

   
    static let pataka = Mudra(
        name: "Pataka",
        sanskritName: "पताक",
        category: .asamyukta,
        orderIndex: 0,
        shortDescription: "All four fingers held straight and close together, thumb slightly bent. The hand is held flat and upright, resembling a flag or banner.",
        significance: "Pataka is the most foundational mudra in Bharatanatyam and is used at the commencement of Natya (classical dance). It is the first mudra every student learns and appears more frequently than any other gesture. Its versatility spans the natural world, human experience, and the divine realm.",
        meanings: [
            MudraMeaning(context: "Nature & Elements",
                         meaning: "Clouds, forest, night, river, sea, wind, moonlight, fierce heat, a drizzly day"),
            MudraMeaning(context: "Actions & Gestures",
                         meaning: "Denial, cutting, sweeping with a broom, smearing oneself, feeling objects, opening doors, grasping a sword, stepping forward, taking a pledge, silence"),
            MudraMeaning(context: "Body & World",
                         meaning: "Breasts, the realm of divinities, horse, tides, entering a lane, a lane or path"),
            MudraMeaning(context: "Time & Honor",
                         meaning: "Month, year, equanimity, benefaction, strength, addressing, a good king, series of meritorious actions, blessing"),
            MudraMeaning(context: "Grammar & Ritual",
                         meaning: "All seven case-endings (Vibhakti), palmyra leaf, shield, describing a location, invocations at the commencement of Natya"),
        ],
        poseTarget: ARPoseTarget(
            jointTargets: [
                JointAngleTarget(finger: .index,  joint: .pip, minAngle: 0,  maxAngle: 15,  tolerance: 15, correctionHint: "Straighten your index finger"),
                JointAngleTarget(finger: .middle, joint: .pip, minAngle: 0,  maxAngle: 15,  tolerance: 15, correctionHint: "Straighten your middle finger"),
                JointAngleTarget(finger: .ring,   joint: .pip, minAngle: 0,  maxAngle: 15,  tolerance: 15, correctionHint: "Straighten your ring finger"),
                JointAngleTarget(finger: .little, joint: .pip, minAngle: 0,  maxAngle: 15,  tolerance: 15, correctionHint: "Straighten your little finger"),
                JointAngleTarget(finger: .thumb,  joint: .mcp, minAngle: 25, maxAngle: 65,  tolerance: 25, correctionHint: "Tuck your thumb flat across your palm"),
            ],
            fingerStates: [
                .thumb: .halfBent,
                .index: .straight,
                .middle: .straight,
                .ring: .straight,
                .little: .straight,
            ],
            dominantHand: .right
        ),
        isUnlocked: true,
        illustrationAssetName: "mudra_pataka"
    )

    
    static let tripataka = Mudra(
        name: "Tripataka",
        sanskritName: "त्रिपताक",
        category: .asamyukta,
        orderIndex: 1,
        shortDescription: "From the Pataka pose, the ring finger is bent more than halfway down while all other fingers — index, middle, and little — remain straight. The thumb is slightly tucked.",
        significance: "Tripataka is derived from Pataka and carries rich symbolic meaning in both Nritta and Abhinaya. According to the Abhinaya Darpana, those who know Natya use this mudra to represent a wide range of elements from the natural and cosmic world.",
        meanings: [
            MudraMeaning(context: "Royalty & Nature",
                         meaning: "A crown, a tree, Indra (king of celestials), thunder and Vajrayudha (Indra's thunderbolt weapon), Ketaki flower"),
            MudraMeaning(context: "Fire & Light",
                         meaning: "A lamp, flames of fire"),
            MudraMeaning(context: "Birds & Writing",
                         meaning: "A pigeon, putting marks, writing"),
            MudraMeaning(context: "Action & Change",
                         meaning: "An arrow, transformation"),
        ],
        poseTarget: ARPoseTarget(
            jointTargets: [
                
                JointAngleTarget(finger: .thumb,  joint: .mcp, minAngle: 20,  maxAngle: 55,  tolerance: 20, correctionHint: "Bend thumb toward your ring finger"),

                
                JointAngleTarget(finger: .index,  joint: .pip, minAngle: 0,   maxAngle: 12,  tolerance: 12, correctionHint: "Keep index finger straight"),

                
                JointAngleTarget(finger: .middle, joint: .pip, minAngle: 0,   maxAngle: 12,  tolerance: 12, correctionHint: "Keep middle finger straight"),
                JointAngleTarget(finger: .little, joint: .pip, minAngle: 0,   maxAngle: 12,  tolerance: 12, correctionHint: "Keep little finger straight"),

               
                JointAngleTarget(finger: .ring,   joint: .pip, minAngle: 60,  maxAngle: 100, tolerance: 15, correctionHint: "Bend ring finger down toward your thumb"),
            ],
            fingerStates: [
                .thumb: .slightlyBent,
                .index: .straight,
                .middle: .straight,
                .ring: .halfBent,
                .little: .straight,
            ],
            dominantHand: .right
        ),
        illustrationAssetName: "mudra_tripataka"
    )

    
    static let ardhapataka = Mudra(
        name: "Ardhapataka",
        sanskritName: "अर्धपताक",
        category: .asamyukta,
        orderIndex: 2,
        shortDescription: "In Tripataka Hasta, bending the little finger along with the ring finger forms Ardhapataka. All other fingers — index, middle, and thumb — are held straight.",
        significance: "Ardhapataka is an evolution of Tripataka where one more finger (the little finger) joins the bend. It is used in storytelling to represent physical objects, writing, structures, and relational concepts.",
        meanings: [
            MudraMeaning(context: "Nature & Objects",
                         meaning: "Leaves, a writing or painting board"),
            MudraMeaning(context: "Places & References",
                         meaning: "A river bank, to mention 'both', elaboration"),
            MudraMeaning(context: "Tools & Structures",
                         meaning: "A knife, a flag, a tower, horns"),
        ],
        poseTarget: ARPoseTarget(
            jointTargets: [
               
                JointAngleTarget(finger: .index,  joint: .pip, minAngle: 0,   maxAngle: 8,   tolerance: 10, correctionHint: "Straighten index fully"),
                JointAngleTarget(finger: .middle, joint: .pip, minAngle: 0,   maxAngle: 8,   tolerance: 10, correctionHint: "Straighten middle fully"),
                JointAngleTarget(finger: .ring,   joint: .pip, minAngle: 105, maxAngle: 145, tolerance: 15, correctionHint: "Curl ring finger deeply into palm"),
                JointAngleTarget(finger: .little, joint: .pip, minAngle: 60,  maxAngle: 100, tolerance: 18, correctionHint: "Bend little finger toward your thumb"),
                JointAngleTarget(finger: .thumb,  joint: .mcp, minAngle: 35,  maxAngle: 70,  tolerance: 20, correctionHint: "Bend thumb in toward your little finger"),
            ],
            fingerStates: [
                .thumb: .straight,
                .index: .straight,
                .middle: .straight,
                .ring: .curled,
                .little: .curled,
            ],
            dominantHand: .right
        ),
        illustrationAssetName: "mudra_ardhapataka"
    )

    // MARK: - 4. Kartarimukha 
    static let kartarimukha = Mudra(
        name: "Kartarimukha",
        sanskritName: "कर्तरीमुख",
        category: .asamyukta,
        orderIndex: 3,
        shortDescription: "In Ardhapataka, bending the index and little fingers backwards forms Kartarimukha. The index and middle fingers (or index and little) splay apart like scissors while the remaining fingers curl inward.",
        significance: "Kartarimukha is one of the most versatile and expressive Asamyukta mudras. Its scissor-like form lends itself to depicting sharp contrasts, conflict, separation, and the passage between states — life and death, union and division.",
        meanings: [
            MudraMeaning(context: "Relationships & Conflict",
                         meaning: "Parting of a couple, conflicts, opposition, looting, alienating, disjunction"),
            MudraMeaning(context: "Nature & Forces",
                         meaning: "Lightning, a creeper, fall"),
            MudraMeaning(context: "Human States",
                         meaning: "Corner of the eye, sleeping, clever or inconsistency, death"),
        ],
        poseTarget: ARPoseTarget(
            jointTargets: [
                
                JointAngleTarget(finger: .index,  joint: .pip,
                    minAngle: 0, maxAngle: 18, tolerance: 20,
                    correctionHint: "Extend your index finger straight up"),

                
                JointAngleTarget(finger: .middle, joint: .pip,
                    minAngle: 0, maxAngle: 18, tolerance: 20,
                    correctionHint: "Extend your middle finger straight up"),

                
                JointAngleTarget(finger: .ring,   joint: .pip,
                    minAngle: 75, maxAngle: 155, tolerance: 20,
                    correctionHint: "Curl your ring finger into your palm"),

                
                JointAngleTarget(finger: .little, joint: .pip,
                    minAngle: 65, maxAngle: 145, tolerance: 20,
                    correctionHint: "Curl your little finger into your palm"),

                
                JointAngleTarget(finger: .thumb,  joint: .mcp,
                    minAngle: 30, maxAngle: 80, tolerance: 20,
                    correctionHint: "Bend your thumb inward across the curled fingers"),
            ],
            fingerStates: [
                .thumb:  .halfBent,
                .index:  .straight,
                .middle: .straight,
                .ring:   .fullyBent,
                .little: .fullyBent,
            ],
            dominantHand: .right
        ),
        illustrationAssetName: "mudra_kartarimukha"
    )

    // MARK: - 5. Mayura
    static let mayura = Mudra(
        name: "Mayura",
        sanskritName: "मयूर",
        category: .asamyukta,
        orderIndex: 4,
        shortDescription: "The tip of the ring finger and the tip of the thumb touch each other. All other fingers — index, middle, and little — are held straight and close together.",
        significance: "Mayura is named after the peacock, the divine bird of grace and beauty associated with Saraswati and Lord Muruga. Its delicate formation — thumb tip meeting ring fingertip — evokes the graceful arc of a peacock's neck.",
        meanings: [
            MudraMeaning(context: "Bird & Nature",
                         meaning: "Peacock head and neck, a bird, a creeper"),
            MudraMeaning(context: "Ritual & Adornment",
                         meaning: "Spewing or throwing out, parting of the locks, ornamenting the forehead with a mark, dispersing water of rivers or holy water"),
            MudraMeaning(context: "Knowledge & Fame",
                         meaning: "Knowledge or dialects of scriptural texts, something famous"),
        ],
        poseTarget: ARPoseTarget(
            jointTargets: [
                
                JointAngleTarget(finger: .index,  joint: .pip,
                    minAngle: 0, maxAngle: 20, tolerance: 20,
                    correctionHint: "Keep your index finger straight up"),

                JointAngleTarget(finger: .middle, joint: .pip,
                    minAngle: 0, maxAngle: 20, tolerance: 20,
                    correctionHint: "Keep your middle finger straight up"),

                
                JointAngleTarget(finger: .ring,   joint: .pip,
                    minAngle: 50, maxAngle: 110, tolerance: 20,
                    correctionHint: "Bend your ring finger toward the thumb"),

                
                JointAngleTarget(finger: .little, joint: .pip,
                    minAngle: 0, maxAngle: 40, tolerance: 20,
                    correctionHint: "Let your little finger relax naturally"),

                
                JointAngleTarget(finger: .thumb,  joint: .mcp,
                    minAngle: 25, maxAngle: 70, tolerance: 20,
                    correctionHint: "Bend your thumb toward the ring finger"),

                
                JointAngleTarget(finger: .thumb,  joint: .pip,
                    minAngle: 25, maxAngle: 70, tolerance: 20,
                    correctionHint: "Curl your thumb tip to touch the ring finger"),
            ],
            fingerStates: [
                .thumb:  .halfBent,
                .index:  .straight,
                .middle: .straight,
                .ring:   .halfBent,
                .little: .straight,
            ],
            dominantHand: .right
        ),
        illustrationAssetName: "mudra_mayura"
    )

    // MARK: - 6. Ardhachandra
    static let ardhachandra = Mudra(
        name: "Ardhachandra",
        sanskritName: "अर्धचन्द्र",
        category: .asamyukta,
        orderIndex: 5,
        shortDescription: "From Pataka, the thumb is stretched outward while all other fingers are held straight and together. The open arc of thumb and fingers depicts the half moon.",
        significance: "Ardhachandra is defined in the Abhinaya Darpana as the Pataka hand with the thumb outstretched. Its crescent shape captures the essence of the moon on the eighth night of the waning fortnight and is used for both sacred and worldly representations.",
        meanings: [
            MudraMeaning(context: "Cosmic & Sacred",
                         meaning: "The digit of moon on the eighth night of the waning fortnight, consecrating and bathing an image, invocation, meditation"),
            MudraMeaning(context: "Action & Body",
                         meaning: "Grabbing and pushing by neck, touching one's own limbs, contemplating on oneself"),
            MudraMeaning(context: "Objects & Places",
                         meaning: "A lance, a dining vessel, source of origin, waist"),
            MudraMeaning(context: "Social & Addressing",
                         meaning: "Accosting ordinary people, addressing a group"),
        ],
        poseTarget: ARPoseTarget(
            jointTargets: [
                
                JointAngleTarget(finger: .thumb,  joint: .mcp, minAngle: 0,   maxAngle: 25,  tolerance: 25, correctionHint: "Spread your thumb up and outward"),
                JointAngleTarget(finger: .index,  joint: .pip, minAngle: 0,   maxAngle: 12,  tolerance: 15, correctionHint: "Extend your index finger fully straight"),
                JointAngleTarget(finger: .middle, joint: .pip, minAngle: 0,   maxAngle: 12,  tolerance: 15, correctionHint: "Extend your middle finger fully straight"),
                JointAngleTarget(finger: .ring,   joint: .pip, minAngle: 0,   maxAngle: 12,  tolerance: 15, correctionHint: "Extend your ring finger fully straight"),
                JointAngleTarget(finger: .little, joint: .pip, minAngle: 0,   maxAngle: 12,  tolerance: 15, correctionHint: "Extend your little finger fully straight"),
            ],
            fingerStates: [
                .thumb: .straight,
                .index: .straight,
                .middle: .straight,
                .ring: .straight,
                .little: .straight,
            ],
            dominantHand: .right
        ),
        illustrationAssetName: "mudra_ardhachandra"
    )

    // MARK: - Samyukta Mudras

    // MARK: - Anjali
    static let anjali = Mudra(
        name: "Anjali",
        sanskritName: "अञ्जलि",
        category: .samyukta,
        orderIndex: 0,
        shortDescription: "Anjali is the joining of two Pataka poses — both palms pressed together with all fingers straight and pointing upward. Held above the head for deities, in front of the face for teachers, and at the chest for elders.",
        significance: "Prescribed by the wise for salutations, Anjali is the most universally recognised gesture in Indian tradition and Bharatanatyam. Its placement communicates the rank of the person being honoured — divine, learned, or elder.",
        meanings: [
            MudraMeaning(context: "For Deities",
                         meaning: "Held above the head — the highest salutation, offered to gods and the divine"),
            MudraMeaning(context: "For Teachers",
                         meaning: "Held in front of the face — salutation to gurus and spiritual guides"),
            MudraMeaning(context: "For Elders & Twice-Born",
                         meaning: "Held in front of the chest — respectful greeting to elders and the learned"),
        ],
        poseTarget: ARPoseTarget(
            jointTargets: [
                JointAngleTarget(finger: .index,  joint: .pip, minAngle: 0, maxAngle: 20, tolerance: 10, correctionHint: "Press your index fingers straight together"),
                JointAngleTarget(finger: .middle, joint: .pip, minAngle: 0, maxAngle: 20, tolerance: 10, correctionHint: "Keep your middle fingers straight"),
                JointAngleTarget(finger: .ring,   joint: .pip, minAngle: 0, maxAngle: 20, tolerance: 10, correctionHint: "Keep your ring fingers straight"),
                JointAngleTarget(finger: .little, joint: .pip, minAngle: 0, maxAngle: 20, tolerance: 10, correctionHint: "Keep your little fingers straight"),
                JointAngleTarget(finger: .thumb,  joint: .mcp, minAngle: 30, maxAngle: 60, tolerance: 15, correctionHint: "Rest thumbs against chest"),
            ],
            fingerStates: [
                .thumb: .slightlyBent,
                .index: .straight,
                .middle: .straight,
                .ring: .straight,
                .little: .straight,
            ],
            dominantHand: .both
        ),
        isUnlocked: true,
        illustrationAssetName: "mudra_anjali"
    )

    // MARK: - Kapotha
    static let kapotha = Mudra(
        name: "Kapotha",
        sanskritName: "कपोत",
        category: .samyukta,
        orderIndex: 1,
        shortDescription: "Two Pataka hands joined and cupped toward the fingertips, sides, and base — creating a hollow between the palms like a pigeon's body. Differs from Anjali in this gentle cupping.",
        significance: "Kapota (pigeon) is a gesture of deep reverence and humble acceptance. The cupped hands form a vessel of respect, used specifically when addressing teachers or accepting instructions from those of higher knowledge.",
        meanings: [
            MudraMeaning(context: "Social & Spiritual",
                         meaning: "Respectful salutation, conversation with teachers"),
            MudraMeaning(context: "Attitude & Conduct",
                         meaning: "Mark of obedience, acceptance of instructions"),
        ],
        poseTarget: ARPoseTarget(
            jointTargets: [
                JointAngleTarget(finger: .thumb, joint: .mcp, minAngle: 70, maxAngle: 110, tolerance: 15, correctionHint: "Tuck thumbs deeper to create hollow space"),
                JointAngleTarget(finger: .middle, joint: .pip, minAngle: 0,  maxAngle: 20,  tolerance: 10, correctionHint: "Keep middle fingers straight"),
                JointAngleTarget(finger: .ring,   joint: .pip, minAngle: 0,  maxAngle: 20,  tolerance: 10, correctionHint: "Keep ring fingers straight"),
                JointAngleTarget(finger: .little, joint: .pip, minAngle: 0,  maxAngle: 20,  tolerance: 10, correctionHint: "Keep little fingers straight"),
                JointAngleTarget(finger: .thumb,  joint: .mcp, minAngle: 60, maxAngle: 90,  tolerance: 15, correctionHint: "Tuck thumbs into palms to cup the hands"),
            ],
            fingerStates: [
                .thumb: .halfBent,
                .index: .straight,
                .middle: .straight,
                .ring: .straight,
                .little: .straight,
            ],
            dominantHand: .both
        ),
        illustrationAssetName: "mudra_kapotha"
    )

    // MARK: - Karkata
    static let karkata = Mudra(
        name: "Karkata",
        sanskritName: "कर्कट",
        category: .samyukta,
        orderIndex: 2,
        shortDescription: "Fingers of both hands are interlocked and stretched across each other. The interlaced fingers spread outward, creating a cradle or basket shape between the two hands.",
        significance: "Karkata's interlocked formation symbolises the joining of forces and the arrival of multitudes. Its expansive shape — fingers spread and stretched — evokes both physical stretching and the gathering of many.",
        meanings: [
            MudraMeaning(context: "People & Movement",
                         meaning: "Arrival of many people, sight of the belly"),
            MudraMeaning(context: "Actions",
                         meaning: "Blowing the conch, stretching the limbs, bending a bench"),
        ],
        poseTarget: ARPoseTarget(
            jointTargets: [
                
                JointAngleTarget(finger: .index,  joint: .pip,
                    minAngle: 0, maxAngle: 100, tolerance: 30,
                    correctionHint: "Interlock and stretch your index fingers"),

                JointAngleTarget(finger: .middle, joint: .pip,
                    minAngle: 0, maxAngle: 100, tolerance: 30,
                    correctionHint: "Interlock and stretch your middle fingers"),

                JointAngleTarget(finger: .ring,   joint: .pip,
                    minAngle: 0, maxAngle: 100, tolerance: 30,
                    correctionHint: "Interlock and stretch your ring fingers"),

                JointAngleTarget(finger: .little, joint: .pip,
                    minAngle: 0, maxAngle: 100, tolerance: 30,
                    correctionHint: "Interlock and stretch your little fingers"),

                JointAngleTarget(finger: .thumb,  joint: .mcp,
                    minAngle: 0, maxAngle: 90, tolerance: 30,
                    correctionHint: "Let your thumbs rest naturally"),
            ],
            fingerStates: [
                .thumb:  .straight,
                .index:  .straight,
                .middle: .straight,
                .ring:   .straight,
                .little: .straight,
            ],
            dominantHand: .both
        ),
        illustrationAssetName: "mudra_karkata"
    )

    // MARK: - Swastika
    static let swastika = Mudra(
        name: "Swastika",
        sanskritName: "स्वस्तिक",
        category: .samyukta,
        orderIndex: 3,
        shortDescription: "Two Pataka poses crossed and held together at the wrist. The backs of the hands face outward, forming an X at the wrist joint.",
        significance: "Svastika (Sanskrit for 'well-being') is an ancient auspicious symbol. In Bharatanatyam, its primary use is to denote a crocodile — the wrists crossed like the reptile's powerful jaw.",
        meanings: [
            MudraMeaning(context: "Animal",
                         meaning: "A crocodile"),
            MudraMeaning(context: "Symbol",
                         meaning: "An auspicious cross, the four directions, well-being"),
        ],
        poseTarget: ARPoseTarget(
            jointTargets: [
                JointAngleTarget(finger: .index,  joint: .pip, minAngle: 0,  maxAngle: 20,  tolerance: 10, correctionHint: "Straighten your index finger"),
                JointAngleTarget(finger: .middle, joint: .pip, minAngle: 0,  maxAngle: 20,  tolerance: 10, correctionHint: "Straighten your middle finger"),
                JointAngleTarget(finger: .ring,   joint: .pip, minAngle: 0,  maxAngle: 20,  tolerance: 10, correctionHint: "Straighten your ring finger"),
                JointAngleTarget(finger: .little, joint: .pip, minAngle: 0,  maxAngle: 20,  tolerance: 10, correctionHint: "Straighten your little finger"),
                JointAngleTarget(finger: .thumb, joint: .mcp, minAngle: 65, maxAngle: 95, tolerance: 15, correctionHint: "Press thumb flat across palm"),
            ],
            fingerStates: [
                .thumb: .halfBent,
                .index: .straight,
                .middle: .straight,
                .ring: .straight,
                .little: .straight,
            ],
            dominantHand: .both
        ),
        illustrationAssetName: "mudra_swastika"
    )
}
