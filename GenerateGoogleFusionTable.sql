drop table data;
CREATE TABLE data AS 
  SELECT tx.frequency                     AS frequency, 
         tx.licence_no                    AS licence_no, 
         licencee                         AS licencee, 
         description                      AS description, 
         tx.name                          AS tx_name, 
         tx.latitude                      AS tx_lat, 
         tx.longitude                     AS tx_long, 
         NULL                             AS tx_antenna_type, 
         rx.name                          AS rx_name, 
         rx.latitude                      AS rx_lat, 
         rx.longitude                     AS rx_long, 
         NULL                             AS rx_antenna_type, 
         '<LineString><coordinates>' || tx.longitude || ',' || tx.latitude || ' ' || rx.longitude || ',' || rx.latitude || '</coordinates></LineString>' AS xml 
  FROM   (SELECT d.licence_no, 
                 d.frequency, 
                 d.device_type, 
                 d.efl_id, 
                 d.related_efl_id, 
                 s.latitude, 
                 s.longitude, frequency
                 s.name, 
                 c.licencee, 
                 ic.description 
          FROM   device_details d 
                 inner join site s 
                         ON d.site_id = s.site_id 
                 inner join licence l 
                         ON d.licence_no = l.licence_no 
                 inner join client c 
                         ON l.client_no = c.client_no 
                 inner join industry_cat ic 
                         ON c.cat_id = ic.cat_id) tx 
         inner join (SELECT d.licence_no, 
                            d.frequency, 
                            d.device_type, 
                            d.efl_id, 
                            d.related_efl_id, 
                            s.latitude, 
                            s.longitude, 
                            s.name 
                     FROM   device_details d 
                            inner join site s 
                                    ON d.site_id = s.site_id) rx 
                 ON tx.efl_id = rx.related_efl_id 
  WHERE  tx.latitude <> rx.latitude 
         AND tx.longitude <> rx.longitude 
  ORDER  BY rx.name; 