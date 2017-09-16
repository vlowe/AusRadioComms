DROP TABLE data; 
CREATE TABLE data AS 
SELECT     tx.frequency  AS frequency, 
           tx.licence_no AS licence_no, 
           licencee      AS licencee, 
           description   AS description, 
           tx.name       AS tx_name, 
           tx.latitude   AS tx_lat, 
           tx.longitude  AS tx_long, 
           NULL          AS tx_antenna_type, 
           rx.name       AS rx_name, 
           rx.latitude   AS rx_lat, 
           rx.longitude  AS rx_long, 
           NULL          AS rx_antenna_type, 
           '<LineString><coordinates>' || tx.longitude || ',' || tx.latitude || ' ' || rx.longitude || ',' || rx.latitude || '</coordinates></LineString>' AS xml 
FROM       ( 
                      SELECT     d.licence_no, 
                                 CASE 
                                            WHEN d.frequency > 1e9 THEN Cast(d.frequency / 1e9 AS VARCHAR) || ' GHz' 
                                            WHEN d.frequency > 1e6 THEN Cast(d.frequency / 1e6 AS VARCHAR) || ' MHz' 
                                            ELSE Cast(d.frequency AS VARCHAR) || ' Hz' 
                                 END AS frequency, 
                                 d.device_type, 
                                 d.efl_id, 
                                 d.related_efl_id, 
                                 s.latitude, 
                                 s.longitude, 
                                 s.name, 
                                 c.licencee, 
                                 ic.description 
                      FROM       device_details d 
                      INNER JOIN site s 
                      ON         d.site_id = s.site_id 
                      INNER JOIN licence l 
                      ON         d.licence_no = l.licence_no 
                      INNER JOIN client c 
                      ON         l.client_no = c.client_no 
                      INNER JOIN industry_cat ic 
                      ON         c.cat_id = ic.cat_id) tx 
INNER JOIN 
           ( 
                      SELECT     d.licence_no, 
                                 d.frequency, 
                                 d.device_type, 
                                 d.efl_id, 
                                 d.related_efl_id, 
                                 s.latitude, 
                                 s.longitude, 
                                 s.name 
                      FROM       device_details d 
                      INNER JOIN site s 
                      ON         d.site_id = s.site_id) rx 
ON         tx.efl_id = rx.related_efl_id 
WHERE      tx.latitude <> rx.latitude 
AND        tx.longitude <> rx.longitude 
ORDER BY   rx.name;