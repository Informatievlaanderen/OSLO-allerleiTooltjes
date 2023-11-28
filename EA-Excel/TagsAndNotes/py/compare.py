import pandas as pd

def compare_excel_files(file1, file2):
    # Read the Excel files
    df1 = pd.read_excel(file1, engine='openpyxl')
    df2 = pd.read_excel(file2, engine='openpyxl')

    # Ensure the first column is the index
    df1.set_index(df1.columns[0], inplace=True)
    df2.set_index(df2.columns[0], inplace=True)

    # Find the minimum number of columns in both DataFrames
    min_columns = min(len(df1.columns), len(df2.columns))

    # Iterate through each row and cell to find differences
    for row_number, (index, row) in enumerate(df2.iterrows(), start=1):
        if index in df1.index:
            for col_idx in range(min_columns):
                if row.iloc[col_idx] != df1.iloc[df1.index.get_loc(index), col_idx]:
                    print(f"Row Number: {row_number}, Index: {index}, Column Number: {col_idx + 1}, Value in First File: {df1.iloc[df1.index.get_loc(index), col_idx]}")
                    change_cell_background_to_red(file2, 'TagsAndNotes', row_number, col_idx + 1)
        else:
            print(f"New row in second file: Row Number: {row_number}, Index: {index}")

def change_cell_background_to_red(file_path, sheet_name, row, column):
    """
    Opens an .xlsm file and changes the background color of a specified cell to red.
    """
    try:
        if is_file_open(file_path):
            print("File is currently open. Closing it now.")
            os.system(f'taskkill /f /im excel.exe')

            # Wait a bit to ensure Excel has been closed
            time.sleep(5)

        # Load the workbook
        workbook = openpyxl.load_workbook(file_path, keep_vba=True)
        sheet = workbook[sheet_name]

        # Convert row and column to cell address
        cell_address = f"{get_column_letter(column)}{row}"

        # Change the cell's background color to red
        red_fill = PatternFill(start_color='FFFF0000',
                               end_color='FFFF0000',
                               fill_type='solid')
        cell = sheet[cell_address]
        cell.fill = red_fill

        # Save the changes
        workbook.save(file_path)


    except FileNotFoundError:
        print(f"File not found: {file_path}")
    except KeyError:
        print(f"Sheet '{sheet_name}' not found in the workbook.")
    except Exception as e:
        print(f"An error occurred: {e}")

# Example usage
file1 = './to/TagsAndNotes.xlsm'
file2 = './from/TagsAndNotes.xlsm'
compare_excel_files(file1, file2)

