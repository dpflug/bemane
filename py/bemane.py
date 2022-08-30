#!/usr/bin/env python3
"""A short script to keep a dir of BEMA episodes up-to-date"""

from pathlib import Path

import requests
from bs4 import BeautifulSoup
from bs4.element import Tag


def weirdo_title(title: str) -> str:
    """A couple of the titles (as of 2022-02-09) are non-numbered. We give them
    b-numbers, copying the website's URL schema and putting them in their
    correct place in the sequence."""
    if title == '"Jesus Shema"':
        return "021b: " + title
    if title == "Verastikh (Hosea)":
        return "049b: " + title
    return title


def pad_title(title: str) -> str:
    """Zero-pad the number in the titles so that
    Roku Media Player sorts correctly"""
    parts = title.split(":")
    number, title_name = parts[0], ":".join(parts[1:])
    return number.zfill(3) + ":" + title_name


def handle_title(title: str) -> Path:
    "There's a few different quirks in the titles that need handled"
    if "/" in title:
        title = title.replace("/", "_")

    if ":" in title:
        new_title = pad_title(title)
    else:
        new_title = weirdo_title(title)

    return Path(new_title + ".mp3")


def downloader(item: Tag) -> str:
    """Download a given file"""
    filename = handle_title(item.title.text)
    url = item.enclosure["url"]
    if not filename.exists():
        with requests.get(url, stream=True) as request:
            request.raise_for_status()
            with open(filename, "wb") as filehandle:
                for chunk in request.iter_content(chunk_size=8192):
                    filehandle.write(chunk)

    return filename


def main() -> None:
    """Entrypoint"""
    rss = requests.get("https://www.bemadiscipleship.com/rss")
    rss.raise_for_status()
    soup = BeautifulSoup(rss.text, "html.parser")
    channel = soup.rss.channel
    for item in channel.find_all("item"):
        downloader(item)


if __name__ == "__main__":
    main()
