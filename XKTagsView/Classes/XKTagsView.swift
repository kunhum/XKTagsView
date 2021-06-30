//
//  XKTagsView.swift
//  XKTagsView
//
//  Created by kenneth on 2021/6/29.
//

import UIKit

public protocol XKTagsViewDelegate: NSObjectProtocol {
    
    func xk_tagsView(_ tagsView: XKTagsView, editTag tagItem: UIButton, atIndex index: Int)
    func xk_tagsView(_ tagsView: XKTagsView, didSelectItemAtIndex index: Int)
    func xk_tagsView(_ tagsView: XKTagsView, didLongPressedItemAtIndex index: Int)
    
}
public extension XKTagsViewDelegate {
    func xk_tagsView(_ tagsView: XKTagsView, editTag tagItem: UIButton, atIndex index: Int) {}
    func xk_tagsView(_ tagsView: XKTagsView, didSelectItemAtIndex index: Int) {}
    func xk_tagsView(_ tagsView: XKTagsView, didLongPressedItemAtIndex index: Int) {}
}

public class XKTagsView: UIView {
    
    public weak var delegate: XKTagsViewDelegate? = nil
    
    ///标签
    public var tags = [String]() {
        didSet {
            selectedIndexes.removeAll()
        }
    }
    ///行距
    public lazy var lineSpacing: CGFloat = 8.0
    ///item水平间距
    public lazy var itemSpacing: CGFloat = 8.0
    ///item的高度
    public lazy var itemHeight: CGFloat = 30.0
    ///item的颜色
    public lazy var itemColor = UIColor.lightGray
    ///字体
    public lazy var font = UIFont.systemFont(ofSize: 14.0)
    ///字体颜色
    public lazy var textColor = UIColor.black
    ///边界颜色
    public lazy var xk_borderColor = UIColor.clear
    ///边界宽
    public lazy var xk_borderWidth: CGFloat = 0.5
    ///边界圆角
    public lazy var xk_cornerRadius: CGFloat = 4.0
    ///设置边距，上左下右统一用此边距
    public lazy var edgeMargin: CGFloat = 8.0
    ///选项增长
    public lazy var itemIncreasedSize: CGSize? = nil
    ///是否允许选中选项
    public var shouldSelectItem = false
    ///最大选择数，默认为1
    public lazy var maximumSelected = 1
    public lazy var selectedBackgroundColor = itemColor
    public lazy var selectedTextColor = textColor
    public lazy var selectedBorderColor = xk_borderColor
    public lazy var selectedBorderWidth = xk_borderWidth
    ///初始选择的下标，在只选择一个的时候有用
    public var defaultSelectIndex: Int? = nil
    
    ///上一个选中按钮
    private var lastButton: UIButton? = nil
    ///多选时，已选中的下标
    private lazy var selectedIndexes = [Int]()
    ///视图高度
    private lazy var viewHeight: CGFloat = 0.0
    private lazy var buttons = [UIButton]()
}

//MARK: - public
public extension XKTagsView {
    
    func xk_refreshView() {
        
        setNeedsLayout()
        layoutIfNeeded()
        
        frame.size.height = viewHeight
        
        setupSubViews()
    }
    
    func xk_viewHeight() -> CGFloat {
        return viewHeight
    }
    
    func xk_fetchSelectedIndexes() -> [Int]? {
        return selectedIndexes.map { index in
            return index - 100
        }
    }
}

//MARK: - private
extension XKTagsView {
    
    func setupSubViews() {
        
        var lastTag: UIButton? = nil
        
        buttons.forEach { button in
            button.isHidden = true
        }
        
        var tempButtons = buttons
        for (i, tag) in tags.enumerated() {
            
            let buttonTag = 100+i
            let tagButton: UIButton
            
            if buttons.count > i {
                tagButton = buttons[i]
            }
            else {
                tagButton = UIButton(type: .custom)
                addSubview(tagButton)
                tempButtons.append(tagButton)
                tagButton.tag = buttonTag
            }
            
            tagButton.isHidden = false
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapTag(_:)))
            tagButton.addGestureRecognizer(tapGesture)
            
            let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
            tagButton.addGestureRecognizer(longGesture)
            
            let textWidth = (tag as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: itemHeight), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font : font], context: nil).width
            
            var buttonWidth = textWidth + 2.0*edgeMargin
            
            if buttonWidth > frame.width {
                buttonWidth = frame.width
            }
            
            var buttonFrame: CGRect
            
            if let lastTag = lastTag {
                
                var lastMaxX = lastTag.frame.maxX
                var y = lastTag.frame.minY
                //超出范围
                if lastMaxX + itemSpacing > bounds.width {
                    y = lastTag.frame.maxY + lineSpacing
                    lastMaxX = 0.0
                }
                else {
                    lastMaxX += itemSpacing
                }
                
                if lastMaxX + buttonWidth > frame.width {
                    lastMaxX = 0.0
                    y = lastTag.frame.maxY + lineSpacing
                }
                
                buttonFrame = CGRect(x: lastMaxX, y: y, width: buttonWidth, height: itemHeight)
                
            }
            else {
                buttonFrame = CGRect(x: 0.0, y: 0.0, width: buttonWidth, height: itemHeight)
            }
            
            if let increaseSize = self.itemIncreasedSize {
                
                buttonFrame.size.width  = buttonFrame.width - 2.0*edgeMargin + increaseSize.width
                buttonFrame.size.height = buttonFrame.height + increaseSize.height
            }
            
            tagButton.frame = buttonFrame
            
            tagButton.setTitle(tag, for: .normal)
            tagButton.setTitleColor(textColor, for: .normal)
            tagButton.titleLabel?.font      = font
            tagButton.layer.borderColor     = xk_borderColor.cgColor
            tagButton.layer.borderWidth     = xk_borderWidth
            tagButton.layer.cornerRadius    = xk_cornerRadius
            tagButton.layer.backgroundColor = itemColor.cgColor
            
            if shouldSelectItem {
                
                if maximumSelected == 1 {
                    
                    if i == defaultSelectIndex {
                        
                        tagButton.setTitleColor(selectedTextColor, for: .normal)
                        tagButton.layer.backgroundColor = selectedBackgroundColor.cgColor
                        tagButton.layer.borderWidth     = selectedBorderWidth
                        tagButton.layer.borderColor     = selectedBorderColor.cgColor
                        
                        lastButton = tagButton
                    }
                    
                }
                else {
                    
                    if selectedIndexes.contains(buttonTag) {
                        
                        updateSelectedButton(tagButton)
                    }
                }
            }
            
            lastTag = tagButton
            
            delegate?.xk_tagsView(self, editTag: tagButton, atIndex: i)
        }
        
        let maxY          = (lastTag?.frame ?? CGRect.zero).maxY
        frame.size.height = maxY
        viewHeight        = maxY
        buttons           = tempButtons
    }
    
    func updateSelectedButton(_ button: UIButton) {
        
        button.setTitleColor(selectedTextColor, for: .normal)
        button.layer.backgroundColor = selectedBackgroundColor.cgColor
        button.layer.borderWidth     = selectedBorderWidth
        button.layer.borderColor     = selectedBorderColor.cgColor
    }
    
    @objc func tapTag(_ tap: UITapGestureRecognizer) {
        
        guard let button = tap.view as? UIButton else {
            return
        }
        
        guard shouldSelectItem else {
            delegate?.xk_tagsView(self, didSelectItemAtIndex: button.tag - 100)
            return
        }
        
        guard maximumSelected > 1 else {
            
            guard lastButton != button else {
                delegate?.xk_tagsView(self, didSelectItemAtIndex: button.tag - 100)
                return
            }
            
            button.setTitleColor(selectedTextColor, for: .normal)
            button.layer.backgroundColor = selectedBackgroundColor.cgColor
            button.layer.borderWidth     = selectedBorderWidth
            button.layer.borderColor     = selectedBorderColor.cgColor
            
            lastButton?.setTitleColor(textColor, for: .normal)
            lastButton?.layer.borderWidth     = xk_borderWidth
            lastButton?.layer.borderColor     = xk_borderColor.cgColor
            lastButton?.layer.backgroundColor = itemColor.cgColor
            
            lastButton = button
            
            delegate?.xk_tagsView(self, didSelectItemAtIndex: button.tag - 100)
            
            return
        }
        
        let exist = selectedIndexes.contains(button.tag)
        
        guard selectedIndexes.count != maximumSelected else {
            
            if let index = selectedIndexes.firstIndex(of: button.tag), exist {
                selectedIndexes.remove(at: index)
                xk_refreshView()
            }
            
            return
        }
        
        if let index = selectedIndexes.firstIndex(of: button.tag), exist {
            selectedIndexes.remove(at: index)
        }
        else {
            selectedIndexes.append(button.tag)
        }
        
        xk_refreshView()
    }
    
    @objc func longPress(_ longPregrss: UILongPressGestureRecognizer) {
        
        guard longPregrss.state == .began else {
            return
        }
        
        if let button = longPregrss.view as? UIButton {
            
            lastButton = button
            delegate?.xk_tagsView(self, didLongPressedItemAtIndex: button.tag - 100)
        }
    }
}
