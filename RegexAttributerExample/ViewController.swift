//
//  ViewController.swift
//  RegexAttributerExample
//
//  Created by raja vijaya kumar on 11/10/20.
//

import UIKit
import RegexAttributer

class ViewController: UIViewController {

	@IBOutlet weak var textView: UITextView!
	@IBOutlet weak var label: UILabel!
	
	var regexManager: RegexAttributerManager<RegexAttributerType>!
	override func viewDidLoad() {
		super.viewDidLoad()
		let string = "This is an **Example** for regex and making the regex attributed string. [Here](https://www.google.com/) is a link embedded where **clicking on it** revels the Corresponding URL. [Clicking Here](http://www.youtube.com) will reveal another url #Easier_Regex_Management using **RegexAttributer**"
		let initialAttr: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 18), .foregroundColor: UIColor.black]
		self.regexManager = RegexAttributerManager<RegexAttributerType>(string: string, textHighlightable: [.bold, .url, .highlight], initialAttributes: initialAttr)
		self.textView.attributedText = regexManager.getAttributedString()
		let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapDescriptionTextView(_:)))
		textView.addGestureRecognizer(gesture)
	}


	@objc
	func didTapDescriptionTextView(_ gesture: UITapGestureRecognizer) {
		guard let range = self.regexManager.getTextRanges(for: .url) else { return }
		for (range, url) in range {
			guard gesture.didTapAttributedTextInLabel(label: textView, inRange: range) else { continue }
			self.label.text = url
		}
	}
}

enum RegexAttributerType: RegexAttributable {
	
	case bold, highlight, url
	
	var regex: String {
		switch self {
			case .bold:
				return "\\*\\*(?<X>.*?)\\*\\*"
			case .highlight:
				return "\\#(?<X>.*?).\\h"
			case .url:
				return "(\\[(?<X>.*?)\\])(\\()(http|https)?:\\/\\/([-\\w\\.]+)+(:\\d+)?(\\/([\\w|\\-\\/_\\.]*(\\?\\S+)?)?)?(\\))"
		}
	}
	
	var attributes: [NSAttributedString.Key : Any] {
		switch self {
			case .bold:
				return [.font: UIFont.boldSystemFont(ofSize: 18)]
			case .highlight:
				return [.font: UIFont.boldSystemFont(ofSize: 18),
						.foregroundColor: UIColor.darkGray]
			case .url:
				return [.foregroundColor: UIColor.blue,
						.underlineStyle: NSUnderlineStyle.thick.rawValue]
		}
	}
	
	func generateTextRange(_ string: String) -> (String, String) {
		
		switch self {
			case .bold:
				var boldString = string
				boldString.removeFirst(2)
				boldString.removeLast(2)
				return (boldString, boldString)
			case .highlight:
				return (string, string)
			case .url:
				let splitedUrl = TextHightlighterHelper().splitUrl(from: string)
				return (splitedUrl.absoluteUrl, splitedUrl.prefix)
		}
	}
}

struct TextHightlighterHelper {
	
	func splitUrl(from string: String) -> (prefix: String, absoluteUrl: String) {
		let urlPrefixRegex = "(\\[(?<X>.*?)\\])"
		let urlRegex = "(http|https)?:\\/\\/([-\\w\\.]+)+(:\\d+)?(\\/([\\w|\\-\\/_\\.]*(\\?\\S+)?)?)?"
		var finalResultPrefix: String = ""
		var finalResultUrl: String = ""
		do {
			let prefixRegex = try NSRegularExpression(pattern: urlPrefixRegex, options: .caseInsensitive)
			let prefixResult = prefixRegex.matches(in: string, options: .withoutAnchoringBounds, range: NSRange(string.startIndex..., in: string))
			for prefix in prefixResult {
				guard var prefixString = string.substring(with: prefix.range) else { continue }
				prefixString.removeFirst()
				prefixString.removeLast()
				finalResultPrefix = String(prefixString)
			}
			
			let urlRegexS = try NSRegularExpression(pattern: urlRegex, options: .caseInsensitive)
			let urlResult = urlRegexS.matches(in: string, options: .withoutAnchoringBounds, range: NSRange(string.startIndex..., in: string))
			for url in urlResult {
				guard let urlString = string.substring(with: url.range) else { continue }
				finalResultUrl = String(urlString)
			}
			return (finalResultPrefix, finalResultUrl)
		} catch let error {
			print("REGEX ERROR MINI: \(error)")
			return ("", "")
		}
	}
}

fileprivate extension String {
	func substring(with nsrange: NSRange) -> Substring? {
		guard let range = Range(nsrange, in: self) else { return nil }
		return self[range]
	}
}


extension UITapGestureRecognizer {
	
	func didTapAttributedTextInLabel(label: UITextView, inRange targetRange: NSRange) -> Bool {
		let mutableAttribString = NSMutableAttributedString(attributedString: label.attributedText)
		let textStorage = NSTextStorage(attributedString: mutableAttribString)
		let layoutManager = NSLayoutManager()
		textStorage.addLayoutManager(layoutManager)
		let textContainer = NSTextContainer(size: label.frame.size)
		textContainer.lineFragmentPadding = 5
		layoutManager.addTextContainer(textContainer)
		let index = layoutManager.characterIndex(for: self.location(in: label), in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
		return NSLocationInRange(index, targetRange)
	}
	
}
