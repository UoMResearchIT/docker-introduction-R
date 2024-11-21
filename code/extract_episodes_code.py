# Script to extract code blocks to be used for teaching notes
# Usage:
#   From the repository's base directory, call as:
#       python3 code/extract_episodes_code.py

import os


def extract_episodes_code(
    episode_names=None, output_dir="code/episodes", with_blocks=True, quiet=False
):
    # Create the list of episode files if not provided
    if episode_names is None:
        episode_files = [f for f in os.listdir("episodes") if f.endswith(".Rmd")]
        episode_names = [os.path.join("episodes", f) for f in episode_files]

    # Create the "code" folder if it does not exist
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # Extract the code blocks, headers and image alt text from each episode
    for episode_name in episode_names:
        if not quiet:
            print(f"Processing episode {episode_name}")

        # Read the file content
        with open(episode_name, "r") as episode_file:
            lines = episode_file.readlines()

        in_code_block = False
        code_blocks = []
        code_block = []

        for line in lines:
            # Check for the start of a code block
            if not in_code_block:
                # Adds headers
                if line.startswith("#"):
                    code_blocks.append(line.rstrip())
                # Adds empty lines with ::: delimiters
                if line.startswith(":::"):
                    if "challenge" in line:
                        code_blocks.append("\n# ! Challenge:")
                    elif "solution" in line:
                        code_blocks.append("# !! Solution:")
                    else:
                        code_blocks.append("")
                # Adds image alt text
                if line.startswith("!"):
                    alt_text = line.rstrip().split("alt")[1][2:-2]
                    code_blocks.append(f"Image: {alt_text}")
                # Starts code_block
                if line.startswith("```") and len(line.strip()) > 3:
                    in_code_block = True
            if in_code_block:
                # Accumulate lines within the code block
                code_block.append(line.rstrip())
                if line.strip() == "```":
                    in_code_block = False
                    # Skip outputs
                    if not code_block[0].strip() == ("```output"):
                        # Append full code_block to code_blocks array
                        if with_blocks:
                            code_blocks.append("\n".join(code_block))
                        else:
                            code_blocks.append("\n".join(code_block[1:-1]))
                    code_block = []

        # Write code blocks to markdown file
        output_file_name = os.path.join(
            output_dir, os.path.basename(episode_name).replace(".Rmd", ".md")
        )
        with open(output_file_name, "w") as out_file:
            for block in code_blocks:
                out_file.write(block + "\n")

        if not quiet:
            print(f"Saved code blocks to {output_file_name}")


if __name__ == "__main__":
    extract_episodes_code()
