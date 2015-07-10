SELECT vlu FROM
(
SELECT a.row_num as i , b.col_num as j , SUM(a.value * b.value) as vlu
  FROM a, b
 WHERE a.col_num = b.row_num
 GROUP BY a.row_num, b.col_num
)
 
 where i = 2 AND j = 3;