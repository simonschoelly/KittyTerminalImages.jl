
"""
    imresize(img; ratio)

Return a copy of the image `img` scaled by `ratio`.

In case `ratio` is close to `1`, this function might also return
the original argument.

This is a replacement for a similar function from ImageTransformations.jl,
in order to avoid the loading time of that package. Currently this function might
not be as fancy as the one it replaces.
"""
function imresize(img; ratio::Float64)

    height, width = size(img)
    new_height = max(1, round(Int, ratio * height))
    new_width = max(1, round(Int, ratio * width))

    if (new_height == height && new_width == width)
        return img
    end

    new_img = similar(img, new_height, new_width)
    # TODO it would be nicer to use Lanczos interpolation
    # but that one creates negative colors at the moment
    itp = interpolate(img, BSpline(Linear()))

    # TODO StepRangeLen does not work for length == 1, maybe we can
    # solve this without type instability
    xs = (new_width <= 1) ? (1:1) : range(1, width, length=new_width)
    ys = (new_height <= 1) ? (1:1) : range(1, height, length=new_height)

    for (new_x, x) in enumerate(xs), (new_y, y) in enumerate(ys)
        new_img[new_y, new_x] = itp(y, x)
    end

    return new_img
end
