-- ========================================
-- PEUPLEMENT DU SOCLE DATAFLOW
-- À exécuter avec le compte dataflow_app
-- ========================================

DECLARE
  v_order_id   NUMBER;
  v_product_id NUMBER;
BEGIN
  -- 10 utilisateurs
  FOR i IN 1..10 LOOP
    INSERT INTO USERS (name, email)
    VALUES ('user'||i, 'user'||i||'@dataflow.io');
  END LOOP;

  -- 15 produits
  FOR i IN 1..15 LOOP
    INSERT INTO PRODUCTS (name, price, stock)
    VALUES ('product_'||i,
            ROUND(DBMS_RANDOM.VALUE(5,200),2),
            TRUNC(DBMS_RANDOM.VALUE(0,100)));
  END LOOP;

  -- 20 commandes (user_id aléatoire parmi les 10 users créés)
  FOR i IN 1..20 LOOP
    INSERT INTO ORDERS (user_id)
    VALUES (TRUNC(DBMS_RANDOM.VALUE(1,11)));
  END LOOP;

  -- 30 lignes de commande

  FOR i IN 1..30 LOOP
    LOOP
      v_order_id   := TRUNC(DBMS_RANDOM.VALUE(1,21));
      v_product_id := TRUNC(DBMS_RANDOM.VALUE(1,16));

      BEGIN
        INSERT INTO ORDER_ITEMS (order_id, product_id, quantity)
        VALUES (v_order_id, v_product_id, TRUNC(DBMS_RANDOM.VALUE(1,5)));
        EXIT; 
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          NULL; 
      END;
    END LOOP;
  END LOOP;

  COMMIT;
END;
/