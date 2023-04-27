--categories

CREATE OR REPLACE FUNCTION add_category(d_title character varying, d_ptitle character varying) RETURNS RECORD AS $$
DECLARE
	par_id integer;
	max_num integer;
	d_attrs RECORD;
BEGIN
	IF d_ptitle IS NULL THEN SELECT null INTO par_id;
	ELSE 
		SELECT category_id INTO par_id FROM categories WHERE title = d_ptitle;
	END IF;
	
	WITH t0(m_num) AS (SELECT MAX(num) AS m_num FROM categories WHERE parent_id = par_id)
	SELECT 
		CASE
			WHEN m_num IS NULL THEN 1
			ELSE (m_num+1)
		END AS n_num 
	INTO max_num
	FROM t0;
	
	INSERT INTO categories(parent_id, title, num)
	VALUES (par_id, d_title, max_num) RETURNING* INTO d_attrs;
RETURN d_attrs;
END
$$ LANGUAGE plpgsql;

SELECT add_category('all items', null);
SELECT add_category('clothes', 'all items');
SELECT add_category('bags', 'all items');
SELECT add_category('shoes', 'all items');
SELECT add_category('tops', 'clothes');
SELECT add_category('skirts', 'clothes');
SELECT add_category('jackets', 'clothes');
SELECT add_category('mini-skirts', 'skirts');
SELECT add_category('midi-skirts', 'skirts');
SELECT add_category('maxi-skirts', 'skirts');
SELECT add_category('sneakers', 'shoes');
SELECT add_category('boots', 'shoes');
SELECT add_category('backpacks', 'bags');
SELECT add_category('hand bags', 'bags');



--clients

INSERT INTO clients (fio, telephone, email, address) VALUES 
('Ivanov Ivan Ivanovich', '+79153425678', 'ivanov01@mail.ru', 'Moscow, Tverskaya street, 8'),
('Smirnova Maria Sergeeevna', '+79037456321', 'smirnov02@gmail.com', 'Saint Petersburg, Nevsky Avenue, 10'),
('Pavlov Pavel Pavlovich', '+79213456789', 'pavlov03@mail.ru', 'Ekaterinburg, Sverdlova street, 2'),
('Sidorova Anastasia Dmitrievna', '+79990001122', 'sidorova04@mail.ru', 'Moscow, Arbat street, 3'),
('Kostrova Alina Igorevna', '+79172345678', 'kostrova05@mail.ru', 'Novosibirsk, Lenina street, 1');

--colors
INSERT INTO colors(color_code, color_desc) VALUES
('\xFFFFFF', 'white'),
('\x000000', 'black'),
('\x663300', 'brown'),
('\x003300', 'green'),
('\xFFCC00', 'yellow'),
('\x333333', 'grey'),
('\x990000', 'red'),
('\x990066', 'pink'),
('\x996633', 'camel'),
('\x3399FF', 'blue'),
('\xAAAAAA', 'multicolor');


--sizes
CREATE OR REPLACE FUNCTION add_sizes(sz_num integer, cat_title character varying, sz_desc character varying) RETURNS RECORD AS $$
DECLARE
	cat_id integer;
	d_attrs RECORD;
BEGIN
	SELECT category_id INTO cat_id FROM categories WHERE title = cat_title;
	INSERT INTO sizes(size_num, category_id, size_desc) VALUES (sz_num, cat_id, sz_desc) RETURNING* INTO d_attrs;
RETURN d_attrs;
END
$$ LANGUAGE plpgsql;


SELECT add_sizes(34, 'tops', 'XS');
SELECT add_sizes(36, 'tops', 'XS');
SELECT add_sizes(38, 'tops', 'S');
SELECT add_sizes(40, 'tops', 'M');
SELECT add_sizes(42, 'tops', 'M');
SELECT add_sizes(44, 'tops', 'L');
SELECT add_sizes(46, 'tops', 'XL');
SELECT add_sizes(48, 'tops', 'XL');
SELECT add_sizes(50, 'tops', 'XXL');
SELECT add_sizes(52, 'tops', 'XXXL');
SELECT add_sizes(0, 'tops', 'one size');

SELECT add_sizes(34, 'skirts', 'XS');
SELECT add_sizes(36, 'skirts', 'XS');
SELECT add_sizes(38, 'skirts', 'S');
SELECT add_sizes(40, 'skirts', 'M');
SELECT add_sizes(42, 'skirts', 'M');
SELECT add_sizes(44, 'skirts', 'L');
SELECT add_sizes(46, 'skirts', 'XL');
SELECT add_sizes(48, 'skirts', 'XL');
SELECT add_sizes(50, 'skirts', 'XXL');
SELECT add_sizes(52, 'skirts', 'XXXL');
SELECT add_sizes(0, 'skirts', 'one size');

SELECT add_sizes(34, 'jackets', 'XS');
SELECT add_sizes(36, 'jackets', 'XS');
SELECT add_sizes(38, 'jackets', 'S');
SELECT add_sizes(40, 'jackets', 'M');
SELECT add_sizes(42, 'jackets', 'M');
SELECT add_sizes(44, 'jackets', 'L');
SELECT add_sizes(46, 'jackets', 'XL');
SELECT add_sizes(48, 'jackets', 'XL');
SELECT add_sizes(50, 'jackets', 'XXL');
SELECT add_sizes(52, 'jackets', 'XXXL');
SELECT add_sizes(0, 'jackets', 'one size');

SELECT add_sizes(35, 'shoes', '23 sm');
SELECT add_sizes(36, 'shoes', '23,5 sm');
SELECT add_sizes(37, 'shoes', '24,5 sm');
SELECT add_sizes(38, 'shoes', '25,5 sm');
SELECT add_sizes(39, 'shoes', '26 sm');
SELECT add_sizes(40, 'shoes', '26,5 sm');
SELECT add_sizes(41, 'shoes', '27 sm');
SELECT add_sizes(42, 'shoes', '27,5 sm');
SELECT add_sizes(43, 'shoes', '28 sm');
SELECT add_sizes(44, 'shoes', '28,5 sm');
SELECT add_sizes(45, 'shoes', '29 sm');
SELECT add_sizes(0, 'bags', 'one size');

--items
INSERT INTO items (item_article, title, long_desc, short_desc, base_price, current_price,  min_order_amount, category_id)
VALUES
('01', 'Adidas Premium Essential Tee', 'Classic, minimalist style with a contemporary twist', 
 '93% Cotton, 7% Elastane; Pintuck Stich Detail; Crewneck', 2800, 3325, 1, 
 (SELECT category_id FROM categories WHERE title = 'tops')
),
 
('02', 'Acne Studios Exford 1996 Tee', 'Featuring an Acne Studios 1996 logo stamp on the front', 
 '100% cotton; Ribbedd Trims; Crewneck', 14000, 16765, 1, 
 (SELECT category_id FROM categories WHERE title = 'tops')
),
 
('03', 'GANNI FITTED TEE', 'Harking back to early 00s styling', '100% Cotton, Made in Portugal',
7900, 8785, 1, (SELECT category_id FROM categories WHERE title = 'tops')),

('04', 'Shrims Knitted Mini Skirt', 
 'This chic cable knit design is aborned with hand sewn bobbles ang contrasting green stripe trim', 
 '100% Merino Wool; Button Closure', 16900, 14155, 1, 
 (SELECT category_id FROM categories WHERE title = 'mini-skirts')
),
 
('05', 'Alexander McQueen Skirt', 'The black Paris skirt is made to a midi length and is constructed of layers of tulle', 
 '100% Nylon; Zip Fastening; High Waist', 118950, 52000, 2, 
 (SELECT category_id FROM categories WHERE title = 'midi-skirts')
),
 
('06', 'Balmain Zebra Printed Knotted Pareo Skirt', 'Unique, asymmetrical silhouette down the body', 
 '71% Viscose, 29% Tencel', 121125, 32450, 3, 
 (SELECT category_id FROM categories WHERE title = 'midi-skirts')
),
 
 ('07', 'Nike W Dunk Low', 'Made to a low-top stule these sneakers are made with a grained bone-coloured uppers and metallic black lether overlays', 
 'Leather Uppers; Leather Overlays; Textile Lining; Rubber Outsole; Tongue Branding', 10450, 10450, 1, 
  (SELECT category_id FROM categories WHERE title = 'sneakers')
 ),
 
 ('08', 'Air Jordan 1 LV8D W', 'Keeping things minimalist on the uppers. they are styled in tones of grey and white', 
  'Leather Uppers; Leather Overlays; Textile Lining; Rubber Outsole;', 11875, 10110, 1, 
  (SELECT category_id FROM categories WHERE title = 'sneakers')
 ),
  
 ('09', 'New Balance U9060BLK', 
  'The uppers are made with a mix of black and dark brown mesh and suede - nodding to autumn',
  'Textile Uppers; Rubber Outsole', 14725, 7300, 2, 
  (SELECT category_id FROM categories WHERE title = 'sneakers')
 ),
  
 ('10', 'Maison Margiela Tabi Boots', 'Created from buttery soft calf leather and closed in with a hook and eye fastening', 
 'Lambskin Leather Uppers; Made in Italy; Calf Leather Lining', 94219, 76800, 5, 
  (SELECT category_id FROM categories WHERE title = 'boots')
 ),
 
 ('11', 'Dr.Martens Jadon 8 Eye Boot', 'They retain all the brands classic DNA with black leather uppers and yellow stiching', 
 'Leather Upper; Goodyear Welt; Rubber Outsole', 17955, 17955, 1, 
  (SELECT category_id FROM categories WHERE title = 'boots')
 ),
 
 ('12', 'OSOI Toni Mini Bag', 'Crafted from sleek leather and has an angular teardrop shape', 
 '100% Calf Leather; Zip Closure; Printed Branding', 25555, 20000, 1, 
  (SELECT category_id FROM categories WHERE title = 'hand bags')
 ),
 
 ('13', 'Master-Piece Slick Backpack', 'Crafted with practicality, functionality and quality at its core', 
 'Zip Closure; Watter Bottle Pockets; Carry Handle; Front Zip Pocket', 24605, 24605, 1, 
  (SELECT category_id FROM categories WHERE title = 'backpacks')
 );
 
 --images
 INSERT INTO images (image_link, item_article) VALUES
 ('link1.1', '01'),
 ('link1.2', '01'),
 ('link1.3', '01'),
 ('link2.1', '02'),
 ('link2.2', '02'),
 ('link2.3', '02'),
 ('link3.1', '03'),
 ('link3.2', '03'),
 ('link3.3', '03'),
 ('link4.1', '04'),
 ('link4.2', '04'),
 ('link4.3', '04'),
 ('link5.1', '05'),
 ('link5.2', '05'),
 ('link5.3', '05'),
 ('link6.1', '06'),
 ('link6.2', '06'),
 ('link6.3', '06'),
 ('link7.1', '07'),
 ('link7.2', '07'),
 ('link7.3', '07'),
 ('link8.1', '08'),
 ('link8.2', '08'),
 ('link8.3', '08'), 
 ('link9.1', '09'),
 ('link9.2', '09'),
 ('link9.3', '09'),
 ('link10.1', '10'),
 ('link10.2', '10'),
 ('link10.3', '10'),
 ('link11.1', '11'),
 ('link11.2', '11'),
 ('lin11.3', '11'),
 ('link12.1', '12'),
 ('link12.2', '12'),
 ('link12.3', '12'),
 ('link13.1', '13'),
 ('link13.2', '13'),
 ('link13.3', '13');

SELECT* FROM colors;

--items_colors

 INSERT INTO items_colors (item_article, color_id) VALUES
 ('01', (SELECT color_id FROM colors WHERE color_desc = 'white')),
 ('01', (SELECT color_id FROM colors WHERE color_desc = 'black')), 
 ('01', (SELECT color_id FROM colors WHERE color_desc = 'camel')), 
 ('02', (SELECT color_id FROM colors WHERE color_desc = 'brown')),
 ('02', (SELECT color_id FROM colors WHERE color_desc = 'grey')), 
 ('02', (SELECT color_id FROM colors WHERE color_desc = 'blue')),
 ('03', (SELECT color_id FROM colors WHERE color_desc = 'white')),
 ('03', (SELECT color_id FROM colors WHERE color_desc = 'green')), 
 ('03', (SELECT color_id FROM colors WHERE color_desc = 'yellow')),
 ('04', (SELECT color_id FROM colors WHERE color_desc = 'white')),
 ('04', (SELECT color_id FROM colors WHERE color_desc = 'yellow')),
 ('05', (SELECT color_id FROM colors WHERE color_desc = 'black')),
 ('06', (SELECT color_id FROM colors WHERE color_desc = 'multicolor')),
 ('07', (SELECT color_id FROM colors WHERE color_desc = 'grey')),
 ('07', (SELECT color_id FROM colors WHERE color_desc = 'red')),
 ('07', (SELECT color_id FROM colors WHERE color_desc = 'pink')),
 ('08', (SELECT color_id FROM colors WHERE color_desc = 'white')),
 ('08', (SELECT color_id FROM colors WHERE color_desc = 'grey')),
 ('09', (SELECT color_id FROM colors WHERE color_desc = 'black')),
 ('09', (SELECT color_id FROM colors WHERE color_desc = 'brown')),
 ('10', (SELECT color_id FROM colors WHERE color_desc = 'camel')),
 ('10', (SELECT color_id FROM colors WHERE color_desc = 'white')),
 ('11', (SELECT color_id FROM colors WHERE color_desc = 'black')),
 ('12', (SELECT color_id FROM colors WHERE color_desc = 'multicolor')),
 ('13', (SELECT color_id FROM colors WHERE color_desc = 'green')),
 ('13', (SELECT color_id FROM colors WHERE color_desc = 'yellow')),
 ('13', (SELECT color_id FROM colors WHERE color_desc = 'red'));
 
 --items_sizes
 CREATE OR REPLACE FUNCTION add_items_sizes(itm_art character varying, sz_num integer, cat_title character varying) RETURNS RECORD AS $$
DECLARE
	cat_id integer;
	sz_id integer;
	i_art character varying;
	d_attrs RECORD;
BEGIN
	SELECT category_id INTO cat_id FROM categories WHERE title = cat_title;
	SELECT size_id INTO sz_id FROM sizes WHERE size_num = sz_num AND category_id = cat_id;
	SELECT item_article INTO i_art FROM items WHERE item_article=itm_art;
	INSERT INTO items_sizes(item_article, size_id) VALUES
	(i_art, sz_id) RETURNING* INTO d_attrs;
RETURN d_attrs;
END
$$ LANGUAGE plpgsql;

SELECT add_items_sizes('01', 34, 'tops');
SELECT add_items_sizes('01', 36, 'tops');
SELECT add_items_sizes('01', 38, 'tops');
SELECT add_items_sizes('01', 40, 'tops');
SELECT add_items_sizes('01', 42, 'tops');
SELECT add_items_sizes('01', 44, 'tops');

SELECT add_items_sizes('02', 38, 'tops');
SELECT add_items_sizes('02', 40, 'tops');
SELECT add_items_sizes('02', 42, 'tops');
SELECT add_items_sizes('02', 44, 'tops');
SELECT add_items_sizes('02', 46, 'tops');
SELECT add_items_sizes('02', 48, 'tops');

SELECT add_items_sizes('03', 0, 'tops');
SELECT add_items_sizes('04', 34, 'skirts');
SELECT add_items_sizes('04', 36, 'skirts');
SELECT add_items_sizes('04', 38, 'skirts');
SELECT add_items_sizes('04', 40, 'skirts');
SELECT add_items_sizes('04', 42, 'skirts');
SELECT add_items_sizes('04', 44, 'skirts');
SELECT add_items_sizes('04', 46, 'skirts');
SELECT add_items_sizes('04', 48, 'skirts');
SELECT add_items_sizes('04', 50, 'skirts');

SELECT add_items_sizes('05', 34, 'skirts');
SELECT add_items_sizes('05', 36, 'skirts');
SELECT add_items_sizes('05', 38, 'skirts');

SELECT add_items_sizes('06', 0, 'skirts');

SELECT add_items_sizes('07', 37, 'shoes');
SELECT add_items_sizes('07', 38, 'shoes');
SELECT add_items_sizes('07', 39, 'shoes');
SELECT add_items_sizes('07', 40, 'shoes');
SELECT add_items_sizes('07', 41, 'shoes');
SELECT add_items_sizes('07', 42, 'shoes');
SELECT add_items_sizes('07', 43, 'shoes');
SELECT add_items_sizes('07', 44, 'shoes');
SELECT add_items_sizes('07', 45, 'shoes');

SELECT add_items_sizes('08', 35, 'shoes');
SELECT add_items_sizes('08', 36, 'shoes');
SELECT add_items_sizes('08', 37, 'shoes');
SELECT add_items_sizes('08', 38, 'shoes');
SELECT add_items_sizes('08', 39, 'shoes');
SELECT add_items_sizes('08', 40, 'shoes');
SELECT add_items_sizes('08', 41, 'shoes');

SELECT add_items_sizes('09', 36, 'shoes');
SELECT add_items_sizes('09', 37, 'shoes');
SELECT add_items_sizes('09', 38, 'shoes');
SELECT add_items_sizes('09', 39, 'shoes');
SELECT add_items_sizes('09', 40, 'shoes');
SELECT add_items_sizes('09', 41, 'shoes');
SELECT add_items_sizes('09', 42, 'shoes');


SELECT add_items_sizes('10', 40, 'shoes');
SELECT add_items_sizes('10', 41, 'shoes');
SELECT add_items_sizes('10', 42, 'shoes');
SELECT add_items_sizes('10', 43, 'shoes');
SELECT add_items_sizes('10', 44, 'shoes');
SELECT add_items_sizes('10', 45, 'shoes');

SELECT add_items_sizes('11', 35, 'shoes');
SELECT add_items_sizes('12', 0, 'bags');
SELECT add_items_sizes('13', 0, 'bags');

SELECT* FROM items_sizes;

--available

CREATE OR REPLACE FUNCTION add_available(
	itm_art character varying,
	clr_desc character varying,
	sz_num integer,
	categ_title character varying,
	amount integer
	) RETURNS RECORD AS $$
DECLARE
	item_clr_id integer;
	sz_id integer;
	item_sz_id integer;
	d_attrs RECORD;
BEGIN
	SELECT item_color_id INTO item_clr_id 
	FROM items_colors INNER JOIN colors USING(color_id)
	WHERE color_desc = clr_desc AND item_article = itm_art;
	
	SELECT item_size_id INTO item_sz_id
	FROM items_sizes 
	INNER JOIN sizes USING (size_id) 
	INNER JOIN categories 
	USING (category_id)
	WHERE item_article = itm_art
	AND size_num = sz_num
	AND categories.title = categ_title;
	
	
	INSERT INTO available(item_article, item_color_id, item_size_id, available_amount)
	VALUES
	((SELECT item_article FROM items WHERE item_article = itm_art),
	item_clr_id,
	item_sz_id,
	amount);
RETURN NULL;
END
$$ LANGUAGE plpgsql;

SELECT item_color_id FROM items_colors INNER JOIN colors USING (color_id)
WHERE item_article = '01' AND color_desc = 'white'

SELECT* FROM items_colors;
SELECT* FROM available;

SELECT add_available('01', 'white', 34, 'tops', 20);
SELECT add_available('01', 'white', 36, 'tops', 25);
SELECT add_available('01', 'white', 38, 'tops', 12);
SELECT add_available('01', 'white', 44, 'tops', 8);
SELECT add_available('01', 'camel', 34, 'tops', 38);
SELECT add_available('01', 'camel', 36, 'tops', 27);
SELECT add_available('02', 'brown', 38, 'tops', 24);
SELECT add_available('02', 'brown', 42, 'tops', 39);
SELECT add_available('02', 'brown', 44, 'tops', 21);
SELECT add_available('02', 'brown', 46, 'tops', 16);
SELECT add_available('02', 'brown', 48, 'tops', 3);
SELECT add_available('02', 'grey', 38, 'tops', 57);
SELECT add_available('02', 'grey', 40, 'tops', 41);
SELECT add_available('02', 'grey', 48, 'tops', 63);
SELECT add_available('02', 'blue', 38, 'tops', 109);
SELECT add_available('02', 'blue', 40, 'tops', 89);
SELECT add_available('02', 'blue', 42, 'tops', 83);
SELECT add_available('02', 'blue', 44, 'tops', 54);
SELECT add_available('02', 'blue', 46, 'tops', 67);
SELECT add_available('03', 'white', 0, 'tops', 100);
SELECT add_available('03', 'green', 0, 'tops', 119);
SELECT add_available('03', 'yellow', 0, 'tops', 98);
SELECT* FROM available;

SELECT add_available('04', 'white', 34, 'skirts', 87);
SELECT add_available('04', 'white', 36, 'skirts', 47);
SELECT add_available('04', 'white', 40, 'skirts', 96);
SELECT add_available('04', 'white', 48, 'skirts', 123);
SELECT add_available('04', 'white', 50, 'skirts', 130);
SELECT add_available('04', 'yellow', 34, 'skirts', 89);
SELECT add_available('04', 'yellow', 46, 'skirts', 54);
SELECT add_available('04', 'yellow', 48, 'skirts', 71);
SELECT add_available('04', 'yellow', 50, 'skirts', 62);
SELECT add_available('06', 'multicolor', 0, 'skirts', 14);
SELECT add_available('07', 'grey', 37, 'shoes', 36);
SELECT add_available('07', 'grey', 38, 'shoes', 38);
SELECT add_available('07', 'grey', 39, 'shoes', 12);
SELECT add_available('07', 'grey', 40, 'shoes', 16);
SELECT add_available('07', 'grey', 41, 'shoes', 6);
SELECT add_available('07', 'grey', 42, 'shoes', 2);
SELECT add_available('07', 'red', 37, 'shoes', 54);
SELECT add_available('07', 'red', 39, 'shoes', 32);
SELECT add_available('07', 'red', 40, 'shoes', 56);
SELECT add_available('07', 'red', 42, 'shoes', 76);
SELECT add_available('07', 'red', 43, 'shoes', 69);
SELECT add_available('07', 'red', 45, 'shoes', 21);
SELECT add_available('07', 'pink', 37, 'shoes', 9);
SELECT add_available('07', 'pink', 38, 'shoes', 4);
SELECT add_available('09', 'black', 36, 'shoes', 120);
SELECT add_available('09', 'black', 37, 'shoes', 103);
SELECT add_available('09', 'black', 38, 'shoes', 87);
SELECT add_available('09', 'black', 41, 'shoes', 43);
SELECT add_available('09', 'brown', 36, 'shoes', 20);
SELECT add_available('09', 'brown', 37, 'shoes', 15);
SELECT add_available('09', 'brown', 39, 'shoes', 4);
SELECT add_available('10', 'camel', 40, 'shoes', 67);
SELECT add_available('10', 'camel', 41, 'shoes', 39);
SELECT add_available('10', 'camel', 42, 'shoes', 48);
SELECT add_available('10', 'camel', 43, 'shoes', 32);
SELECT add_available('10', 'camel', 45, 'shoes', 17);
SELECT add_available('11', 'black', 35, 'shoes', 7);
SELECT add_available('12', 'multicolor', 0, 'bags', 67);
SELECT add_available('13', 'green', 0, 'bags', 53);
SELECT add_available('13', 'yellow', 0, 'bags', 49);

SELECT* FROM available;

--orders
CREATE OR REPLACE FUNCTION add_order(
	ord_num character varying,
	cl_nm character varying, 
	pay_t character varying, 
	del_t character varying,
	del_price numeric,
	ord_d date) 
RETURNS RECORD AS $$
DECLARE 
cl_id integer;
d_attrs RECORD;
BEGIN
	SELECT client_id INTO cl_id FROM clients WHERE fio = cl_nm;
	IF cl_id IS NULL THEN SELECT 'no such client' INTO d_attrs;
	ELSE
		INSERT INTO orders(order_number, client_id, payment_type, delivery_type, delivery_price, order_date)
		VALUES (ord_num, cl_id, pay_t, del_t, del_price, ord_d) RETURNING* INTO d_attrs;
	END IF;
RETURN d_attrs;
END
$$ LANGUAGE plpgsql;

SELECT add_order('ord1', 'Ivanov Ivan Ivanovich', 'cash', 'self-delivery', 0, '02-04-2023');
SELECT add_order('ord2', 'Ivanov Ivan Ivanovich', 'card', 'door-to-door', 200, '01-04-2023');
SELECT add_order('ord3', 'Pavlov Pavel Pavlovich', 'credit', 'pickup point', 400, '10-04-2023');
SELECT add_order('ord4', 'Kostrova Alina Igorevna', 'cash', 'door-to-door', 1000, '03-04-2023');
SELECT add_order('ord5', 'Kostrova Alina Igorevna', 'cash', 'pickup point', 500, '07-04-2023');
SELECT add_order('ord6', 'Kostrova Alina Igorevna', 'card', 'door-to-door', 400, '08-04-2023');

SELECT* FROM orders;

CREATE OR REPLACE FUNCTION add_item_order(
	ord_num character varying,
	itm_art character varying,
	clr_desc character varying,
	sz_nm integer, 
	ctg_title character varying,
	amount integer
	) RETURNS RECORD AS $$

DECLARE 
	ord_id integer;
	d_attrs RECORD;
BEGIN
	SELECT order_id INTO ord_id FROM orders WHERE order_number = ord_num;
	INSERT INTO items_orders(order_id, available_id, order_amount)
	VALUES
	(
		ord_id,
		(
			SELECT available_id FROM available 
			INNER JOIN items_colors USING (item_color_id)
			INNER JOIN items_sizes USING(item_size_id) 
			INNER JOIN colors USING(color_id)
			INNER JOIN sizes USING(size_id)
			INNER JOIN categories USING(category_id)
			WHERE color_desc = clr_desc AND size_num = sz_nm AND title = ctg_title AND available.item_article = itm_art
		),
		amount
	);
RETURN NULL;
END
$$ LANGUAGE plpgsql; 

SELECT add_item_order('ord1', '13', 'yellow', 0, 'bags', 1);
SELECT add_item_order('ord2', '09', 'black', 37, 'shoes', 3);
SELECT add_item_order('ord2', '04', 'white', 34, 'skirts', 2);
SELECT add_item_order('ord3', '10', 'camel', 41, 'shoes', 1);
SELECT add_item_order('ord3', '10', 'camel', 42, 'shoes', 1);
SELECT add_item_order('ord4', '11', 'black', 35, 'shoes', 2);
SELECT add_item_order('ord4', '12', 'multicolor', 0, 'bags', 1);
SELECT add_item_order('ord5', '02', 'brown', 42, 'tops', 1);
SELECT add_item_order('ord5', '02', 'grey', 40, 'tops', 1);
SELECT add_item_order('ord5', '02', 'blue', 40, 'tops', 1);
SELECT add_item_order('ord1', '07', 'pink', 38, 'shoes', 2);
SELECT add_item_order('ord6', '13', 'yellow', 0, 'bags', 8);
SELECT add_item_order('ord1', '01', 'camel', 34, 'tops', 1);
SELECT add_item_order('ord1', '07', 'red', 37, 'shoes', 1);