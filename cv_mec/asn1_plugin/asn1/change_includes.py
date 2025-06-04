import os
import re

# Directory to search for .c and .h files
directory = '/build/src/generated-files/2024'

# Regular expression to find #include <...>
include_pattern = re.compile(r'#include <(.*)>')

def replace_includes(file_path):
    with open(file_path, 'r') as file:
        content = file.read()

    # Replace angle bracket includes with quotes
    new_content = include_pattern.sub(r'#include "\1"', content)

    with open(file_path, 'w') as file:
        file.write(new_content)

# Walk through the directory
for root, _, files in os.walk(directory):
    for file in files:
        if file.endswith('.c') or file.endswith('.h'):
            file_path = os.path.join(root, file)
            replace_includes(file_path)
            print(f'Processed {file_path}')

print('Finished processing all files.')
