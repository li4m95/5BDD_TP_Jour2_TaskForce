# TASK FORCE FONDATIONS — Projet Genesis

**Note de mission interne — DataFlow**

| | |
|---|---|
| **À l'attention de** | Task Force Fondations (groupe 1) |
| **De** | Direction Technique — DataFlow |
| **Objet** | Conception et mise en service du socle de données DataFlow avant démonstration investisseur |
| **Confidentialité** | Usage interne — ne pas diffuser hors de l'équipe |

> *« DataFlow vient de boucler son tour de table. Notre investisseur ne veut plus entendre parler d'une startup qui vend des comptes utilisateurs : il veut voir une vraie plateforme, avec des produits, des commandes, un historique. Vous partez d'une page blanche pour construire tout le socle de données de l'entreprise. C'est le geste fondateur du projet Genesis — tout ce qui suivra aujourd'hui, chez les deux autres équipes, s'appuiera sur une réplique de ce que vous allez concevoir. »*

---

## Votre rôle dans le projet Genesis

DataFlow fait avancer trois Task Forces en parallèle sur toute la journée, chacune sur sa propre réplique de l'environnement :
- **Vous (Fondations)** : concevez et construisez le socle de données de zéro
- **Task Force Bouclier** : durcit et optimise une réplique identique
- **Task Force Interconnexion** : en déploie une autre

Vous êtes les seuls à partir d'une page blanche — un privilège et une responsabilité : la qualité de votre modélisation inspirera directement la présentation des deux autres équipes ce soir devant le comité de direction.

---

## Votre mission

### 1. Mise en service de l'environnement

- [ ] Installer/vérifier WSL + Ubuntu (si Windows) et Docker Desktop
- [ ] Récupérer l'image officielle :
```bash
docker pull container-registry.oracle.com/database/free:latest
```
- [ ] Lancer le conteneur en exposant les ports **1521** (SQL*Net) et **5500** (EM Express), avec un volume nommé pour la persistance, et un mot de passe administrateur choisi par l'équipe
- [ ] Vérifier le démarrage (`docker ps`, logs jusqu'au message confirmant que la base est prête)

### 2. Connexion et création du compte applicatif

- [ ] Installer DBeaver et créer une connexion (port 1521, SID `FREEPDB1`, utilisateur `sys`, rôle SYSDBA)
- [ ] Depuis DBeaver ou sqlplus, créer un utilisateur `dataflow_app` avec un quota sur le tablespace USERS
- [ ] Lui attribuer les privilèges nécessaires (session, table, séquence, procédure, vue, trigger)
- [ ] **À partir d'ici, ne plus utiliser le compte sys**

### 3. Modélisation du socle de données DataFlow

DataFlow ne gère plus seulement des comptes : elle vend des produits, à des utilisateurs, via des commandes.

**À faire en équipe :**
- [ ] Concevoir un schéma relationnel de **quatre tables** — USERS, PRODUCTS, ORDERS, ORDER_ITEMS — en réfléchissant vous-mêmes aux colonnes, aux types, aux clés primaires et étrangères, et aux contraintes pertinentes (unicité, valeurs par défaut, NOT NULL)
- [ ] Produire un **dictionnaire de données** (une ligne par colonne : nom, type, contrainte, rôle) — *c'est ce document que le comité de direction consultera ce soir pour juger vos choix*

**Proposition de structure possible (à discuter et enrichir en équipe avant de l'exécuter) :**

```sql
CREATE TABLE USERS (
  id    NUMBER PRIMARY KEY,
  name  VARCHAR2(100),
  email VARCHAR2(150) UNIQUE NOT NULL
);

CREATE TABLE PRODUCTS (
  id    NUMBER PRIMARY KEY,
  name  VARCHAR2(150) NOT NULL,
  price NUMBER(10,2) NOT NULL,
  stock NUMBER DEFAULT 0
);

CREATE TABLE ORDERS (
  id         NUMBER PRIMARY KEY,
  user_id    NUMBER NOT NULL REFERENCES USERS(id),
  order_date DATE DEFAULT SYSDATE,
  status     VARCHAR2(20) DEFAULT 'PENDING'
);

CREATE TABLE ORDER_ITEMS (
  id         NUMBER PRIMARY KEY,
  order_id   NUMBER NOT NULL REFERENCES ORDERS(id),
  product_id NUMBER NOT NULL REFERENCES PRODUCTS(id),
  quantity   NUMBER NOT NULL
);
```

### 4. Peupler le socle

- [ ] Insérer un jeu de données de référence : **10 utilisateurs**, **~15 produits**, **~20 commandes** et leurs lignes de commande
- [ ] Le faire via des **boucles PL/SQL** plutôt que ligne par ligne

```sql
BEGIN
  FOR i IN 1..10 LOOP
    INSERT INTO USERS VALUES (i, 'user'||i, 'user'||i||'@dataflow.io');
  END LOOP;

  FOR i IN 1..15 LOOP
    INSERT INTO PRODUCTS VALUES (i, 'product_'||i,
      ROUND(DBMS_RANDOM.VALUE(5,200),2), TRUNC(DBMS_RANDOM.VALUE(0,100)));
  END LOOP;

  FOR i IN 1..20 LOOP
    INSERT INTO ORDERS (id, user_id) VALUES (i, TRUNC(DBMS_RANDOM.VALUE(1,11)));
  END LOOP;

  FOR i IN 1..30 LOOP
    INSERT INTO ORDER_ITEMS VALUES (i,
      TRUNC(DBMS_RANDOM.VALUE(1,21)), TRUNC(DBMS_RANDOM.VALUE(1,16)),
      TRUNC(DBMS_RANDOM.VALUE(1,5)));
  END LOOP;
  COMMIT;
END;
```

### 5. Une vue métier pour la direction

Le comité de direction veut pouvoir consulter en un clin d'œil le chiffre d'affaires généré par chaque client.

- [ ] Créer une vue `V_CA_PAR_CLIENT` qui agrège, pour chaque utilisateur, la somme de (prix × quantité) sur l'ensemble de ses commandes

```sql
CREATE VIEW V_CA_PAR_CLIENT AS
SELECT u.id, u.name, SUM(p.price * oi.quantity) AS total_ca
FROM USERS u
JOIN ORDERS oo ON oo.user_id = u.id
JOIN ORDER_ITEMS oi ON oi.order_id = oo.id
JOIN PRODUCTS p ON p.id = oi.product_id
GROUP BY u.id, u.name;
```

### 6. Un trigger de traçabilité

- [ ] Ajouter une colonne `last_modified` (DATE) à la table USERS
- [ ] Écrire un trigger `BEFORE UPDATE ON USERS` qui renseigne automatiquement cette colonne à `SYSDATE` à chaque modification, sans que le développeur applicatif ait à y penser

### 7. Bloc PL/SQL de synthèse

- [ ] Écrire un bloc `DECLARE / BEGIN / END` qui affiche, via `DBMS_OUTPUT.PUT_LINE` :
  - le nombre total de commandes
  - le nombre de produits en rupture de stock (stock = 0)
  - le client au chiffre d'affaires le plus élevé (à partir de la vue créée à l'étape 5)

---

## Présentation devant le comité de direction (fin de journée)

Votre équipe ne se contente pas d'envoyer un livrable : elle vient **présenter et démontrer son travail en direct** devant le comité de direction (le formateur) et les deux autres Task Forces. Prévoyez une présentation de plusieurs minutes, écran partagé, sur votre propre réplique — **pas de diaporama, du concret**.

### Ce que vous devez montrer en direct

- [ ] Votre schéma (les quatre tables et leurs relations) et le dictionnaire de données associé
- [ ] Le jeu de données peuplé, interrogé en direct
- [ ] La vue `V_CA_PAR_CLIENT` exécutée, avec un résultat commenté
- [ ] Une modification déclenchant le trigger `last_modified`, avant/après
- [ ] Le résultat du bloc PL/SQL de synthèse

### Ce que vous devez pouvoir justifier à l'oral si le comité vous challenge

- [ ] Pourquoi ce découpage en quatre tables plutôt qu'un autre
- [ ] Pourquoi ces contraintes (ou leur absence) sur telle colonne
- [ ] Une difficulté rencontrée dans la modélisation et la façon dont vous l'avez résolue

---

> **Vous partez de zéro, sans filet : chaque choix de modélisation doit pouvoir se justifier devant le comité — c'est sur ce socle que les deux autres équipes bâtissent toute leur journée.**

*DataFlow — Projet Genesis · Document interne · 5BDDD*
