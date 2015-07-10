select count(s) from (select docid, sum(count) as s from frequency GROUP BY docid) where s > 300;

