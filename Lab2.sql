--task0
CREATE TRIGGER insert_category BEFORE INSERT OR UPDATE ON categories 
FOR EACH ROW EXECUTE PROCEDURE tr_add_category();

CREATE OR REPLACE FUNCTION tr_add_category() RETURNS TRIGGER AS $$
DECLARE
	p_id0 integer;
	p_id integer;
	counter integer:=0;
BEGIN
	SELECT NEW.parent_id INTO p_id0;
	IF p_id0 IS NOT NULL THEN 
		counter = counter+1;
		WHILE (counter<4 OR p_id IS NOT NULL) LOOP
			SELECT parent_id INTO p_id FROM categories WHERE category_id = p_id0;
			p_id0 = p_id;
			counter = counter+1;
		END LOOP;
	END IF;
	counter = counter-1;
	IF counter > 3 
		THEN RAISE INFO 'нельзя добавлять категорию уровня вложенности больше 3';
		RETURN NULL;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

SELECT add_category('mini-mini-skirts', 'mini-skirts');
SELECT add_category('test-skirts', 'skirts');
SELECT* FROM categories

--task1
CREATE OR REPLACE FUNCTION order_sum(art character varying) RETURNS numeric(8, 2) AS $$
DECLARE
	tot_sum numeric(8,2);
BEGIN
	WITH t0(article, total_sum) AS(
		SELECT
			items.item_article AS article,
			SUM(order_amount*current_price - order_amount*current_price*discount) AS total_sum
		FROM available 
			INNER JOIN items USING (item_article)
			INNER JOIN items_orders USING(available_id)
			INNER JOIN orders USING(order_id)
		GROUP BY article
	)
	SELECT total_sum INTO tot_sum FROM t0 WHERE article = art;
	RAISE INFO 'total sum of all orders with article %: %', art, tot_sum;
RETURN tot_sum;
END;
$$ LANGUAGE plpgsql;

SELECT order_sum('07');

--task3
CREATE OR REPLACE VIEW items_available AS
	SELECT 
	item_article, title, short_desc, long_desc, base_price, current_price, min_order_amount, category_id,
	available_id, available_amount
	FROM items LEFT JOIN available USING(item_article);
	
CREATE TRIGGER items_available_change INSTEAD OF INSERT OR UPDATE OR DELETE ON items_available
FOR EACH ROW EXECUTE PROCEDURE update_items_avails_tr();

CREATE OR REPLACE FUNCTION update_items_avails_tr() RETURNS TRIGGER AS $$
BEGIN
	IF (TG_OP = 'DELETE') THEN 
			DELETE FROM items WHERE item_article = OLD.item_article;
		IF NOT FOUND THEN RETURN NULL; END IF;
		RETURN OLD;
	ELSEIF (TG_OP = 'UPDATE') THEN 
			UPDATE available SET available_amount = NEW.available_amount
			WHERE available_id = OLD.available_id;
		IF NOT FOUND THEN RETURN NULL; END IF;
		RETURN NEW;
	ELSEIF (TG_OP = 'INSERT') THEN
			INSERT INTO items(item_article, title, short_desc, 
							  long_desc, base_price, current_price, 
							  min_order_amount, category_id)
			VALUES (NEW.item_article,
				   NEW.title,
				   NEW.short_desc.
				   NEW.long_desc,
				   NEW.base_price,
				   NEW.current_price,
				   NEW.min_order_amount,
				   NEW.category_id);
		RETURN NEW;
	END IF;
END;
$$ LANGUAGE plpgsql;

SELECT* FROM available
UPDATE items_available SET available_amount = 50 WHERE available_id = 166


SELECT item_article, COUNT (item_article) 
FROM items_orders INNER JOIN available 
USING(available_id) GROUP BY item_article



CREATE OR REPLACE FUNCTION count_step(integer, anycompatible) RETURNS integer AS $$
DECLARE
	itm_art integer;
BEGIN 
	IF $2 IS NULL THEN RETURN $1;
	ELSEIF $1 IS NULL THEN RETURN 1;
	ELSE
		SELECT item_article INTO itm_art FROM items_orders INNER JOIN available 
		USING(available_id) WHERE item_article = $2;
	END IF;
	IF itm_art IS NOT NULL THEN RETURN $1+1;
	ELSE RETURN $1;
	END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE AGGREGATE count_items(anycompatible)
(
	stype = integer,
	sfunc = count_step
);

SELECT* FROM items;

SELECT count_items(item_article) FROM items;


--task 4
--initing queue
CREATE OR REPLACE FUNCTION q_init() RETURNS RECORD AS $$
DECLARE
	attrs RECORD;
	q_state text;
	q_msg text;
	q_detail text;
	q_context text;
BEGIN
	CREATE TABLE IF NOT EXISTS queue (id integer PRIMARY KEY, s_value character varying(64) NOT NULL);
	SELECT 0 AS q_code, 'queue successfully inited' AS q_message INTO attrs;
	RAISE INFO 'code: %; message: %', attrs.q_code, attrs.q_message;
RETURN attrs;
EXCEPTION
	WHEN others THEN GET stacked diagnostics
		q_state = returned_sqlstate,
		q_msg = message_text,
		q_detail = pg_exception_detail,
		q_context = pg_exception_context;
	SELECT 1 AS q_code, q_state, q_msg, q_detail, q_context INTO attrs;
	RAISE NOTICE E'code: %; Got Exception:
		state: %,
		message: %,
		detail: %,
		context: %',
	attrs.q_code, attrs.q_state, attrs.q_msg, attrs.q_detail, attrs.q_context;
RETURN attrs;
END;
$$ LANGUAGE plpgsql;
SELECT q_init();

--cleaning queue
CREATE OR REPLACE FUNCTION q_empty() RETURNS RECORD AS $$
DECLARE
	attrs RECORD;
	res RECORD;
	q_state text;
	q_msg text;
	q_detail text;
	q_context text;
BEGIN
	FOR attrs IN
		DELETE FROM queue RETURNING*
	LOOP
		RAISE INFO 'was deleted: %', attrs.s_value;
	END LOOP;
	SELECT 0 AS q_code, 'successfull cleaning' AS q_message INTO res;
	RAISE INFO 'code: %; message: %', res.q_code, res.q_message;
RETURN res;
EXCEPTION 
	WHEN others THEN get stacked diagnostics
		q_state = returned_sqlstate,
		q_msg = message_text,
		q_detail = pg_exception_detail,
		q_context = pg_exception_context;
	SELECT 1 AS q_code, q_state, q_msg, q_detail, q_context INTO attrs;
	RAISE NOTICE E'code: %; Got Exception:
		state: %,
		message: %,
		detail: %,
		context: %',
	res.q_code, res.q_state, res.q_msg, res.q_detail, res.q_context;
RETURN res;
END;
$$ LANGUAGE plpgsql;
SELECT q_empty();

--droping queue
CREATE OR REPLACE FUNCTION q_drop() RETURNS RECORD AS $$
DECLARE
    v_state	text;
    v_msg	text;
    v_detail	text;
    v_context	text;
	attrs RECORD;
BEGIN
	DROP TABLE queue;
	SELECT 0 AS q_code, 'successfull drop' AS q_message INTO attrs;
	RAISE INFO 'code: %; message: %', attrs.q_code, attrs.q_message;
RETURN attrs;
EXCEPTION WHEN others THEN
	GET stacked diagnostics
		v_state   = returned_sqlstate,
        v_msg     = message_text,
        v_detail  = pg_exception_detail,
        v_context = pg_exception_context;
		
	SELECT 1 AS q_code,
	v_state AS q_state,
	v_msg AS q_message,
	v_detail AS q_detail,
	v_context AS q_cont
	INTO attrs;
    RAISE NOTICE E'code: %; Got exception:
        state  : %
        message: %
        detail : %
        context: %', attrs.q_code, attrs.q_state, attrs.q_message, attrs.q_detail, attrs.q_cont;
	RETURN attrs;
END;
$$ LANGUAGE plpgsql;
SELECT q_drop();

--inserting in queue
CREATE OR REPLACE FUNCTION enqueue(str character varying(64)) RETURNS RECORD AS $$
DECLARE 
	ins_id integer;
	attrs RECORD;
BEGIN
	SELECT id INTO ins_id FROM queue ORDER BY id DESC LIMIT 1;
	IF ins_id IS NULL THEN ins_id = 0;
	END IF;
	IF str IS NULL 
		THEN RAISE INFO 'the string should be not null';
	ELSE
		INSERT INTO queue VALUES (ins_id+1, str) RETURNING* INTO attrs;
	END IF;
RETURN attrs;
END;
$$ LANGUAGE plpgsql;
SELECT enqueue('first');
SELECT enqueue('second');
SELECT enqueue('third');

--deleting the first
CREATE OR REPLACE FUNCTION dequeue() RETURNS RECORD AS $$
DECLARE
 attrs RECORD;
BEGIN
	DELETE FROM queue WHERE id = (SELECT MIN(id) FROM queue) RETURNING* INTO attrs;
	RAISE INFO 'the first record was successfully deleted: %', attrs.s_value;
RETURN attrs;
END;
$$ LANGUAGE plpgsql;
SELECT dequeue();

--see the first
CREATE OR REPLACE FUNCTION top() RETURNS character varying AS $$
DECLARE
	str character varying;
BEGIN
	SELECT s_value INTO str FROM queue ORDER BY id LIMIT 1;
	RAISE INFO 'top: %', str;
RETURN str;
END;
$$ LANGUAGE plpgsql;
SELECT top();

--see the last
CREATE OR REPLACE FUNCTION tail() RETURNS character varying AS $$
DECLARE 
	str character varying;
BEGIN
	SELECT s_value INTO str FROM queue ORDER BY id DESC LIMIT 1;
	RAISE INFO 'tail: %', str;
RETURN str;
END;
$$ LANGUAGE plpgsql;
SELECT tail();