OPEN "7b1.com" FOR RANDOM AS #1 LEN = 16
DIM a AS STRING * 16
GET #1, 1, a
OPEN "bs-blc" FOR RANDOM AS #2 LEN = 16
PUT #2, 1, a
CLOSE #1
OPEN "bmp-blc.com" FOR RANDOM AS #1 LEN = 16
FOR t = 1 TO LOF(1) / 16
        GET #1, , a
        PUT #2, , a
NEXT

