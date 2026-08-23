#!/usr/bin/env python3

import argparse
import struct
from PIL import Image


# ============================================================
# EGA 16-color palette
# ============================================================

EGA_PALETTE = [
    (0x00, 0x00, 0x00),  # 0  black
    (0x00, 0x00, 0xAA),  # 1  blue
    (0x00, 0xAA, 0x00),  # 2  green
    (0x00, 0xAA, 0xAA),  # 3  cyan
    (0xAA, 0x00, 0x00),  # 4  red
    (0xAA, 0x00, 0xAA),  # 5  magenta
    (0xAA, 0x55, 0x00),  # 6  brown
    (0xAA, 0xAA, 0xAA),  # 7  light gray
    (0x55, 0x55, 0x55),  # 8  dark gray
    (0x55, 0x55, 0xFF),  # 9  light blue
    (0x55, 0xFF, 0x55),  # 10 light green
    (0x55, 0xFF, 0xFF),  # 11 light cyan
    (0xFF, 0x55, 0x55),  # 12 light red
    (0xFF, 0x55, 0xFF),  # 13 light magenta
    (0xFF, 0xFF, 0x55),  # 14 yellow
    (0xFF, 0xFF, 0xFF),  # 15 white
]


EGA_NAMES = [
    "black",
    "blue",
    "green",
    "cyan",
    "red",
    "magenta",
    "brown",
    "light gray",
    "dark gray",
    "light blue",
    "light green",
    "light cyan",
    "light red",
    "light magenta",
    "yellow",
    "white",
]


# ============================================================
# Number of bits required for color index
# ============================================================

def get_color_bits(color_count):
    if color_count <= 1:
        return 0
    elif color_count <= 2:
        return 1
    elif color_count <= 4:
        return 2
    elif color_count <= 8:
        return 3
    else:
        return 4


# ============================================================
# Nearest EGA color
# ============================================================

def nearest_ega_color(rgb):
    r, g, b = rgb

    best_index = 0
    best_distance = None

    for i, (er, eg, eb) in enumerate(EGA_PALETTE):

        dr = r - er
        dg = g - eg
        db = b - eb

        distance = (
            dr * dr +
            dg * dg +
            db * db
        )

        if best_distance is None or distance < best_distance:
            best_distance = distance
            best_index = i

    return best_index


# ============================================================
# PNG -> EGA pixel array
# ============================================================

def convert_pixels(image):

    image = image.convert("RGBA")

    pixels = []

    for r, g, b, a in image.getdata():

        # Transparent pixel -> black
        if a == 0:
            pixels.append(0)
        else:
            pixels.append(
                nearest_ega_color((r, g, b))
            )

    return pixels


# ============================================================
# Build palette
#
# Order is the order of first appearance in image.
#
# Example:
#
# image:
#
# black black yellow green black
#
# palette:
#
# 0 = black
# 1 = yellow
# 2 = green
#
# ============================================================

def create_palette(pixels):

    palette = []

    for color in pixels:

        if color not in palette:
            palette.append(color)

    if len(palette) > 16:
        raise ValueError(
            "Image contains more than 16 EGA colors"
        )

    return palette


# ============================================================
# Palette -> binary
#
# Two EGA color numbers per byte.
#
# high nibble = first color
# low nibble  = second color
#
# Example:
#
# [0, 14, 2]
#
# 0000 1110
# 0010 0000
#
# ============================================================

def encode_palette(palette):

    result = bytearray()

    for i in range(0, len(palette), 2):

        first = palette[i]

        if i + 1 < len(palette):
            second = palette[i + 1]
        else:
            second = 0

        result.append(
            (first << 4) | second
        )

    return result


# ============================================================
# Create color -> palette index map
# ============================================================

def create_color_map(palette):

    return {
        color: index
        for index, color in enumerate(palette)
    }


# ============================================================
# Convert pixels into palette indices
# ============================================================

def make_indexed_pixels(pixels, color_map):

    return [
        color_map[color]
        for color in pixels
    ]


# ============================================================
# Create RLE runs
#
# Returns:
#
# [(color_index, count), ...]
#
# ============================================================

def make_runs(indexed_pixels):

    if not indexed_pixels:
        return []

    runs = []

    current = indexed_pixels[0]
    count = 1

    for color in indexed_pixels[1:]:

        if color == current:

            count += 1

        else:

            runs.append(
                (current, count)
            )

            current = color
            count = 1

    runs.append(
        (current, count)
    )

    return runs


# ============================================================
# Encode one RLE record
#
# color_bits:
#
# 0 -> 1 color
# 1 -> 2 colors
# 2 -> 3-4 colors
# 3 -> 5-8 colors
# 4 -> 9-16 colors
#
# ============================================================

def encode_rle_record(
    color_index,
    count,
    color_bits
):

    # --------------------------------------------------------
    # Validate color index
    # --------------------------------------------------------

    if color_bits == 0:

        if color_index != 0:
            raise ValueError(
                "Color index must be 0"
            )

    else:

        max_color = (1 << color_bits) - 1

        if color_index > max_color:
            raise ValueError(
                "Color index does not fit"
            )

    # --------------------------------------------------------
    # 1-byte record
    #
    # bit 7 = 0
    #
    # Remaining 7 bits:
    #
    # repeat + color
    #
    # repeat bits = 7 - color_bits
    # --------------------------------------------------------

    repeat_bits_1 = 7 - color_bits

    max_repeat_1 = (
        (1 << repeat_bits_1) - 1
    )

    if count <= max_repeat_1:

        value = (
            (count << color_bits) |
            color_index
        )

        return bytes([value])

    # --------------------------------------------------------
    # 2-byte record
    #
    # bit 15 = 1
    #
    # repeat bits = 15 - color_bits
    # --------------------------------------------------------

    repeat_bits_2 = 15 - color_bits

    max_repeat_2 = (
        (1 << repeat_bits_2) - 1
    )

    if count <= max_repeat_2:

        value = (
            (1 << 15) |
            (count << color_bits) |
            color_index
        )

        return struct.pack(
            "<H",
            value
        )

    # --------------------------------------------------------
    # Count is too large for one record.
    # Caller must split it.
    # --------------------------------------------------------

    raise ValueError(
        f"Repeat count {count} is too large"
    )


# ============================================================
# Encode complete RLE
# ============================================================

def encode_rle(
    runs,
    color_bits
):

    result = bytearray()

    # Maximum count for 2-byte record

    max_repeat = (
        (1 << (15 - color_bits)) - 1
    )

    for color_index, count in runs:

        remaining = count

        while remaining > 0:

            # Prefer 1-byte record whenever possible.

            max_repeat_1 = (
                (1 << (7 - color_bits)) - 1
            )

            if remaining <= max_repeat_1:

                part = remaining

            else:

                part = min(
                    remaining,
                    max_repeat
                )

            result += encode_rle_record(
                color_index,
                part,
                color_bits
            )

            remaining -= part

    return result


# ============================================================
# Header
#
# byte 0:
#
# bits 7..4 = version
# bits 3..0 = colors count
#
# 0 = 16 colors
#
#
# word:
#
# bits 15..12 = background color
# bits 11..0  = x offset
#
#
# next word:
#
# pixel count
#
# ============================================================

def make_header(
    color_count,
    background,
    x_offset,
    pixel_count
):

    if not 1 <= color_count <= 16:
        raise ValueError(
            "Color count must be 1..16"
        )

    if not 0 <= background <= 15:
        raise ValueError(
            "Background color must be 0..15"
        )

    if not 0 <= x_offset <= 4095:
        raise ValueError(
            "X offset must be 0..4095"
        )

    if not 0 <= pixel_count <= 65535:
        raise ValueError(
            "Pixel count must be 0..65535"
        )

    version = 1

    # 0 represents 16 colors

    encoded_color_count = (
        0
        if color_count == 16
        else color_count
    )

    first_byte = (
        (version << 4) |
        encoded_color_count
    )

    # Background + offset

    background_offset = (
        (background << 12) |
        x_offset
    )

    result = bytearray()

    result.append(first_byte)

    result += struct.pack(
        "<H",
        background_offset
    )

    result += struct.pack(
        "<H",
        pixel_count
    )

    return result


# ============================================================
# Main converter
# ============================================================

def convert_png(
    input_file,
    output_file,
    x_offset=0,
    background=None
):

    image = Image.open(input_file)

    width, height = image.size

    pixel_count = width * height

    if pixel_count > 65535:

        raise ValueError(
            f"Image contains {pixel_count} pixels. "
            f"Maximum is 65535."
        )

    # --------------------------------------------------------
    # PNG -> EGA
    # --------------------------------------------------------

    pixels = convert_pixels(image)

    # --------------------------------------------------------
    # Palette
    # --------------------------------------------------------

    palette = create_palette(pixels)

    color_count = len(palette)

    color_bits = get_color_bits(
        color_count
    )

    # --------------------------------------------------------
    # Background
    #
    # Automatically choose most frequent EGA color.
    # --------------------------------------------------------

    if background is None:

        histogram = [0] * 16

        for color in pixels:
            histogram[color] += 1

        background = max(
            range(16),
            key=lambda x: histogram[x]
        )

    if background not in palette:

        raise ValueError(
            f"Background color {background} "
            f"is not used in image"
        )

    # --------------------------------------------------------
    # Color -> palette index
    # --------------------------------------------------------

    color_map = create_color_map(
        palette
    )

    indexed_pixels = make_indexed_pixels(
        pixels,
        color_map
    )

    # --------------------------------------------------------
    # RLE runs
    # --------------------------------------------------------

    runs = make_runs(
        indexed_pixels
    )

    # --------------------------------------------------------
    # RLE data
    # --------------------------------------------------------

    rle = encode_rle(
        runs,
        color_bits
    )

    # --------------------------------------------------------
    # Header
    # --------------------------------------------------------

    header = make_header(
        color_count,
        background,
        x_offset,
        pixel_count
    )

    # --------------------------------------------------------
    # Palette
    # --------------------------------------------------------

    palette_data = encode_palette(
        palette
    )

    # --------------------------------------------------------
    # Write file
    #
    # HEADER
    # PALETTE
    # RLE
    # --------------------------------------------------------

    with open(output_file, "wb") as f:

        f.write(header)
        f.write(palette_data)
        f.write(rle)

    # ========================================================
    # Information
    # ========================================================

    print()
    print("========================================")
    print("PNG -> EGA RLE")
    print("========================================")

    print(f"Input       : {input_file}")
    print(f"Output      : {output_file}")

    print(
        f"Image       : "
        f"{width} x {height}"
    )

    print(
        f"Pixels      : "
        f"{pixel_count}"
    )

    print(
        f"Colors      : "
        f"{color_count}"
    )

    print(
        f"Color bits  : "
        f"{color_bits}"
    )

    print()

    print("Palette:")

    for index, ega_color in enumerate(palette):

        print(
            f"  {index:2} = "
            f"EGA {ega_color:2} "
            f"{EGA_NAMES[ega_color]}"
        )

    print()

    print(
        f"Background  : "
        f"EGA {background} "
        f"({EGA_NAMES[background]})"
    )

    print(
        f"X offset    : "
        f"{x_offset}"
    )

    print()

    print(
        f"Header      : "
        f"{len(header)} bytes"
    )

    print(
        f"Palette     : "
        f"{len(palette_data)} bytes"
    )

    print(
        f"RLE         : "
        f"{len(rle)} bytes"
    )

    print(
        f"File size   : "
        f"{len(header) + len(palette_data) + len(rle)} bytes"
    )

    print(
        f"RLE records : "
        f"{len(runs)}"
    )

    print("========================================")


# ============================================================
# Command line
# ============================================================

def main():

    parser = argparse.ArgumentParser(
        description=(
            "Convert PNG to EGA palette + "
            "variable-color-bit RLE format"
        )
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
        help="X offset (0..4095)"
    )

    parser.add_argument(
        "--background",
        type=int,
        default=None,
        help="EGA background color (0..15)"
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