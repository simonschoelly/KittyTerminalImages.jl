module KittyTerminalImages

using FileIO: save, Stream, @format_str
using Base64: base64encode
using Rsvg
using Cairo: FORMAT_ARGB32, CairoImageSurface, CairoContext
using Base.Multimedia: xdisplayable

import Base: display

export pushKittyDisplay!, forceKittyDisplay!


struct KittyDisplay <: AbstractDisplay end

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

kitty_mime_types = [MIME"image/png"(), MIME"image/svg+xml"()]

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
                 m::MIME"image/png", x)
    path, io = mktemp()
    show(io, m, x)
    close(io)
    draw_temp_file(path)
    return
end

function display(d::KittyDisplay,
                 m::MIME"image/svg+xml", x)
    # Write x to a cairo buffer a and the use the png display method
    buff = IOBuffer()
    show(buff, m, x)
    svg_data = String(take!(buff))
    handle = Rsvg.handle_new_from_data(svg_data)
    dims = Rsvg.handle_get_dimensions(handle)
    surface = CairoImageSurface(dims.width, dims.height, FORMAT_ARGB32)
    context = CairoContext(surface)
    Rsvg.handle_render_cairo(context, handle)
    # Rsvg.handle_free(handle) # this leads to error messages
    display(d, MIME"image/png"(), surface)
    return
end

randkitty() = '\U1f600' + rand([-463, -504, 63, 57, 64, 60, 62, 59, 58, 56, 61, 897, -465])

end # module
