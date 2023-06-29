//
//  FacilitiesViewCell.swift
//  Radius Assignemnt
//
//  Created by Tushar Tiwary on 29/06/23.
//

import UIKit

class FacilitiesViewCell: UITableViewCell {

    static let reuseID = "CellId"
    
    let facilitiesImage: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.layer.masksToBounds = true
        return img
    }()
    
    let facilitiesName: UILabel = {
        let l = UILabel()
        l.textColor = .gray
        l.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return l
    }()
    
    let selectedImage: UIImageView = {
        let l = UIImageView()
        l.contentMode = .scaleAspectFill
        return l
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        
        contentView.addSubview(facilitiesImage)
        contentView.addSubview(facilitiesName)
        contentView.addSubview(selectedImage)
        
        facilitiesImage.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.size.equalTo(50)
            make.top.equalTo(16)
        }
        
        facilitiesName.snp.makeConstraints { make in
            make.left.equalTo(facilitiesImage.snp.right).offset(10)
            make.centerY.equalTo(facilitiesImage)
        }
        
        selectedImage.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(facilitiesName)
            make.size.equalTo(50)
        }
    }
    
    func setSelectedState(_ selected: Bool) {
        if selected {
            selectedImage.image = UIImage(named: "tick")
        } else {
            selectedImage.image = .none
            
        }
    }
    
    func setFacilitiesImage(_ img: String) {
        return facilitiesImage.image = UIImage(named: img)
    }
    
    func setFacilitiesName(_ text: String) {
        return facilitiesName.text = text
    }
}
