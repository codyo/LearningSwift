//
//  MasterViewController.swift
//  Selfiegram
//
//  Created by Cody on 9/21/18.
//  Copyright © 2018 HoorayArray. All rights reserved.
//

import UIKit

class SelfieListViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var selfies:[Selfie] = []
    
    //The formatter for creating the "1 minute ago" style label
    let timeIntervalFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .spellOut
        formatter.maximumUnitCount = 1
        return formatter
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load the list of selfies from the selfie store
        do {
            //get the list of photos, sorted by date (newer first)
            selfies = try SelfieStore.shared.listSelfies().sorted(by: {$0.created > $1.created})
        } catch let error {
            showError(message: "Failed to load selfies: \(error.localizedDescription)")
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        //navigationItem.leftBarButtonItem = editButtonItem

        //let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        let addSelfieButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewSelfie))
        navigationItem.rightBarButtonItem = addSelfieButton
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }
    
    //called after the user has selected a photo
    func newSelfieTaken(image: UIImage) {
        //create a new image
        let newSelfie = Selfie(title: "New Selfie")
        
        //store the image
        newSelfie.image = image
        
        //attempt to save the photo
        do {
            try SelfieStore.shared.save(selfie: newSelfie)
        } catch let error {
            showError(message: "Can't save photo: \(error)")
            return
        }
        
        //insert this photo into the view controllers list
        selfies.insert(newSelfie, at:0)
        
        //update the table view to show the new photo
        tableView.insertRows(at: [IndexPath(row:0, section:0)], with: .automatic)
    }
    
    @objc func createNewSelfie(){
        //create a new image picker
        let imagePicker = UIImagePickerController()
        
        //If a camera is avalible, use it; otherwise, use the photo library
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            
            //if the front facing camera is avalible, use that
            if UIImagePickerController.isCameraDeviceAvailable(.front) {
                imagePicker.cameraDevice = .front
            }
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        
        //we want this object to be notified when the user takes a photo
        imagePicker.delegate = self
        
        //present the image picker
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func showError (message:String){
        //create an alert controller, with the message received
        let alert = UIAlertController(title:"Error", message:message, preferredStyle: .alert)
        
        //add an action to it - it won't do anything, but doing this means
        //that it will have a button to dismiss it
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        //show the alert and it's message
        self.present(alert, animated:true, completion:nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    @objc
    func insertNewObject(_ sender: Any) {
        objects.insert(NSDate(), at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as! NSDate
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    */

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selfies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        //get a selfie and use it to configure the cell
        let selfie = selfies[indexPath.row] //as! NSDate
        
        //set up the main label
        cell.textLabel?.text = selfie.title
        
        //set up it's time ago sublabel
        if let interval = timeIntervalFormatter.string(from: selfie.created, to: Date()) {
            cell.detailTextLabel?.text = "\(interval) ago"
        } else {
            cell.detailTextLabel?.text = nil
        }
        
        //show the selfie image to the left of the cell
        cell.imageView?.image = selfie.image
        
        return cell
    }

    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //If this was a deletion, we have deleting to do
        if editingStyle == .delete {
            //get the object from the content array
            let selfieToRemove = selfies[indexPath.row]
            
            //attempt to delete the selfie
            do{
                try SelfieStore.shared.delete(selfie:selfieToRemove)
                //remove it from that array
                selfies.remove(at: indexPath.row)
                //remove the entry from the table view
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                let title = selfieToRemove.title
                showError(message: "Failed to delete \(title).")
            }
            
            
        } //else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        //}
    }
 


}

extension SelfieListViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //called when the user cancels selecting an image
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //called when the user has finished selecting an image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage
            ?? info[UIImagePickerControllerOriginalImage] as? UIImage
            else {
                let message = "Couldn't get a picture from the image Picker!"
                showError(message: message)
                return
            }
        
        self.newSelfieTaken(image:image)
        
        //get rid of the view controller
        self.dismiss(animated: true, completion: nil)
        
    }
}

