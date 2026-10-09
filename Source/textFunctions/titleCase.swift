//
//  titleCase.swift
//  KyoNeo
//
//  Created by Aether on 07/11/2023.
//

import Foundation

extension String {
    /// Changes camel case to title case.
    /// https://stackoverflow.com/questions/41292671/separating-camelcase-string-into-space-separated-words-in-swift
    /// For case names:
    /// https://danielmiessler.com/blog/a-list-of-different-case-types/
    /// https://winnercrespo.com/naming-conventions/
    public func titleCase() -> String {
        return self
            .replacingOccurrences(of: "([A-Z])",
                                  with: " $1",
                                  options: .regularExpression,
                                  range: range(of: self))
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .capitalized // If input is in llamaCase
    }
}
