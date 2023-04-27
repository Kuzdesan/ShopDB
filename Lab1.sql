--task0
SELECT SUM(available_amount*current_price) AS total FROM available INNER JOIN items USING (item_article);

--task1
SELECT ROUND((COUNT(DISTINCT order_id)::numeric(4,2)/COUNT(DISTINCT clients.client_id)::numeric(4, 2)), 2) AS total
FROM clients, orders;

--task2
WITH t0(order_id, total_order_amount) AS 
	(SELECT order_id, SUM(order_amount) AS total_order_amount 
	 FROM orders INNER JOIN items_orders USING(order_id)
	GROUP BY order_id)
SELECT 'minimum' AS order_type, order_id, total_order_amount FROM t0
WHERE 
	total_order_amount = (SELECT MIN(total_order_amount) FROM t0)
	UNION
SELECT 'maximum' AS order_type, order_id, total_order_amount FROM t0
WHERE 
	total_order_amount = (SELECT MAX(total_order_amount) FROM t0);
	
--task3		
DELETE FROM categories 
WHERE category_id 
		NOT IN (
		SELECT DISTINCT parent_id FROM categories WHERE category_id IN (
				SELECT category_id FROM items
		)
		UNION ALL
		SELECT DISTINCT category_id FROM items
		) 
AND parent_id IS DISTINCT FROM NULL RETURNING*;

--task4
-- DELETE FROM items_colors WHERE item_article IN ('05', '06') AND color_id = 5;
INSERT INTO items_colors(item_article, color_id) SELECT item_article, color_id FROM 
(
	WITH t0(item_article) AS 
	(SELECT item_article
	FROM colors LEFT JOIN items_colors USING (color_id) 
	RIGHT JOIN items USING (item_article)
			WHERE 
				item_article NOT IN (
					SELECT item_article 
					FROM items_colors INNER JOIN colors USING (color_id) 
					WHERE color_desc = 'yellow') 
			AND
				title LIKE '%Skirt%')
	SELECT item_article, color_id FROM t0, colors WHERE color_desc = 'yellow'
) AS qq;

SELECT* FROM items_colors WHERE item_article IN ('05', '06');

--task5
ALTER TABLE clients
DROP COLUMN IF EXISTS discount,
ADD COLUMN IF NOT EXISTS discount numeric (4, 2) DEFAULT 0;

--task6
ALTER TABLE clients
DROP CONSTRAINT IF EXISTS check_discount,
ADD CONSTRAINT check_discount CHECK (discount <= 75);