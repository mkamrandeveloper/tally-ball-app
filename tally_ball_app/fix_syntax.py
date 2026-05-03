import os

lib_dir = "lib"

for root, dirs, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r') as f:
                content = f.read()

            new_content = content.replace('TallyTextStyles.label(context)Yellow', 'TallyTextStyles.labelYellow(context)')
            
            if new_content != content:
                with open(filepath, 'w') as f:
                    f.write(new_content)
                print(f"Fixed syntax in {filepath}")

