//
//  ViewController.swift
//  Finder_Abhi
//
//  Created by BALAJI ABHISHEK on 1/17/19.
//  Copyright © 2019 BALAJI ABHISHEK. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

//This class is about SearchViewController having delegate methods for TableView & PickerView And Playing the media content based on selection.
class ViewController: UIViewController
{
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var myPicker : UIPickerView!
    @IBOutlet weak var activityIndicatorObj : UIActivityIndicatorView!
    var cache:NSCache<AnyObject, AnyObject>!
    
    var mediaOptionStr = String()
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target:self, action: #selector(dismissKeyboard))
        return recognizer
    }()
    
    var searchResults: [Media] = []
    let queryService = SearchService()
    var pickerMediaSearchOptions = [String]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.activityIndicatorObj.isHidden = true
        self.pickerMediaSearchOptions = [CHOICEKEY,MUSICKEY,TVSHOWKEY,MOVIEKEY]
    }
}

//Here we are extending ViewController Class to put delegate methods for TableView & PickerView.
extension ViewController: UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource
{
    //Start - TableView.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: REUSE_IDENTIFIER, for: indexPath) as! ArtworkTableViewCell
        
        let iTunesTrack = searchResults[indexPath.row]
        
        cell.imgArtwork.image = UIImage(named: "placeholder")
        
        if (self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) != nil)
        {
            cell.imgArtwork.image = self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) as? UIImage
        }
        else
        {
            DispatchQueue.main.async(execute: { () -> Void in
                if cell == tableView.cellForRow(at: indexPath)
                {
                    do
                    {
                        let imageData = try Data(contentsOf: iTunesTrack.artworkUrl60)
                        cell.imgArtwork.image = UIImage(data: imageData)
                        self.cache.setObject(cell.imgArtwork.image!, forKey: (indexPath as NSIndexPath).row as AnyObject)
                    }
                    catch
                    {
                        print(error)
                    }
                }
            })
        }
        
        if self.mediaOptionStr == MUSICKEY
        {
            cell.lblArtistName.text = iTunesTrack.artistName
            cell.lblTrackName.text = iTunesTrack.trackName
            cell.lblDescOrUrl.text = iTunesTrack.artworkUrl100.description
        }
        else if self.mediaOptionStr == TVSHOWKEY
        {
            cell.lblArtistName.text = iTunesTrack.artistName
            cell.lblTrackName.text = iTunesTrack.longDescription
            cell.lblDescOrUrl.text = iTunesTrack.artworkUrl100.description
        }
        else if self.mediaOptionStr == MOVIEKEY
        {
            cell.lblArtistName.text = iTunesTrack.trackName
            cell.lblTrackName.text = iTunesTrack.longDescription
            cell.lblDescOrUrl.text = iTunesTrack.artworkUrl100.description
        }
        
        //Adding TapGesture For Artwork Image.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imgTapped(sender:)))
        cell.imgArtwork.addGestureRecognizer(tapGesture)
        cell.imgArtwork.isUserInteractionEnabled = true
        
        return cell
    }
    
    //Playing the media content based on selection.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let iTunesTrack = searchResults[indexPath.row]
        let urlObj = iTunesTrack.previewUrl
        let playerObj = AVPlayer.init(url: urlObj)
        
        let playerControllerObj = AVPlayerViewController()
        self.present(playerControllerObj, animated: true, completion: nil)
        playerControllerObj.player = playerObj
        playerObj.play()
    }
    //End - TableView.
    
    //Showing bouncing effect when user taps on the artwork image.
    @objc func imgTapped(sender: UITapGestureRecognizer)
    {
        guard let tappedView = sender.view else {
            return
        }
        
        let touchPointInSearchTableView = self.searchTableView.convert(tappedView.center, from: tappedView)
        
        guard let indexPath = self.searchTableView.indexPathForRow(at: touchPointInSearchTableView) else {
            return
        }
        
        let currentCell = self.searchTableView.cellForRow(at: indexPath) as! ArtworkTableViewCell
        
        let origin:CGPoint = currentCell.imgArtwork.center
        let target:CGPoint = CGPoint(x: currentCell.imgArtwork.center.x, y: currentCell.imgArtwork.center.y+35)
        let bounce = CABasicAnimation(keyPath: "position.y")
        bounce.duration = 0.25
        bounce.fromValue = origin.y
        bounce.toValue = target.y
        bounce.repeatCount = 1
        bounce.autoreverses = true
        currentCell.imgArtwork.layer.add(bounce, forKey: "position")
    }
    
    //Start - PickerView.
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 150
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return self.pickerMediaSearchOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        let mediaOption = self.pickerMediaSearchOptions[row]
        return mediaOption
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        self.mediaOptionStr = self.pickerMediaSearchOptions[row]
        
        if row != 0
        {
            queryService.mediaStr = self.mediaOptionStr
        }
        
        if row == 0
        {
            queryService.mediaStr = ""
        }
        
        self.cache = NSCache()
        self.searchResults.removeAll()
        self.searchTableView.reloadData()
    }
    //End - PickerView.
}
