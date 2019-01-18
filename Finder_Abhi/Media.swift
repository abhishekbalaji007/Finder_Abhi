//
//  Media.swift
//  Finder_Abhi
//
//  Created by BALAJI ABHISHEK on 1/17/19.
//  Copyright © 2019 BALAJI ABHISHEK. All rights reserved.
//

import Foundation

//This class contrains variables regarding iTunes Search API.
class Media
{
    let artistName: String
    let trackName: String
    let longDescription : String
    let artworkUrl100: URL
    let artworkUrl60: URL
    let previewUrl: URL
    
    init(artistName: String, trackName: String, longDescription: String, artworkUrl100: URL, artworkUrl60: URL, previewUrl : URL)
    {
        self.artistName = artistName
        self.trackName = trackName
        self.longDescription = longDescription
        self.artworkUrl100 = artworkUrl100
        self.artworkUrl60 = artworkUrl60
        self.previewUrl = previewUrl
    }
}
