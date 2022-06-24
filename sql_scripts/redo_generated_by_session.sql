set pages 22 lines 80
 ---ttitle off
 COLUMN value  FORMAT 999999999999 HEADING "value"
 prompt
 prompt +----------------------------------------------------+
 prompt | AMOUNT OF REDO GENERATED BY SESSION
 prompt +----------------------------------------------------+
 select sid, value
 from v$sesstat s, v$statname n
 where n.statistic# = s.statistic#
 and n.name = 'redo size'
 and rownum <=10
 order by value desc;
