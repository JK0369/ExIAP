//
//  ProductCell.swift
//  ExInAppPurchase
//
//  Created by 김종권 on 2022/06/04.
//

import UIKit

final class ProductCell: UITableViewCell {
  static let id = "ProductCell"
  
  // MARK: UI
  private let nameLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 20, weight: .bold)
    label.numberOfLines = 1
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  private let priceLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 18)
    label.numberOfLines = 1
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  private let buyButton: UIButton = {
    let button = UIButton()
    button.setTitle("buy", for: .normal)
    button.setTitleColor(.systemBlue, for: .normal)
    button.setTitleColor(.blue, for: .highlighted)
    button.addTarget(self, action: #selector(didTapBuyButton), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  // MARK: Properties
  var buyButtonTap: (() -> Void)? // delegate (인스턴스 주입은 외부에서, 실행은 내부에서)
  
  // MARK: Initializer
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    self.contentView.addSubview(self.nameLabel)
    self.contentView.addSubview(self.priceLabel)
    self.contentView.addSubview(self.buyButton)
    
    NSLayoutConstraint.activate([
      self.nameLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 16),
      self.nameLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16),
    ])
    NSLayoutConstraint.activate([
      self.priceLabel.leftAnchor.constraint(equalTo: self.nameLabel.leftAnchor),
      self.priceLabel.topAnchor.constraint(equalTo: self.nameLabel.bottomAnchor, constant: 8),
      self.priceLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16),
    ])
    NSLayoutConstraint.activate([
      self.buyButton.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -16),
      self.buyButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16),
      self.buyButton.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16),
      self.buyButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
    ])
  }
  
  override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    super.setHighlighted(highlighted, animated: animated)
    
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    self.prepare(name: nil, price: nil, isPurchased: false)
  }
  
  func prepare(name: String?, price: String?, isPurchased: Bool?) {
    self.nameLabel.text = name
    self.priceLabel.text = price
    self.buyButton.isHidden = isPurchased ?? true
  }
  
  @objc private func didTapBuyButton() {
    self.buyButtonTap?()
  }
}

