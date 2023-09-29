from pathlib import Path

import cv2
import matplotlib.cbook as cbook
import matplotlib.pyplot as plt
import numpy as np
import numpy.typing as npt
import tifffile as tiff
from matplotlib_scalebar.scalebar import ScaleBar

# 0.096 x 0.096 x 0.192 microns


def read_image_file(image_file_path: Path) -> npt.NDArray[np.uint8]:
    return tiff.imread(image_file_path)


def draw_optical_section_image(image: npt.NDArray[np.uint8]) -> None:
    fig, ax = plt.subplots(figsize=(8, 8))
    ax.imshow(image, cmap="gray")
    scalebar = ScaleBar(
        0.096,
        "um",
        length_fraction=0.1,
        location="lower right",
        box_alpha=0.0,
        color="white",
    )
    ax.add_artist(scalebar)
    plt.axis("off")
    plt.show()


def draw_overall_color_image(image: npt.NDArray[np.uint8]) -> None:
    fig, ax = plt.subplots(figsize=(8, 8))
    ax.imshow(image, cmap="viridis")
    scalebar = ScaleBar(
        0.096,
        "um",
        length_fraction=0.1,
        location="lower right",
        box_alpha=0.0,
        color="white",
    )
    ax.add_artist(scalebar)
    ax.axis("off")
    plt.show()


def draw_nucleus_color_image(image: npt.NDArray[np.uint8]) -> None:
    fig, ax = plt.subplots(figsize=(8, 8))
    ax.imshow(image, cmap="viridis")
    scalebar = ScaleBar(
        0.096,
        "um",
        length_fraction=0.1,
        location="lower right",
        box_alpha=0.0,
        color="white",
    )
    fig.colorbar(ax)
    ax.add_artist(scalebar)
    ax.axis("off")
    plt.show()


def main():
    RAW_IMAGE_PATH = "data/raw/figure1"
    image_file_list = {
        "T1": Path(
            RAW_IMAGE_PATH, "20220603.211532.508.CD8_3-046_RI Tomogram.tiff"
        ),
        "T2": Path(
            RAW_IMAGE_PATH, "20220510.171950.017.CD8-036_RI Tomogram.tiff"
        ),
        "T3": Path(
            RAW_IMAGE_PATH, "20220614.142226.453.CD8-141_RI Tomogram.tiff"
        ),
        "HC": Path(
            RAW_IMAGE_PATH, "20220610.165803.956.CD8_2-017_RI Tomogram.tiff"
        ),
    }
    image = read_image_file(image_file_list["T1"])
    optical_section_image = draw_optical_section_image(image[105, :, :])
    overall_image = draw_overall_color_image(image[105, :, :])
    nucleus_image = draw_nucleus_color_image(image[105, :, :])


if __name__ == "__main__":
    main()
