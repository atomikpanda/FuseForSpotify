//
//  SettingsViewController.swift
//  Fuse
//
//  Created by Bailey Seymour on 11/11/18.
//  Copyright © 2018 Bailey Seymour. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    @IBOutlet weak var useDarkModeSwitch: UISwitch!
    @IBOutlet weak var fontSizeSegmentedControl: UISegmentedControl!
    var selectedAccentColor = UIColor.fuseTintColorType
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as! ColorCollectionViewCell
        cell.colorView.backgroundColor = UIColor.fuseTint(type: FuseTintColorType(rawValue: indexPath.row)!)
        cell.colorView.layer.cornerRadius = cell.bounds.size.width / 2.0
        
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
            if let firstIndex = selectedIndexPaths.firstIndex(of: indexPath) {
                selectedIndexPaths.remove(at: firstIndex)
            }
            for indexPath in selectedIndexPaths {
                guard let cell = collectionView.cellForItem(at: indexPath) else {continue}
                cell.isSelected = false
            }
        }
        
        guard let cell = collectionView.cellForItem(at: indexPath) else {return}
        cell.isSelected = true
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
            UserDefaults.standard.set(useDarkModeSwitch.isOn, forKey: "isDark")
            UserDefaults.standard.set(fontSizeSegmentedControl.selectedSegmentIndex, forKey: "fontSize")
            UserDefaults.standard.set(selectedAccentColor.rawValue, forKey: "tintColor")
        }
    }
    

}
