module KittyTerminalImages

using Colors: Colorant
using FileIO: save, Stream, @format_str
using Base64: base64encode
using Plots: Plot, png
using Compose
import Cairo

import Base: display

# export KittyImageDisplay TODO remove

struct KittyImageDisplay <: AbstractDisplay end

function __init__()
    # TODO verify that we are actually using kitty
    @info "pushing KittyImageDisplay() on top of stack"
    pushdisplay(KittyImageDisplay())
end
    

function draw_temp_file(path::String)
    cmd_start = transcode(UInt8, "\033_Gf=100,t=t,a=T;")
    cmd_end = transcode(UInt8, "\033\\") 
    payload = transcode(UInt8, base64encode(path))
    cmd = [cmd_start; payload; cmd_end]
    write(stdout, cmd)
end

# TODO ensure that is no racing condition with these tempfiles

function display(d::KittyImageDisplay, 
                 img::AbstractArray{C, 2}) where {C <: Colorant}
    path, io = mktemp()
    save(Stream(format"PNG", io), img)
    close(io)
    draw_temp_file(path)
end

function display(d::KittyImageDisplay, 
                 ctx::Context)
    path, io = mktemp()
    close(io)
    w = sqrt(2)*6*cm
    h = 6cm
    draw(PNG(path, w, h), ctx)
    draw_temp_file(path)
end

function display(d::KittyImageDisplay, 
                 plot::Plot)
    path = tempname() * ".png"
    png(plot, path)
    draw_temp_file(path)
end



end # module
