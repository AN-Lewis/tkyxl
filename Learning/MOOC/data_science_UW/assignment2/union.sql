select count(*) from (select term from frequency where docid = '10398_txt_earn' AND count = '1' 
UNION
select term from frequency where docid = '925_txt_trade' AND count = '1');