---Вывести информацию обо всех депо, имеющих свободные электрифицированные пути.
SELECT DISTINCT d.* 
FROM depo d
JOIN tracks t ON d.depo_number = t.depo_number
WHERE t.is_track_free = TRUE AND t.is_electrified = TRUE;

---Вывести информацию обо всех свободных путях длиной более 100 м, находящихся в Краснопресненском трамвайном депо.
SELECT t.* 
FROM tracks t
JOIN depo d ON t.depo_number = d.depo_number
WHERE d.name = 'Краснопресненское трамвайное депо' 
  AND t.is_track_free = TRUE 
  AND t.track_length > 100;

---Создать таблицу, содержащую данные 1 запроса с указанием информации о путях в этих депо.
SELECT d.depo_number, 
       d.name AS depo_name, 
       d.address, 
       d.contact_phone, 
       d.parking_spaces, 
       d.repair_spaces,
       t.track_number, 
       t.purpose, 
       t.track_length, 
       t.is_track_free, 
       t.is_electrified
INTO Depot_Tracks_Report
FROM depo d
JOIN tracks t ON d.depo_number = t.depo_number
WHERE t.is_track_free = TRUE AND t.is_electrified = TRUE;

---Добавить в созданную таблицу депо, в которых нет ни одного пути для ремонта трамваев.
INSERT INTO Depot_Tracks_Report (depo_number, depo_name, address, contact_phone, parking_spaces, repair_spaces)
SELECT depo_number, name, address, contact_phone, parking_spaces, repair_spaces
FROM depo
WHERE depo_number NOT IN (
    SELECT depo_number FROM tracks WHERE purpose LIKE '%Ремонтный%'
);

---В созданной таблице поменять местами количества парковочных и ремонтных мест во всех депо.
UPDATE Depot_Tracks_Report 
SET parking_spaces = repair_spaces, 
    repair_spaces = parking_spaces;

---Удалить из созданной таблицы все депо, имеющие свободные пути.
DELETE FROM Depot_Tracks_Report
WHERE depo_number IN (
    SELECT depo_number FROM tracks WHERE is_track_free = TRUE
);

---Посчитать количество путей и среднюю длину пути для каждого депо.
SELECT d.name AS depo_name, 
       COUNT(t.track_number) AS total_tracks, 
       ROUND(AVG(t.track_length), 2) AS avg_length
FROM depo d
LEFT JOIN tracks t ON d.depo_number = t.depo_number
GROUP BY d.name;