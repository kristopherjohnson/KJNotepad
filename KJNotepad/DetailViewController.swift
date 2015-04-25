//
//  DetailViewController.swift
//  KJNotepad
//
//  Created by Kristopher Johnson on 4/24/15.
//  Copyright (c) 2015 Kristopher Johnson. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!

    var textChanged = false

    var detailItem: Note? {
        willSet {
            if textChanged {
                saveChanges()
            }
        }

        didSet {
            self.configureView()
        }
    }

    func configureView() {
        if let note = detailItem, textView = textView {
            textView.text = note.text
            textView.delegate = self
            textChanged = false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "keyboardWillChangeFrameNotification:",
            name: UIKeyboardWillChangeFrameNotification,
            object: nil)
    }

    override func viewWillDisappear(animated: Bool) {
        if textChanged {
            saveChanges()
        }
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.viewDidDisappear(animated)
    }

    func textViewDidChange(textView: UITextView) {
        textChanged = true
    }

    func saveChanges() {
        if let note = detailItem, textView = textView {
            note.text = textView.text
            note.lastEditedDate = NSDate()

            if !note.text.isEmpty {
                note.title = note.text // TODO: Use first line/paragraph
            }
            else {
                note.title = "(empty note)"
            }

            var error: NSError? = nil
            note.managedObjectContext?.save(&error)
            if let error = error {
                NSLog("Save error: %@", error.localizedDescription)
            }
            else {
                textChanged = false
            }
        }
    }

    func keyboardWillChangeFrameNotification(notification: NSNotification) {
        let n = KeyboardNotification(notification)
        let keyboardFrame = n.frameEndForView(self.view)
        let animationDuration = n.animationDuration
        let animationCurve = n.animationCurve

        let viewFrame = self.view.frame
        let newBottomOffset = viewFrame.maxY - keyboardFrame.minY

        self.view.layoutIfNeeded()
        UIView.animateWithDuration(animationDuration,
            delay: 0,
            options: UIViewAnimationOptions(rawValue: UInt(animationCurve << 16)),
            animations: {
                self.textViewBottomConstraint.constant = newBottomOffset
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }
}

