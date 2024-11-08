# Run this script from the episodes folder:
#    python3 ./fig/docker-desktop/automation/tabs_instead_of_gifs.py

import re, os

# File where gifs are being used
Rmd_file = "docker-desktop.Rmd"
# Path to the directory where gif files live
gif_path = "fig/docker-desktop/"
# Path to the directory where dirs of screenshots that form the gifs live
png_path = "fig/docker-desktop/cropped_screenshots/gifs/"

content = ""
with open("docker-desktop.Rmd", "r") as file:

    # Find all gifs and their alt text
    content = file.read()
    matches = re.findall(r"!.*?\.gif.*\n", content)
    gifs = [match.split("{")[0][4 + len(gif_path) : -5] for match in matches]
    alts = [match.split("{")[1][5:-4] for match in matches]

    # Generate replacement text (tab structure)
    for k, gif in enumerate(gifs):
        pngs = sorted(os.listdir(f"{png_path}/{gif}"))
        replacement_text = f"::: tab\n\n"
        for i, png in enumerate(pngs):
            replacement_text += f"### Step {i+1}\n"
            replacement_text += (
                f"![]({png_path}/{gif}/{png}){{alt='{alts[k]} - Step {i+1}'}}\n\n"
            )
        replacement_text += ":::\n"

        # Replace on memory
        # print(f"Replacing:\n{matches[k]}\nWith:\n{replacement_text}")
        content = content.replace(matches[k], replacement_text)

# Write to file
with open("docker-desktop.Rmd", "w") as file:
    file.write(content)
