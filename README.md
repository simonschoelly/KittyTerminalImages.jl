# KittyTerminalImages.jl
![](https://img.shields.io/badge/lifecycle-experimental-orange.svg)

## Description
A package that allows Julia to display images in the kitty terminal editor. This package is in an experimental stage and might
be added to [TerminalExtensions.jl](https://github.com/Keno/TerminalExtensions.jl) later.

## Installation
KittyTerminalImages.jl is currently not a registred Julia package. Therefore to install it enter the following in your REPL:
```julia
] add "https://github.com/simonschoelly/KittyTerminalImages.jl"
```
In addition you will need install the Kitty terminal emulator. You can get it here: https://github.com/kovidgoyal/kitty


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
You can also overwritte the general display behaviour so KittyTerminalImages is on top of the stack. This is a hack and can have
unwanted side effects. To do that, execute the following:
```julia
forceKittyDisplay!()
```

### Setting the scale
If the images are too small or too large for your terminal,
you can specify a scale
```julia
set_kitty_config!(:scale, 2.0) # scale all images by a factor 2
```

## Features
KittyTerminalImages can display all data types than can be converted to either `png` or `svg`.

## Limitations
* Does not work over SSH yet.
* Does not work with Tmux or screen yet.
* Can only display static images, there is no interaction.

## TODO list
- [ ] Display LaTex images.
- [ ] Support for SSH.
- [ ] Support for Tmux and screen.
- [x] Add an option for setting the image output size.
- [ ] Query for the terminal size and colors.
- [ ] Ensure that kitty is the actual terminal emulator.


## Similar packages
* [TerminalExtensions.jl](https://github.com/Keno/TerminalExtensions.jl)
* [TerminalGraphics.jl](https://github.com/m-j-w/TerminalGraphics.jl) (outdated)
* [SixelTerm.jl](https://github.com/tshort/SixelTerm.jl) (outdated)

## Screenshots

| <img src="https://github.com/simonschoelly/KittyTerminalImages.jl/blob/master/screenshots/screenshot-colors.png" alt="Colors.jl" style="zoom:50%;" /> | <img src="https://github.com/simonschoelly/KittyTerminalImages.jl/blob/master/screenshots/screenshot-images.png" alt="Images.jl" style="zoom:50%;" /> | <img src="https://github.com/simonschoelly/KittyTerminalImages.jl/blob/master/screenshots/screenshot-plots.png" alt="Plots.jl" style="zoom:50%;" /> |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| <img src="https://github.com/simonschoelly/KittyTerminalImages.jl/blob/master/screenshots/screenshot-luxor.png" alt="Luxor.jl" style="zoom:50%;" /> | <img src="https://github.com/simonschoelly/KittyTerminalImages.jl/blob/master/screenshots/screenshot-juliagraphs.png" alt="JuliaGraphs" style="zoom:50%;" /> |                                                              |

