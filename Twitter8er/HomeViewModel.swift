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

class HomeViewModel {
    
    let accountStore = ACAccountStore()
    
    func fetchTweets(success: () -> ()) {
        // get the tweets
        if (self.userHasAccessToTwitter()) {
            let accountType = self.accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
            self.accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (granted, error) -> Void in
                if (granted) {
                    self.loadTweetsForAccountType(accountType) { (tweets) -> Void in
                        
                    }
                }
            }
        }
        
    }
    
    func userHasAccessToTwitter() -> Bool {
        return SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)
    }
    
    func loadTweetsForAccountType(accountType: ACAccountType, completion:(tweets: [NSDictionary]) -> Void) {
        let twitterAccounts = self.accountStore.accountsWithAccountType(accountType) as [ACAccount]
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
        let params = ["count": "100", "exclude_replies": "false"]
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
                        if jsonError != nil {
                            completion(tweets: json)
                        }
                    }
                default:
                    return
                }
            }
        }
    }
}
