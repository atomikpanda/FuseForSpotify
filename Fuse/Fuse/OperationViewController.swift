//
//  OperationViewController.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/2/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//

import UIKit

public enum OperationType: Int {
    case combine = 0
    case intersect = 1
    case subtract = 2
}

class OperationViewController: UIViewController {

    @IBOutlet weak var combineButton: OperationButtonView!
    @IBOutlet weak var intersectButton: OperationButtonView!
    @IBOutlet weak var subtractButton: OperationButtonView!
    
    @IBOutlet weak var playlistAButton: RoundedButton!
    @IBOutlet weak var playlistBButton: RoundedButton!
    @IBOutlet weak var swapButton: UIButton!
    var playlists: [Playlist]?
    
    var playlistA: Playlist?
    var playlistB: Playlist?
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
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for button in [combineButton, intersectButton, subtractButton] {
            button?.setSelected(false)
            button?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(operationButtonSelected(gesture:))))
        }
        
        combineButton.setSelected(true)
        
        if let a = playlistA {
            playlistAButton.setTitle(a.name, for: .normal)
        }
        if playlistB == nil {
            playlistBButton.setTitle("Choose Playlist...", for: .normal)
        }
    }
    
    @objc func operationButtonSelected(gesture: UITapGestureRecognizer) {
        if let tappedButton = gesture.view as? OperationButtonView {
            var btns = [combineButton, intersectButton, subtractButton]
            if let indexToRemove = btns.firstIndex(of: tappedButton) {
                btns.remove(at: indexToRemove)
            }
            for button in btns {
                button?.setSelected(false)
            }
            tappedButton.setSelected(true)
        }
    }
    
    @IBAction func playlistBButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toPlaylistSelection", sender: self)
    }
    
    @IBAction func swapTapped(_ sender: UIButton) {
        
        guard let b = playlistB else {return}
        
        let a = playlistA
        
        playlistA = b
        playlistB = a
        
        playlistAButton.setTitle(b.name, for: .normal)
        playlistBButton.setTitle(playlistB?.name ?? "Choose Playlist...", for: .normal)
        
        if playlistA != nil && playlistB != nil {
            swapButton.isEnabled = true
        }
        else {
            swapButton.isEnabled = false
        }
    }
    
    @IBAction func cancelTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    var createAction: UIAlertAction?
    
    @IBAction func doneTapped(_ sender: AnyObject) {
        // Next button tapped
        
         let alert = UIAlertController(title: "Enter Playlist Name", message: "Enter the name of the new playlist that will be created.", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Playlist Name"
            textField.addTarget(self, action: #selector(self.textFieldValueChanged(_:)), for: .editingChanged)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        createAction = UIAlertAction(title: "Create", style: .default, handler: { action in
            
            if let textField = alert.textFields?.first,
                let playlistTitle = textField.text,
                playlistTitle.isEmpty == false {
                self.performSegue(withIdentifier: "unwindToPlaylistList", sender: self)
            }
        })
        guard let action = createAction else {return}
        action.isEnabled = false
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc
    func textFieldValueChanged(_ textField: UITextField) {
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
        if let actualPlaylists = playlists, segue.identifier == "toPlaylistSelection", let nav = segue.destination as? UINavigationController, let dest = nav.topViewController as? PlaylistSelectionViewController {
            
            dest.playlists = actualPlaylists
            dest.operationType = operationType
            dest.playlistAName = playlistA?.name
        }
    }
    
    @IBAction func unwindToOperation(_ unwindSegue: UIStoryboardSegue) {
        if let source = unwindSegue.source as? PlaylistSelectionViewController,
            let selectedPlaylist = source.selectedPlaylist {
            playlistB = selectedPlaylist
            playlistBButton.setTitle(selectedPlaylist.name, for: .normal)
            
            if playlistA != nil && playlistB != nil {
                swapButton.isEnabled = true
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(doneTapped(_:)))
            }
            else {
                swapButton.isEnabled = false
                navigationItem.rightBarButtonItem = nil
            }
        }
        
    }

}
