//
//  DetailViewController.swift
//  Selfiegram
//
//  Created by Cody on 9/21/18.
//  Copyright © 2018 HoorayArray. All rights reserved.
//

import UIKit

class SelfieDetailViewController: UIViewController {

    //@IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var selfieNameField: UITextField!
    @IBOutlet weak var dateCreatedLabel: UILabel!
    @IBOutlet weak var selfieImageView: UIImageView!

    @IBAction func doneButtonTapped(_ sender: Any) {
        self.selfieNameField.resignFirstResponder()
        
        //ensure that we have a selfie to work with
        guard let selfie = selfie else {
            return
        }
        
        //ensure that we have text in the text field
        guard let text = selfieNameField?.text else {
            return
        }
        
        //update the selfie and save it
        selfie.title = text
        
        try? SelfieStore.shared.save(selfie: selfie)
    }
    
    func configureView() {
        // Update the user interface for the detail item.
//        if let detail = selfie {
//            if let label = detailDescriptionLabel {
//                label.text = detail.description
//            }
//        }
        guard let selfie = selfie else {
            return
        }
        
        //ensure that we have references to the controls we need
        guard let selfieNameField = selfieNameField,
            let selfieImageView = selfieImageView,
            let dateCreatedLabel = dateCreatedLabel
            else {
                return
            }
        
        selfieNameField.text = selfie.title
        dateCreatedLabel.text = dateFormatter().string(from: selfie.created)
        selfieImageView.image = selfie.image
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var selfie: Selfie? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    //the date formatter used to format the time and date of the photo.
    //it's created in a closure like this so that when it's used, it's already configured the way we need it.
    let dateFormatter = { () -> DateFormatter in
        let d = DateFormatter()
        d.dateStyle = .short
        d.timeStyle = .short
        return d
    }


}

