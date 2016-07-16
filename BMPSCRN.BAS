TYPE BMPHeadertype
        id AS STRING * 2      'Should be "BM"
        size AS LONG          'Size of the data
        rr1 AS INTEGER        '
        rr2 AS INTEGER        '
        offset AS LONG        'Position of start of pixel data
        horz AS LONG          '
        wid AS INTEGER           'Image width
        hei AS INTEGER           'Image height
        planes AS INTEGER     '
        bpp AS INTEGER        'Should read 8 for a 256 colour image
        pal AS STRING * 768  'Stored as &amp;lt;Blue, Green, Red, 0&amp;gt;
END TYPE
WIDTH 80, 50
PRINT "Searching for BMPs..."
SHELL "dir/s/b *.bmp>list1"
OPEN "\list1" FOR INPUT AS #1
OPEN "list2" FOR RANDOM AS #2 LEN = 126
DIM FileNameZ AS STRING * 126
LOCATE , 52
PRINT "Frmt Chk";
LOCATE , 64
PRINT "Dmnsn Chk";
LOCATE , 74
PRINT "Sz Chk"
DO
        INPUT #1, a$
        a$ = RIGHT$(a$, LEN(a$) - 3)
        PRINT a$;
        DIM BmpHeader AS BMPHeadertype

        OPEN a$ FOR RANDOM AS #3 LEN = LEN(b)
        GET #3, 1, b
        LOCATE , 52

        IF BmpHeader.bpp = 8 AND BmpHeader.id = "BM" AND BmpHeader.offset = 794 THEN 'Check for 8 bit pixel
                COLOR 0, 2
                PRINT "BMPv2 8bit";

                IF BmpHeader.hei <= 200 AND BmpHeader.wid <= 320 THEN
                                FileNameZ = a$ + CHR$(0)
                                PUT #2, , FileNameZ
                                sec% = sec% + INT((LOF(3) + 511) / 512)
                                COLOR 7, 0
                                LOCATE , 74
                                PRINT STR$(INT((LOF(3) + 511) / 512));
                                COLOR 0, 3
                ELSE
                                COLOR 0, 4
                END IF
                LOCATE , 64

                PRINT STR$(BmpHeader.wid); "x"; STR$(BmpHeader.hei)
        ELSE
                COLOR 0, 4
                PRINT "Other"
        END IF
        COLOR 7, 0

        CLOSE #3
LOOP UNTIL EOF(1) OR sec% > 8191-129 ' Make sure there is at least 129 sectors left before drive 1, so that a full 320x200 BMP can be added if we continue the loop
PRINT "Total";
LOCATE , 74
PRINT STR$(sec%)
FileNameZ = ":"
PUT #2, , FileNameZ
CLOSE #2

