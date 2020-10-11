# RegexAttributer

RegexAttributer is a simple, light weight attributed string generator based on the given regular expression. 

As mobile developers we may have needed to perform regex validation on a string and give some other attributes for that particular match alone in our projects. (i.e):- This should be rendered as ##Bold##. -> This should be renderd as **Bold**.

And sometimes we may need to add some action based on the regex highlighted string we have rendered.
(i.e):- {Click Here}(https://www.google.com) to view the website. -> [Click Here](https://www.google.com) to view the website.

This is where RegexAttributer comes in handy.

## Usage

```swift
import RegexAttributor

// Confirm to RegexAttributable protocol for enums, structs or classes. It should also confirm to Hashable Protocol

enum RegexAttributerType: RegexAttributable {
	
	case bold, highlight, url
	
	var regex: String {
		switch self {
			
			// **Bold**
			case .bold:
				return "\\*\\*(?<X>.*?)\\*\\*"
				
			// #Highlighter
			case .highlight:
				return "\\#(?<X>.*?).\\h"
				
			// [Click Here](https://www.google.com/)
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
	
  // Here provide the function with your own logic on how will your regex matched string should be replaced and what should be the string retrived if 
  // any action is to be given for the rendered text.
  // (i.e):- Take URL for example
  // [Click Here](https://www.google.com/) is the match found for our Regex
  // we should replace 'Click Here' and store the url to perform any action when 'Click Here' is tapped
  // So perform your logic and return the replaced string in #1 tuple parameter and the url in #2 tuple parameter
	func generateTextRange(_ string: String) -> (String, String) {
		
		switch self {
			
			// **Bold** -> (Bold, Bold)
			case .bold:
				var boldString = string
				boldString.removeFirst(2)
				boldString.removeLast(2)
				return (boldString, boldString)
				
			// #Highlight -> (#Highlight, #Highlight)
			case .highlight:
				return (string, string)
			
			// [Click Here](https://www.google.com/) -> (Click Here, https://www.google.com/)
			// Click Here will be replaced in place of this regex and the url will be available in two places
			// RegexAttributerManager.getTextRanges(for key:) [NSRange(location: 0, length: 10): "https://www.google.com/"]
			// RegexAttributerManager.getAbsoluteValues(for key:) ["https://www.google.com/": "Click Here"]
			case .url:
				let splitedUrl = TextHightlighterHelper().splitUrl(from: string)
				return (splitedUrl.absoluteUrl, splitedUrl.prefix)
		}
	}
}
```

After confirming to the type you can create RegexAttributerManager instance

```swift 

let string = "This is an **Example** for regex and making the regex attributed string. [Here](https://www.google.com/) is a link embedded where **clicking on it** revels the Corresponding URL. [Clicking Here](http://www.youtube.com) will reveal another url #Easier_Regex_Management using **RegexAttributer**"

let initialAttr: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 18), .foregroundColor: UIColor.black]
let regexManager = RegexAttributerManager<RegexAttributerType>(string: string, textHighlightable: [.bold, .url, .highlight], initialAttributes: initialAttr)
let textView = UITextView()
textView.attributedText = regexManager.getAttributedString()

// regexManager.getTextRanges(for: .url) gives
// [{69, 4}: "https://www.google.com/", {144, 13}: "http://www.youtube.com"]

// regexManager.getAbsoluteValues(for: .url)
// ["http://www.youtube.com": "Clicking Here", "https://www.google.com/": "Here"]

```

# Installation Guide

RegexAttributor is available in Cocoapods. Add this to your podfile

```rb

use_frameworks!

	pod 'RegexAttributer'
  
end

```

and run pod install.

## License

RegexAttributer is released under an MIT license. See [License.md](https://github.com/rajavijayakumar/RegexAttributer/blob/main/LICENSE) for more information.
