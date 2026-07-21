# macOS Ergonomics and Finder Setup

**Reviewed:** July 21, 2026

A productive setup includes more than packages. Finder view, pointer behavior,
keyboard repeat, window tiling, screenshots, the Dock, and accessibility options
can have a larger daily effect than another command-line utility.

These settings remain separate from the bootstrap because they depend on the
person, pointing device, display, accessibility needs, and established muscle
memory. This guide prefers supported System Settings and Finder controls over
undocumented `defaults` keys copied from old setup posts.

## A practical starting profile

Use this as a review checklist, not as a universal optimum:

- Finder opens the home folder in List view.
- List view shows Name, Date Modified, Size, and Kind.
- Filename extensions, the path bar, and the status bar are visible.
- Folders stay above files when sorting by name.
- Mouse or trackpad tracking is moved toward the faster half of the slider.
- Pointer acceleration is tested both on and off with the actual mouse.
- Secondary click is enabled.
- Trackpad users consider Tap to Click and Three Finger Drag.
- Key repeat is faster and Delay Until Repeat is shorter, subject to comfort.
- Keyboard navigation is enabled when keyboard-first UI control is useful.
- The Dock is reduced or auto-hidden, and recent-app suggestions are reviewed.
- Built-in window tiling is configured before adding a window-manager app.
- Screenshots save to a dedicated folder instead of accumulating on the Desktop.

Change one area at a time. A setting is only an improvement when it remains
comfortable after ordinary work, not merely during a thirty-second test.

## Finder: make List view the normal view

Apple supports per-folder view settings plus a **Use as Defaults** action. There
is not one literal “force every existing folder forever” switch: folders can
retain their own saved view overrides.

1. Open Finder and select a representative folder such as your home folder.
2. Press **Command-2** or choose **View > as List**.
3. Press **Command-J** or choose **View > Show View Options**.
4. Select **Always open in List View** for that folder.
5. Select **Browse in List View** when its subfolders should inherit the view.
6. Choose the columns, text size, icon size, relative dates, and sort order.
7. Click **Use as Defaults** to apply the List-view configuration to other folders
   that use the default for that view.

Apple documents that a subfolder with its own **Always open in** or **Browse in**
selection can continue opening differently. Open that folder's View Options and
clear its override when needed.

See [Change how folders are displayed in Finder](https://support.apple.com/guide/mac-help/change-how-folders-are-displayed-mchldaafb302/mac).

### Suggested List-view columns

A useful general set is:

- Name;
- Date Modified;
- Size;
- Kind;
- Date Added for Downloads or intake folders;
- iCloud Status when iCloud Drive state matters.

More columns are not automatically better. Keep the window readable on the
actual display and resize the most useful columns first.

### Sorting and grouping

Finder preserves sorting and arranging choices for folders. Common choices:

- sort source and project folders by Name;
- sort Downloads by Date Added or Date Modified;
- avoid grouping when a simple continuous list is easier to scan;
- use Finder's **Keep folders on top** setting when sorting by Name.

See [Sort and arrange items in Finder](https://support.apple.com/guide/mac-help/sort-and-arrange-items-in-the-finder-on-mac-mchlp1745/mac).

## Finder settings worth reviewing

Open **Finder > Settings**.

### General

- **New Finder windows show**: Home is a useful general default; choose Downloads,
  Desktop, or another folder only when it is genuinely the normal starting point.
- **Open folders in tabs instead of new windows**: choose based on whether one
  window or several independent windows fits the workflow.
- **Show these items on the desktop**: avoid visual clutter unless mounted disks
  or connected servers need to be obvious.

Apple documents these controls in
[Change Finder settings](https://support.apple.com/guide/mac-help/change-finder-settings-mchlp2803/mac).

### Sidebar

Show only locations used often, then drag them into a useful order. Common items
include:

- the home folder;
- Downloads, Documents, and Desktop;
- a development folder such as `~/Developer` or `~/Code`;
- iCloud Drive when used;
- connected servers or external disks when relevant.

A sidebar item is an alias; adding or removing it does not move the original.
See [Customize the Finder sidebar](https://support.apple.com/guide/mac-help/customize-the-finder-sidebar-on-mac-mchl83c9e8b8/mac).

### Advanced

Review:

- **Show all filename extensions**;
- **Show warning before changing an extension**;
- **Show warning before removing from iCloud Drive**;
- **Show warning before emptying the Trash**;
- **Keep folders on top in windows when sorting by name**;
- **When performing a search**: search the current folder when that matches your
  normal workflow, or the entire Mac when broad search is more useful.

Showing extensions makes file types explicit and is already included in the
repository's narrow preference script. Apple documents the supported setting in
[Show or hide filename extensions](https://support.apple.com/guide/mac-help/show-or-hide-filename-extensions-on-mac-mchlp2304/mac).

## Finder bars and previews

In Finder's **View** menu, consider:

- **Show Path Bar**: displays the location hierarchy and supports copying a path;
- **Show Status Bar**: shows item counts and available storage context;
- **Show Preview**: useful for images and documents, but consumes horizontal space;
- **Show Sidebar** and **Show Toolbar**: usually useful unless a minimal window is
  preferred.

The existing `scripts/macos-defaults.sh` can show the path bar and status bar,
but the supported Finder menu remains the clearest manual path.

## Mouse: tracking speed and acceleration

Open **System Settings > Mouse > Point & Click**.

1. Move **Tracking speed** toward the faster half of the slider.
2. Test precise selection, text editing, large pointer movement, and multiple
   displays—not only one quick sweep.
3. Open **Advanced** and test **Pointer acceleration** both on and off.

Current macOS exposes pointer acceleration as a supported setting. With
acceleration on, a fast physical movement moves the pointer farther while a slow
movement remains more precise. Some people prefer that behavior; others prefer a
more linear relationship, especially with a conventional mouse.

Apple documents these controls in
[Change mouse or trackpad tracking, double-click, and scrolling speed](https://support.apple.com/guide/mac-help/change-mouse-or-trackpad-tracking-double-click-and-scrolling-speed-mchlp1138/mac).

### Scroll and double-click speed

Open **System Settings > Accessibility > Pointer Control**.

- Adjust **Double-click speed** when clicks are being missed or mistaken.
- Open **Mouse Options** or **Trackpad Options** to adjust scrolling speed.

Do not make a value faster merely because a setup guide calls it faster. The
correct value avoids strain and accidental input with the actual hardware.

### When a mouse utility is justified

The built-in controls should be tried first. Consider one additional utility only
for a requirement macOS does not meet:

- [LinearMouse](https://linearmouse.app/) for per-device pointer, acceleration,
  scrolling, and button behavior;
- [Mos](https://mos.caldis.me/) mainly for smooth scrolling or independent mouse
  and trackpad scroll direction;
- [SteerMouse](https://plentycom.jp/en/steermouse/) for deep third-party mouse
  button, wheel, chord, and cursor configuration;
- [BetterMouse](https://better-mouse.com/) for third-party mouse acceleration,
  scrolling, and button features.

Run one owner for pointer and scrolling behavior. Multiple input utilities can
fight over the same events and make troubleshooting difficult. These applications
may request Accessibility or Input Monitoring permissions.

## Trackpad

Open **System Settings > Trackpad** and review the demonstrations rather than
enabling every gesture.

### Point & Click

- **Tracking speed**;
- click pressure and Quiet Click where available;
- **Secondary click**—two-finger click is a common choice;
- **Tap to click** when light touch is more comfortable;
- Force Click and data-detector gestures only when they are useful rather than
  accidental.

### Scroll & Zoom

- decide whether **Natural scrolling** matches existing muscle memory;
- keep pinch, smart zoom, and rotate only when used.

### More Gestures

- swipe between pages;
- swipe between full-screen applications or Spaces;
- Mission Control;
- App Exposé;
- Show Desktop;
- Notification Center.

Apple documents current options in
[Change Trackpad settings](https://support.apple.com/guide/mac-help/change-trackpad-settings-mchlp1226/mac)
and [Use Multi-Touch gestures](https://support.apple.com/102482).

### Three Finger Drag

Three Finger Drag can reduce click-and-hold strain:

1. Open **System Settings > Accessibility > Pointer Control**.
2. Open **Trackpad Options**.
3. Turn on trackpad dragging.
4. Select **Three Finger Drag**.

See [Turn on three finger drag](https://support.apple.com/102341).

## Keyboard speed and navigation

Open **System Settings > Keyboard**.

### Key repeat

Review:

- **Key repeat rate**: move toward Fast when navigation and deletion feel slow;
- **Delay until repeat**: move toward Short when you want held keys to repeat sooner.

Test ordinary prose and code. An extremely short delay can create accidental
repeated characters.

Apple documents these controls in
[Keyboard settings](https://support.apple.com/guide/mac-help/keyboard-settings-kbdm162/mac).

### Keyboard navigation

Enable **Keyboard navigation** when Tab and Shift-Tab should move among controls.
For a fuller keyboard-only interface, review **System Settings > Accessibility >
Keyboard > Full Keyboard Access**.

Apple documents the commands and tradeoffs in
[Navigate using Full Keyboard Access](https://support.apple.com/guide/mac-help/use-full-keyboard-access-mchlc06d1059/mac).

### Shortcuts and function keys

Review:

- Spotlight and launcher shortcuts;
- screenshots;
- Mission Control and Spaces;
- input sources;
- application shortcuts;
- whether F1, F2, and other keys act as standard function keys.

Do this after choosing launchers, window managers, editors, and terminals so the
same shortcut is not assigned to several owners.

### Advanced remapping

Use [Karabiner-Elements](https://karabiner-elements.pqrs.org/docs/) only when a
hardware or layout problem cannot be solved by supported Keyboard settings. Its
low-level remapping and permissions deserve reviewed, version-controlled rules.

## Dock, Desktop, Mission Control, and windows

Open **System Settings > Desktop & Dock**.

### Dock

Consider:

- reduce Dock size;
- move it to the left or right on a wide display;
- enable **Automatically hide and show the Dock**;
- enable or disable magnification deliberately;
- enable **Minimize windows into application icon** when separate minimized
  thumbnails create clutter;
- disable **Show suggested and recent apps in Dock** when the Dock should remain
  stable;
- keep indicators for open applications when they help distinguish running state.

Apple documents these settings in
[Change Desktop & Dock settings](https://support.apple.com/guide/mac-help/change-desktop-dock-settings-mchlp1119/mac).

### Built-in window tiling

Before adding Rectangle, Loop, AeroSpace, yabai, or another manager, review the
current built-in controls under **Desktop & Dock > Windows**:

- drag windows to the left or right edge to tile;
- drag to the menu bar to fill the screen;
- hold Option while dragging to tile;
- show or remove margins around tiled windows.

See [Change window tiling settings](https://support.apple.com/guide/mac-help/change-window-tiling-settings-on-mac-mchl118087b0/mac).

Add a third-party window manager only for missing layouts, repeatable workspace
arrangements, keyboard behavior, or automation. Grant Accessibility permission
only after reviewing the application.

### Mission Control and Hot Corners

Review:

- whether Spaces rearrange automatically based on recent use;
- whether displays use separate Spaces;
- the shortcut for Mission Control and application windows;
- Hot Corners, ideally with a modifier key to prevent accidental activation.

Changing separate-Spaces behavior may require logging out. Multi-display and
remote-presentation workflows should drive the choice.

## Screenshots and recordings

Press **Shift-Command-5**, open **Options**, and choose a dedicated save location
such as `~/Pictures/Screenshots`. The panel also controls timers, the floating
thumbnail, pointer visibility, and supported capture formats.

Apple documents the current panel in
[Take screenshots or screen recordings](https://support.apple.com/guide/mac-help/take-a-screenshot-mh26782/mac).

The repository's preference script creates `~/Pictures/Screenshots` and sets it as
the location. Use the supported panel when you prefer not to automate the change.

Useful shortcuts:

- **Shift-Command-3**: entire screen;
- **Shift-Command-4**: selected area;
- **Shift-Command-4**, then Space: a window;
- add **Control** to copy to the clipboard instead of saving a file.

## Display and visual comfort

Open **System Settings > Displays** and **Accessibility > Display**.

Review:

- scaling and effective text size on every display;
- arrangement and primary display;
- refresh rate and HDR where available;
- Night Shift or other color scheduling;
- Reduce motion;
- Reduce transparency;
- Increase contrast;
- pointer size and color when helpful.

Display tuning is hardware- and vision-specific. Do not automate a single scaling
or color choice across unlike displays.

For requirements beyond macOS controls, evaluate one owner:

- [BetterDisplay](https://github.com/waydabber/BetterDisplay/wiki) for advanced
  scaling, virtual displays, brightness, and overrides;
- [Lunar](https://lunar.fyi/docs) for adaptive external-display brightness and
  monitor control.

Document overrides so recovery is possible when a display is disconnected or a
configuration stops working.

## Text input and developer typing

Under **System Settings > Keyboard > Text Input**, review autocorrection,
automatic capitalization, smart quotes, smart dashes, and inline predictions.

These features are useful in prose and can be surprising in code, terminals, or
plain-text formats. Many code editors already disable or isolate them. Prefer
per-application behavior when available instead of globally degrading writing
support.

## Notifications, Focus, and login items

A new Mac often feels slow or distracting because too many applications launch,
notify, index, or update in the background.

Review:

- **System Settings > Notifications**: allow only useful, actionable alerts;
- **System Settings > Focus**: create work, meeting, or presentation modes when
  they solve a real interruption problem;
- **System Settings > General > Login Items & Extensions**: understand every item
  that opens at login or runs in the background.

Do not disable an unfamiliar security, backup, device-management, accessibility,
or synchronization component until its owner and purpose are known.

## What the repository automates

The opt-in script currently changes only:

- show all filename extensions;
- show Finder's path bar;
- show Finder's status bar;
- save screenshots in `~/Pictures/Screenshots`.

Preview it with:

```bash
./scripts/macos-defaults.sh
```

Apply it only after review:

```bash
./scripts/macos-defaults.sh --apply
```

Finder List view, mouse speed, pointer acceleration, scrolling speed, key repeat,
Dock behavior, trackpad gestures, display scaling, and window tiling remain manual
because they are personal or hardware-dependent. Some of their underlying
preference keys are undocumented implementation details even when the visible UI
is supported.

## Why this guide avoids old `defaults write` collections

A command can continue executing while no longer producing the intended result.
Preference domains and keys can change, values can be typed incorrectly, and a
full-domain import can overwrite unrelated settings.

For a setting not already in the narrow script:

1. Prefer the supported UI.
2. Record the current state and exact path.
3. Change one setting.
4. Test it through ordinary work.
5. Keep a manual rollback note.
6. Automate only after confirming the key and behavior on every supported macOS
   version and hardware class.

That approach is slower than pasting a hundred commands, but it produces a setup
that remains understandable and recoverable.
