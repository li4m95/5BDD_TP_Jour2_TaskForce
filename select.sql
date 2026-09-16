DECLARE
  v_nb_commandes   NUMBER;
  v_nb_ruptures    NUMBER;
  v_client_nom     VARCHAR2(100);
  v_client_ca      NUMBER;
BEGIN
  -- 1. Nombre total de commandes
  SELECT COUNT(*) INTO v_nb_commandes
  FROM ORDERS;

  -- 2. Nombre de produits en rupture de stock (stock = 0)
  SELECT COUNT(*) INTO v_nb_ruptures
  FROM PRODUCTS
  WHERE stock = 0;

  -- 3. Le client au chiffre d'affaires le plus élevé (via la vue de l'étape 5)
  SELECT name, total_ca INTO v_client_nom, v_client_ca
  FROM (
    SELECT name, total_ca
    FROM V_CA_PAR_CLIENT
    ORDER BY total_ca DESC
  )
  WHERE ROWNUM = 1;

  -- Affichage des résultats
  DBMS_OUTPUT.PUT_LINE('=== SYNTHÈSE DATAFLOW ===');
  DBMS_OUTPUT.PUT_LINE('Nombre total de commandes : ' || v_nb_commandes);
  DBMS_OUTPUT.PUT_LINE('Produits en rupture de stock : ' || v_nb_ruptures);
  DBMS_OUTPUT.PUT_LINE('Meilleur client : ' || v_client_nom || ' (CA = ' || v_client_ca || ')');
END;
