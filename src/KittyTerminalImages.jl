module KittyTerminalImages

using FileIO: load, save, Stream, @format_str
using Base64: base64encode
using Rsvg
using Cairo: FORMAT_ARGB32, CairoImageSurface, CairoContext
import Cairo
using Base.Multimedia: xdisplayable
using ImageTransformations: imresize

import Base: display

# this seem to be necessary to enforce the usage of ImageMagic -- ImageIO
# produces an eof error.
using ImageMagick

export pushKittyDisplay!, forceKittyDisplay!, set_kitty_config!, get_kitty_config


struct KittyDisplay <: AbstractDisplay end

include("configuration.jl")

function __init__()
    # TODO verify that we are actually using kitty
    pushKittyDisplay!()
end


function draw_temp_file(path::String)
    cmd_prefix = transcode(UInt8, "\033_Gf=100,t=t,X=1,Y=1,a=T;")
    cmd_postfix = transcode(UInt8, "\033\\")
    payload = transcode(UInt8, base64encode(path))
    cmd = [cmd_prefix; payload; cmd_postfix]
    write(stdout, cmd)
end


# This is basically just what is defined in Base.Multimedia.display(x)
# but tries to display with KittyDisplay before trying the rest of
# the stack.
function _display(@nospecialize x)
    displays = Base.Multimedia.displays
    for d in reverse(vcat(displays, KittyDisplay()) )
        if xdisplayable(d, x)
            try
                display(d, x)
                return
            catch e
                if !(isa(e, MethodError) && e.f in (display, show))
                    rethrow()
                end
            end
        end
    end
    throw(MethodError(display, (x,)))
end

function forceKittyDisplay!()
    @eval display(@nospecialize x) = _display(x)
    return
end


function pushKittyDisplay!()
    d = Base.Multimedia.displays
    if !isempty(d) && !isa(d[end], KittyDisplay)
        Base.Multimedia.pushdisplay(KittyDisplay())
    end
    return
end

# Supported mime types, they are tried in order that they appear in this list
# svg is before png so that we can apply scaling to a vector graphics instead of
# pixels if both formats are supported

kitty_mime_types = [MIME"image/svg+xml"(), MIME"image/png"()]

function display(d::KittyDisplay, x)
    for m in kitty_mime_types
        if showable(m, x)
            display(d, m, x)
            return
        end
    end
    throw(MethodError(display, (x,)))
end

# TODO ensure that there is no racing condition with these tempfiles

function display(d::KittyDisplay,
                 m::MIME"image/png", x; scale=get_kitty_config(:scale, 1.0))
    buff = IOBuffer()
    show(buff, m, x)
    img = load(Stream(format"PNG", buff))
    img = imresize(img; ratio=scale)

    path, io = mktemp()
    save(Stream(format"PNG", io), img)
    close(io)
    draw_temp_file(path)
    return
end

function display(d::KittyDisplay,
                 m::MIME"image/svg+xml", x; scale=get_kitty_config(:scale, 1.0))
    # Write x to a cairo buffer a and the use the png display method
    buff = IOBuffer()
    show(buff, m, x)
    svg_data = String(take!(buff))
    handle = Rsvg.handle_new_from_data(svg_data)
    dims = Rsvg.handle_get_dimensions(handle)
    width = round(Int, dims.width * scale)
    height = round(Int, dims.height * scale)
    surface = CairoImageSurface(width, height, FORMAT_ARGB32)
    context = CairoContext(surface)
    Cairo.scale(context, scale, scale)
    Rsvg.handle_render_cairo(context, handle)
    # Rsvg.handle_free(handle) # this leads to error messages
    display(d, MIME"image/png"(), surface; scale=1.0) # scaling already happened to svg
    return
end

randkitty() = '\U1f600' + rand([-463, -504, 63, 57, 64, 60, 62, 59, 58, 56, 61, 897, -465])

end # module
