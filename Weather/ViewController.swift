//
//  ViewController.swift
//  Weather
//
//  Created by Benjamin Shyong on 9/19/14.
//  Copyright (c) 2014 ShyongTech. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet weak var iconView: UIImageView!
  @IBOutlet weak var locationName: UILabel!
  @IBOutlet weak var currentTime: UILabel!
  @IBOutlet weak var currentTemperature: UILabel!
  @IBOutlet weak var humidity: UILabel!
  @IBOutlet weak var rain: UILabel!
  @IBOutlet weak var summary: UILabel!
  @IBOutlet weak var refreshButton: UIButton!
  @IBOutlet weak var refreshActivityIndicator: UIActivityIndicatorView!
  
  
  //  forecast.io apiKey
  private let apiKey = "357ef3a58975f8e49bbe27c2ae97696e"

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    refreshActivityIndicator.hidden = true
    getCurrentWeatherData()
  }
  
  func getCurrentWeatherData() -> Void {
    let baseURL = NSURL(string: "https://api.forecast.io/forecast/\(apiKey)/")
    let forecastURL = NSURL(string: "37.8267,-122.423", relativeToURL: baseURL)
    
    let sharedSession = NSURLSession.sharedSession()
    let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(forecastURL, completionHandler: { (location: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
      if (error == nil){
        let dataObject = NSData(contentsOfURL: location)
        let weatherDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataObject, options: nil, error: nil) as NSDictionary
        
        let currentWeather = Weather(weatherDictionary: weatherDictionary)
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          self.currentTemperature.text = "\(currentWeather.temperature)"
          self.iconView.image = currentWeather.icon!
          
          let formatter = NSDateFormatter()
          formatter.timeStyle = .ShortStyle
          self.currentTime.text = formatter.stringFromDate(NSDate())
          self.humidity.text = "\(Int(currentWeather.humidity * 100))%"
          self.rain.text = "\(Int(currentWeather.precipProbability))%"
          self.summary.text = "\(currentWeather.summary)"
          
          self.refreshActivityIndicator.stopAnimating()
          self.refreshActivityIndicator.hidden = true
          self.refreshButton.hidden = false
        })
      } else {
        let networkIssueController = UIAlertController(title: "Error", message: "Unable to load data. Connectivity error!", preferredStyle: .Alert)
        let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
        networkIssueController.addAction(okButton)
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        networkIssueController.addAction(cancelButton)
        
        self.presentViewController(networkIssueController, animated: true, completion: nil)
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          self.refreshActivityIndicator.stopAnimating()
          self.refreshActivityIndicator.hidden = true
          self.refreshButton.hidden = false
        })
      }
    })
    downloadTask.resume()
  }

  @IBAction func refreshAction(sender: AnyObject) {
    getCurrentWeatherData()
    refreshButton.hidden = true
    refreshActivityIndicator.hidden = false
    refreshActivityIndicator.startAnimating()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

