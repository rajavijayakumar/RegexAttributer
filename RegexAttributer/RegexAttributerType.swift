//
//  RegexAttributerType.swift
//  RegexAttributer
//
//  Created by raja vijaya kumar on 11/10/20.
//

import UIKit

public enum RegexAttributerType: RegexAttributable {
	
	case bold(size: CGFloat)
	case highlight(size: CGFloat)
	case url
	
	
	// Delegate methods
	public var regex: String {
		switch self {
			case .bold:
				return "\\*\\*(?<X>.*?)\\*\\*"
			case .highlight:
				return "\\#(?<X>.*?).\\h"
			case .url:
				return "(\\[(?<X>.*?)\\])(\\()(http|https)?:\\/\\/([-\\w\\.]+)+(:\\d+)?(\\/([\\w|\\-\\/_\\.]*(\\?\\S+)?)?)?(\\))"
		}
	}
	
	public var attributes: [NSAttributedString.Key : Any] {
		switch self {
			case .bold(let size):
				return [.font: UIFont.boldSystemFont(ofSize: size)]
			case .highlight(let size):
				return [.font: UIFont.boldSystemFont(ofSize: size),
						.foregroundColor: UIColor.black]
			case .url:
				return [.foregroundColor: UIColor.blue,
						.underlineStyle: NSUnderlineStyle.thick.rawValue]
		}
	}
	
	public func generateTextRange(_ string: String) -> (String, String) {
		
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



fileprivate struct TextHightlighterHelper {
	
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
