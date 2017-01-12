## Toward a more useful keyboard

Steve Losh's [Modern Space Cadet][modern-space-cadet] is an inspiration.
It opened my eyes to the fact that there's a more useful keyboard hidden inside the vanilla QWERTY package that most of us have tolerated for all these years.
This repo represents my nascent quest to unleash that more useful keyboard.

At first, this might sound no different than the typical Emacs/Vim/\<Every-Other-Editor> tweakfest.
But it is.
I'm not talking about honing my editor-of-choice.
I'm not talking about pimping out my shell.
I want a more useful keyboard _everywhere_.
Whether I'm in my editor, in the terminal, in the browser, or in Keynote,
I want a more useful keyboard.

And ideally, I want the _same_ (more useful) keyboard in every app.
Ubiquitous keyboarding.
Muscle memory.
[Don't make me think][don't-make-me-think].

How do I go to the beginning of the line in this app?
The same way I go to the beginning of the line in _every_ app!
Don't make me think.

How do I go to the top of the file/screen/page in this app?
The same way I...
Well, you get the point.

## Some assembly required

In its current state, my more-useful keyboard is built on top of a few tools, and some custom keymappings for those tools (all of which are described below).
Where possible, this repo houses the configuration files that power my more-useful keyboard.
In the places where the customization requires manual steps, I describe those steps.

Below you'll find a step-by-step guide for building this more-useful keyboard from scratch.

## More useful (for me)

> **cus·tom·ize** (_verb_): to modify or build according to individual or personal specifications or preference [[dictionary.com][customize]]

Any customization is, by definition, personal.
While I find that these customizations yield a more-useful keyboard for me, they might not feel like a win for you.

These customizations currently provide a fraction of what I want from my more-useful keyboard.
I find it to be a very useful fraction, but I don't consider it complete by any means.

<a name="sierra-port"></a>:construction: **Work in progress to port to macOS Sierra** :construction: This customization previously relied heavily on [Karabiner](https://pqrs.org/osx/karabiner/). Karabiner does not currently work on macOS Sierra. Simply put, the tools available on Sierra lack the power and flexibility available in Karabiner. This branch represents an attempt to port my [pre-Sierra customizations](https://github.com/jasonrudolph/keyboard/blob/e19948b26cc569e41637d60a5357d1d2e46669eb/README.md#more-useful-for-me) to Sierra. Given the lack of Karabiner's power and flexibility, porting the previous functionality to Sierra will likely involve compromises. It's unlikely to be an exact port.

Here's what it provides so far:

- A more useful caps lock key
    - Tap **caps lock** for **escape**
    - Hold **caps lock** for **control**

- (S)uper (D)uper Mode

  To activate, push the **s** and **d** keys simultaneously and hold them down. Now you're in (S)uper (D)uper mode. It's like a secret keyboard _inside_ your keyboard. (Whoa.) It's optimized for keeping you on the home row, or very close to it. Now you can:

    - Use **h**/**j**/**k**/**l** for **up**/**down**/**left**/**right** respectively
    - Use **a** for **option** (AKA **alt**)
    - Use **f** for **command**
    - Use **space** for **shift**
    - Use **a** + **j**/**k** for **page up**/**page down**
    - Use **i**/**o** to move to the previous/next tab
    - Use **u**/**p** to go to the first/last tab (in most apps)
    - Use **a** + **h**/**l** to move to previous/next word (in most apps)

- Basic window management
    - **control** + **s**, **h**: Send window left (left half of screen)
    - **control** + **s**, **j**: Send window down (bottom half of screen)
    - **control** + **s**, **k**: Send window up (top half of screen)
    - **control** + **s**, **l**: Send window right (right half of screen)
    - **control** + **s**, **i**: Send window to upper left quarter of screen
    - **control** + **s**, **o**: Send window to upper right quarter of screen
    - **control** + **s**, **,**: Send window to lower left quarter of screen
    - **control** + **s**, **.**: Send window to lower right quarter of screen
    - **control** + **s**, **space**: Send window to center of screen
    - **control** + **s**, **enter**: Resize window to fill the screen
    - **control** + **s**, **n**: Send window to next monitor

- Markdown formatting
    - **control** + **m**, **b**: Wrap selected text in double asterisks ("B" for "Bold")
    - **control** + **m**, **i**: Wrap selected text in single asterisks ("I" for "Italic")
    - **control** + **m**, **s**: Wrap selected text in double tildes ("S" for "Strikethrough")
    - **control** + **m**, **l**: Convert the currently-selected text to an inline link, using a URL from the clipboard ("L" for "Link")

- Hyper key for quickly launching apps
    - Use **right option** key as **hyper** key
    - **hyper** + **a** to open iTunes ("A" for "Apple Music")
    - **hyper** + **b** to open Google Chrome ("B" for "Browser")
    - **hyper** + **c** to open Slack ("C for "Chat")
    - **hyper** + **d** to open Remember The Milk ("D" for "Do!" ... or "Done!")
    - **hyper** + **e** to open Atom Beta ("E" for "Editor")
    - **hyper** + **f** to open Finder ("F" for "Finder")
    - **hyper** + **g** to open Mailplane 3 ("G" for "Gmail")
    - **hyper** + **t** to open iTerm2 ("T" for "Terminal")

- Use **control** + **-**/**|** to split iTerm2 panes horizontally/vertically

- Use **control** + **h**/**j**/**k**/**l** to move left/down/up/right by one pane in iTerm2

- Use **control** + **u** to delete to the start of the line

- Use **option** + **h**/**l** to delete previous/next word

## Dependencies

This setup is honed and tested with the following dependencies.

- macOS Sierra, 10.12
- [Karabiner-Elements 0.90.76][karabiner]
- [Hammerspoon 0.9.52][hammerspoon]

## The Setup

### Grab the bits

```sh
git clone https://github.com/jasonrudolph/keyboard.git

cd keyboard

git checkout sierra

# Prepare custom settings for Karabiner-Elements
mkdir -p ~/.config/karabiner/
ln -s $PWD/karabiner/karabiner.json ~/.config/karabiner/karabiner.json

# Prepare custom settings for Hammerspoon
ln -s $PWD/hammerspoon ~/.hammerspoon

# Prepare custom settings for navigating between words in iTerm2
cat $PWD/inputrc >> ~/.inputrc
```

### Install the apps

- Install [Karabiner-Elements][karabiner]
- Install [Hammerspoon][hammerspoon-releases]
    1. Install it
    2. Launch it
    3. Configure it to launch at login
    4. Enable accessibility to allow Hammerspoon to do its thing [[screenshot]](screenshots/hammerspoon-accessibility-permissions.png)

### Put _control_ and _escape_ on the home row

#### Goals

- Tap **caps lock** for **escape**
- Hold **caps lock** for **control**
- Access the default **caps lock** behavior in those rare cases where it's helpful

#### Making it happen

_TODO_: Update this section for macOS Sierra port.

### Make navigation accessible via the the home row

#### Goals

- Enable navigation (up/down/left/right) via the home row
- Enable word navigation (option+left/right) via the home row
- Enable other commonly-used actions on or near the home row

#### Making it happen

_TODO_: Update this section for macOS Sierra port.

### Control window management from the home row

#### Goals

- Quickly arrange and resize windows in common configurations, using keyboard
  shortcuts that are on or near the home row

#### Making it happen

_TODO_: Update this section for macOS Sierra port.

### Format text as Markdown

#### Goals

- Perform common Markdown-formatting tasks anywhere that you're editing text
  (e.g. in a GitHub comment, in your editor, in your email client)

#### Making it happen

_TODO_: Port this functionality to macOS Sierra.

## TODO

- Add "goals" section for "Hyper" key
- Add `./script/setup` command to automate the manual setup steps

[customize]: http://dictionary.reference.com/browse/customize
[don't-make-me-think]: http://en.wikipedia.org/wiki/Don't_Make_Me_Think
[karabiner]: https://github.com/tekezo/Karabiner-Elements
[hammerspoon]: http://www.hammerspoon.org
[hammerspoon-releases]: https://github.com/Hammerspoon/hammerspoon/releases
[modern-space-cadet]: http://stevelosh.com/blog/2012/10/a-modern-space-cadet
[modern-space-cadet-key-repeat]: http://stevelosh.com/blog/2012/10/a-modern-space-cadet/#controlescape
