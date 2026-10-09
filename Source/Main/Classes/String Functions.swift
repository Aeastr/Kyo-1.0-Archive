//
//  String Functions.swift
//  KyoNeo
//
//  Created by Aether on 04/04/2023.
//

import SwiftUI
extension String {
    func shortened(maxLength: Int = 15) -> String {
        if self.count <= maxLength {
            return self
        } else {
            let endIndex = self.index(self.startIndex, offsetBy: maxLength)
            let substring = self.prefix(upTo: endIndex)
            return "\(substring)..."
        }
    }
}
extension String {
    func shortenedClassName(maxLength: Int = 20) -> String {
        if self.count <= maxLength{
            return self
        }
        let replacements = [
            ("Professional", "Pro"),
            ("Professionals", "Pros"),
            ("Operating Systems", "OS"),
            ("Operating System", "OS"),
            ("User Experience", "UX"),
            ("User Interface", "UI"),
            ("Computer", "Comp"),
            ("Experience", "Exp"),
            (" And", ","),
            (" For", ","),
            ("Collaboration", "Collab"),
            ("Collaborative", "Collab"),
            ("Science", "Sci"),
            ("Mathematics", "Math"),
            ("Biology", "Bio"),
            ("Chemistry", "Chem"),
            ("Physics", "Phys"),
            ("History", "Hist"),
            ("English", "Eng"),
            ("Literature", "Lit"),
            ("Physical", "Phys"),
            ("Education", "Educ"),
            ("Business", "Bus"),
            ("Studies", "Stud"),
            ("Geography", "Geo"),
            ("Foreign", "For"),
            ("Language", "Lang"),
            ("Art", "Art"),
            ("History", "Hist"),
            ("Environmental", "Env"),
            ("Science", "Sci"),
            ("Political", "Pol"),
            ("Economics", "Econ"),
            ("Psychology", "Psych"),
            ("Sociology", "Soc"),
            ("Philosophy", "Phil"),
            ("Anthropology", "Anthro"),
            ("Engineering", "Eng"),
            ("Architecture", "Arch"),
            ("Marketing", "Mktg"),
            ("Journalism", "Journ"),
            ("Music", "Music"),
            ("Theory", "Theor"),
            ("Drama", "Dram"),
            ("Creative", "Creat"),
            ("Writing", "Writ"),
            ("Physical", "Phys"),
            ("Science", "Sci"),
            ("Statistics", "Stat"),
            ("Information", "Info"),
            ("Technology", "Tech"),
            ("Data", "Data"),
            ("Science", "Sci"),
            ("Graphic", "Graph"),
            ("Design", "Des"),
            ("Organic", "Org"),
            ("Chemistry", "Chem"),
            ("Microbiology", "Micro"),
            ("Human", "Hum"),
            ("Anatomy", "Anat"),
            ("International", "Intl"),
            ("Relations", "Rel"),
            ("Linear", "Lin"),
            ("Algebra", "Alg"),
            ("Multivariable", "Multi"),
            ("Calculus", "Calc"),
            ("Data", "Data"),
            ("Structures", "Struct"),
            ("Artificial", "Artif"),
            ("Intelligence", "Intel"),
            ("Machine", "Mach"),
            ("Learning", "Learn"),
            ("Operating", "Oper"),
            ("Systems", "Sys"),
            ("Database", "DB"),
            ("Management", "Mgmt"),
            ("Object-Oriented", "OOP"),
            ("Programming", "Prog"),
            ("Web", "Web"),
            ("Development", "Dev"),
            ("Mobile", "Mob"),
            ("App", "App"),
            ("Development", "Dev"),
            ("Network", "Net"),
            ("Security", "Sec"),
            ("Human-Computer", "HCI"),
            ("Interaction", "Interact"),
            ("Project", "Proj"),
            ("Management", "Mgmt"),
            ("Financial", "Fin"),
            ("Accounting", "Acc"),
            ("Corporate", "Corp"),
            ("Finance", "Fin"),
            ("Investments", "Invest"),
            ("International", "Intl"),
            ("Business", "Bus"),
            ("Organizational", "Org"),
            ("Behavior", "Behav"),
            ("Strategic", "Strat"),
            ("Management", "Mgmt"),
            ("Cultural", "Cult"),
            ("Anthropology", "Anthro"),
            ("Comparative", "Comp"),
            ("Politics", "Pol"),
            ("Behavioral", "Behav"),
            ("Psychology", "Psych"),
            ("Social", "Soc"),
            ("Psychology", "Psych"),
            ("Quantitative", "Quant"),
            ("Research", "Res"),
            ("Methods", "Meth"),
            ("Qualitative", "Qual"),
            ("Research", "Res"),
            ("Methods", "Meth"),
            ("Software", "Soft"),
            ("Engineering", "Eng")
        ]


        var shortenedName = self.lowercased()

               // Convert the original string and the replacements to lowercase to make the search case-insensitive
               let lowercaseSelf = self.lowercased()
               let lowercaseReplacements = replacements.map { ($0.0.lowercased(), $0.1) }

                    for replacement in lowercaseReplacements {
                        let originalReplacement = replacement.1.replacingOccurrences(of: ".", with: " ")
                        shortenedName = shortenedName.replacingOccurrences(of: replacement.0, with: originalReplacement)
                    }




               // Capitalize the first letter of each word in the shortenedName
               let words = shortenedName.components(separatedBy: " ")
               var capitalizedWords = [String]()
               for word in words {
                   capitalizedWords.append(word.prefix(1).capitalized + word.dropFirst())
               }
               shortenedName = capitalizedWords.joined(separator: " ")

               return shortenedName.shortened(maxLength: maxLength)
           }
       }

