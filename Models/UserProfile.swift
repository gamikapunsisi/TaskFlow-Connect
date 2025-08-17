//
//  UserProfile.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-18.
//

import Foundation
import FirebaseFirestore

struct UserProfile: Identifiable, Codable {
    @DocumentID var id: String?
    var fullName: String
    var email: String
    var phoneNumber: String?
    var profileImageUrl: String?
    var profession: String
    var location: String
    var bio: String?
    var rating: Double
    var totalJobs: Int
    var joinedDate: Timestamp
    var isVerified: Bool
    var languages: [String]
    var createdAt: Timestamp?
    var updatedAt: Timestamp?
    
    init(fullName: String = "", email: String = "", phoneNumber: String? = nil, profileImageUrl: String? = nil, profession: String = "", location: String = "", bio: String? = nil, rating: Double = 0.0, totalJobs: Int = 0, joinedDate: Timestamp = Timestamp(), isVerified: Bool = false, languages: [String] = ["English"]) {
        self.fullName = fullName
        self.email = email
        self.phoneNumber = phoneNumber
        self.profileImageUrl = profileImageUrl
        self.profession = profession
        self.location = location
        self.bio = bio
        self.rating = rating
        self.totalJobs = totalJobs
        self.joinedDate = joinedDate
        self.isVerified = isVerified
        self.languages = languages
    }
}
