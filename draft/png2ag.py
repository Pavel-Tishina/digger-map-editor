#!/usr/bin/env python3

import argparse
import struct
from pathlib import Path
from PIL import Image


# ------------------------------------------------------------
# EGA 16-color palette
#
# Index:
#  0 black
#  1 blue
#  2 green
#  3 cyan
#  4 red
#  5 magenta
#  6 brown
#  7 light gray
#  8 dark gray
#  9 light blue
# 10 light green
# 11 light cyan
# 12 light red
# 13 light magenta
# 14 yellow
# 15 white
# ------------------------------------------------------------

EGA_PALETTE = [
    (0x00, 0x00, 0x00),  # 0
    (0x00, 0x00, 0xAA),  # 1
    (0x00, 0xAA, 0x00),  # 2
    (0x00, 0xAA, 0xAA),  # 3
    (0xAA, 0x00, 0x00),  # 4
    (0xAA, 0x00, 0xAA),  # 5
    (0xAA, 0x55, 0x00),  # 6
    (0xAA, 0xAA, 0xAA),  # 7
    (0x55, 0x55, 0x55),  # 8
    (0x55, 0x55, 0xFF),  # 9
    (0x55, 0xFF, 0x55),  # 10
    (0x55, 0xFF, 0xFF),  # 11
    (0xFF, 0x55, 0x55),  # 12
    (0xFF, 0x55, 0xFF),  # 13
    (0xFF, 0xFF, 0x55),  # 14
    (0xFF, 0xFF, 0xFF),  # 15
]


# ------------------------------------------------------------
# Find nearest EGA color
# ------------------------------------------------------------

def nearest_ega_color(rgb):
    r, g, b = rgb

    best_index = 0
    best_distance = None

    for i, (er, eg, eb) in enumerate(EGA_PALETTE):
        dr = r - er
        dg = g - eg
        db = b - eb

        distance = dr * dr + dg * dg + db * db

        if best_distance is None or distance < best_distance:
            best_distance = distance
            best_index = i

    return best_index


# ------------------------------------------------------------
# Convert PNG to EGA indexed pixels
# ------------------------------------------------------------

def convert_pixels(image):
    image = image.convert("RGBA")

    result = []

    for r, g, b, a in image.getdata():

        # Transparent pixels become black.
        if a == 0:
            result.append(0)
        else:
            result.append(nearest_ega_color((r, g, b)))

    return result


# ------------------------------------------------------------
# RLE
#
# 16-bit value:
#
# 15                 4 3            0
# +--------------------+--------------+
# | repeat count (12)  | color (4)   |
# +--------------------+--------------+
#
# repeat count: 1..4095
# ------------------------------------------------------------

def encode_rle(pixels):
    result = bytearray()

    if not pixels:
        return result

    current_color = pixels[0]
    count = 1

    for color in pixels[1:]:

        if color == current_color and count < 4095:
            count += 1
            continue

        value = (count << 4) | current_color

        result += struct.pack("<H", value)

        current_color = color
        count = 1

    # Last run
    value = (count << 4) | current_color
    result += struct.pack("<H", value)

    return result


# ------------------------------------------------------------
# Header
#
# byte 0:
#
#  bits 7..4 = version
#  bits 3..0 = colors count
#
# We use:
#   1..15 = number of colors
#   0      = 16 colors
#
# ------------------------------------------------------------

def make_header(color_count, background, x_offset, pixel_count):

    if color_count > 16:
        raise ValueError(
            f"Image contains {color_count} colors, maximum is 16"
        )

    if not 0 <= background <= 15:
        raise ValueError("Background color must be 0..15")

    if not 0 <= x_offset <= 4095:
        raise ValueError("X offset must fit into 12 bits (0..4095)")

    if not 0 <= pixel_count <= 65535:
        raise ValueError(
            "Pixel count must fit into 16 bits (0..65535)"
        )

    version = 1

    # 4 bits cannot directly represent 16.
    # We use 0 as the representation of 16.
    encoded_color_count = color_count & 0x0F

    byte0 = (version << 4) | encoded_color_count

    # background: 4 bits
    # x-offset:   12 bits
    word1 = (background << 12) | x_offset

    result = bytearray()

    result.append(byte0)
    result += struct.pack("<H", word1)
    result += struct.pack("<H", pixel_count)

    return result


# ------------------------------------------------------------
# Main conversion
# ------------------------------------------------------------

def convert_png(input_file, output_file, x_offset=0, background=None):

    image = Image.open(input_file)

    width, height = image.size

    pixel_count = width * height

    if pixel_count > 65535:
        raise ValueError(
            f"Image contains {pixel_count} pixels. "
            f"Maximum is 65535."
        )

    pixels = convert_pixels(image)

    used_colors = sorted(set(pixels))
    color_count = len(used_colors)

    # Automatically choose the most frequent color
    # as background.
    if background is None:

        histogram = [0] * 16

        for color in pixels:
            histogram[color] += 1

        background = max(
            range(16),
            key=lambda c: histogram[c]
        )

    if background not in used_colors:
        raise ValueError(
            f"Background color {background} "
            f"is not present in the image."
        )

    header = make_header(
        color_count,
        background,
        x_offset,
        pixel_count
    )

    rle = encode_rle(pixels)

    with open(output_file, "wb") as f:
        f.write(header)
        f.write(rle)

    print(f"Input       : {input_file}")
    print(f"Output      : {output_file}")
    print(f"Size        : {width} x {height}")
    print(f"Pixels      : {pixel_count}")
    print(f"Colors      : {color_count}")
    print(f"Used colors : {used_colors}")
    print(f"Background  : {background}")
    print(f"X offset    : {x_offset}")
    print(f"RLE bytes   : {len(rle)}")
    print(f"File size   : {len(header) + len(rle)} bytes")


# ------------------------------------------------------------
# Command line
# ------------------------------------------------------------

def main():

    parser = argparse.ArgumentParser(
        description="Convert PNG to EGA RLE sprite format"
    )

    parser.add_argument(
        "input",
        help="Input PNG file"
    )

    parser.add_argument(
        "output",
        help="Output binary file"
    )

    parser.add_argument(
        "--x-offset",
        type=int,
        default=0,
        help="12-bit X offset (0..4095), default: 0"
    )

    parser.add_argument(
        "--background",
        type=int,
        default=None,
        help="EGA background color 0..15. "
             "If omitted, most frequent color is used."
    )

    args = parser.parse_args()

    convert_png(
        args.input,
        args.output,
        args.x_offset,
        args.background
    )


if __name__ == "__main__":
    main()