//
//  TitleEnum.swift
//  KyoNeo
//
//  Created by Aether on 05/05/2024.
//

import Foundation

enum TitleEnum: Int16, CaseIterable {
    case none
    // Elementary School Titles
    case teacher
    case assistantTeacher
    case educator

    // High School Titles
    case instructor
    case lecturer
    case coach

    // University Titles
    case professor
    case associateProfessor
    case assistantProfessor
    case dean

    // Administrative Titles
    case principal
    case vicePrincipal
    case chancellor
    case superintendent

    // Specialized Educational Titles
    case counselor
    case librarian

    // Honorific Titles
    case doctor
    case sir
    case dame
    case mr
    case mrs
    case ms
    case miss
    case mx

    var category: String {
        switch self {
        case .none:
            return "Default"
        case .teacher, .assistantTeacher, .educator:
            return "Elementary School"
        case .instructor, .lecturer, .coach:
            return "High School"
        case .professor, .associateProfessor, .assistantProfessor, .dean:
            return "University"
        case .principal, .vicePrincipal, .chancellor, .superintendent:
            return "Administrative"
        case .counselor, .librarian:
            return "Specialized Educational"
        case .doctor, .sir, .dame, .mr, .mrs, .ms, .miss, .mx:
            return "Honorific"
        }
    }

    var description: String {
        switch self {
        case .none: return "None"
        case .teacher: return "Teacher"
        case .assistantTeacher: return "Assistant Teacher"
        case .educator: return "Educator"
        case .instructor: return "Instructor"
        case .lecturer: return "Lecturer"
        case .coach: return "Coach"
        case .professor: return "Professor"
        case .associateProfessor: return "Associate Professor"
        case .assistantProfessor: return "Assistant Professor"
        case .dean: return "Dean"
        case .principal: return "Principal"
        case .vicePrincipal: return "Vice Principal"
        case .chancellor: return "Chancellor"
        case .superintendent: return "Superintendent"
        case .counselor: return "Counselor"
        case .librarian: return "Librarian"
        case .doctor: return "Doctor"
        case .sir: return "Sir"
        case .dame: return "Dame"
        case .mr: return "Mr."
        case .mrs: return "Mrs."
        case .ms: return "Ms."
        case .miss: return "Miss"
        case .mx: return "Mx"
        }
    }
}

extension TitleEnum {
    static var groupedByCategory: [String: [TitleEnum]] {
        var categories = [String: [TitleEnum]]()
        for title in TitleEnum.allCases {
            let category = title.category
            if categories[category] == nil {
                categories[category] = []
            }
            categories[category]?.append(title)
        }
        return categories
    }
}



