//
//  SettingsViewController.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/11/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//
// Bailey Seymour
// DVP4 1811

import UIKit

class SettingsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - Outlets & Vars
    @IBOutlet weak var useDarkModeSwitch: UISwitch!
    @IBOutlet weak var fontSizeSegmentedControl: UISegmentedControl!
    var selectedAccentColor = UIColor.fuseTintColorType
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load settings
        fontSizeSegmentedControl.selectedSegmentIndex = UIFont.fuseFontSize.rawValue
        useDarkModeSwitch.setOn(UIColor.fuseIsDark, animated: false)
        selectedAccentColor = UIColor.fuseTintColorType
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupFuseAppearance()
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FuseTintColorType.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as! ColorCollectionViewCell
        
        // Set up our collection view cell's colorView
        cell.colorView.backgroundColor = UIColor.fuseTint(type: FuseTintColorType(rawValue: indexPath.row)!)
        
        if indexPath.row == UIColor.fuseTintColorType.rawValue {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
            cell.isSelected = true
            
        } else {
            cell.isSelected = false
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if var selectedIndexPaths = collectionView.indexPathsForSelectedItems {
            
            // Remove our new selected index path before we deselect all selected
            if let firstIndex = selectedIndexPaths.firstIndex(of: indexPath) {
                selectedIndexPaths.remove(at: firstIndex)
            }
            
            // Deselect all but the one just now
            for indexPath in selectedIndexPaths {
                guard let cell = collectionView.cellForItem(at: indexPath) else {continue}
                cell.isSelected = false
            }
        }
        
        // Select the new cell
        guard let cell = collectionView.cellForItem(at: indexPath) else {return}
        cell.isSelected = true
        
        // Save the tint color
        if let newSelection = FuseTintColorType(rawValue: indexPath.row) {
            selectedAccentColor = newSelection
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "unwindToPlaylistsFromSettings" {
            saveSettings()
        }
    }
    
    /// Save to user defaults only on save (not cancel)
    func saveSettings() {
        UserDefaults.standard.set(useDarkModeSwitch.isOn, forKey: "isDark")
        BSLog.D("Dark Mode: \(useDarkModeSwitch.isOn ? "Enabled" : "Disabled")")
        
        UserDefaults.standard.set(fontSizeSegmentedControl.selectedSegmentIndex, forKey: "fontSize")
        BSLog.D("Font Size: \(UIFont.fuseFontSize)")
        
        UserDefaults.standard.set(selectedAccentColor.rawValue, forKey: "tintColor")
        BSLog.D("Accent Color: \(selectedAccentColor)")
    }
    
}
