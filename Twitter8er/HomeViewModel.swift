//
//  HomeViewModel.swift
//  Twitter8er
//
//  Created by Josh Brown on 9/19/14.
//  Copyright (c) 2014 Roadfire Software. All rights reserved.
//

import Foundation
import Accounts
import Social

final class Box<A> {
    let value: A

    init(_ value: A) {
        self.value = value
    }
}

enum Result<A> {
    case Success(Box<A>)
    case Failure(String)
}

class HomeViewModel {
    let accountStore = ACAccountStore()
    var tweets = [NSDictionary]()
    
    func fetchTweets(completion: (Result<[NSDictionary]>) -> ()) {
        // get the tweets
        if (self.userHasAccessToTwitter()) {
            let accountType = self.accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
            self.accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (granted, error) -> Void in
                if (granted) {
                    self.loadTweetsForAccountType(accountType) { (tweets) -> Void in
                        completion(.Success(Box(tweets)))
                    }
                } else {
                    completion(.Failure("Can't connect to Twitter. Make sure you've given Twitter8er access to your Twitter account."))
                }
            }
        } else {
            completion(.Failure("Can't connect to Twitter. Check to make sure you have a Twitter account set up in Settings."))
        }
    }
    
    func userHasAccessToTwitter() -> Bool {
        return SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)
    }
    
    func loadTweetsForAccountType(accountType: ACAccountType, completion:(tweets: [NSDictionary]) -> Void) {
        let twitterAccounts = self.accountStore.accountsWithAccountType(accountType) as [ACAccount]
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
        let params = ["count": "50", "exclude_replies": "false"]
        let request = SLRequest(forServiceType: SLServiceTypeTwitter,
            requestMethod: .GET,
            URL: url,
            parameters: params)
        request.account = twitterAccounts.first
        
        request.performRequestWithHandler { (data, response, error) -> Void in
            if let unwrappedData = data {
                switch response.statusCode {
                case 200...299:
                    var jsonError: NSError?
                    if let json = NSJSONSerialization.JSONObjectWithData(unwrappedData, options: nil, error: &jsonError) as? [NSDictionary] {
                        if jsonError == nil {
                            self.tweets = json
                            completion(tweets: json)
                        }
                    }
                default:
                    println("unexpected status code: \(response.statusCode)")
                    return
                }
            }
        }
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfItemsInSection(section: Int) -> Int {
        return tweets.count
    }
    
    func tweetForRowAtIndexPath(indexPath: NSIndexPath) -> String {
        let tweetDict = tweets[indexPath.row] as NSDictionary
        return tweetDict.valueForKeyPath("text") as String
    }
    
    func usernameForRowAtIndexPath(indexPath: NSIndexPath) -> String {
        let tweetDict = tweets[indexPath.row] as NSDictionary
        let screenName = tweetDict.valueForKeyPath("user.screen_name") as String
        return "@\(screenName)"
    }
    
    func nameForRowAtIndexPath(indexPath: NSIndexPath) -> String {
        let tweetDict = tweets[indexPath.row] as NSDictionary
        return tweetDict.valueForKeyPath("user.name") as String
    }
    
    func fetchImageForRowAtIndexPath(indexPath: NSIndexPath, success:(image: UIImage) -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let urlString = self.urlStringForImageAtIndexPath(indexPath)
            if let imageURL = NSURL(string: urlString) {
                if let imageData = NSData(contentsOfURL: imageURL) {
                    if let image = UIImage(data: imageData) {
                        success(image: image)
                    }
                }
            }
        }
    }
        
    func urlStringForImageAtIndexPath(indexPath: NSIndexPath) -> String {
        let tweetDict = tweets[indexPath.row] as NSDictionary
        let urlString = tweetDict.valueForKeyPath("user.profile_image_url") as String
        return urlString.stringByReplacingOccurrencesOfString("_normal", withString: "")
    }
}
