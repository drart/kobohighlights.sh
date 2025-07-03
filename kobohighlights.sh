#!/bin/bash

if [ -n "$KOBOLOCATION" ]; then
    kobolocation="$KOBOLOCATION"
else
    kobolocation="/Volumes/KOBOeReader/.kobo/KoboReader.sqlite"
fi

escape_sql_string() {
    # Escape special characters for safe SQL string interpolation:
    # ' → '' (SQL standard), \ → \\, " → \", ; → \;
    echo "$1" | sed -e "s/'/''/g" -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/;/\\;/g'
}

show_available_books() {
    echo "Available book titles:" >&2
    echo "=====================" >&2
    # Query joins Bookmark table with content table to get book titles with highlights
    sqlite3 "$sqlite_file" "SELECT DISTINCT content.title FROM Bookmark INNER JOIN content on Bookmark.VolumeID = content.ContentID ORDER BY content.title;" >&2
}

select_book_with_fzf() {
    if ! command -v fzf &> /dev/null; then
        echo "fzf not found. Install fzf for interactive book selection." >&2
        echo "" >&2
        show_available_books
        return 1
    fi

    echo "Using fzf to select book..." >&2
    echo "Press Ctrl+C to cancel" >&2
    echo "" >&2
    
    # Query joins Bookmark table with content table to get book titles with highlights
    sqlite3 "$sqlite_file" "SELECT DISTINCT content.title FROM Bookmark INNER JOIN content on Bookmark.VolumeID = content.ContentID ORDER BY content.title;" | fzf --prompt="Select a book: " --height=20 --border
    
    if [ -z "${PIPESTATUS[1]}" ] || [ "${PIPESTATUS[1]}" -ne 0 ]; then
        echo "No book selected. Exiting." >&2
        return 1
    fi
}

extract_highlights() {
    local book_title="$1"
    
    echo "Highlights for: $book_title"
    echo "=========================="
    echo ""
    
    # Query joins Bookmark and content tables: VolumeID links bookmarks to their source books
    local highlights
    highlights=$(sqlite3 "$sqlite_file" "SELECT Bookmark.Text FROM Bookmark INNER JOIN content on Bookmark.VolumeID = content.ContentID WHERE content.title = '$(escape_sql_string "$book_title")';")
    
    if [ -z "$highlights" ]; then
        echo "Error: No highlights found for book '$book_title'"
        echo ""
        show_available_books
        return 1
    fi
    
    echo "$highlights" | pbcopy
    echo "Highlights successfully copied to system buffer!"
}

usage() {
    echo "Usage: $0 [-f sqlite_file] [book_title]"
    echo ""
    echo "Options:"
    echo "  -f, --file FILE    Path to custom Kobo SQLite database file"
    echo "  -h, --help         Show this help message"
    echo ""
    echo "Arguments:"
    echo "  book_title         Optional book title to extract highlights from"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Use default location, select with fzf"
    echo "  $0 \"Book's \\\"Great\\\" Title\"            # Use default location, book with special characters"
    echo "  $0 -f /custom/path/KoboReader.sqlite  # Use custom file, select with fzf"
    echo "  $0 -f /custom/path/KoboReader.sqlite \"Book's Title\"  # Use custom file, specific book"
    echo ""
    echo "Default SQLite location: $kobolocation"
    echo "Set KOBOLOCATION environment variable to change default location"
    exit 0
}

validate_sqlite_file() {
    if [ ! -f "$sqlite_file" ]; then
        echo "Error: SQLite file not found at: $sqlite_file"
        if [ "$sqlite_file" = "$kobolocation" ]; then
            echo ""
            echo "The default Kobo location is not accessible."
            echo "Please ensure your Kobo device is connected, or use the -f flag to specify a custom location:"
            echo "  $0 -f /path/to/your/KoboReader.sqlite"
        fi
        exit 1
    fi
}

sqlite_file=""
booktitle=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--file)
            [ -z "$2" ] && { echo "Error: -f flag requires a file path"; usage; }
            sqlite_file="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        -*)
            echo "Error: Unknown option $1"
            usage
            ;;
        *)
            [ -n "$booktitle" ] && { echo "Error: Multiple book titles specified. Please provide only one."; usage; }
            booktitle="$1"
            shift
            ;;
    esac
done

[ -z "$sqlite_file" ] && sqlite_file="$kobolocation"

validate_sqlite_file

echo "Using SQLite file: $sqlite_file"
echo ""

if [ -n "$booktitle" ]; then
    extract_highlights "$booktitle"
else
    selected_book=$(select_book_with_fzf) && extract_highlights "$selected_book"
fi
