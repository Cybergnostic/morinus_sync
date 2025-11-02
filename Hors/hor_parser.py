#!/usr/bin/env python3
import os
import re
from datetime import datetime

# Path to your file with all the lines
input_file = "/run/media/cyber/9B9E-236C/History.log"

# Output directory (same as script location)
output_dir = os.path.abspath("./")

def sanitize_filename(name):
    name = re.sub(r"[^\w\s-]", "", name).strip()
    return name if name else "unnamed"

def create_hor_file(name, date_str, time_str, tz, lat, lon, place, index):
    try:
        dt = datetime.strptime(date_str.strip() + " " + time_str.strip(), "%d.%m.%Y %H:%M:%S")
    except ValueError:
        print(f"Skipping entry with invalid datetime: {name} | {date_str} {time_str}")
        return

    lat_deg = int(re.search(r'\d+', lat).group()) if lat else 0
    lon_deg = int(re.search(r'\d+', lon).group()) if lon else 0

    hor_content = (
        f"V{name}\n"
        f"p0\n"
        f".I01\n.I0\n.I00\n"
        f".I{dt.year}\n"
        f".I{dt.month}\n"
        f".I{dt.day}\n"
        f".I{dt.hour}\n"
        f".I{dt.minute}\n"
        f".I0\n.I0\n.I0\n"
        f".I01\n.I1\n.I0\n.I01\n"
        f".V{place}\n"
        f"p0\n"
        f".I{lat_deg}\n.I00\n.I0\n.I01\n"
        f".I{lon_deg}\n.I00\n.I0\n.I01\n"
        f".I195\n.V\np0\n."
    )

    filename = sanitize_filename(name) + ".hor"
    filepath = os.path.join(output_dir, filename)
    with open(filepath, "w", encoding="utf-8") as f:
        f.write(hor_content)

# Read and process the file
with open(input_file, "r", encoding="windows-1252", errors="replace") as f:
    for idx, line in enumerate(f):
        if not line.startswith("#"):
            continue
        parts = line.strip("#").split(";")
        if len(parts) < 8:
            continue
        name = parts[1].strip()
        date_str = parts[2].strip()
        time_str = parts[3].strip()
        tz = parts[4].strip()
        lat = parts[5].strip()
        lon = parts[6].strip()
        place = parts[7].strip()

        create_hor_file(name, date_str, time_str, tz, lat, lon, place, idx)

print("✅ All entries processed.")
