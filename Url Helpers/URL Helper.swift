//
//  URL Helper.swift
//  KyoNeo
//
//  Created by Aether on 21/07/2023.
//

import SwiftUI

func findURL(in text: String) -> String? {
    let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))

    for match in matches {
        guard let range = Range(match.range, in: text) else { continue }
        let url = text[range]
        return String(url) // Return the URL as a string
    }

    return nil // Return nil if no URLs are found
}

func cleanUpURLForDisplay(_ urlString: String) -> String {
    let pattern = "https?://(?:www\\.)?|(en|fr|es|de|it|ja|ko)\\."
    guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
        return urlString
    }

    let range = NSRange(location: 0, length: urlString.utf16.count)
    let cleanedURL = regex.stringByReplacingMatches(in: urlString, options: [], range: range, withTemplate: "")

    if cleanedURL.isEmpty {
        return urlString
    } else {
        return cleanedURL
    }
}

func getIconForURL(_ url: String) -> String {
    // List of video call platforms and Moodle
    let platforms = [
        // Video call platforms
        "meet.google.com": "video",
        "zoom.us": "video",
        "teams.microsoft.com": "video",
        "facetime.apple.com": "video",

        // School/college/university-related platforms
        "showmyhomework.com": "book.circle",
        "satchelone.com": "pencil.circle",
        "moodle": "book",
        "canvas": "pencil",
        "blackboard": "square.and.pencil",
        "brightspace": "graduationcap",
        "google-classroom": "graduationcap",
        "classroom": "graduationcap",
        "classroom.google.com": "graduationcap",
        "schoology": "graduationcap",
        "webex.com": "video",
        "gotomeeting.com": "video",
        "bluejeans.com": "video",
        "jitsi.org": "video",
        "skype.com": "video",
        "discord.com": "video",
        "ringcentral.com": "video",

        // Learning Management Systems (LMS)
        "edx.org": "graduationcap",
        "coursera.org": "graduationcap",
        "udemy.com": "graduationcap",
        "udacity.com": "graduationcap",

        // Educational resources
        "khanacademy.org": "graduationcap",
        "wikipedia.org": "globe",
        "britannica.com": "book",
        "dictionary.com": "book",

        // Libraries and bookstores
        "libbyapp.com": "book",
        "audible.com": "book",
        "amazon.com": "book",
        "barnesandnoble.com": "book",

        // Online courses and tutorials
        "codecademy.com": "graduationcap",
        "pluralsight.com": "graduationcap",
        "treehouse.com": "graduationcap",

        // Collaboration and project management
        "trello.com": "tray",
        "asana.com": "tray",
        "notion.so": "tray",
        "microsoft.sharepoint.com": "tray",
        "slack.com": "tray",

        // Educational blogs and forums
        "medium.com": "pencil",
        "stackoverflow.com": "pencil",
        "reddit.com": "pencil",
        "quora.com": "pencil",

        // Online quizzes and tests
        "quizlet.com": "doc",
        "kahoot.com": "doc",
        "gradeup.co": "doc",
        "gktoday.in": "doc",

        // Educational news and articles
        "bbc.co.uk/news/education": "newspaper",
        "theatlantic.com/education": "newspaper",
        "insidehighered.com": "newspaper",
        "chronicle.com": "newspaper"
    ]

    // Check if the URL matches any video call platform or Moodle
    let lowercasedURL = url.lowercased()
    for (platform, icon) in platforms {
        if lowercasedURL.contains(platform) {
            return icon
        }
    }

    // If no video call platform or Moodle matches, return the default icon
    return "link"
}

func formatLink(_ link: String) -> String {
    // Check if the link is empty
    guard !link.isEmpty else {
        return ""
    }

    // Check if the link starts with "http://" or "https://"
    if !link.lowercased().hasPrefix("http://") && !link.lowercased().hasPrefix("https://") {
        return "https://" + link
    }


    return link
}
