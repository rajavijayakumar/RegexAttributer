//
//  RegexAttributerManager.swift
//  RegexAttributer
//
//  Created by raja vijaya kumar on 11/10/20.
//

import Foundation

open class RegexAttributerManager<T: Hashable & RegexAttributable> {
	
	struct TextRendererGrouper {
		var range: NSRange
		var hightlightner: Dictionary<T, RegexAttributerProtocol>.Element
		var difference: Int
	}
	
	private var string: String
	private var textHighlightable: Set<T>
	private var attributedString: NSMutableAttributedString = NSMutableAttributedString()
	
	private var hightLightnersDict: [T: RegexAttributerProtocol] = [:]
	private var rawRanges: [T: [NSRange]] = [:]
	private var textRanges: [T: [NSRange: String]] = [:]
	
	public init(string: String, textHighlightable: Set<T>, initialAttributes: Attributes = [:]) {
		self.string = string
		self.textHighlightable = textHighlightable
		
		let (hightLightnersDict, replacedString) = getHightlightnerAndReplacedString(for: textHighlightable, string: string)
		
		self.hightLightnersDict = hightLightnersDict
		self.attributedString = NSMutableAttributedString(string: replacedString, attributes: initialAttributes)
		self.adjustReplaceableRanges()
		self.generateTextRanges()
	}
	
	public func getAttributedString() -> NSAttributedString {
		return attributedString
	}
	
	public func getTextRanges(for key: T) -> [NSRange: String]? {
		return textRanges[key]
	}
	
	public func getAbsoluteValues(for key: T) -> [String: String]? {
		return hightLightnersDict[key]?.getAbsoluteValues()
	}
	
	private func adjustReplaceableRanges() {
		
		var textRendererGrouper: [TextRendererGrouper] = getTextRendererGroupers()
		textRendererGrouper.sort(by: { $0.range.location < $1.range.location })
		var count = 0
		var sumOfDifferences = 0
		
		while count < textRendererGrouper.count {
			
			let grouper = textRendererGrouper[count]
			textRendererGrouper[count].range.location -= sumOfDifferences
			textRendererGrouper[count].range.length -= grouper.difference
			
			addAttr(range: textRendererGrouper[count].range, attr: grouper.hightlightner.value.getAttributes())
			setRawRange(for: grouper, range: textRendererGrouper[count].range)
			
			sumOfDifferences += grouper.difference
			count += 1
		}
	}
	
	private func generateTextRanges() {
		for (key, value) in rawRanges {
			textRanges[key] = hightLightnersDict[key]?.generateRangeTexts(adjustedRanges: value)
		}
	}
	
	private func addAttr(range: NSRange, attr: Attributes) {
		guard (range.location + range.length) <= attributedString.string.count else { return }
		attributedString.addAttributes(attr, range: range)
	}
	
	private func getHightlightnerAndReplacedString(for hightlights: Set<T>, string: String) -> (dict: [T: RegexAttributerProtocol], replacedString: String) {
		var hightLightnersDict: [T: RegexAttributerProtocol] = [:]
		var replacedString = string
		for highLights in hightlights {
			let hightLights = RegexAttributer<T>(string: replacedString, originalString: string, textHightlightable: highLights)
			replacedString = hightLights.getReplacedString()
			hightLightnersDict[highLights] = hightLights
		}
		return (hightLightnersDict, replacedString)
	}
	
	private func setRawRange(for grouper: TextRendererGrouper, range: NSRange) {
		if var ranges = self.rawRanges[grouper.hightlightner.key] {
			ranges.append(range)
			self.rawRanges[grouper.hightlightner.key] = ranges
		} else {
			self.rawRanges[grouper.hightlightner.key] = [range]
		}
	}
	
	private func getTextRendererGroupers() -> [TextRendererGrouper] {
		var textRendererGrouper: [TextRendererGrouper] = []
		for (key, textHightlightner) in hightLightnersDict {
			let replaceableRanges = textHightlightner.getReplaceableRanges()
			let generatedDifference = textHightlightner.getGeneratedDifference()
			for i in 0..<replaceableRanges.count {
				let range = replaceableRanges[i]
				let difference = generatedDifference[i]
				textRendererGrouper.append(TextRendererGrouper(range: range, hightlightner: (key: key, value: textHightlightner), difference: difference))
			}
		}
		return textRendererGrouper
	}
}


