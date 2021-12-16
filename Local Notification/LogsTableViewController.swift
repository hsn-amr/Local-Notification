//
//  LogsTableViewController.swift
//  Local Notification
//
//  Created by administrator on 16/12/2021.
//

import UIKit
import CoreData

class LogsTableViewController: UITableViewController {

    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var logs = [Logs]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchAllLogs()
    }
    
    @IBAction func deleteAllLogsButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Deleting All Logs", message: "Do You Want To Delete All Logs?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete All", style: .destructive, handler: {
            action in
            self.deletAllLogs()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func fetchAllLogs(){
        let logsRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Logs")
        
        do {
            let result = try managedObjectContext.fetch(logsRequest)
            logs = result as! [Logs]
            print("Fetched")
            tableView.reloadData()
        } catch {
            print("fetching error : \(error.localizedDescription)")
        }
    }
    
    private func deletAllLogs(){
        for log in logs {
            managedObjectContext.delete(log)
        }
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
                print("All have deleted")
                logs.removeAll()
                tableView.reloadData()
            } catch {
                print("deleting error \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Table view data source

    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return logs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = logs[indexPath.row].log
        cell.textLabel?.textColor = .white
        return cell
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
