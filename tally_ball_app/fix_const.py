import re
import subprocess

def run_analyze():
    print("Running flutter analyze...")
    result = subprocess.run(['flutter', 'analyze'], capture_output=True, text=True)
    return result.stdout + "\n" + result.stderr

def fix_errors():
    output = run_analyze()
    lines = output.split('\n')
    
    files_to_fix = {}
    
    # Parse errors like:
    # error • Invalid constant value • lib/screens/match/match_setup_screen.dart:30:134 • invalid_constant
    pattern = re.compile(r'error • Invalid constant value •\s+(lib/.*?):(\d+):(\d+) • invalid_constant')
    
    for i, line in enumerate(lines):
        if 'error • Invalid constant value •' in line:
            # The next line contains the file path and line number
            if i + 1 < len(lines):
                next_line = lines[i+1].strip()
                # Try to parse from the same line or next line
                match = pattern.search(line + " " + next_line)
                if match:
                    filepath = match.group(1).strip()
                    linenum = int(match.group(2))
                    colnum = int(match.group(3))
                    
                    if filepath not in files_to_fix:
                        files_to_fix[filepath] = []
                    files_to_fix[filepath].append((linenum, colnum))
                    continue
                    
        # Or parse directly from the same line if it's there
        match = re.search(r'(lib/.*?\.dart):(\d+):(\d+) • invalid_constant', line)
        if match:
            filepath = match.group(1).strip()
            linenum = int(match.group(2))
            colnum = int(match.group(3))
            
            if filepath not in files_to_fix:
                files_to_fix[filepath] = []
            files_to_fix[filepath].append((linenum, colnum))

    # Apply fixes
    for filepath, errors in files_to_fix.items():
        try:
            with open(filepath, 'r') as f:
                content_lines = f.readlines()
            
            # Sort errors in descending order so modifications don't shift positions
            errors.sort(key=lambda x: (x[0], x[1]), reverse=True)
            
            for linenum, colnum in errors:
                line_idx = linenum - 1
                if line_idx < len(content_lines):
                    line = content_lines[line_idx]
                    # We need to remove the word 'const' around this column
                    # The column points to the start of the invalid constant expression
                    # Usually it's `const Widget(...)`
                    
                    # We'll just replace 'const ' with '' on this line if it's there
                    if 'const ' in line:
                        # Find the last 'const ' before colnum
                        # Alternatively, just replace all 'const ' on this line as a brute force fix
                        # since if one is invalid, it's safer to remove it.
                        content_lines[line_idx] = line.replace('const ', '')
            
            with open(filepath, 'w') as f:
                f.writelines(content_lines)
            print(f"Fixed const errors in {filepath}")
        except Exception as e:
            print(f"Failed to fix {filepath}: {e}")

fix_errors()
