//
//  ViewController.swift
//  Radius Assignemnt
//
//  Created by Tushar Tiwary on 28/06/23.
//

import UIKit
import SnapKit

public protocol FacilitiesInterface: UIViewController {
    
}

protocol FacilitiesInteractable {
    
    func fetchFacilities(apiURL: String, completion: @escaping (Result<Facilities, Error>) -> Void)
}

class FacilitiesViewController: UIViewController {
    
    var interactor: FacilitiesInteractable!
    var facilities: Facilities?
    var activeOptions: [String: String] = [:]
    private var exclusions: [[Exclusion]] = []
    
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FacilitiesViewCell.self, forCellReuseIdentifier: FacilitiesViewCell.reuseID)
        tableView.separatorStyle = .none
        return tableView
    }()
    
    init(interactor: FacilitiesInteractable) {
        super.init(nibName: nil, bundle: nil)
        self.interactor = interactor
        facilitiesDidFetched()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        let img = UIImageView(image: UIImage(named: "logo"))
        let imageSize = CGSize(width: 30, height: 30)
        let imageFrame = CGRect(origin: .zero, size: imageSize)
        img.frame = imageFrame
        
        navigationItem.titleView = img
    }
    
    private func facilitiesDidFetched() {
        interactor.fetchFacilities(apiURL: API.getFacilitiesData) { [weak self] result in
            switch result {
            case .success(let facilities):
                print(facilities)
                self?.facilities = facilities
                self?.exclusions = facilities.exclusions
            case .failure(let error):
                print(error)
            }
            DispatchQueue.main.async {
                self?.reloadView()
            }
        }
    }
    
    private func reloadView() {
        tableView.reloadData()
    }
    
    private func shakeCell(_ cell: UITableViewCell?) {
        guard let cell = cell else { return }
        
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-8, 8, -8, 8, -4, 4, -2, 2, 0]
        
        cell.layer.add(animation, forKey: "shake")
    }
    
    private func isOptionExcluded(for facilityID: String, optionID: String) -> Bool {
        for exclusionGroup in exclusions {
            if let exclusion = exclusionGroup.first(where: { $0.facilityID == facilityID }), exclusion.optionsID == optionID {
                
                let excludedFacilityID = exclusionGroup.filter { $0.facilityID != facilityID }.map { $0.facilityID }
                let excludedOptionID = exclusionGroup.filter { $0.facilityID != facilityID }.map { $0.optionsID }
                
                if let activeFacilityID = excludedFacilityID.first,
                   let activeOptionID = activeOptions[activeFacilityID],
                   excludedOptionID.contains(activeOptionID) {

                    return true
                }
            }
        }
        return false
    }
}

// MARK: - UITableViewDelegate

extension FacilitiesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100
    }
    
    func tableView(_ tableView: UITableView, widthForRowAt indexPath: IndexPath) -> CGFloat {
        
        return tableView.frame.width
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        headerView.backgroundColor = UIColor(red: 177/255, green: 1, blue: 1, alpha: 1)
        
        let titleLabel = UILabel(frame: headerView.bounds)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        titleLabel.textColor = .black
        
        if let facility = facilities?.facilities[section] {
            titleLabel.text = facility.name
        }
        
        headerView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let facility = facilities?.facilities[indexPath.section] {
            let option = facility.options[indexPath.row]
     
            if isOptionExcluded(for: facility.facilityID, optionID: option.id) {
                if let cell = tableView.cellForRow(at: indexPath) as? FacilitiesViewCell {
                    shakeCell(cell)
                }
                return
            }
            activeOptions[facility.facilityID] = option.id
            
            tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource

extension FacilitiesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return facilities?.facilities.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return facilities?.facilities[section].options.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FacilitiesViewCell.reuseID, for: indexPath) as! FacilitiesViewCell
        
        if let facility = facilities?.facilities[indexPath.section] {
            let option = facility.options[indexPath.row]
            
            let facilityID = facility.facilityID
            let optionID = option.id
            
            let isExcluded = isOptionExcluded(for: facilityID, optionID: optionID)
            
            cell.setFacilitiesName(option.name)
            cell.setSelectedState(activeOptions[facilityID] == optionID)
            
            cell.setFacilitiesName(option.name)
            
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    cell.setFacilitiesImage("apartment")
                }
                if indexPath.row == 1 {
                    cell.setFacilitiesImage("condo")
                }
                if indexPath.row == 2 {
                    cell.setFacilitiesImage("boat")
                }
                if indexPath.row == 3 {
                    cell.setFacilitiesImage("land")
                }
            }
            
            if indexPath.section == 1 {
                if indexPath.row == 0 {
                    cell.setFacilitiesImage("rooms")
                }
                if indexPath.row == 1 {
                    cell.setFacilitiesImage("no-room")
                }
            }
            
            if indexPath.section == 2 {
                if indexPath.row == 0 {
                    cell.setFacilitiesImage("swimming")
                }
                if indexPath.row == 1 {
                    cell.setFacilitiesImage("garden")
                }
                if indexPath.row == 2 {
                    cell.setFacilitiesImage("garage")
                }
            }
        }
        
        return cell
    }
}
