import os
import re

lib_dir = "lib"

# Mappings for colors
color_pattern = re.compile(r'TallyColors\.(\w+)')

# Mappings for text styles (since we changed them from const variables to methods taking context)
# e.g. TallyTextStyles.heading1 -> TallyTextStyles.heading1(context)
style_pattern = re.compile(r'TallyTextStyles\.(heading1|heading2|heading3|scoreDisplay|scoreMedium|scriptAccent|bodyLarge|bodyMedium|bodySmall|label|labelYellow|button)(?!Legacy|\()')

for root, dirs, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart') and file != 'theme.dart':
            filepath = os.path.join(root, file)
            with open(filepath, 'r') as f:
                content = f.read()

            # Replace TallyColors.xyz -> context.colors.xyz
            new_content = color_pattern.sub(r'context.colors.\1', content)
            
            # Replace TallyTextStyles.xyz -> TallyTextStyles.xyz(context)
            new_content = style_pattern.sub(r'TallyTextStyles.\1(context)', new_content)

            if new_content != content:
                # Make sure theme.dart is imported since context.colors is an extension in theme.dart
                if 'import' in new_content and 'config/theme.dart' not in new_content:
                    # add import if it's missing, though mostly it uses relative imports
                    pass # We will rely on existing imports, or flutter analyze to find missing

                with open(filepath, 'w') as f:
                    f.write(new_content)
                print(f"Refactored {filepath}")

print("Refactoring complete.")
