//
//  RegexAttributer.swift
//  RegexAttributer
//
//  Created by raja vijaya kumar on 11/10/20.
//

import Foundation

public protocol RegexAttributable {
	var regex: String { get }
	var attributes: Attributes { get }
	func generateTextRange(_ string: String) -> (String, String)
}

internal protocol RegexAttributerProtocol {
	func getAbsoluteText() -> [String]
	func getReplaceables() -> [String: String]
	func getAbsoluteValues() -> [String: String]
	func getGeneratedDifference() -> [Int]
	func getReplaceableRanges() -> [NSRange]
	func getReplacedString() -> String
	func getAttributes() -> Attributes
	func generateRangeTexts(adjustedRanges: [NSRange]) -> [NSRange: String]
}

extension RegexAttributerProtocol {
	func generateRangeTexts(adjustedRanges: [NSRange]) -> [NSRange: String] {
		let absoluteText = getAbsoluteText()
		guard adjustedRanges.count == absoluteText.count else {
			assertionFailure("URL Ranges and urls cannot mismatch")
			return [:]
		}
		var range: [NSRange: String] = [:]
		for i in 0..<adjustedRanges.count {
			range[adjustedRanges[i]] = absoluteText[i]
		}
		return range
	}
}

internal class RegexAttributer<T: Hashable & RegexAttributable>: RegexAttributerProtocol {
	
	private var string: String
	private var originalString: String
	private var textHightlightable: T
	
	private var absoluteText: [String] = []
	private var replaceables: [String: String] = [:]
	private var absoluteValues: [String: String] = [:]
	private var generatedDifference: [Int] = []
	private var replaceableRanges: [NSRange] = []
	
	private var replacedString: String = ""
	
	init(string: String, originalString: String, textHightlightable: T) {
		
		self.string = string
		self.originalString = originalString
		self.textHightlightable = textHightlightable
		
		generateTextReplaceables()
		generateReplaceableRanges()
		generateReplacedString()
	}
	
	internal func getAbsoluteText() -> [String] {
		return absoluteText
	}
	
	internal func getReplaceables() -> [String: String] {
		return replaceables
	}
	
	internal func getAbsoluteValues() -> [String: String] {
		return absoluteValues
	}
	
	internal func getGeneratedDifference() -> [Int] {
		return generatedDifference
	}
	
	internal func getReplaceableRanges() -> [NSRange] {
		return replaceableRanges
	}
	
	internal func getReplacedString() -> String {
		return replacedString
	}
	
	internal func getAttributes() -> Attributes {
		return textHightlightable.attributes
	}
	
	private func generateTextReplaceables() {
		do {
			let regex = try NSRegularExpression(pattern: textHightlightable.regex, options: .caseInsensitive)
			let urlResult = regex.matches(in: string, options: .withoutAnchoringBounds, range:  NSRange(string.startIndex..., in: string))
			for urlPattern in urlResult {
				guard let string = substring(with: urlPattern.range, string: string) else { continue }
				let (absoluteString, replaceableString) = self.textHightlightable.generateTextRange(String(string))
				absoluteText.append(absoluteString)
				replaceables[String(string)] = replaceableString
				absoluteValues[absoluteString] = replaceableString
				generatedDifference.append(string.count - replaceableString.count)
			}
		} catch let error {
			debugPrint("RegexAttributer: Generating Text Replaceable Error:\(error as Any)")
		}
	}
	
	private func generateReplaceableRanges() {
		do {
			let boldRegex = try NSRegularExpression(pattern: textHightlightable.regex, options: .caseInsensitive)
			let boldResult = boldRegex.matches(in: originalString, options: .withoutAnchoringBounds, range:  NSRange(originalString.startIndex..., in: originalString))
			for boldPattern in boldResult {
				replaceableRanges.append(boldPattern.range)
			}
		} catch let error {
			debugPrint("RegexAttributer: Generating Replaceable Ranges Error:\(error as Any)")
		}
	}
	
	private func generateReplacedString() {
		var replacedString = string
		for (key, value) in replaceables {
			replacedString = replacedString.replacingOccurrences(of: key, with: value)
		}
		self.replacedString = replacedString
	}
	
	private func substring(with nsrange: NSRange, string: String) -> String? {
		guard let range = Range(nsrange, in: string) else { return nil }
		return String(string[range])
	}
}
