-- ========================================
-- SOCLE DE DONNÉES DATAFLOW — Projet Genesis
-- À exécuter avec le compte dataflow_app
-- ========================================

CREATE TABLE USERS (
  id           NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name         VARCHAR2(100) NOT NULL,
  email        VARCHAR2(150) NOT NULL,
  created_at   DATE DEFAULT SYSDATE NOT NULL,
  updated_at   DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT uq_users_email UNIQUE (email)
);

CREATE TABLE PRODUCTS (
  id           NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name         VARCHAR2(150) NOT NULL,
  price        NUMBER(10,2) NOT NULL,
  stock        NUMBER DEFAULT 0 NOT NULL,
  created_at   DATE DEFAULT SYSDATE NOT NULL,
  updated_at   DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT ck_products_price_positive CHECK (price >= 0),
  CONSTRAINT ck_products_stock_positive CHECK (stock >= 0)
);

CREATE TABLE ORDERS (
  id           NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id      NUMBER NOT NULL,
  order_date   DATE DEFAULT SYSDATE NOT NULL,
  status       VARCHAR2(20) DEFAULT 'PENDING' NOT NULL,
  created_at   DATE DEFAULT SYSDATE NOT NULL,
  updated_at   DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT fk_orders_user FOREIGN KEY (user_id)
      REFERENCES USERS(id) ON DELETE CASCADE,
  CONSTRAINT ck_orders_status CHECK (status IN ('PENDING','PAID','SHIPPED','CANCELLED'))
);

CREATE TABLE ORDER_ITEMS (
  id           NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  order_id     NUMBER NOT NULL,
  product_id   NUMBER NOT NULL,
  quantity     NUMBER NOT NULL,
  updated_at   DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT fk_items_order FOREIGN KEY (order_id)
      REFERENCES ORDERS(id) ON DELETE CASCADE,
  CONSTRAINT fk_items_product FOREIGN KEY (product_id)
      REFERENCES PRODUCTS(id),
  CONSTRAINT ck_items_quantity_positive CHECK (quantity > 0),
  CONSTRAINT uq_items_order_product UNIQUE (order_id, product_id)
);  