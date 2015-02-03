# scurl
Download files in splitted parts with curl and merge files back in one file.

#Usage
Download file in given sized parts:
./scurl.sh [ url ]

Download one part of the file:
./scurl.sh [ url ] -p

Merge split parts back in one:
./scurl.sh -m [output_file.name]

