select DISTINCT r.PTNT_LST_NAM, r.PTNT_FST_NAM, r.MED_REC_NUM,  RTRIM(c.ANTGN_CD) + ' ' + a.INTPRTN_CD COLLATE sql_latin1_general_cp1_cs_as AS ANTIGENS 
from PTNT_ANTGN a                  
--join PTNT_MST m
--ON r.intnl_ptnt_num = m.INTNL_PTNT_NUM
join PTNT_RGSTRTN r
ON a.intnl_ptnt_num = r.INTNL_PTNT_NUM
JOIN ANTGN_CD c
ON a.intnl_antgn_num = c.INTNL_ANTGN_NUM
Where r.PTNT_LST_NAM LIKE 'CHAPMAN%' AND r.PTNT_FST_NAM LIKE 'K%' AND a.CNL_DTTM IS NULL AND (r.MRG_UNMRG_IND IS NULL OR r.MRG_UNMRG_IND = 'M')
ORDER BY r.PTNT_LST_NAM, r.PTNT_FST_NAM
;





WITH detail AS
(
	select DISTINCT
		r.intnl_ptnt_num,
		r.MED_REC_NUM, 
		(RTRIM(r.PTNT_FST_NAM) + ' ' + RTRIM(r.PTNT_LST_NAM)) full_name
	from PTNT_RGSTRTN r
	where (r.MRG_UNMRG_IND IS NULL OR r.MRG_UNMRG_IND = 'M')
),
antigen AS
(
	select DISTINCT a.intnl_ptnt_num, RTRIM(REPLACE(c.ANTGN_CD, ' ', '') + ' ' + a.INTPRTN_CD) COLLATE sql_latin1_general_cp1_cs_as AS ANTIGEN 
	from PTNT_ANTGN a                  
	JOIN ANTGN_CD c
	ON a.intnl_antgn_num = c.INTNL_ANTGN_NUM
	Where  a.CNL_DTTM IS NULL
	and EXISTS
	(
		select D.intnl_ptnt_num
		from DETAIL D   
		where  D.intnl_ptnt_num = A.intnl_ptnt_num           
	)
)
SELECT DISTINCT 
	dt1.MED_REC_NUM,
	stuff( (SELECT ', ' + dt2.full_name
			FROM detail dt2
			WHERE dt2.intnl_ptnt_num = dt1.intnl_ptnt_num
			GROUP BY dt2.full_name
			ORDER BY dt2.full_name
			FOR XML PATH(''), TYPE).value('.', 'varchar(max)')
		,1,1,'') full_names,
	stuff( (SELECT ', ' + a2.antigen
			FROM antigen a2
			WHERE a2.intnl_ptnt_num = a1.intnl_ptnt_num
			GROUP BY a2.antigen
			ORDER BY a2.antigen
			FOR XML PATH(''), TYPE).value('.', 'varchar(max)')
		,1,1,'') antigens
FROM detail dt1
JOIN antigen a1
	ON a1.INTNL_PTNT_NUM = dt1.INTNL_PTNT_NUM
ORDER BY dt1.MED_REC_NUM
;


   CROSS APPLY ( SELECT a2.antigen + ',' 
                     FROM antigen a2
                     WHERE a1.INTNL_PTNT_NUM = a2.INTNL_PTNT_NUM
                     ORDER BY a2.antigen 
                     FOR XML PATH('') )  D ( Antigens )

	SELECT 
		t.intnl_ptnt_num,
		t.MED_REC_NUM,
		 STUFF(
		  (
			select ',' + d.ANTIGEN
			FROM antigen d
			where t.MED_REC_NUM=d.MED_REC_NUM
			group by d.ANTIGEN for xml path('')
		), 1, 2, '') as ANTIGENS
	FROM antigen t

,
antigen_list AS
(
	SELECT 
		pr.intnl_ptnt_num,
		pr.MED_REC_NUM,
		 STUFF(
		  (
			select ',' + d.ANTIGEN
			FROM antigen d
			where t.MED_REC_NUM=d.MED_REC_NUM
			group by d.ANTIGENS for xml path('')
		), 1, 2, '') as ANTIGENS
	FROM antigen t
)

select r.PTNT_LST_NAM, r.PTNT_FST_NAM, r.MED_REC_NUM,
 STUFF(
      (
        select ',' + d.ANTIGENS
		FROM #temp d
        where t.MED_REC_NUM=d.MED_REC_NUM
group by d.ANTIGENS for xml path('')
        ), 1, 2, '') as ANTIGENS1
	from #temp t
from antigens a                  
join PTNT_RGSTRTN r
	ON a.intnl_ptnt_num = r.INTNL_PTNT_NUM





SELECT 
pr.PTNT_LST_NAM, pr.PTNT_FST_NAM, pr.MED_REC_NUM, pr.ANTIGENS
FROM
(
	select DISTINCT r.PTNT_LST_NAM, r.PTNT_FST_NAM, r.MED_REC_NUM, a.intnl_antgn_num, REPLACE(c.ANTGN_CD, ' ', '') + ' ' + a.INTPRTN_CD AS ANTIGENS
	from PTNT_ANTGN a                  
	--join PTNT_MST m
	--ON r.intnl_ptnt_num = m.INTNL_PTNT_NUM
	join PTNT_RGSTRTN r
	ON a.intnl_ptnt_num = r.INTNL_PTNT_NUM
	JOIN ANTGN_CD c
	ON a.intnl_antgn_num = c.INTNL_ANTGN_NUM
	Where r.PTNT_LST_NAM LIKE 'CHAPMAN%' AND r.PTNT_FST_NAM LIKE 'K%' AND a.CNL_DTTM IS NULL AND (r.MRG_UNMRG_IND IS NULL OR r.MRG_UNMRG_IND = 'M')
) pr
ORDER BY pr.PTNT_LST_NAM, pr.PTNT_FST_NAM
;

EXEC sp_columns ANTGN_CD;




select DISTINCT r.PTNT_LST_NAM, r.PTNT_FST_NAM, r.MED_REC_NUM, a.intnl_antgn_num, 
substring(c.ANTGN_CD,charindex('',c.ANTGN_CD)+1, LEN(c.ANTGN_CD)) + ' ' + a.INTPRTN_CD
--CONVERT(VARCHAR,RTRIM(LTRIM(c.ANTGN_CD))) antgn_cd, 
	
from PTNT_ANTGN a                  
--join PTNT_MST m
--ON r.intnl_ptnt_num = m.INTNL_PTNT_NUM
join PTNT_RGSTRTN r
ON a.intnl_ptnt_num = r.INTNL_PTNT_NUM
JOIN ANTGN_CD c
ON a.intnl_antgn_num = c.INTNL_ANTGN_NUM
Where r.PTNT_LST_NAM LIKE 'CHAPMAN%' AND r.PTNT_FST_NAM LIKE 'K%' AND a.CNL_DTTM IS NULL AND (r.MRG_UNMRG_IND IS NULL OR r.MRG_UNMRG_IND = 'M')



IF OBJECT_ID('tempdb..#temp') IS NOT NULL                                                
DROP TABLE #temp                                                     

select DISTINCT r.PTNT_LST_NAM r.PTNT_FST_NAM, r.MED_REC_NUM,  RTRIM(c.ANTGN_CD) + ' ' + a.INTPRTN_CD COLLATE sql_latin1_general_cp1_cs_as AS ANTIGENS 
INTO #TEMP
from PTNT_ANTGN a                  
--join PTNT_MST m
--ON r.intnl_ptnt_num = m.INTNL_PTNT_NUM
join PTNT_RGSTRTN r
ON a.intnl_ptnt_num = r.INTNL_PTNT_NUM
JOIN ANTGN_CD c
ON a.intnl_antgn_num = c.INTNL_ANTGN_NUM
Where r.PTNT_LST_NAM LIKE 'CHAPMAN%' AND r.PTNT_FST_NAM LIKE 'K%' AND a.CNL_DTTM IS NULL AND (r.MRG_UNMRG_IND IS NULL OR r.MRG_UNMRG_IND = 'M')
;


--select * from #temp




select distinct PTNT_LST_NAM, PTNT_FST_NAM, MED_REC_NUM, 
	stuff( (SELECT ', ' + a.ANTIGENS
			FROM #temp a
			WHERE t.MED_REC_NUM=a.MED_REC_NUM
			ORDER BY a.antigens
			FOR XML PATH(''), TYPE).value('.', 'varchar(max)')
		,1,1,'') as ANTIGENS1
	from #temp t


SELECT * FROM #TEMP

	select PTNT_LST_NAM, PTNT_FST_NAM,MED_REC_NUM,
	STUFF(
			(
				select ',' + STR(d.intnl_antgn_num)
				FROM #temp d
				where t.MED_REC_NUM=d.MED_REC_NUM
				group by d.intnl_antgn_num for xml path('')
			), 1, 2, '') as ANTIGEN_NUMS,
	STUFF(
			(
			select ', ' + d.ANTIGENS FROM #temp d
				  where t.MED_REC_NUM=d.MED_REC_NUM
				group by d.ANTIGENS for xml path('')
			), 1, 2, '') as ANTIGEN_LIST
	from #temp t