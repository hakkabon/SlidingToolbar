# SlidingToolbar
A sliding toolbar written for iOS in Swift. A toolbar that can be attached to either side of a view - left or right.  The toolbar is hidden or revealed by swiping the finger over the right and left side edges of the screen.  
![sliding tollbar looks like this](https://github.com/hakkabon/Assets/blob/master/slidetoolbar.gif)


## Import Statement
First, add an import statement for *SlidingToolbar* like so:

```swift
import UIKit
import SlidingToolbar
```

## Toolbar buttons
Fill a toolbar with a bunch of toolbar buttons. Buttons can be grouped into units of buttons by adding a separator item in between.  The below example shows 5 toolbar buttons, and 2 separators.

```swift

let lbutton1 = ToolbarButton(image: UIImage(named:"Icon-Light")!)
let lbutton2 = ToolbarButton(image: UIImage(named:"Icon-Plus")!)
let separator1 = ToolbarButton(separator: Separator())
let lbutton3 = ToolbarButton(image: UIImage(named:"Icon-Settings")!)
let lbutton4 = ToolbarButton(image: UIImage(named:"Icon-Microphone")!)
let separator2 = ToolbarButton(separator: Separator())
let lbutton5 = ToolbarButton(image: UIImage(named:"Icon-Trashcan")!)

self.leftToolbar = SlidingToolbar(parent: self, attachedTo: .left, withOffsets: [0.1, 1])
self.leftToolbar?.buttons = [ lbutton1, lbutton2, separator1, lbutton3, lbutton4, separator2, lbutton5 ]
self.leftToolbar?.delegate = self
self.leftToolbar?.title = "Left Toolbar"

```
## Actions 
Attach a method to each toolbar button by assigning a closure to the action method of the toolbar button.

```swift

lbutton1.action = { print("button (1) tapped") }
lbutton2.action = { /* do sothing meaningful here ... */ }
lbutton3.action = { /* do sothing meaningful here ... */ }
lbutton4.action = { /* do sothing meaningful here ... */ }
lbutton5.action = { /* do sothing meaningful here ... */ }

```
## Sample App
There is demo project available at [SlidingToolbar-Demo ](https://github.com/hakkabon/SlidingToolbar-Demo)  with sample code explaining the use of the component.  

## License
MIT
