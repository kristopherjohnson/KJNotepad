//
//  DetailViewController.swift
//  KJNotepad
//
//  Created by Kristopher Johnson on 4/24/15.
//  Copyright (c) 2015 Kristopher Johnson. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView?
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint?

    var detailItem: Note? {
        willSet {
            saveChanges()
        }

        didSet {
            self.configureView()
        }
    }

    func configureView() {
        if let note = detailItem, textView = textView {
            textView.text = note.text
            textView.delegate = self
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

        if let note = detailItem, textView = self.textView {
            if note.text.isEmpty {
                textView.becomeFirstResponder()
            }
        }
    }

    override func viewWillDisappear(animated: Bool) {
        saveChanges()
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.viewDidDisappear(animated)
    }

    func textViewDidChange(textView: UITextView) {
        if let note = detailItem {
            note.text = textView.text
            note.lastEditedDate = NSDate()
        }
    }

    func saveChanges() {
        if let note = detailItem, context = note.managedObjectContext {
            if context.hasChanges {
                // Update title
                if !note.text.isEmpty {
                    note.title = note.text // TODO: Use first line/paragraph
                }
                else {
                    note.title = "(empty note)"
                }

                var error: NSError? = nil
                context.save(&error)
                if let error = error {
                    NSLog("Save error: %@", error.localizedDescription)
                }
            }
        }
    }

    func keyboardWillChangeFrameNotification(notification: NSNotification) {
        // Update the constraint for the bottom edge of the text view
        if let textView = self.textView, bottomConstraint = self.textViewBottomConstraint {
            let n = KeyboardNotification(notification)
            let keyboardFrame = n.frameEndForView(self.view)
            let animationDuration = n.animationDuration
            let animationCurve = n.animationCurve

            let newBottomOffset = textView.frame.maxY - keyboardFrame.minY

            self.view.layoutIfNeeded()
            UIView.animateWithDuration(animationDuration,
                delay: 0,
                options: UIViewAnimationOptions(rawValue: UInt(animationCurve << 16)),
                animations: {
                    bottomConstraint.constant = newBottomOffset
                    self.view.layoutIfNeeded()
                },
                completion: nil
            )
        }
    }
}

