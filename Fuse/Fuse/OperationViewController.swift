//
//  OperationViewController.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/2/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//

import UIKit

// Represents the different types of operations
public enum OperationType: Int {
    case combine = 0
    case intersect = 1
    case subtract = 2
}

class OperationViewController: UIViewController {

    // MARK: - Three operation buttons that act like a segemented control
    @IBOutlet weak var combineButton: OperationButtonView!
    @IBOutlet weak var intersectButton: OperationButtonView!
    @IBOutlet weak var subtractButton: OperationButtonView!
    
    // MARK: - Playlist selection buttons
    @IBOutlet weak var playlistAButton: RoundedButton!
    @IBOutlet weak var playlistBButton: RoundedButton!
    @IBOutlet weak var swapButton: UIButton!
    
    // All of the playlists
    var playlists: [Playlist]?
    
    // The currently selected playlists
    var playlistA: Playlist?
    var playlistB: Playlist?
    
    // The segmented control option value
    // defaults to .combine
    var operationType: OperationType {
        if combineButton?.isSelected == true  {
            return .combine
        }
        else if intersectButton?.isSelected == true {
            return .intersect
        }
        else if subtractButton?.isSelected == true {
            return .subtract
        }
        
        return .combine
    }
    
    // Used to hold the new playlist name
    // to create on unwind to playlist list vc
    var newPlaylistName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup our segmented control buttons
        for button in [combineButton, intersectButton, subtractButton] {
            button?.setSelected(false)
            button?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(operationButtonSelected(gesture:))))
        }
        
        // Select combine since it is the default
        combineButton.setSelected(true)
        
        // Load the title of playlistA
        if let a = playlistA {
            playlistAButton.setTitle(a.name, for: .normal)
        }
        
        // Since playlistB is nil give the user the option to select
        if playlistB == nil {
            playlistBButton.setTitle("Choose Playlist...", for: .normal)
        }
    }
    
    @objc func operationButtonSelected(gesture: UITapGestureRecognizer) {
        if let tappedButton = gesture.view as? OperationButtonView {
            
            // Our buttons
            var btns = [combineButton, intersectButton, subtractButton]
            
            // Remove the button that was just tapped
            if let indexToRemove = btns.firstIndex(of: tappedButton) {
                btns.remove(at: indexToRemove)
            }
            
            // Deselect all other buttons
            for button in btns {
                button?.setSelected(false)
            }
            
            // Select our button that was just tapped
            tappedButton.setSelected(true)
        }
    }
    
    @IBAction func playlistBButtonTapped(_ sender: UIButton) {
        // Open the selection view when the "Choose Playlist Button" was tapped
        performSegue(withIdentifier: "toPlaylistSelection", sender: self)
    }
    
    @IBAction func swapTapped(_ sender: UIButton) {
        
        // Ensure we have a playlist in the b position
        guard let b = playlistB else {return}
        
        // Get playlist a
        let a = playlistA
        
        // Swap
        playlistA = b
        playlistB = a
        
        // Load the new button titles
        playlistAButton.setTitle(b.name, for: .normal)
        playlistBButton.setTitle(playlistB?.name ?? "Choose Playlist...", for: .normal)
        
        // Update the swap button enabled status
        if playlistA != nil && playlistB != nil {
            swapButton.isEnabled = true
        }
        else {
            swapButton.isEnabled = false
        }
    }
    
    @IBAction func cancelTapped(_ sender: AnyObject) {
        // Cancel this view controller and all info by dismissing
        dismiss(animated: true, completion: nil)
    }
    
    // The create action in the alert popup
    // used later for enabling only when the name is not blank
    var createAction: UIAlertAction?
    
    @IBAction func doneTapped(_ sender: AnyObject) {
        // Next button tapped
        
         let alert = UIAlertController(title: "Enter Playlist Name", message: "Enter the name of the new playlist that will be created.", preferredStyle: .alert)
        
        // Playlist title tf
        alert.addTextField { (textField) in
            textField.placeholder = "Playlist Name"
            // add handler
            textField.addTarget(self, action: #selector(self.textFieldValueChanged(_:)), for: .editingChanged)
        }
        
        // Cancel
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Create button
        createAction = UIAlertAction(title: "Create", style: .default, handler: { action in
            // Make sure we have a playlist name before proceeding
            if let textField = alert.textFields?.first,
                let playlistTitle = textField.text,
                playlistTitle.isEmpty == false {
                // Save the name and unwind back to our main playlist list
                self.newPlaylistName = playlistTitle
                self.performSegue(withIdentifier: "unwindToPlaylistList", sender: self)
            }
        })
        
        // Disable and add the action
        guard let action = createAction else {return}
        action.isEnabled = false
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc
    func textFieldValueChanged(_ textField: UITextField) {
        // Check if we have text in the text field
        // and then adjust the state of the action
        // to be disabled for blank text
        if textField.text?.isEmpty == false {
            createAction?.isEnabled = true
        }
        else {
            createAction?.isEnabled = false
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Before showing the playlist selection view controller
        // load all data
        if let actualPlaylists = playlists,
            segue.identifier == "toPlaylistSelection",
            let nav = segue.destination as? UINavigationController,
            let dest = nav.topViewController as? PlaylistSelectionViewController {
            
            // Pass the data over
            dest.playlists = actualPlaylists
            dest.operationType = operationType
            dest.playlistAName = playlistA?.name
        }
    }
    
    @IBAction func unwindToOperation(_ unwindSegue: UIStoryboardSegue) {
        
        // This gets called after unwinding from a selection
        if let source = unwindSegue.source as? PlaylistSelectionViewController,
            let selectedPlaylist = source.selectedPlaylist {
            
            // Load the selected playlist
            playlistB = selectedPlaylist
            playlistBButton.setTitle(selectedPlaylist.name, for: .normal)
            
            // If we have both playlists selected
            // then update the UI appropriately
            if playlistA != nil && playlistB != nil {
                swapButton.isEnabled = true
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(doneTapped(_:)))
            }
            else {
                // if we don't have all data disable buttons
                swapButton.isEnabled = false
                navigationItem.rightBarButtonItem = nil
            }
        }
        
    }

}
