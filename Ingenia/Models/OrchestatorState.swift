//
//  OrchestatorState.swift
//  Ingenia
//
//  Created by Omar Sánchez on 13/05/25.
//
import Foundation

let GOAL = 5

struct OrchestatorState {
    var objectives: [Objective] {
        didSet {
            print("Objectives updated: \(objectives)")
        }
    }
    var careerAffinity: STEMAffinity {
        didSet {
            print("Career affinity updated: \(careerAffinity)")
        }
    }
    
    func getSemanticTags() -> [String] {
        return objectives.map { $0.tag }
    }
    
    func getProgress() -> Double {
        let completedObjectives = objectives.filter { $0.status == .completed }
        let totalObjectives = GOAL
        let progress = Double(completedObjectives.count) / Double(totalObjectives) * 100
        return progress > 100 ? 100 : progress
    }
    
    mutating func updateObjectives(with: [String]){
        for objective in objectives {
            if with.contains(objective.tag) {
                if let index = objectives.firstIndex(where: { $0.tag == objective.tag }) {
                    if objectives[index].status == .completed { continue}
                    objectives[index].status = .completed
                }
            }
        }
    }
    
    mutating func updateCareerAffinity(with: [String: Int]) {
        for (tag, value) in with {
            switch tag {
            case "biotechnology":
                careerAffinity.biotechnology += value
            case "robotics":
                careerAffinity.robotics += value
            case "softwareEngineering":
                careerAffinity.softwareEngineering += value
            case "dataScience":
                careerAffinity.dataScience += value
            case "environmentalEngineering":
                careerAffinity.environmentalEngineering += value
            default:
                break
            }
        }
    }
}

enum ObjectiveStatus {
    case notStarted
    case inProgress
    case completed
}

struct Objective: Identifiable {
    let id = UUID()
    let tag: String
    let name: String
    let description: String
    var status: ObjectiveStatus
}

struct STEMAffinity {
    var biotechnology: Int = 0
    var robotics: Int = 0
    var softwareEngineering: Int = 0
    var dataScience: Int = 0
    var environmentalEngineering: Int = 0
}

extension OrchestatorState {
    static let initialState = OrchestatorState(
        objectives: [
            Objective(
                tag: "introduce_yourself",
                name: "Introduce Yourself",
                description: "Send your first message in the group to say hello and present yourself.",
                status: .notStarted
            ),
            Objective(
                tag: "choose_your_role",
                name: "Choose Your Role",
                description: "Decide whether you’ll focus on Biotechnology, Robotics, Data Science, or Software Engineering.",
                status: .notStarted
            ),
            Objective(
                tag: "join_project_group",
                name: "Join a Project Group",
                description: "Join or chat at the “First UDG Challenge” group chat.",
                status: .notStarted
            ),
            Objective(
                tag: "first_dm",
                name: "Initiate a DM",
                description: "Send a private message to one character to build rapport.",
                status: .notStarted
            ),
            Objective(
                tag: "make_a_technical_decision",
                name: "Make a Technical Decision",
                description: "Choose a specific sensor or analysis method in the group discussion.",
                status: .notStarted
            ),
            Objective(
                tag: "share_a_resource",
                name: "Support a Teammate",
                description: "Offer help or encouragement to a character during a setback.",
                status: .notStarted
            ),
            Objective(
                tag: "resolve_a_crisis",
                name: "Resolve a Crisis",
                description: "Respond to a field-test failure and propose a solution collaboratively.",
                status: .notStarted
            ),
            Objective(
                tag: "define_presentation_focus",
                name: "Define Presentation Focus",
                description: "Select the angle for your final pitch: technical, ecological, or UX.",
                status: .notStarted
            ),
            Objective(
                tag: "contribute_pitch_idea",
                name: "Contribute a Pitch Idea",
                description: "Share at least one concrete idea for the final presentation.",
                status: .notStarted
            ),
            Objective(
                tag: "reach_story_completion",
                name: "Reach Story Completion",
                description: "Finish all chapters and reveal your top STEM career affinities.",
                status: .notStarted
            )
        ],
        careerAffinity: STEMAffinity(
            biotechnology: 0,
            robotics: 0,
            softwareEngineering: 0,
            dataScience: 0,
            environmentalEngineering: 0
        )
    )
}
