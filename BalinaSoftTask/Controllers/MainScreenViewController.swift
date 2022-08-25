//
//  MainScreenViewController.swift
//  BalinaSoftTask
//
//  Created by Ilya on 24.08.22.
//

import UIKit
import SnapKit

final class MainScreenViewController: UIViewController {
    var tableView: UITableView!
    let networkService = NetworkService()
    private var pictureId: Int?
    var imagePicker = UIImagePickerController()
    var photos = [PhotoInfo]()
    
    
    fileprivate var photoInfo = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        networkService.delegate = self
        networkService.getPhotoInfo()
        self.navigationItem.title = "Photos"
        setupTableView()
    }
    
    func setupTableView() {
        tableView = UITableView(frame: view.bounds)
        view.addSubview(tableView)
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        
        tableView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension MainScreenViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.identifier, for: indexPath) as! CustomTableViewCell
        cell.setTitle(photos[indexPath.item].name)
        let image = UIImage(named: "no-photos")!
        cell.setImage(photos[indexPath.item].image ?? image)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            self.pictureId = indexPath.item
            navigationController?.present(imagePicker, animated: true)
        }
        else {
            let alert = UIAlertController(title: "Warning", message: "No camera available", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            navigationController?.present(alert, animated: true)
        }
    }
}

extension MainScreenViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let pickedImage = info[.originalImage] as? UIImage else {
            return
        }
        let imageData: Data = pickedImage.pngData() ?? Data()
        let imageString: String = imageData.base64EncodedString()
        imagePicker.dismiss(animated: true, completion: {
            let sentData = SentData(name: developer, typeId: self.pictureId ?? 0, photo: imageString)
            self.networkService.sendImage(sentData, completionHandler: {})
        })
    }
}

extension MainScreenViewController: NetworkServiceDelegate {
    func onData(_ data: PhotoInfo) {
        photos.append(data)
        photos.sort(by: { $0.id < $1.id})
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func onImage(_ image: UIImage?) {
        
    }
}
