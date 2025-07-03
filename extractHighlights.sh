#!/bin/bash
#
#sqlite3 Mar1.sqlite "SELECT Bookmark.Text  FROM Bookmark INNER JOIN content on Bookmark.VolumeID = content.ContentID WHERE content.title LIKE 'The Overstory';"

# sqlite3 Mar1.sqlite "SELECT Bookmark.Text  FROM Bookmark INNER JOIN content on Bookmark.VolumeID = content.ContentID WHERE content.title LIKE 'The Overstory';"

# arg 1 sqlite file
# arg 2 book
#
#
#
#
kobolocation=/Volumes/Kobo/.kobo/KoboReader.sqlite

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
fi

if [ $# -eq 1 ]
  then
    # echo "output book title"
    # echo $1
    sqlite3 $1 "SELECT DISTINCT content.title FROM Bookmark INNER JOIN content on Bookmark.VolumeID = content.ContentID;"
fi

if [ $# -eq 2 ]
  then
    # echo "output book annotations"
    # echo $2
    booktitle=$2
    export booktitle
    sqlite3 $1 "SELECT Bookmark.Text  FROM Bookmark INNER JOIN content on Bookmark.VolumeID = content.ContentID WHERE content.title LIKE '$booktitle';"
fi
