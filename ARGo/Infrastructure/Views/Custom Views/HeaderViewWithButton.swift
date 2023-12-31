//
//  ChangeColorHeaderView.swift
//  ARGo
//
//  Created by ברק בן חור on 13/11/2023.
//

import UIKit
import AVFAudio

protocol ChangeColorHeaderViewDelegate: UIViewController {
    func didSelect(view: HeaderViewWithButton)
    func voice(view: HeaderViewWithButton)
}

enum HeaderType: Int {
    case color, voice, purchases
}

class HeaderViewWithButton: CleanView {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var buttonTitle: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var subtitleView: UIView! {
        didSet {
            subtitleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(voice)))
        }
    }
    @IBOutlet weak var subtitleGif: UIImageView! {
        didSet {
            guard let gif = try? UIImage(gifName: "voice") else { return }
            subtitleGif.setGifImage(gif)
        }
    }
    @IBOutlet weak var buttonStack: UIStackView! {
        didSet {
            buttonStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectFromStack)))
        }
    }
    
    var selected = {
        return UserDefaults.standard.bool(forKey: "isAllColors")
    }
    
    var type: HeaderType! {
        didSet {
            setUI()
        }
    }
    
    weak var delegate: ChangeColorHeaderViewDelegate?
    
    func setUI() {
        switch type {
        case .color:
            subtitleView.isHidden = true
            title.text = NSLocalizedString("color", comment: "")
            button.setImage(UIImage(systemName: "circle"), for: .normal)
            button.setImage(UIImage(systemName: "checkmark.circle"), for: .selected)
            button.isSelected = UserDefaults.standard.bool(forKey: "isAllColors")
        case .voice:
            buttonTitle.isHidden = true
            title.text = NSLocalizedString("voice", comment: "")
            button.alpha = 0
            button.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
            if let id = (UserDefaults.standard.string(forKey:"voiceID - \(Locale.getDescription(id: Locale.current.identifier)?.components(separatedBy: " ").first ?? "error")") ?? AVSpeechSynthesisVoice(language: Locale.current.identifier)?.identifier) {
                subtitle.text = AVSpeechSynthesisVoice(identifier: id)?.name
            }
        case .purchases:
            subtitleView.isHidden = true
            buttonTitle.isHidden = true
            button.isHidden = true
            buttonStack.isHidden = true
            title.text = NSLocalizedString("purchases", comment: "")
        case .none:
            return
        }
    }
    
    
    @IBAction func voice(_ sender: UIButton) {
        delegate?.voice(view: self)
    }
    
    @IBAction func didSelect(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        switch type {
        case .color:
            UserDefaults.standard.setValue(sender.isSelected, forKey: "isAllColors")
        default:
            break
        }
        delegate?.didSelect(view: self)
    }
    
    @objc private func didSelectFromStack() {
        didSelect(button)
    }
}
