# Kobo Highlights Extractor

A bash script to extract highlights from Kobo e-reader devices and copy them directly to your clipboard.

## How It Works

1. **Connects to Kobo database** - Reads the SQLite database from your connected Kobo device
2. **Queries highlights** - Joins the `Bookmark` and `content` tables to find highlights for books
3. **Interactive selection** - Uses fzf for fuzzy finding if available and no book title is specified
4. **Copies to clipboard** - Automatically copies all highlights to your system clipboard using `pbcopy`

## Requirements

- **macOS** (uses `pbcopy` for clipboard functionality)
- **SQLite3** (typically pre-installed on macOS)
- **fzf** (optional, for interactive book selection) - Install with `brew install fzf`
- **Connected Kobo device** or access to Kobo database file

## Usage

```bash
# Interactive selection with fzf (recommended)
./extractHighlights.sh

# Extract specific book
./extractHighlights.sh "Book Title"

# Use custom database location
./extractHighlights.sh -f /path/to/KoboReader.sqlite

# Works with special characters
./extractHighlights.sh "Reader's \"Great\" Book; Volume 1"
```

## Installation

```bash
chmod +x extractHighlights.sh
```

## Acknowledgments

Inspired by [kobo_annotations](https://github.com/pterodactylptarty/kobo_annotations)
