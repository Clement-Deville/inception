# 📦 INCEPTION

Ce projet est une introduction a l'administration systeme a travers la la mise en place d'un **serveur web** grace aux technologies de conteneurisation **docker** et d'orchestration **docker compose**.

## 🧰 Technologies utilisées

- Docker et Docker Compose
- [Serveur web] Nginx
- [CMS] Wordpress
- [Langages] Bash, Golang, PHP, Dockerfile, Makefile
- [Autres] Redis, Goaccess, Hugo, VSFTPD, adminer
---

## 🚀 Installation

### Prérequis:
- Distribution Linux
- Privileges requis pour Docker
### Dependances:
- Docker, Docker compose
- OpenSSL (Certificats)

### Étapes

```bash
# Cloner le dépôt
git clone https://github.com/Clement-Deville/inception

# Entrer dans le dossier
cd inception

# Configurer les variables d'environnement
cp .env.example .env
# Modifier les valeurs du fichier .env selon votre environnement
# POUR LES SECRETS SE REPORTER A LA RUBRIQUE EXPLICATIVE

# Gestion des secrets (Docker secrets)
make secrets ## Pour generer des fichiers vides dans lesquels ecrire les secrets correspondants

# Lancer le projet
make
# Build les images et lance les conteneurs en arriere plan.
```
### Commandes supplementaires:

```bash
# Construire les images
make build

# Lister les conteneurs actifs
make ps

# Lancer les conteneurs
make up

# ou en arriere plan
make upd

# Stopper les conteneurs
make stop

# Stopper et supprimer les etats des conteneurs/reseaux/images
make down
```

# Architecture de Inception

![Alt Text](./srcs/images/Inception%20visualization_standard.png)

## 🔆 LES DIFFERENTS SERVICES/CONTENEURS

## --> PARTIE OBLIGATOIRE:

- ## Nginx:
C'est le serveur web qui a le role ici de reverse proxy. Il transmet les requetes, gere le traffic et le chiffrement des donnees grace a TLS v1.2/1.3.

- ## Wordpress - PHP-FPM:
Wordpress est le CMS (Content Management System), qui a pour but creer et generer facilement notre site web, est ecrit en PHP.

PHP-FPM s'occupe d'executer les scripts PHP pour NGINX via FASTCGI.

- ## Mariadb:
Mariadb est un systeme de gestion de base de donne qui est necessaire au fonctionnement de Wordpress, la base de donnee est stocker sur un volume docker.

## --> PARTIE BONUS:

- ## Redis:
Redis est un systeme de gestion de cache de base de donnee, il stocke les donnes dans la memoire vive pour permettre une reponse plus rapide du serveur.

- ## Adminer:
Adminer est un outil de gestion de base de donnee, il met a disposition une interface graphique qui sera accessible a l'adresse [https://url_de_votre_site/adminer]().

- ## Hugo:
Hugo est un logiciel de generation de page statique ultra rapide ecrit en Go, dans notre cas une page statique exemple est generee et accessible a l'adresse: [https://url_de_votre_site/hugo]().

- ## Goaccess
Goaccess est une application de monitoring Web ayant a la fois une interface web mais aussi une interface utilisable dans un terminal.

Une authentification sera effectue grace a HTTP Basic Authenfication a l'adresse: [https://url_de_votre_site/goaccess]().

- ## VSFTPD
Vsftpd est serveur FTP repute pour sa securite. Il est configure pour accepter aussi le mode passif et permettra d'acceder au volume ou sont stockes les fichiers de Wordpress.

---
## 💿 LES DIFFERENTS VOLUMES

### - Volume wordpress:
Stocke les fichiers relatifs a Wordpress, Adminer, Goaccess.

### - Volume Database:
Permet de stocker la database.

### - Volume Logs:
Permet de garder les logs de Nginx de maniere persistante et les rends disponible a Goaccess.

### - Volume Hugo:
Permet de stocker les fichiers de configuration et les pages web de Hugo.


---
##  🔐 LES SECRETS:

### - LES IDENTIFIANTS DE CONNECTION
Il y a deux manieres actuellement implementee ici pour la transmission des secrets aux services correspondants:
- L'utilisation de Docker Secrets
- L'utilisation de l'environnement (.env)

### IMPORTANT:

Il est important de noter qu'en cas de conflit entre les methodes, le secret defini dans le .env sera retenu.

#### - **Docker Secrets:**
Ici nous allons importer ou creer des fichiers depuis l'hote qui seront lus par les conteneurs correspondants grace a un montage de type "secret" (read-only) qui apparaitra dans le conteneur au chemin: "/run/secrets/nom_du_secret"

Pour cela nous utilisons:
```bash
## GENERE LES CERTIFICATS ET LES FICHIERS OU ECRIRE NOS SECRETS DANS LE DOSSIER ./secrets/
make secrets
```

Nous pouvons aussi les supprimer grace a la commande:
```bash
## SUPPRIME LES CERTIFICATS ET FICHIER AVEC LES SECRETS
make clean_sec
```

#### - **Secrets depuis l'environnement:**
Il nous suffit de remplir ici le fichier .env que nous avons cree depuis le .env.example, par exemple:
```bash
DB_USER="my_user"
DB_USER_PASSWORD="3rhklhg3w4tdgd"
```

## 👤 Auteur:

    Clement DEVILLE
    Email :  cdeville@student.42.fr
