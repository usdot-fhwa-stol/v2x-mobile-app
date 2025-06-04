import os
import re

def find_files_with_capital_imports(directory):
    """
    Recursively searches for files in the given directory that contain 'import' lines with capital letters,
    excluding lines that contain "as C".

    Args:
        directory (str): Path to the directory to search.

    Returns:
        List[str]: List of file paths that match the criteria.
    """
    matching_files = []

    # Regular expression to match import lines with capital letters, excluding lines with "as C"
    import_pattern = re.compile(r"^\s*import\s+.*[A-B,D-Z].*;(?!.*\sas\sC\b;)", re.MULTILINE)

    for root, _, files in os.walk(directory):
        for file in files:
            file_path = os.path.join(root, file)
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    if import_pattern.search(content):
                        matching_files.append(file_path)
            except (UnicodeDecodeError, OSError) as e:
                print(f"Could not read file: {file_path}, Error: {e}")

    return matching_files

if __name__ == "__main__":
    # Directory to search
    directory_to_search = input("Enter the directory to search: ").strip()

    if not os.path.isdir(directory_to_search):
        print(f"Error: {directory_to_search} is not a valid directory.")
    else:
        print("Scanning for files containing import lines with capital letters...\n")
        result_files = find_files_with_capital_imports(directory_to_search)

        if result_files:
            print("Files containing import lines with capital letters:")
            for file in result_files:
                print(file)
        else:
            print("No files with capital-letter import lines were found.")

