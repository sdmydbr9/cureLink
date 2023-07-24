from PIL import Image

def create_animated_gif(png_image_path, gif_output_path, duration=100):
    # Load the PNG image
    image = Image.open(png_image_path)

    # Create a list to store the frames for the animated GIF
    frames = []

    # Set the transparency for GIF
    image = image.convert("RGBA")

    # Add the original image as the first frame
    frames.append(image)

    # Create additional frames with slight transparency variations
    for alpha in range(254, 0, -10):
        # Create a copy of the original image
        frame = image.copy()

        # Set the transparency (alpha) for the current frame
        frame.putalpha(alpha)

        # Add the frame to the frames list
        frames.append(frame)

    # Save the frames as an animated GIF
    frames[0].save(
        gif_output_path,
        save_all=True,
        append_images=frames[1:],
        optimize=False,
        duration=duration,
        loop=0  # 0 means loop forever
    )

if __name__ == "__main__":
    # Replace 'input.png' and 'output.gif' with your file paths
    input_png_file = "rotate.png"
    output_gif_file = "output.gif"

    # Call the function to create the animated GIF
    create_animated_gif(input_png_file, output_gif_file)

    print("Animated GIF created successfully!")
