CREATE VIEW V_CA_PAR_CLIENT AS
SELECT u.id, u.name, SUM(p.price * oi.quantity) AS total_ca
FROM USERS u
JOIN ORDERS oo ON oo.user_id = u.id
JOIN ORDER_ITEMS oi ON oi.order_id = oo.id
JOIN PRODUCTS p ON p.id = oi.product_id
GROUP BY u.id, u.name;

SELECT * FROM V_CA_PAR_CLIENT;