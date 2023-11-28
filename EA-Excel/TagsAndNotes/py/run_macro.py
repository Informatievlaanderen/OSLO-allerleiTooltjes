import win32com.client as win32

def run_excel_macro(file_path, macro_name):
    """
    Run a macro in a given Excel file via Python.

    :param file_path: Path to the Excel file containing the macro
    :param macro_name: Name of the macro to run
    """
    try:
        excel = win32.Dispatch('Excel.Application')
        excel.Visible = True  # Keep Excel in the background

        workbook = excel.Workbooks.Open(Filename=file_path, ReadOnly=1)
        excel.Application.Run(f'{file_path}!{macro_name}')
        #workbook.Close(SaveChanges=False)

        #excel.Application.Quit()
        #del excel

    except Exception as e:
        print(f"Error running macro: {e}")

# Example usage
run_excel_macro('C:/Users/samue/Documents/OSLO Tools/EA-Excel/TagsAndNotes/TagsAndNotes.xlsm', 'PullFromEA')
