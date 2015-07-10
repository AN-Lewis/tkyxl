select SUM(total) from (select a.count*b.count total from frequency a, frequency b where a.docid='10080_txt_crude' and b.docid='17035_txt_earn' and a.term=b.term group by a.term,b.term);

