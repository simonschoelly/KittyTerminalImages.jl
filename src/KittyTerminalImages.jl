module KittyTerminalImages

using FileIO: load, save, Stream, @format_str
using Base64: base64encode
using Rsvg
using Cairo: FORMAT_ARGB32, CairoImageSurface, CairoContext
import Cairo
using Base.Multimedia: xdisplayable
using ImageTransformations: imresize
using ImageCore: RGBA, channelview
using CodecZlib: ZlibCompressor, ZlibCompressorStream
using Requires: @require

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
    @require Compose="a81c6b42-2e10-5240-aca2-a61377ecd94b" include("integration/Compose.jl")
end

function draw_temp_file(img)

    # TODO ensure that there is no racing condition with these tempfiles
    path, io = mktemp()
    ImageMagick.save_(Stream(format"PNG", io), img)
    close(io)

    payload = transcode(UInt8, base64encode(path))
    write_kitty_image_escape_sequence(stdout, payload, f=100, t='t', X=1, Y=1, a='T')
end

function draw_direct(img)

    # TODO this adds some unnecessary channels for alpha and colors that are not always necessary
    # TODO might be easiert to write to a png then we have some compression, then we can also maybe remove zlib
    img_rgba = permutedims(channelview(RGBA.(img)), (1, 3, 2))
    img_encoded = base64encode(ZlibCompressorStream(IOBuffer(vec(reinterpret(UInt8, img_rgba)))))

    (_, width, height) = size(img_rgba)

    buff = IOBuffer()
    partitions = Iterators.partition(transcode(UInt8, img_encoded), 4096)
    for (i, payload) in enumerate(partitions)

        m = (i == length(partitions)) ? 0 : 1 # 0 if this is the last data chunk

        if i == 1
            write_kitty_image_escape_sequence(buff, payload, f=32, s=width, v=height, X=1, Y=1, a='T', o='z', m=m)
        else
            write_kitty_image_escape_sequence(buff, payload, m=m)
        end

    end

    write(stdout, take!(buff))

    return
end

# allows to define custom behaviour for special cases of show within this package
show_custom(io::IO, m::MIME, x) = show(io, m , x)

# values for controll data: https://sw.kovidgoyal.net/kitty/graphics-protocol.html#control-data-reference
function write_kitty_image_escape_sequence(io::IO, payload::AbstractVector{UInt8}; controll_data...)

    cmd_prefix = "\033_G"
    first_iteration = true
    for (key, value) in controll_data
        if first_iteration
            first_iteration = false
        else
            cmd_prefix *= ','
        end
        cmd_prefix *= string(key)
        cmd_prefix *= '='
        cmd_prefix*= string(value)
    end
    cmd_prefix *= ';'
    cmd_postfix = "\033\\"
    cmd = [transcode(UInt8, cmd_prefix); payload; transcode(UInt8, cmd_postfix)]
    write(io, cmd)

    return
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

# Supported mime types, they are tried in order that they appear of the list returned
# svg should be preferred png so that we can apply scaling to a vector graphics instead of
# pixels if both formats are supported but because of a bug, (https://github.com/simonschoelly/KittyTerminalImages.jl/issues/4),
# that has not been solved yet, some svg's are not rendered correctly
function kitty_mime_types()
    if get_kitty_config(:prefer_png_to_svg)
        [MIME"image/png"(), MIME"image/svg+xml"()]
    else
        [MIME"image/svg+xml"(), MIME"image/png"()]
    end
end

function display(d::KittyDisplay, x)
    for m in kitty_mime_types()
        if showable(m, x)
            display(d, m, x)
            return
        end
    end
    throw(MethodError(display, (x,)))
end


function display(d::KittyDisplay,
                 m::MIME"image/png", x; scale=get_kitty_config(:scale, 1.0))
    buff = IOBuffer()
    show_custom(buff, m, x)
    img = load(Stream(format"PNG", buff))
    img = imresize(img; ratio=scale)

    if get_kitty_config(:transfer_mode) == :direct
        draw_direct(img)
    else
        draw_temp_file(img)
    end

    return
end

function display(d::KittyDisplay,
                 m::MIME"image/svg+xml", x; scale=get_kitty_config(:scale, 1.0))
    # Write x to a cairo buffer a and the use the png display method
    buff = IOBuffer()
    show_custom(buff, m, x)
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
