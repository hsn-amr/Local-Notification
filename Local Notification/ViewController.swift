
//
//  ViewController.swift
//  Local Notification
//
//  Created by administrator on 15/12/2021.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {

    @IBOutlet weak var pickerTimer: UIPickerView!
    @IBOutlet weak var totalTime: UILabel!
    @IBOutlet weak var hoursAndMins: UILabel!
    @IBOutlet weak var settingTimer: UILabel!
    @IBOutlet weak var localNotification: UILabel!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var startTimerButton: UIButton!
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var timers = [Int]()
    var selectedTimer = Timers.five.rawValue
    var didTimeFinish = false
    
    let userNotificationCenter = UNUserNotificationCenter.current()
    override func viewDidLoad() {
        super.viewDidLoad()
        userNotificationCenter.delegate = self
        requestNotificationAuthorization()
        // change color of text inside picker view
        cancelButton.isEnabled = false
        pickerTimer.setValue(UIColor.white, forKeyPath: "textColor")
        pickerTimer.dataSource = self
        pickerTimer.delegate = self
        timers = getAllTimersValues()
        
        // Do any additional setup after loading the view.
    }
    
    func requestNotificationAuthorization(){
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
        self.userNotificationCenter.requestAuthorization(options: authOptions, completionHandler: {
            (success, error) in
            if let error = error {
                print("Notification Error : ", error)
            }
        })
    }
    func sendNotification(time: Int){
        let notificationContent = UNMutableNotificationContent()
        
        notificationContent.title = "Time Over"
        notificationContent.body = "The Timer You Started Has Finished"
        notificationContent.badge = NSNumber(value: 1)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(time), repeats: false)
        
        let request = UNNotificationRequest(identifier: "Timer", content: notificationContent, trigger: trigger)
        
        userNotificationCenter.add(request) { (error) in
            if let error = error {
                print("Notification Sending Error: ", error)
            }
        }
    }
    
    func getSecondsFromMinutes(mins: Int) -> Int{
        return mins * 60
    }


    @IBAction func startTimerButtonPressed(_ sender: UIButton) {
        sendNotification(time: getSecondsFromMinutes(mins: selectedTimer))
        showOkAlert()
        startTimerButton.isEnabled = false
        cancelButton.isEnabled = true
        let currentTime = getCurrentTime()
        let timeafterStartTimer = getTimeAfterStartTimer()
        totalTime.text = "Total Time: \(selectedTimer)"
        hoursAndMins.text = "0 Hours, \(selectedTimer) Min"
        
        settingTimer.text = "\(selectedTimer) minutes timer set"
        localNotification.text = timeafterStartTimer
        let log = "\(currentTime) - \(timeafterStartTimer) ... \(selectedTimer) Minutes"
        addLog(log: log)
        
    }
    
    @IBAction func newDayButtonPressed(_ sender: UIBarButtonItem) {
        // to do: method for stop timer and show alert
        let alert = UIAlertController(title: "Are You Sure It's New Day?", message: nil, preferredStyle: .alert)
        
        let newDayAction = UIAlertAction(title: "New Day", style: .destructive, handler: {
            action in
            self.startNewDay()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alert.addAction(newDayAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
       
    }
    @IBAction func cancelTimerButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Cancel Current Timer?", message: nil, preferredStyle: .alert)
        
        let continueAction = UIAlertAction(title: "Continue", style: .cancel, handler: nil)
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: {
            action in
            self.cancelTimer()
        })
        
        alert.addAction(continueAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func startNewDay(){
        userNotificationCenter.removePendingNotificationRequests(withIdentifiers: ["Timer"])
        userNotificationCenter.removeDeliveredNotifications(withIdentifiers: ["Timer"])
        totalTime.text = ""
        hoursAndMins.text = ""
        localNotification.text = ""
        settingTimer.text = ""
        startTimerButton.isEnabled = true
        cancelButton.isEnabled = false
    }
    
    
    func cancelTimer(){
        userNotificationCenter.removePendingNotificationRequests(withIdentifiers: ["Timer"])
        userNotificationCenter.removeDeliveredNotifications(withIdentifiers: ["Timer"])
        totalTime.text = "Total Time: 00"
        hoursAndMins.text = "0 Hours, 0 Mins"
        settingTimer.text = "\(selectedTimer) Mins Has Cancelled"
        addLog(log: "\(selectedTimer) Mins Has Cancelled")
        localNotification.text = ""
        startTimerButton.isEnabled = true
        cancelButton.isEnabled = false
    }
    
    func showOkAlert(){
        let alert = UIAlertController(title: "\(selectedTimer) Min CountDown", message: "After \(selectedTimer) minutes, you wil be notified. Turn your ringer on", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    

    
    func addLog(log: String){
        let newLog = Logs(context: managedObjectContext)
        newLog.log = log
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
                print("Saved")
            } catch {
                print("saving error - \(error.localizedDescription)")
            }
        }
    }
    
    func getTimeAfterStartTimer() -> String {
        let date = Date()
        let calender = Calendar.current
        var hour = calender.component(.hour, from: date)
        var minute = calender.component(.minute, from: date)
        
        minute += selectedTimer
        if minute >= 60 {
            hour += (minute/60)
            minute = minute%60
        }
        return "Work until: \(hour):\(minute)"
    }

    func getCurrentTime() -> String {
        let date = Date()
        let calender = Calendar.current
        let hour = calender.component(.hour, from: date)
        let minute = calender.component(.minute, from: date)
        
        return "\(hour):\(minute)"
    }
    
    func getAllTimersValues() -> [Int] {
        var timers = [Int]()
        for timer in Timers.allCases {
            timers.append(timer.rawValue)
        }
        return timers
    }
    
    func timeOver(){
        if didTimeFinish {
            (UIApplication.shared).applicationIconBadgeNumber = 0
            totalTime.text = "Total Time: 00"
            hoursAndMins.text = "0 Hours, 0 Mins"
            settingTimer.text = "Time Over"
            localNotification.text = ""
            addLog(log: "Time Over")
            startTimerButton.isEnabled = true
            cancelButton.isEnabled = false
            didTimeFinish = false
        }
    }
}

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timers.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let timer = timers[row]
        return "\(timer) Minutes"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedTimer = timers[row]
    }
    
    
}

extension ViewController: UNUserNotificationCenterDelegate{
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        didTimeFinish = true
        timeOver()
        print("recive")
        completionHandler()
    
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        didTimeFinish = true
        timeOver()
        completionHandler([.alert, .badge, .sound])
        print("present")
    }
    
    
}
