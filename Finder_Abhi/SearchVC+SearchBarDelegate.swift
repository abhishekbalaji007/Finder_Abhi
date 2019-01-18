//
//  SearchVC+SearchBarDelegate.swift
//  Finder_Abhi
//
//  Created by BALAJI ABHISHEK on 1/17/19.
//  Copyright © 2019 BALAJI ABHISHEK. All rights reserved.
//

import Foundation
import UIKit

//Here we are extending ViewController to handle SearchBarDelegate methods.
extension ViewController: UISearchBarDelegate
{
    @objc func dismissKeyboard()
    {
        searchBar.resignFirstResponder()
    }
    
    //This method will get called when we are entering on SearchButton.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        self.activityIndicatorObj.isHidden = false
        self.activityIndicatorObj.startAnimating()
        
        dismissKeyboard()
        
        guard let searchText = searchBar.text, !searchText.isEmpty else
        {
            self.activityIndicatorObj.stopAnimating()
            self.activityIndicatorObj.hidesWhenStopped = true
            
            let alertController = UIAlertController(title: WIFINDER, message: "Please provide your input to search.", preferredStyle:UIAlertController.Style.alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(alert :UIAlertAction!) in
            })
            
            alertController.addAction(okAction)
            
            DispatchQueue.main.async
                {
                    UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
            }
            return
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if searchText != ""
        {
            self.searchResults.removeAll()
            self.searchTableView.reloadData()
            
            queryService.retrieveSearchResults(searchTerm: searchText) { results, errorMessage in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let results = results
                {
                    self.searchResults = results
                    self.searchTableView.reloadData()
                    self.searchTableView.setContentOffset(CGPoint.zero, animated: false)
                    self.activityIndicatorObj.stopAnimating()
                    self.activityIndicatorObj.hidesWhenStopped = true
                }
                if !errorMessage.isEmpty
                {
                    print("Search error: " + errorMessage)
                }
            }
        }
    }
    
    //Below are the SearchBar Delegate methods.
    func position(for bar: UIBarPositioning) -> UIBarPosition
    {
        return .topAttached
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        view.addGestureRecognizer(tapRecognizer)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar)
    {
        view.removeGestureRecognizer(tapRecognizer)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchText == ""
        {
            self.cache = NSCache()
            self.searchResults.removeAll()
            self.searchTableView.reloadData()
        }
    }
}

