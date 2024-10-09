module ComposeExt

import Compose
import KittyTerminalImages: show_custom

# This is necessary as without `false` compose tries to draw a png by themself when calling show
# instead of writing it to `io`
show_custom(io::IO, ::MIME"image/png", ctx::Compose.Context) =
    Compose.draw(Compose.PNG(io, Compose.default_graphic_width, Compose.default_graphic_height, false), ctx)

end # module
