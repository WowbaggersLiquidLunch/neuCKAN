# Contributing

Thanks for your interest in contributing to neuCKAN! Currently, neuCKAN is far from complete, but with your help, we can progress it to beta and stable releases much faster. Here's how you can help.

---

### Table of Contents

- [Contribution Workflow](#contribution-workflow)
- [Some Guidellines](#some-guidelines)
	- [UI/UX Guidelines](#ui/ux-guidelines)	
	- [Technical Guidelines](#technical-guidelines)
	- [Styling Guidelines](#styling-guidelines)
- [Current Structure](#current-structure)

---

During this alpha phase, if you plan on doing any work, please check the [_Help, please..._](README.md#help,-please...) section on [`README.md`](README.md). It details some important features that I'm not able to implement by myself, and some bugs that I'm not able to fix, as well as some areas of the codebase that I seek improvements for from the community. In addition, for any contribution you plan to make, other than a quick bug or typo fix, please also open an issue about it first. Not only does this make it easier to track progress, it also prevents people doing duplicate work, as well as allows for the community to weigh in on the implementation of a feature before it's already all coded up. Nothing's more sad than having to go back and delete or rewrite code because of a misunderstanding in how it would fit into neuCKAN :(

## Contribution Workflow

neuCKAN follows the standard fork/commit/pull request process for integrating changes. If you have something that you're interested in working on:

1. Fork and clone the repository
2. Make sure you are using the [latest public version of Xcode](https://itunes.apple.com/us/app/xcode/id497799835); neuCKAN may build with another version but this is not guaranteed.
3. Commit your changes, test them, push to your repository.
4. Submit a pull request against WowbaggersLiquidLunch//neuCKAN's `develop` branch.

Some tips for your pull request:

- If you found `develop` has been updated before your change was merged, you can rebase in the new changes before opening a pull request:
```console
$ git rebase upstream/develop
```
- Please submit separate pull requests for different features; i.e. try not to shove multiple, unrelated changes into one pull request.
- Please make sure the pull request only contains changes that you've made intentionally; if you didn't mean to touch a file, you should probably not include it in your commit. Here are some files that like to have spurious changes in them:
	- `project.pbxproj`: This file may change if you sign the project with a different developer account. Changes due to adding or removing files are OK, generally.
	- `.xib` and `.storyboard` files: Please discard changes to an `xib` file if you didn't change anything in it.

## Some Guidelines

In general, ["being consistent is better than being right. You will experience fewer problems in the long run if you choose an approach and always stick with it."](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/AnatomyofaConstraint.html#//apple_ref/doc/uid/TP40010853-CH9-SW1)

### UI/UX Guidelines

- neuCKAN is designed for modern versions of macOS.
	- Stay consistent with the [macOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos/).
	- Stay consistent with behaviors of the macOS built-in applications, except in certain exceptional cases.
- User interface and user experience is important.
	- Use animations for UI items, if possible.
	- Use the proper system font weight, size and color.
	- Leave margins everywhere.
- Give users more choices when possible.

### Technical Guidelines

- Use the [Model-View-Controller design pattern](https://developer.apple.com/library/archive/documentation/General/Conceptual/DevPedia-CocoaCore/MVC.html) on the application-level.
- Follow [Swift's API Design Guidelines](https://swift.org/documentation/api-design-guidelines/).
- Follow [Apple Style Guide](https://help.apple.com/applestyleguide/)
- Use SwiftUI for UI if possible. As SwiftUI's coverage of AppKit grows, neuCKAN will switch as many UI components as possible to SwiftUI.
- Add comments when necessary.
- Add documentation comments for everything that has a caller, unless its purpose is plainly obvious.

### Styling Guidelines

- Prefer tabs for indentation.
- Use a trailing tab after `//` and `///`, and a full stop `.` after each sentence.
- For documentation comments, prioritise consistency in style with surrounding context. However, in general, prefer
	```
	/**
	This style.
	
	For documentation with multiple lines.
	*/
	```
	and
	```
	///	This style for documentation with a single line.
	```
- Avoid hard-wraps in comments. Use soft-wraps.

## Current Structure

_to be updated with class diagrams_

## Tips for Newbies

Development on Xcode has a super steep learning curve. Fortunately, here are some very well-written resources that can help you get started.

1. To learn Swift:
	- Read _the Swift Programming Language_ [online](https://swift.org/documentation/#the-swift-programming-language), or [on Apple Books](https://books.apple.com/us/book/the-swift-programming-language-swift-5-2/id881256329).
	- Check out [these additional official resources](https://developer.apple.com/swift/resources/).
	- Read [Swift Evolution proposals](https://developer.apple.com/swift/resources/) to keep up with the latest development in Swift.
	- Hang out on [Swift Forums](https://forums.swift.org).
2. To learn SwiftUI:
	- Do [Apple's SwiftUI tutorial](https://developer.apple.com/tutorials/SwiftUI/tutorials).
	- Read [what SwiftUI Lab found out through trial-and-error](https://swiftui-lab.com).
3. To learn Cocoa programming:
	- Read [AppKit's documentation](https://developer.apple.com/documentation/appkit).
	- Follow [this series of tutorials on AppCoda](https://www.appcoda.com/macos-programming/).
4. To learn Xcode and Interface Builder:
	- Read [Xcode's manual](https://help.apple.com/xcode/mac/current/index.html). This manual is also accessible through Xcode's help menu.
	- Read [Xcode's documentation](https://developer.apple.com/documentation/xcode).
	- Read [Auto Layout Guide](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/AutolayoutPG/index.html).
5. To learn some interesting, niche thingies on Swift, Cocoa, and Xcode in general: 
	- Check out [NSHipster](https://nshipster.com).

## Caveat

I copied a large part of this document from the [IINA project's](https://github.com/iina/iina/blob/develop/CONTRIBUTING.md), because I'm lazy.
