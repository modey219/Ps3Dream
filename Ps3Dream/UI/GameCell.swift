// Ps3Dream iOS - Custom Game Cell

import UIKit

class GameCell: UITableViewCell {
    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 8
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor.secondarySystemBackground
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        accessoryType = .disclosureIndicator
        backgroundColor = .clear

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(iconView)
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 56),
            iconView.heightAnchor.constraint(equalToConstant: 56),

            stack.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
        ])
    }

    func configure(title: String, subtitle: String, hasConfig: Bool = false) {
        titleLabel.text = title
        if hasConfig {
            subtitleLabel.text = "\(subtitle)  \u{2705} Optimized"
            subtitleLabel.textColor = .systemGreen
        } else {
            subtitleLabel.text = subtitle
            subtitleLabel.textColor = .secondaryLabel
        }
        iconView.image = UIImage(systemName: "gamecontroller.fill")
        iconView.tintColor = hasConfig ? .systemGreen : .systemBlue
        iconView.backgroundColor = (hasConfig ? UIColor.systemGreen : UIColor.systemBlue).withAlphaComponent(0.1)
    }
}
