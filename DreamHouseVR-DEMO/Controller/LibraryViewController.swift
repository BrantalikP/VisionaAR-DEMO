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
    
    var transparentView = UIView()
    var colorCloseButton = UIButton()
    var colorCollectionView: UICollectionView!
    var colorsView = UIView()
    
    let tableHeight: CGFloat = 200
    var modelColors: [String] = []
    var selectedModel: String?
    var selectedCategory: String = "All"
    var categoryModels: [Model] = []
    
    @IBOutlet var background: UIView!
    
    let categories: [Category] = [Category(name: "All"),Category(name: "Chair"),Category(name: "Bed"),Category(name: "Table")]
    
    let models: [Model] = [Model(name: "cube", colors: []),Model(name: "sofa", colors: []),Model(name: "door", colors: []),Model(name: "chair", colors: ["brown","red","green"],category: "Chair"),Model(name: "mini-desk", colors: [],category: "Table"),Model(name: "bed", colors: [],category:"Bed"),Model(name: "small-chair", colors: [],category: "Chair"),Model(name: "desk", colors: [],category: "Table"),Model(name: "kancl-stul", colors: [],category: "Table"),Model(name: "kancl-zidle-1", colors: [],category: "Chair"),Model(name: "kancl-zidle-2", colors: [],category: "Chair")]
    
    
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var objectsCollectionView: UICollectionView!
    
    var mainController = ViewController()
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    var delegate: DataDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let screenSize = UIScreen.main.bounds.size
        let frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: tableHeight)
        
        // ColorView
        colorsView.frame = frame
    
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 120)
        
       
      
        
        colorCloseButton.layer.cornerRadius = 15
        colorCloseButton.addTarget(self, action: #selector(onClickTransparentView), for: .touchUpInside)
        colorCloseButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
        
        colorCloseButton.frame = CGRect(x: screenSize.width - 50, y: 5, width: 40, height: 40)
        colorCloseButton.setTitle("X", for: .normal)
        colorCloseButton.titleLabel?.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        
        colorCollectionView = UICollectionView(frame: CGRect(x: 0, y: 50, width: screenSize.width, height: 150), collectionViewLayout: layout)
        colorCollectionView.backgroundColor = UIColor.black.withAlphaComponent(0.95)
        loader.hidesWhenStopped = true
        
        // Category
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        
   
        // Objects
        objectsCollectionView.collectionViewLayout = layout
        objectsCollectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 15)
        objectsCollectionView.register(ModelCollectionViewCell.nib(), forCellWithReuseIdentifier: K.collectionCellIdentifier)
        objectsCollectionView.delegate = self
        objectsCollectionView.dataSource = self
        
        
        // Colors

        colorCollectionView.clipsToBounds = true
        colorCollectionView.layer.cornerRadius = 20
        colorCollectionView.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]
        colorCollectionView.contentInset = UIEdgeInsets(top: 10, left: 50, bottom: 10, right: 50)
        colorCollectionView.register(ModelCollectionViewCell.nib(), forCellWithReuseIdentifier: K.collectionCellIdentifier)
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        
        colorsView.addSubview(colorCollectionView)
        colorsView.addSubview(colorCloseButton)
        
      
        
    }
    
    @IBAction func closeLibrary(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func selectCateogoryItem(with category: Category) {
        categoryModels = []
        if category.name == "All" {
            objectsCollectionView.reloadData()
            return
        }
        for model in models {
            if model.category == category.name {
                categoryModels.append(model)
            }
        }
        
        objectsCollectionView.reloadData()
    }
    
    
    
    
}


//MARK: - UITableViewDelegate
extension LibraryViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    
        selectCateogoryItem(with: categories[indexPath.row])
      
        
        selectedCategory = categories[indexPath.row].name
       
        tableView.deselectRow(at: indexPath, animated: true)
         tableView.reloadData()
    }
    
    
}


//MARK: - UItableViewDataSource
extension LibraryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
      
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.tableCellIdentifier, for: indexPath)
        
        if  selectedCategory == categories[indexPath.row].name {
            cell.textLabel?.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        } else {
            cell.textLabel?.font = UIFont.systemFont(ofSize: 19, weight: .regular)
        }
        
        cell.textLabel?.text = categories[indexPath.row].name.uppercased()
        
        
        
        return cell
    }
    
    
}

//MARK: - UICollectionView
extension LibraryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        
        let currentModel = !categoryModels.isEmpty ? categoryModels[indexPath.row] : models[indexPath.row]
        var modelName = currentModel.name
        
        if collectionView == colorCollectionView && selectedModel != nil {
            modelName = "\(selectedModel!)-\(modelColors[indexPath.row])"
        }
        
        if let colorName = currentModel.colors.first {
            modelName = "\(currentModel.name)-\(colorName)"
            selectedModel = currentModel.name
            
            modelColors = currentModel.colors
            
            
            transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            transparentView.frame = self.view.frame
            self.view.addSubview(transparentView)
            
           
           let screenSize = UIScreen.main.bounds.size

            self.view.addSubview(colorsView)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onClickTransparentView))
            transparentView.addGestureRecognizer(tapGesture)
            
            transparentView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
                self.transparentView.alpha = 0.5
                self.colorsView.frame = CGRect(x: 0, y: screenSize.height - self.tableHeight, width: screenSize.width, height: self.tableHeight)
            }, completion: nil)
            
            
            return
        }
        
        loader.startAnimating()
        delegate?.updateItem(name:modelName)
        loader.stopAnimating()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func onClickTransparentView() {
        let screenSize = UIScreen.main.bounds.size
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.colorsView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: self.tableHeight)
        }, completion: nil)
        
    }
    
}

//MARK: - UICollectionViewDataSource
extension LibraryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == colorCollectionView {
            return modelColors.count
        }
        
        if (!categoryModels.isEmpty) {
            return categoryModels.count
        }
        return models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.collectionCellIdentifier, for: indexPath) as! ModelCollectionViewCell
        
        
        let currentModel = !categoryModels.isEmpty ? categoryModels[indexPath.row] : models[indexPath.row]
        var modelName = currentModel.name
        
        if currentModel.name == "cube" && collectionView != colorCollectionView  {
            cell.configure(with: UIImage(named: currentModel.name)!)
            return cell
        }
        
        if let colorName = currentModel.colors.first {
            modelName = "\(currentModel.name)-\(colorName)"
        }
        
        if collectionView == colorCollectionView && selectedModel != nil {
            modelName = "\(selectedModel!)-\(modelColors[indexPath.row])"
        }
        
        
        guard let url = Bundle.main.url(forResource: modelName, withExtension: "usdz") else {
            print("Unable to create url")
            return cell
        }
        
        let scale = UIScreen.main.scale
        
        
        let request = QLThumbnailGenerator.Request(fileAt: url, size: CGSize(width: 120, height: 120), scale: scale, representationTypes: .all)
        
        let generator = QLThumbnailGenerator.shared
        
        generator.generateRepresentations(for: request) { (thumbnail,type,error) in
            DispatchQueue.main.async {
                if thumbnail == nil || error != nil {
                    print("Error generatuing thumbnail: \(error?.localizedDescription ?? self.models[indexPath.row].name)")
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
