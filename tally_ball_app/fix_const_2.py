import os

fixes = {
    "lib/screens/auth/profile_setup_screen.dart": [76, 156],
    "lib/screens/auth/signup_screen.dart": [63],
    "lib/screens/home/dashboard_screen.dart": [82, 174, 190],
    "lib/screens/match/live_match_screen.dart": [146],
    "lib/screens/match/match_setup_screen.dart": [60, 97],
    "lib/screens/practice/live_practice_screen.dart": [231, 277, 303],
    "lib/screens/practice/practice_results_screen.dart": [138],
    "lib/widgets/common.dart": [165]
}

for file, lines in fixes.items():
    filepath = os.path.join(file)
    try:
        with open(filepath, 'r') as f:
            content = f.readlines()
            
        for line in lines:
            idx = line - 1
            # Go backwards from the line to find the nearest 'const ' if it's not on the exact line
            # because sometimes the error is on the method call but the const is on the parent
            for offset in range(5): # search up to 5 lines up
                if idx - offset >= 0 and 'const ' in content[idx - offset]:
                    content[idx - offset] = content[idx - offset].replace('const ', '')
                    break

        with open(filepath, 'w') as f:
            f.writelines(content)
        print(f"Fixed {file}")
    except Exception as e:
        print(e)

