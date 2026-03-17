import os
import shutil

root_dir = os.path.abspath(".")
target_dir = os.path.join(root_dir, "agrobot-inf")

if not os.path.exists(target_dir):
    os.mkdir(target_dir)

for item in os.listdir(root_dir):
    if item in [".git", "agrobot-inf", "move_files.py", "git_out.txt", "git_out2.txt"]:
        continue
    source_path = os.path.join(root_dir, item)
    target_path = os.path.join(target_dir, item)
    try:
        shutil.move(source_path, target_path)
        print(f"Moved {item}")
    except Exception as e:
        print(f"Failed to move {item}: {e}")
