DROP VIEW IF EXISTS items_colors_sizes;
DROP TABLE IF EXISTS items_orders;
DROP TABLE IF EXISTS available;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS clients;
DROP TABLE IF EXISTS items_sizes;
DROP TABLE IF EXISTS items_colors;
DROP TABLE IF EXISTS images;
DROP TABLE IF EXISTS sizes;
DROP TABLE IF EXISTS colors;
DROP TABLE IF EXISTS items;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS images;
DROP TABLE IF EXISTS sizes;
DROP TABLE IF EXISTS colors;
DROP TABLE IF EXISTS items;
DROP TABLE IF EXISTS categories;

CREATE TABLE IF NOT EXISTS categories
(
    category_id serial,
    parent_id integer,
    title character varying NOT NULL,
    num integer NOT NULL,
    CONSTRAINT unique_categories UNIQUE (parent_id, num),
	CONSTRAINT unique_category_title UNIQUE(title), 
	CONSTRAINT categories_fk FOREIGN KEY(parent_id) REFERENCES categories(category_id) ON DELETE SET NULL,
	PRIMARY KEY (category_id)
);

CREATE TABLE IF NOT EXISTS items
(
    item_article character varying(10) NOT NULL,
    title character varying(50) NOT NULL,
    short_desc character varying(250) NOT NULL,
    long_desc character varying(1000) NOT NULL,
    base_price numeric(8, 2) NOT NULL,
    current_price numeric(8, 2) NOT NULL,
    min_order_amount integer NOT NULL,
    category_id integer NOT NULL,
    PRIMARY KEY (item_article),
	CONSTRAINT items_fk FOREIGN KEY(category_id) REFERENCES categories(category_id) ON DELETE CASCADE,
	CONSTRAINT base_price_check CHECK(base_price >= 0),
	CONSTRAINT current_price_check CHECK(current_price >= 0),
	CONSTRAINT min_ord_amount_check CHECK(min_order_amount > 0)
);

CREATE TABLE IF NOT EXISTS images
(
    image_id serial,
	image_link character varying(256) NOT NULL,
    item_article character varying(10) NOT NULL,
    PRIMARY KEY (image_id),
	CONSTRAINT item_fk FOREIGN KEY(item_article) REFERENCES items(item_article) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS sizes
(
    size_id serial,
    size_num integer NOT NULL,
    category_id integer NOT NULL,
    size_desc character varying(50) NOT NULL,
    PRIMARY KEY (size_id),
	CONSTRAINT category_fk FOREIGN KEY(category_id) REFERENCES categories(category_id) ON DELETE CASCADE,
    CONSTRAINT unique_sizes UNIQUE (size_num, category_id),
	CONSTRAINT size_num_check CHECK(size_num >= 0)
);

CREATE TABLE IF NOT EXISTS colors
(
    color_id serial,
	color_code bytea NOT NULL,
    color_desc character varying(25) NOT NULL,
    PRIMARY KEY (color_id), 
	CONSTRAINT color_desc_unique UNIQUE(color_desc);
);


CREATE TABLE IF NOT EXISTS clients
(
    client_id serial,
    fio character varying(100) NOT NULL,
    telephone character varying(15) NOT NULL,
    email character varying(50) NOT NULL,
    address character varying(100) NOT NULL,
    PRIMARY KEY (client_id)
);

CREATE TABLE IF NOT EXISTS orders
(
    order_id serial,
    order_number character varying(10) NULL,
    client_id integer NOT NULL,
    payment_type character varying NOT NULL,
    delivery_type character varying NOT NULL,
    delivery_price numeric(8,2) NOT NULL,
    order_date date NOT NULL,
    discount numeric DEFAULT 0,
    PRIMARY KEY (order_id),
	CONSTRAINT ord_num_unique UNIQUE(order_number),
	CONSTRAINT payment_type_check CHECK (payment_type IN ('card', 'cash', 'credit')),
	CONSTRAINT delivery_type_check CHECK (delivery_type IN ('door-to-door', 'pickup point', 'self-delivery')),
	CONSTRAINT delivery_price_check  CHECK (delivery_price >= 0),
	CONSTRAINT client_id_fk FOREIGN KEY(client_id) REFERENCES clients(client_id) ON DELETE NO ACTION
);

CREATE TABLE IF NOT EXISTS items_orders
(
    items_orders_id serial,
    order_id integer NOT NULL,
    available_id integer NOT NULL,
    order_amount integer NOT NULL,
    PRIMARY KEY (items_orders_id),
	CONSTRAINT order_amount_check CHECK (order_amount > 0)
);

ALTER TABLE items_orders
ADD CONSTRAINT order_id_fk FOREIGN KEY(order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
ADD CONSTRAINT available_id_fk FOREIGN KEY(available_id) REFERENCES available(available_id) ON DELETE CASCADE;

CREATE TABLE IF NOT EXISTS items_sizes
(
    item_size_id serial,
    item_article character varying(10) NOT NULL,
    size_id integer NOT NULL,
    PRIMARY KEY (item_size_id),
    CONSTRAINT unique_items_sizes UNIQUE (item_article, size_id),
	CONSTRAINT item_art_fk FOREIGN KEY(item_article) REFERENCES items(item_article) ON DELETE CASCADE,
	CONSTRAINT size_id_fk FOREIGN KEY(size_id) REFERENCES sizes(size_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS items_colors
(
    item_color_id serial,
    item_article character varying(10) NOT NULL,
    color_id integer NOT NULL,
    PRIMARY KEY (item_color_id),
    CONSTRAINT unique_items_colors UNIQUE (item_article, color_id),
	CONSTRAINT item_art_fk FOREIGN KEY(item_article) REFERENCES items(item_article) ON DELETE CASCADE,
	CONSTRAINT color_id_fk FOREIGN KEY(color_id) REFERENCES colors(color_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS available
(
    available_id serial,
    item_article character varying(10) NOT NULL,
    item_color_id integer NOT NULL,
    item_size_id integer NOT NULL,
    available_amount integer DEFAULT 0 NOT NULL,
    PRIMARY KEY (available_id),
    CONSTRAINT unique_available UNIQUE (item_article, item_color_id, item_size_id),
	CONSTRAINT avail_amount_check CHECK (available_amount >= 0),
	CONSTRAINT item_art_fk FOREIGN KEY(item_article) REFERENCES items(item_article) ON DELETE CASCADE,
	CONSTRAINT item_color_fk FOREIGN KEY(item_color_id) REFERENCES items_colors(item_color_id) ON DELETE CASCADE,
	CONSTRAINT item_size_fk FOREIGN KEY(item_size_id) REFERENCES items_sizes(item_size_id) ON DELETE CASCADE
);
