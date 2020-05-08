//
//  LibraryViewController.swift
//  DreamHouseVR-DEMO
//
//  Created by Petr Brantalík on 25/04/2020.
//  Copyright © 2020 Petr Brantalík. All rights reserved.
//

import UIKit
import Combine
import QuickLookThumbnailing


class LibraryViewController: UIViewController {
    @IBOutlet var background: UIView!
    
    
    
    let models = ["ship","cube","sofa","door","chair","mini-desk","bed","chair-brown","desk","kancl-stul","kancl-zidle-1","kancl-zidle-2"]
    
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var objectsCollectionView: UICollectionView!
    
    var mainController = ViewController()
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    var delegate: DataDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        background.backgroundColor = UIColor.red
        
        
        loader.hidesWhenStopped = true
        
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 120)
        objectsCollectionView.collectionViewLayout = layout
        
        objectsCollectionView.register(ModelCollectionViewCell.nib(), forCellWithReuseIdentifier: K.collectionCellIdentifier)
        objectsCollectionView.delegate = self
        objectsCollectionView.dataSource = self
        
        
    }
    
    @IBAction func closeLibrary(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
   
    
    
    
}


//MARK: - UITableViewDelegate
extension LibraryViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected Category")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}


//MARK: - UItableViewDataSource
extension LibraryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.tableCellIdentifier, for: indexPath)
        cell.textLabel?.text = "All"
        
        
        
        
        
        
        return cell
    }
    
    
}

//MARK: - UICollectionView
extension LibraryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        
        loader.startAnimating()
        delegate?.updateItem(name:models[indexPath.row])
        loader.stopAnimating()
        print("selected model")
        dismiss(animated: true, completion: nil)
    }
    
    
}

//MARK: - UICollectionViewDataSource
extension LibraryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.collectionCellIdentifier, for: indexPath) as! ModelCollectionViewCell
        
        
        
      

        if models[indexPath.row] == "cube" {
            cell.configure(with: UIImage(named: models[indexPath.row])!)
            return cell
        }

        guard let url = Bundle.main.url(forResource: models[indexPath.row], withExtension: "usdz") else {
            print("Unable to create url")
            return cell
        }

        let scale = UIScreen.main.scale


        let request = QLThumbnailGenerator.Request(fileAt: url, size: CGSize(width: 120, height: 120), scale: scale, representationTypes: .all)

        let generator = QLThumbnailGenerator.shared

        generator.generateRepresentations(for: request) { (thumbnail,type,error) in
            DispatchQueue.main.async {
                if thumbnail == nil || error != nil {
                    print("Error generatuing thumbnail: \(error?.localizedDescription)")
                    return
                } else {

                    cell.configure(with: thumbnail!.uiImage)


                }


            }
        }

        return cell
    }
    
    
}

//MARK: - UICollectionViewDelegateFlowLayout
extension LibraryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 120)
    }
}
