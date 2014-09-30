//
//  FirstViewController.swift
//  Twitter8er
//
//  Created by Josh Brown on 9/19/14.
//  Copyright (c) 2014 Roadfire Software. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    let viewModel = HomeViewModel()
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refresh()
        self.addRefreshControl()
    }
    
    func addRefreshControl() {
        refreshControl.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func refresh() {
        viewModel.fetchTweets { result in
            switch result {
            case .Success(let tweets):
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            case .Failure(let error):
                let alert = UIAlertController(title: "Can't connect to Twitter.", message: error, preferredStyle: .Alert)
                let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItemsInSection(section)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as TweetTableViewCell
        
        configureCell(cell, forRowAtIndexPath: indexPath)
        
        return cell
    }
    
    func configureCell(cell: TweetTableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.tweetLabel.text = viewModel.tweetForRowAtIndexPath(indexPath)
        cell.usernameLabel.text = viewModel.usernameForRowAtIndexPath(indexPath)
        cell.nameLabel.text = viewModel.nameForRowAtIndexPath(indexPath)
        
        viewModel.fetchImageForRowAtIndexPath(indexPath, success: { (image) -> () in
            dispatch_async(dispatch_get_main_queue()) {
                if let updateCell = self.tableView.cellForRowAtIndexPath(indexPath) as? TweetTableViewCell {
                    updateCell.profileImageView.image = image
                }
            }
        })
        
        cell.profileImageView.image = UIImage(named: "placeholder")
        cell.profileImageView.contentMode = .ScaleAspectFill
    }
}

