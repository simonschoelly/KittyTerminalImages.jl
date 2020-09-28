# KittyTerminalImages.jl
![](https://img.shields.io/badge/lifecycle-maturing-blue.svg)
[![pkgeval](https://juliahub.com/docs/KittyTerminalImages/pkgeval.svg)](https://juliahub.com/ui/Packages/KittyTerminalImages/gIOCR)
[![version](https://juliahub.com/docs/KittyTerminalImages/version.svg)](https://juliahub.com/ui/Packages/KittyTerminalImages/gIOCR)

## Description
A package that allows Julia to display images in the kitty terminal editor.

## Screenshots
| | | |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| <figure><img src="https://github.com/simonschoelly/KittyTerminalImages.jl/blob/master/screenshots/screenshot-colors.png" alt="Colors.jl" style="zoom:50%;" /><figcaption>Colors.jl</figcaption></figure> | <figure><img src="https://github.com/simonschoelly/KittyTerminalImages.jl/blob/master/screenshots/screenshot-images.png" alt="Images.jl" style="zoom:50%;" /><figcaption>Images.jl</figcaption></figure> | <img src="https://github.com/simonschoelly/KittyTerminalImages.jl/blob/master/screenshots/screenshot-plots.png" alt="Plots.jl" style="zoom:50%;" /><figcaption>Plots.jl</figcaption></figure> |
| <figure><img src="https://github.com/simonschoelly/KittyTerminalImages.jl/blob/master/screenshots/screenshot-luxor.png" alt="Luxor.jl" style="zoom:50%;" /><figcaption>Luxor.jl</figcaption></figure> | <figure><img src="https://github.com/simonschoelly/KittyTerminalImages.jl/blob/master/screenshots/screenshot-juliagraphs.png" alt="JuliaGraphs" style="zoom:50%;" /><figcaption>JuliaGraphs</figcaption></figure> |                                                              |



## Installation
KittyTerminalImages.jl can be installed from the package manager by typing the following to your REPL:
```julia
] add KittyTerminalImages
```
In addition you will need install the Kitty terminal emulator. It works on macOS or Linux but (at least currently) not on Windows. You can get it here: https://github.com/kovidgoyal/kitty


## Usage
Simple load KittyTerminalImages in your REPL (assuming that you have opened Julia in kitty)
```julia
using KittyTerminalImages
```
Sometimes when loading another package, such as Plots.jl or Gadfly.jl, they will put their own method for displaying images 
in an external program on the display stack, thus overriding the behaviour of KittyTerminalImages. To put KittyTerminalImages back
on top of the stack, execute the following:
```julia
pushKittyDisplay!()
```
You can also override the general display behaviour so KittyTerminalImages is on top of the stack. This is a hack and can have
unwanted side effects. To do that, execute the following:
```julia
forceKittyDisplay!()
```

## Configuration

### Setting the scale
If the images are too small or too large for your terminal,
you can specify a scale
```julia
set_kitty_config!(:scale, 2.0) # scale all images by a factor 2
```

### Setting preference for PNG or SVG
Certain Julia objects can be drawn as either a PNG or a SVG image. In case both formats are possible,
one can specify that PNG should be preferred by setting the ``:prefer_png_to_svg`` config value:
```julia
set_kitty_config!(:prefer_png_to_svg, true)
```
At the moment this value is set to `true` by default as in some cases the svg renderer creates some incorrect images.
If the `:scale` config is also set, this has the disadvantage that scaled images may appear blurry.

### Setting the transfer mode
To transfer the image from Julia to kitty, one can select between two transfer modes:
* `:direct` (default) -- transfer the imagine with escape sequences
* `:temp_file` -- transfer the imagine by writing it to a temporary file and then transfer only the path of that image

Only `:direct` works if Julia is accessed remotely with SSH but if Julia is on the same machine as kitty then one might switch to `:temp_file` which might be slightly faster.
To switch the mode one can do
```julia
set_kitty_config!(:transfer_mode, :temp_file)
```

## Features
KittyTerminalImages can display all data types than can be converted to either `PNG` or `SVG`.

## Limitations
* There are currently some unresolved issues with some SVG images.
* Does not work with tmux or screen yet.
* Can only display static images, there is no interaction.
* There might be some problems with some Julia packages. If that is the case, feel free to open an issue or submit a PR with a fix.

## TODO list
- [ ] Display LaTeX images.
- [X] Support for SSH.
- [ ] Support for tmux and screen.
- [x] Add an option for setting the image output size.
- [ ] Query for the terminal size and colors.
- [ ] Allow specifying placement of the images - if possible have a mode where the terminal is split into a text and an image section.
- [ ] Figure out if it possible to play animations.


## Similar packages
* [TerminalExtensions.jl](https://github.com/Keno/TerminalExtensions.jl)
* [ImageInTerminal.jl](https://github.com/JuliaImages/ImageInTerminal.jl)
* [SixelTerm.jl](https://github.com/tshort/SixelTerm.jl)
* [TerminalGraphics.jl](https://github.com/m-j-w/TerminalGraphics.jl) (outdated)
