--olos o SQL kodikas pou yparxei mesa sta php arxeia

--6a 
--
--to query diamorfonetai analoga me to posa kai poia filtra exei valei o xristis
--parakato fainetai to query se periptosi pou exei symplirosei ola ta filtra, i ola ektos toy product_category
--to query se periptosi pou exei dothei kai sygekrimeni product_category:
SELECT distinct transaction.card_number, transaction.time, transaction.date, transaction.payment_method, transaction.total_cost, transaction.store_id FROM transaction, consists_of, product WHERE store_id = '$storefromform' AND payment_method = '$paymentmethodfromform' AND date = '$datefromform'  AND total_cost >= $totalcostminfromform AND total_cost <= $totalcostmaxfromform  
	AND (card_number, time, date, $productunitsfromform) in (SELECT card_number, time, date, sum(quantity) FROM consists_of GROUP BY card_number, time, date) AND (card_number, time, date) in (SELECT card_number, time, date FROM consists_of GROUP BY card_number, time, date HAVING sum(quantity) >= $productunitsminfromform) AND (card_number, time, date) in (SELECT card_number, time, date FROM consists_of 
	GROUP BY card_number, time, date HAVING sum(quantity) <= $productunitsmaxfromform) AND transaction.card_number = consists_of.card_number AND transaction.date = consists_of.date AND transaction.time = consists_of.time AND consists_of.barcode = product.barcode AND product.category_name = '$productcategoryfromform' 
--to query se periptosi pou den exei dothei product_category:
SELECT * FROM transaction WHERE store_id = '$storefromform' AND payment_method = '$paymentmethodfromform' AND date = '$datefromform'  AND total_cost >= $totalcostminfromform AND total_cost <= $totalcostmaxfromform  AND (card_number, time, date, $productunitsfromform) in (SELECT card_number, time, date, sum(quantity) FROM consists_of GROUP BY card_number, time, date) 
	AND (card_number, time, date) in (SELECT card_number, time, date FROM consists_of GROUP BY card_number, time, date HAVING sum(quantity) >= $productunitsminfromform) AND (card_number, time, date) in (SELECT card_number, time, date FROM consists_of GROUP BY card_number, time, date HAVING sum(quantity) <= $productunitsmaxfromform) 

--6b
--
--oloi i pelates, gia na epileksoume enan
SELECT * FROM customer
--oles oi sinallages toy
SELECT * FROM transaction WHERE card_number = '$cardnumberfromform'
--10 dimofili proionta
SELECT product.barcode, product.product_name, product.category_name, product.store_tag FROM product, (SELECT barcode, sum(quantity) FROM consists_of WHERE card_number = '$cardnumberfromform' GROUP BY barcode) AS top_barcodes(barcode, sumquantity) WHERE product.barcode = top_barcodes.barcode ORDER BY sumquantity DESC limit 10
--posa katastimata episkeptetai
SELECT count(distinct store.store_id) AS result FROM store, transaction WHERE store.store_id = transaction.store_id AND transaction.card_number = '$cardnumberfromform'
--kai poia
SELECT distinct store.store_id, street, number, city, postal_code, opens, closes, square_meters FROM store, transaction WHERE store.store_id = transaction.store_id AND transaction.card_number = '$cardnumberfromform'
--mesos oros ana evdomada
SELECT CONCAT(YEAR(theybought.date), '/', WEEK(theybought.date)) AS week_name, YEAR(theybought.date), WEEK(theybought.date), AVG(theybought.total_cost) AS avg_cost FROM (SELECT * FROM transaction WHERE card_number = '$cardnumberfromform') AS theybought(card_number, time, date, payment_method, total_cost, store_id) GROUP BY week_name ORDER BY YEAR(date) DESC, WEEK(date) DESC
--mesos oros ana mina
SELECT CONCAT(YEAR(theybought.date), '/', MONTH(theybought.date)) AS month_name, YEAR(theybought.date), MONTH(theybought.date), AVG(theybought.total_cost) AS avg_cost FROM (SELECT * FROM transaction WHERE card_number = '$cardnumberfromform') AS theybought(card_number, time, date, payment_method, total_cost, store_id) GROUP BY month_name ORDER BY YEAR(date) DESC, MONTH(date) DESC
--ores pou episkeptetai kathe katastima,
--epanalamvanoume to parakato gia kathe katastima, kai to vazoume sto idio diagramma
SELECT HOUR(theybought.time) AS hour_name, COUNT(*) AS no_of_transactions FROM (SELECT * FROM transaction WHERE card_number = '$cardnumberfromform' AND store_id = '$currentstore') AS theybought(card_number, time, date, payment_method, total_cost, store_id) GROUP BY hour_name ORDER BY hour_name ASC


--6c
--
--dimofili zevgi proionton
SELECT pr1.product_name as prod1, pr2.product_name as prod2, COUNT(*) pairs FROM product as pr1, product as pr2, consists_of AS c1
    JOIN consists_of AS c2 ON c1.time = c2.time and c1.date = c2.date AND c1.Barcode < c2.Barcode
	WHERE pr1.Barcode = c1.Barcode AND pr2.Barcode = c2.Barcode GROUP BY c1.Barcode, c2.Barcode ORDER BY pairs DESC
--dimofileis theseis
SELECT has_products.position as mypos, product.barcode, product.product_name as myname, product.category_name, product.store_tag FROM product, has_products, (SELECT barcode, sum(quantity) FROM consists_of GROUP BY barcode) AS top_barcodes(barcode, sumquantity) WHERE product.barcode = top_barcodes.barcode and top_barcodes.barcode = has_products.barcode and '$storefromform' = has_products.store_id ORDER BY sumquantity DESC
--pososto etiketon
SELECT DISTINCT B.category_name, etiketes*100/ COUNT(B.category_name) over (partition by B.category_name) as pososto_etiketwn FROM 
(SELECT A.category_name, sum(A.tag) over (partition by A.category_name) as etiketes FROM 
(SELECT category_name,product.barcode, store_tag='y' as tag FROM consists_of,product WHERE product.barcode = consists_of.barcode) AS A) AS B
--ores pou ksodevontai perissotera xrimata
SELECT DISTINCT HOUR(`transaction`.time) as timee, sum(total_cost) over (partition by HOUR(`transaction`.time)) as pipis FROM `transaction` ORDER BY pipis DESC
--pososta ana ora gia kathe ilikiaki omada
SELECT B.H as timeee, SUM(CASE WHEN B.age <31 THEN 1 ELSE 0 END)*100.0/count(B.age) as age1,SUM(CASE WHEN B.age>30 and B.age <61 THEN 1 ELSE 0 END)*100.0/count(B.age) as age2,SUM(CASE WHEN B.age>60 THEN 1 ELSE 0 END)*100.0/count(B.age) as age3 FROM 
(SELECT A.H, year(current_date)-customer.birth_year as age FROM customer,
(SELECT HOUR(transaction.time) as H, transaction.card_number FROM transaction) AS A WHERE A.card_number = customer.card_number) AS B GROUP BY B.H order by B.H


--6d
--
--ektiposi toy view me ta sales, diamorfonetai analoga me to an exei dothei katastima i/kai katigoria
SELECT date, time, total_cost, first_name, last_name, payment_method, category_name, store_id FROM sales_view WHERE sales_view.store_id = '$store_idfromform'  AND sales_view.category_name ='$category_namefromform'
--gia tin ektiposi toy view me pelates
SELECT card_number, first_name, last_name, total_points, birth_year, city, street, number, postal_code, family_size, SSN, sex, phone_no FROM customer_view


--6e
--
--eisagogi customer
INSERT INTO customer (card_number, total_points, city, number, street, postal_code, first_name, last_name, SSN, birth_year, sex, family_size, phone_no) VALUES
('$cardnumberfromform', $totalpointsfromform, '$cityfromform' , '$numberfromform', '$streetfromform', '$postalcodefromform', '$firstnamefromform', '$lastnamefromform', '$SSNfromform', $birthyearfromform ,'$sexfromform' , $familysizefromform, $phonenofromform)
--diagrafi customer
DELETE FROM customer WHERE card_number = '$cardnumberfromform'
--enimerosi customer
UPDATE customer SET card_number = '$cardnumberfromform', total_points = $totalpointsfromform, city = '$cityfromform', number = '$numberfromform',
 street = '$streetfromform', postal_code = '$postalcodefromform', first_name = '$firstnamefromform', last_name = '$lastnamefromform', SSN = '$SSNfromform' ,
 birth_year = $birthyearfromform, sex = '$sexfromform', family_size = '$familysizefromform', phone_no = $phonenofromform
WHERE card_number = '$cardnumberfromform'
--eisagosi katastimatos
INSERT INTO store (store_id, square_meters, opens, closes, city, street, number, postal_code) VALUES
('$storeidfromform' , '$squaremetersfromform', '$opensfromform', '$closesfromform' , '$cityfromform', '$streetfromform', '$numberfromform',  '$postalcodefromform' )
--diagrafi katastimatos
DELETE FROM store WHERE store_id = '$storeidfromform'
--enimerosi katastimatos
UPDATE store SET store_id = $storeidfromform, square_meters = '$squaremetersfromform', opens = '$opensfromform', closes = '$closesfromform',
city = '$cityfromform', street = '$streetfromform', number = '$numberfromform', postal_code = '$postalcodefromform'
 WHERE store_id = '$storeidfromform'
--eisagogi proiontos
INSERT INTO product (barcode, product_name, store_tag, category_name) VALUES
('$barcodefromform' , '$productnamefromform', '$storetagfromform', '$categorynamefromform' )
--diagrafi proiontos
DELETE FROM product WHERE barcode = '$barcodefromform'
--enimerosi proiontos
UPDATE product SET barcode = '$barcodefromform', product_name = '$productnamefromform', store_tag = '$storetagfromform', category_name = '$categorynamefromform'
WHERE barcode = '$barcodefromform'


--6f
--
--gia tin ektiposi listas proionton se sigekrimeno katastima
--oste na epileksoume ena
SELECT product.barcode,product.product_name,has_products.current_price FROM product, has_products WHERE has_products.store_id='$storefromform' AND product.barcode=has_products.barcode
--query gia na vroume tin timi pou exei to proion prin tin eisagogi tis neas ->result5
SELECT * FROM has_products WHERE barcode = '$barcodefromform' AND store_id = '$storefromform'			
--query gia na vroume to end date toy proigoumenou kai na to valoume start date aytou pou tha mpei tora sto istoriko ->result1
SELECT end_date FROM old_price WHERE barcode = '$barcodefromform' AND store_id = '$storefromform'		
--eisagogi proigoumenis timis sto istoriko opou
--$rowe = $row1['end_date'];
--$rowst = $row5['current_price'];
INSERT INTO old_price (store_id, barcode, end_date, start_date, price) VALUES ('$storefromform','$barcodefromform', CURRENT_TIMESTAMP, '$rowe', $rowst )
--enimerosi torinis timis
UPDATE has_products SET current_price = $pricefromfrom WHERE barcode='$barcodefromform' AND store_id ='$storefromform'
--emfanisi istorikou
select * from old_price where barcode = '$barcodefromform' AND store_id =' $storefromform'


--6g
--esoda katastimaton
SELECT store.store_id as mystore, sum(transaction.total_cost) as tootal FROM store, transaction WHERE store.store_id = transaction.store_id group by mystore order by tootal DESC
--pososto gynaikon kai antron pou agorazoyn kathe proion
SELECT first.barcode, product.product_name, (first.trans_bywomen * 100.0 / first.total_trans) AS percentage1, (100.0 - (first.trans_bywomen * 100.0 / first.total_trans)) AS percentage2 FROM (SELECT consists_of.barcode, SUM(CASE WHEN customer.sex='f' THEN consists_of.quantity ELSE 0 END), SUM(consists_of.quantity) FROM consists_of, customer WHERE customer.card_number = consists_of.card_number GROUP BY barcode) AS first(barcode, trans_bywomen, total_trans), product WHERE product.barcode = first.barcode


