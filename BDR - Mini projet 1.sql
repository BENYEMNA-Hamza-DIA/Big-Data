-- Devoir 1 : SUTY Yann & PTACEK Charles & BENYEMNA Hamza

-- cet utlisateur est system/admin


-- Création des utilisateurs

CREATE USER utilisateur1 IDENTIFIED BY password1;
CREATE USER utilisateur2 IDENTIFIED BY password2;
CREATE USER utilisateur3 IDENTIFIED BY password3;
CREATE USER utilisateur4 IDENTIFIED BY password4;
CREATE USER utilisateur5 IDENTIFIED BY password5;


--Allocation de tous les privilèges aux utilisateurs

GRANT ALL PRIVILEGES TO system;

-- Cet utilisateur est l'admin donc on lui alloue tous les droits mais on accorde uniquement ceux nécessaires pour le reste des utilisateurs


-- Utilisateur 1

GRANT CREATE SESSION TO utilisateur1;
GRANT CREATE DATABASE LINK TO utilisateur1;
GRANT CREATE SYNONYM TO utilisateur1;
GRANT CREATE ANY TABLE TO utilisateur1;

-- Utilisateur 2

GRANT CREATE SESSION TO utilisateur2;
GRANT CREATE DATABASE LINK TO utilisateur2;
GRANT CREATE SYNONYM TO utilisateur2;
GRANT CREATE ANY TABLE TO utilisateur2;
GRANT CREATE MATERIALIZED VIEW TO utilisateur2;

-- Utilisateur 3

GRANT CREATE SESSION TO utilisateur3;
GRANT CREATE DATABASE LINK TO utilisateur3;
GRANT CREATE SYNONYM TO utilisateur3;
GRANT CREATE ANY TABLE TO utilisateur3;
GRANT CREATE MATERIALIZED VIEW TO utilisateur3;

-- Utilisateur 4

GRANT CREATE SESSION TO utilisateur4;
GRANT CREATE DATABASE LINK TO utilisateur4;
GRANT CREATE SYNONYM TO utilisateur4;
GRANT CREATE ANY TABLE TO utilisateur4;
GRANT CREATE MATERIALIZED VIEW TO utilisateur4;

-- Utilisateur 5

GRANT CREATE SESSION TO utilisateur5;
GRANT CREATE DATABASE LINK TO utilisateur5;
GRANT CREATE SYNONYM TO utilisateur5;
GRANT CREATE ANY TABLE TO utilisateur5;
GRANT CREATE MATERIALIZED VIEW TO utilisateur5;



-- Allocation des espaces mémoires aux utilisateurs pour qu'ils puissent créer des tables

ALTER USER utilisateur1 QUOTA 512M ON SYSTEM;
ALTER USER utilisateur2 QUOTA 128M ON SYSTEM;
ALTER USER utilisateur3 QUOTA 128M ON SYSTEM;
ALTER USER utilisateur4 QUOTA 128M ON SYSTEM;
ALTER USER utilisateur5 QUOTA 128M ON SYSTEM;


-- Connexion entre l'utilisateur 1 et le système car il est central donc on va copier toutes les tables dans l'utilisateur 1, c'est pourquoi on lui alloue plus d'espace de stocckage
CREATE DATABASE LINK SystemtoU1 CONNECT TO utilisateur1 IDENTIFIED by password1 using 'localhost:1521/XE';



-- Drop des tables : au cas où on aurait besoin de les supprimer
/*
DROP TABLE Dirigeant purge;
DROP TABLE Bureau purge;
DROP TABLE Joueur purge;
DROP TABLE ClubSportif purge;
DROP TABLE Equipe purge;
DROP TABLE StaffTechnique purge;
DROP TABLE Stade purge;
DROP TABLE Arbitre purge;
DROP TABLE Personnel purge;
DROP TABLE Matchs purge;
DROP TABLE Palmares purge;
DROP TABLE Calendrier purge;
*/

-- Création des tables

Create table Dirigeant (
	CodeDirigeant number(3) NOT NULL,
	Nom_d varchar2(70),
	Prenom_d varchar2(70),
	Profession_d varchar2(70),
	PRIMARY KEY (CodeDirigeant)
);


create table Bureau (
  Region number(3) NOT NULL,
  Nom_b varchar2(70),
  Adresse_b varchar2(70),
  DateCreation_b date,
  primary key (Region)
);


Create table Joueur (
	CodeJoueur number(3) NOT NULL,
	Nom_j varchar2(70),
	Prenom_j varchar2(70),
	DateNaissance_j date,
	Nationalite_j varchar2(70),
	Poids_j number(3),
	Taille_j number(3),
	Classe_j varchar2(70),
	PRIMARY KEY (CodeJoueur)
);

Create table ClubSportif (
	CodeClub number(3) NOT NULL,
	NomClub varchar2(70),
	DateCreation_cs date,
	Dirigeant_cs number(3) references Dirigeant (CodeDirigeant),
	Ville_cs varchar2(70),
	Region_cs number(3) references Bureau (Region),
	PRIMARY KEY(CodeClub)
);

Create table Equipe (
    NumeroMaillot_eq number(3) NOT NULL,
	CodeClub_eq number(3)  references ClubSportif (CodeClub),
	CodeJoueur_eq number(3) references Joueur (CodeJoueur),
	DateDebutContrat_eq date,
	DateFinContrat_eq date,
	Poste varchar2(70),
	PRIMARY KEY (NumeroMaillot_eq)
);

Create table StaffTechnique (
	Code_st number(3) NOT NULL,
	Nom_st varchar2(70),
	CodeClub_St number(3) references ClubSportif (CodeClub),
	Fonction_st varchar2(70),
	PRIMARY KEY (Code_st)
);

Create table Stade (
	Codestade number(3) NOT NULL,
	Nom_s varchar2(70),
	Ville_s varchar2(70),
	Region_s number(3) references Bureau (region),
	Capacite_s number(6),
	PRIMARY KEY (Codestade)
);

Create table Arbitre (
	Code_a number(3)  NOT NULL,
	Nom_a varchar2(70),
	Prenom_a varchar2(70),
	DateDeNaissance_a date,
	Region_a number(3) references bureau (region),
	ClubPrefere_a varchar2(70),
	PRIMARY Key (Code_a)
);

Create table Personnel (
	Code_p number(3) NOT NULL,
	Nom_p varchar2(70),
	Prenom_p varchar2(70),
	DateDeNaissance_p date,
	Fonction_p varchar2(70),
	Region_p number(3) references bureau,
	Ville_p varchar2(70),
	PRIMARY KEY (Code_p)
);

create table Matchs (
  Codematch number(3) NOT NULL,
  NbrbutsclubA number(6),
  NbrbutsclubB number(6),
  Nbrespectateurs number(6),
  Codearbitre_m number(3) references Arbitre (Code_a),
  Codestade_m number(3) references Stade (Codestade),
  PRIMARY KEY (Codematch)
);

create table Palmares (
  codeclub_p number(3) references clubsportif (Codeclub),
  annee_p number(4) NOT NULL,
  trophee_p varchar2(70),
  nbrmatchsgagnes_p number(3),
  nbrmatchsperdus_p number(3),
  primary key (codeclub_p, annee_p)
);

create table Calendrier (
  codeMatch_c number(3)  references matchs (Codematch),
  Date_c date,
  heure varchar2(70),
  clubA number(3) references clubsportif,
  clubB number(3) references clubsportif,
  stade_c number(3) references stade (codestade),
  primary key(codematch_c)
);


-- Insertion des tuples dans les tables

insert into bureau values(1,'Paris','Av. du Président John Fitzgerald Kennedy, 78100 Saint-Germain-en-Laye', '12-12-1970');
insert into bureau values(2, 'Lyon', '10 Av. Simone Veil, 69150 Décines-Charpieu', '15-10-1950');
insert into bureau values(3,'Marseilles', '3 Bd Michelet, 13008 Marseille', '12-02-1899');
insert into bureau values(4, 'Saint-Etienne', '14 Rue Paul et Pierre Guichard, 42000 Saint-Étienne', '03-04-1919');
insert into bureau values(5, 'Monaco' , '7 Av. des Castelans, 98000 Monaco', '11-03-1919');

insert into Dirigeant values(1, 'EL-KHELAIFI', 'Nasser', 'President du club');
insert into Dirigeant values(2, 'AULAS', 'Jean-Michel', 'President du club');
insert into Dirigeant values(3, 'LONGORIA', 'Pablo', 'President du club');
insert into Dirigeant values(4, 'ROMEYER', 'Roland', 'President du club');
insert into Dirigeant values(5,'RIBOLOVLEV', 'Dimitri','President du club');

insert into Arbitre values(1, 'Didier', 'Didou', '18-02-1985', 1, 'Paris');
insert into Arbitre values(2, 'Henry', 'Fiscal', '13-06-1974', 2, 'Lyon');
insert into Arbitre values(3, 'Pascal', 'Letourner','13-06-1972', 3, 'Marseilles');
insert into Arbitre values(4, 'Charly', 'Martin','10-01-1980',4,'Saint-Etienne');
insert into Arbitre values(5, 'Sebastien', 'David','25-12-1990',5, 'Monaco');

insert into joueur values(1, 'Didier', 'Deschamps', '01-10-1965', 'Francais', 76, 175, 'Senior');
insert into joueur values(2, 'Cristiano', 'Ronaldo', '05-02-1985', 'Portuguais', 81, 187, 'Senior');
insert into joueur values(3, 'Robert', 'Lewandowski', '21-08-1988', 'Polonais', 82, 185, 'Senior');
insert into joueur values(4, 'Lionel', 'Messi', '24-06-1987', 'Argentin', 71, 169, 'Senior');
insert into joueur values(5, 'Neymar', 'Da Silva Santos', '05-02-1992', 'Bresilien', 76, 175, 'Senior');


insert into stade values(1, 'Parc des Princes', 'Paris', 1, 10000);
insert into stade values(2, 'Groupama Stadium', 'Lyon', 2, 10000);
insert into stade values(3, 'Orange Velodrome', 'Marseille', 3, 10000);
insert into stade values(4, 'Geoffrey Stadium', 'Saint-Etienne', 4, 8000);
insert into stade values(5, 'Louis II Stadium', 'Monaco', 5, 12000);


insert into clubsportif values(1, 'PSG', '12-08-1970', 1, 'Saint-Germain-en-Laye',1);
insert into clubsportif values(2,'Olympique Lyonnais','03-08-1950',2,'Lyon',2);
insert into clubsportif values(3,'Olympique de Marseille','31-08-1899',3,'Marseille',3);
insert into clubsportif values(4,'ASSE','26-06-1933',4,'Saint-Etiennes',4);
insert into clubsportif values(5,'AS Monaco','01-08-1919',5,'Monaco',5); 


insert into equipe values(1,2,'01-01-2012', '01-06-2013',11, 'Attaquant');
insert into equipe values(2,3,'01-06-2013','09-07-2014',5, 'Attaquant');
insert into equipe values(3,4,'09-07-2014','15-08-2015',6,'Attaquant');
insert into equipe values(4,5,'15-08-2015','30-09-2016',2,'Defenseur');
insert into equipe values(5,1,'30-09-2016','09-10-2017',7, 'Attaquant');


insert into StaffTechnique values(1, 'GALTIER Christophe',1 , 'Entraineur');
insert into StaffTechnique values(2, 'BLANC Laurent',2 , 'Entraineur');
insert into StaffTechnique values(3, 'TUDOR Igor',3 , 'Entraineur');
insert into StaffTechnique values(4, 'BATLLES Laurent',4 , 'Entraineur');
insert into StaffTechnique values(5, 'CLEMENT Philippe',5 , 'Entraineur');


insert into personnel values(1, 'Martin', 'Dupont', '01-10-1995', 'Coach', 1, 'Paris');
insert into personnel values(2, 'Martin', 'Dupond', '20-06-1990', 'Soignant', 2, 'Villeurbanne');
insert into personnel values(3, 'Ciril', 'Boyer', '23-07-1985', 'Coach', 3, 'Nice');
insert into personnel values(4, 'Bertrand', 'Foucaud', '22-08-1984','Preparateur',4,'Brest');
insert into personnel values(5, 'Etienne', 'De Perlinp', '17-05-1970','Recruteur' ,5, 'Monaco');


insert into matchs values(1,3,1,10000,1,1);
insert into matchs values(2,3,3,1000,2,2);
insert into matchs values(3,6,0,10000,3,3);
insert into matchs values(4,1,5,1000,4,4);
insert into matchs values(5,3,2,10000,5,5);


insert into palmares values(1,2017, 'Ligue 1',10,1);
insert into palmares values(1,2021, 'Ligue 1',9,2);
insert into palmares values(3,2013, 'Ligue 1',7,3);
insert into palmares values(3,2009,'Ligue 1',11,0);
insert into palmares values(4,2005, 'Ligue 1',6,4);


insert into calendrier values(1, '10-10-2022', '18:10',1,2,1);
insert into calendrier values(2,'11-10-2022','13:10',2,3,2);
insert into calendrier values(3,'11-10-2022','16:20',1,5,1);
insert into calendrier values(4,'11-10-2022','21:05',4,1,4);
insert into calendrier values(5,'12-11-2022','18:10',3,5,3);











