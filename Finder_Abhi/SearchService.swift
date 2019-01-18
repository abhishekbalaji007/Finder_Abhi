//
//  SearchService.swift
//  Finder_Abhi
//
//  Created by BALAJI ABHISHEK on 1/17/19.
//  Copyright © 2019 BALAJI ABHISHEK. All rights reserved.
//

import Foundation
import UIKit

//This class contains logic for getting the data from iTunes Search API.
class SearchService
{
    typealias JSONDictionary = [String: Any]
    typealias SearchResult = ([Media]?, String) -> ()
    
    var media_track: [Media] = []
    var errorMessage = ""
    
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    var mediaStr = String()
    
    //Here we are doing JSON Parsing for music, tvShow & movie category.
    func refreshSearchResults(_ data: Data)
    {
        var response: JSONDictionary?
        media_track.removeAll()
        
        do
        {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        }
        catch let parseError as NSError
        {
            errorMessage += "JSON Error: \(parseError.localizedDescription)\n"
            return
        }
        
        guard let array = response!["results"] as? [Any] else
        {
            errorMessage += "Result Key is not available within Dictionary\n"
            return
        }
        
        var index = 0
        for mediaDictionary in array
        {
            if mediaStr == MUSICKEY
            {
                if let mediaDictionary = mediaDictionary as? JSONDictionary,
                    let artworkURL100String = mediaDictionary[ARTWORKURL100] as? String,
                    let artworkURL100 = URL(string: artworkURL100String),
                    let artworkURLString = mediaDictionary[ARTWORKURL60] as? String,
                    let artworkURL = URL(string: artworkURLString),
                    let previewURLString = mediaDictionary[PREVIEWURL] as? String,
                    let previewURL = URL(string: previewURLString),
                    let trackNameObj = mediaDictionary[TRACKNAME] as? String,
                    let artistNameObj = mediaDictionary[ARTISTNAME] as? String
                {
                    media_track.append(Media(artistName: artistNameObj, trackName: trackNameObj, longDescription: "", artworkUrl100: artworkURL100, artworkUrl60: artworkURL, previewUrl: previewURL))
                    index += 1
                }
                else
                {
                    errorMessage += "Issue in parsing mediaDictionary\n"
                }
            }
            else if mediaStr == TVSHOWKEY
            {
                if let mediaDictionary = mediaDictionary as? JSONDictionary,
                    let artworkURL100String = mediaDictionary[ARTWORKURL100] as? String,
                    let artworkURL100 = URL(string: artworkURL100String),
                    let artworkURLString = mediaDictionary[ARTWORKURL60] as? String,
                    let artworkURL = URL(string: artworkURLString),
                    let previewURLString = mediaDictionary[PREVIEWURL] as? String,
                    let previewURL = URL(string: previewURLString),
                    let artistNameObj = mediaDictionary[ARTISTNAME] as? String,
                    let longDescriptionObj = mediaDictionary[LONG_DESCRIPTION] as? String
                {
                    media_track.append(Media(artistName: artistNameObj, trackName: "", longDescription: longDescriptionObj, artworkUrl100: artworkURL100, artworkUrl60: artworkURL, previewUrl: previewURL))
                    index += 1
                }
                else
                {
                    errorMessage += "Issue in parsing mediaDictionary\n"
                }
            }
            else if mediaStr == MOVIEKEY
            {
                if let mediaDictionary = mediaDictionary as? JSONDictionary,
                    let artworkURL100String = mediaDictionary[ARTWORKURL100] as? String,
                    let artworkURL100 = URL(string: artworkURL100String),
                    let artworkURLString = mediaDictionary[ARTWORKURL60] as? String,
                    let artworkURL = URL(string: artworkURLString),
                    let previewURLString = mediaDictionary[PREVIEWURL] as? String,
                    let previewURL = URL(string: previewURLString),
                    let trackNameObj = mediaDictionary[TRACKNAME] as? String,
                    let longDescriptionObj = mediaDictionary[LONG_DESCRIPTION] as? String
                {
                    media_track.append(Media(artistName: "", trackName: trackNameObj, longDescription: longDescriptionObj, artworkUrl100: artworkURL100, artworkUrl60: artworkURL, previewUrl: previewURL))
                    index += 1
                }
                else
                {
                    errorMessage += "Issue in parsing mediaDictionary\n"
                }
            }
            else
            {
                let alertController = UIAlertController(title: WIFINDER, message: "Please select any of the media content type.", preferredStyle:UIAlertController.Style.alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(alert :UIAlertAction!) in
                })
                
                alertController.addAction(okAction)
                
                DispatchQueue.main.async
                    {
                        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    //Here we are  getting search text based on PickerView Selection and Search Text From SearchBar.
    func retrieveSearchResults(searchTerm: String, completion: @escaping SearchResult)
    {
        dataTask?.cancel()
        if var urlComponents = URLComponents(string: "https://itunes.apple.com/search")
        {
            urlComponents.query = "media=\(mediaStr)&term=\(searchTerm)"
            guard let url = urlComponents.url else { return }
            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                defer { self.dataTask = nil }
                if let error = error
                {
                    self.errorMessage += "Data Task Error: " + error.localizedDescription + "\n"
                }
                else if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200
                {
                    self.refreshSearchResults(data)
                    DispatchQueue.main.async{
                        completion(self.media_track, self.errorMessage)
                    }
                }
            }
            dataTask?.resume()
        }
    }
}

