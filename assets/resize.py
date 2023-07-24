from PIL import Image
import os
import sys

def resize_and_rename_icon(icon_path, output_folder):
    sizes = [(64, 64), (192, 192), (384, 384), (512, 512)]

    # Open the original icon image
    with Image.open(icon_path) as img:
        for size in sizes:
            # Resize the image
            resized_img = img.resize(size, Image.ANTIALIAS)

            # Generate the output filename
            filename = f"icon-{size[0]}x{size[1]}.png"
            output_path = os.path.join(output_folder, filename)

            # Save the resized image
            resized_img.save(output_path)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python resize_icons.py <icon_path>")
        sys.exit(1)

    icon_path = sys.argv[1]
    if not os.path.exists(icon_path):
        print("Error: Icon file not found.")
        sys.exit(1)

    output_folder = os.getcwd()

    resize_and_rename_icon(icon_path, output_folder)

