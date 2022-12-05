-- Création des connexions
CREATE DATABASE LINK U1toSystem CONNECT TO system IDENTIFIED by admin using 'localhost:1521/XE'; --permet de copier les tables

CREATE DATABASE LINK U1toU2 CONNECT TO utilisateur2 IDENTIFIED by password2 using 'localhost:1521/XE';
CREATE DATABASE LINK U1toU3 CONNECT TO utilisateur3 IDENTIFIED by password3 using 'localhost:1521/XE';
CREATE DATABASE LINK U1toU4 CONNECT TO utilisateur4 IDENTIFIED by password4 using 'localhost:1521/XE';
CREATE DATABASE LINK U1toU5 CONNECT TO utilisateur5 IDENTIFIED by password5 using 'localhost:1521/XE';



-- Copie des tables de système vers utilisateur 1 car il est central. La BDD du système sert de backup d'origine

CREATE TABLE Bureau AS SELECT * FROM system.Bureau@U1toSystem;
CREATE TABLE Dirigeant AS SELECT * FROM system.Dirigeant@U1toSystem;
CREATE TABLE Joueur AS SELECT * FROM system.Joueur@U1toSystem;
CREATE TABLE ClubSportif AS SELECT * FROM system.ClubSportif@U1toSystem;
CREATE TABLE Equipe AS SELECT * FROM system.Equipe@U1toSystem;
CREATE TABLE StaffTechnique AS SELECT * FROM system.StaffTechnique@U1toSystem;
CREATE TABLE Stade AS SELECT * FROM system.Stade@U1toSystem;
CREATE TABLE Arbitre AS SELECT * FROM system.Arbitre@U1toSystem;
CREATE TABLE Personnel AS SELECT * FROM system.Personnel@U1toSystem;
CREATE TABLE Matchs AS SELECT * FROM system.Matchs@U1toSystem;
CREATE TABLE Palmares AS SELECT * FROM system.Palmares@U1toSystem;
CREATE TABLE Calendrier AS SELECT * FROM system.Calendrier@U1toSystem;

-- DROP TABLE Bureau;


-- Fragment bureau1

CREATE TABLE Bureau1 AS SELECT * FROM Bureau WHERE region=1;
ALTER TABLE Bureau1 ADD CONSTRAINT pk_bureau1 PRIMARY KEY (region);

SELECT * FROM bureau1;

--DROP TABLE Bureau1;

-- Bureau central VM (reconsitution des fragments bureau1 à 5)

CREATE MATERIALIZED VIEW Bureau_VM
REFRESH
NEXT sysdate + 1/1440
AS
Select * from Bureau1
UNION ALL
Select * from utilisateur2.Bureau2@U1toU2
UNION
Select * from utilisateur3.Bureau3@U1toU3
UNION
Select * from utilisateur4.Bureau4@U1toU4
UNION
Select * from utilisateur5.Bureau5@U1toU5;

ALTER TABLE Bureau_VM ADD CONSTRAINT pk_region PRIMARY KEY  (region);

EXECUTE DBMS_REFRESH.REFRESH('Bureau_VM');

SELECT * FROM Bureau_VM;


-- Mise à jour des foreign key associée à la table bureau

-- Arbitre

ALTER TABLE Arbitre DROP CONSTRAINT fk_region;

ALTER TABLE Arbitre ADD CONSTRAINT fk_region_a FOREIGN KEY (region_a) REFERENCES Bureau_VM(region);

-- ClubSportif

ALTER TABLE ClubSportif DROP CONSTRAINT SYS_C004331;

ALTER TABLE ClubSportif ADD CONSTRAINT fk_region_cs FOREIGN KEY (region_cs) REFERENCES Bureau_VM(region);

--  Personnel

ALTER TABLE Personnel DROP CONSTRAINT SYS_C004325;

ALTER TABLE Personnel ADD CONSTRAINT fk_region_p FOREIGN KEY (region_p) REFERENCES Bureau_VM(region);

-- Stade

ALTER TABLE Stade DROP CONSTRAINT SYS_C004341;

ALTER TABLE Stade ADD CONSTRAINT fk_region_s FOREIGN KEY (region_s) REFERENCES Bureau_VM(region);

-- Suppression du Bureau

--DROP TABLE Bureau;


-- Dirigeant : comme bureau, on créer des fragments des dirigeant de clubs par régions et une VM central

-- Fragment Dirigeant 1

CREATE TABLE Dirigeant1 AS 
SELECT CODEDIRIGEANT, NOM_d, PRENOM_d, PROFESSION_d FROM dirigeant
JOIN Clubsportif ON dirigeant.codedirigeant=clubsportif.dirigeant_cs
WHERE region_cs = 1;

ALTER TABLE Dirigeant1 ADD CONSTRAINT pk_Dirigeant1_codedirigeant PRIMARY KEY (codedirigeant);

SELECT * FROM Dirigeant1;

-- VM central de dirigeant

CREATE MATERIALIZED VIEW Dirigeant_VM
REFRESH
NEXT sysdate + 1/1440
AS
Select * from Dirigeant1
UNION ALL
Select * from utilisateur2.Dirigeant2@U1toU2
UNION
Select * from utilisateur3.Dirigeant3@U1toU3
UNION
Select * from utilisateur4.Dirigeant4@U1toU4
UNION
Select * from utilisateur5.Dirigeant5@U1toU5;

ALTER TABLE Dirigeant_VM ADD CONSTRAINT pk_region PRIMARY KEY  (CodeDirigeant);

EXECUTE DBMS_REFRESH.REFRESH('Dirigeant_VM');

SELECT * FROM Dirigeant_VM;

-- Mise à jour des foreign key associée à la table bureau

-- ClubSportif

ALTER TABLE ClubSportif DROP CONSTRAINT SYS_C004330;

ALTER TABLE ClubSportif ADD CONSTRAINT fk_dirigeant FOREIGN KEY (dirigeant_cs) REFERENCES Dirigeant_VM(codedirigeant);

-- On peut supprimer la table Dirigeant

--DROP TABLE Dirigeant;

-- Stade : on peut fragmenter les stade par région et créer une VM central

-- Fragment Stade 1

CREATE TABLE Stade1 AS SELECT * FROM Stade WHERE region_s=1;

alter table Stade1 add constraint pk_Stade1 primary key (Codestade);
alter table Stade1 add constraint fk_Stade1_region_s foreign key (region_s) references bureau1(region);

SELECT * FROM Stade1;

-- Stade VM Central (reconsitution des fragments Stade 1 à 5)

CREATE MATERIALIZED VIEW Stade_VM
REFRESH
NEXT sysdate + 1/1440
AS
Select * from Stade1
UNION ALL
Select * from utilisateur2.Stade2@U1toU2
UNION
Select * from utilisateur3.Stade3@U1toU3
UNION
Select * from utilisateur4.Stade4@U1toU4
UNION
Select * from utilisateur5.Stade5@U1toU5;

ALTER TABLE Stade_VM ADD CONSTRAINT pk_codestade PRIMARY KEY (codestade);
alter table Stade_VM add constraint fk_Stade_region foreign key (region_s) references bureau_VM(region);

EXECUTE DBMS_REFRESH.REFRESH('Stade_VM');

SELECT * FROM Stade_VM;

-- MAJ des foreign key

-- Match

ALTER TABLE Matchs DROP CONSTRAINT SYS_C004350;

ALTER TABLE Matchs ADD CONSTRAINT fk_codestade_m FOREIGN KEY (codestade_m) REFERENCES Stade_VM(codestade);

--Calendrier

ALTER TABLE Calendrier DROP CONSTRAINT SYS_C004358;

ALTER TABLE Calendrier ADD CONSTRAINT fk_codestade_c FOREIGN KEY (stade_c) REFERENCES Stade_VM(codestade);

--DROP de la table Stade

--DROP TABLE Stade;


-- Table Personnel : fragment par région et reconstitution de la table entière par une VM sur la  région centrale

-- Fragment Personnel 1

create table personnel1 as select * from personnel where region_p=1;
alter table personnel1 add constraint pk_personnel1 primary key (Code_p);
alter table personnel1 add constraint fk_personnel1_region foreign key (region_p) references bureau1(region);

SELECT * FROM personnel1;

-- Personnel VM Central (reconsitution des fragments personnel1 à 5)

CREATE MATERIALIZED VIEW Personnel_VM
REFRESH
NEXT sysdate + 1/1440
AS
Select * from Personnel1
UNION ALL
Select * from utilisateur2.Personnel2@U1toU2
UNION
Select * from utilisateur3.Personnel3@U1toU3
UNION
Select * from utilisateur4.Personnel4@U1toU4
UNION
Select * from utilisateur5.Personnel5@U1toU5;

ALTER TABLE Personnel_VM ADD CONSTRAINT pk_personnel PRIMARY KEY (code_p);
alter table personnel_VM add constraint fk_personnel_region foreign key (region_p) references bureau_VM(region);

EXECUTE DBMS_REFRESH.REFRESH('Personnel_VM');

SELECT * FROM Personnel_VM;


--Drop de la table personnel

-- DROP TABLE Personnel;

-- Calendrier : calendrier centrak avec VM par région

-- Les calendrier sont mis à jour de manière hebdomadaire afin de répartir les arbitre tous les mercredis

-- VM Calendrier 1 : calendrier des matchs des clubs de la région

CREATE MATERIALIZED VIEW Calendrier_VM1
REFRESH
NEXT sysdate + 7
AS SELECT CODEMATCH_c, DATE_c, HEURE, CLUBA, CLUBB, STADE_c FROM 
(SELECT * FROM Calendrier LEFT JOIN Stade ON Calendrier.stade_c=STADE.codestade WHERE Stade.region_s=1) ;  

ALTER TABLE Calendrier_VM1 ADD CONSTRAINT pk_Calendrier1 PRIMARY KEY (codematch_c);

EXECUTE DBMS_REFRESH.REFRESH('Calendrier_VM1');

SELECT * FROM Calendrier_VM1;

--Palmares : table centrale avec des VM sur les régions

-- VM Palmarès 1 : le palmarès des clubs de la région

CREATE MATERIALIZED VIEW Palmares_VM1
REFRESH
NEXT sysdate + 1/1440
AS SELECT CODECLUB_p, ANNEE_p, TROPHEE_p, NBRMATCHSGAGNES_p, NBRMATCHSPERDUS_p FROM (SELECT * FROM Palmares NATURAL JOIN ClubSportif WHERE ClubSportif.region_cs=1) ;  -- 1min=1/24/60 ---

ALTER TABLE Palmares_VM1 ADD CONSTRAINT pk_Palmares1 PRIMARY KEY (CODECLUB_p);

EXECUTE DBMS_REFRESH.REFRESH('Palmares_VM1');

SELECT * FROM Palmares_VM1;


-- Match table sur la région centrale et des VM sur les régions

-- Match VM1 : la liste des match que le club de la région joue

CREATE MATERIALIZED VIEW Match_VM1
REFRESH
NEXT sysdate + 1/1440
AS SELECT * FROM (SELECT codematch, NBRBUTSCLUBA, NBRBUTSCLUBB, NBRESPECTATEURS, CODEARBITRE_m, CODESTADE_m FROM matchs 
NATURAL JOIN Calendrier 
JOIN ClubSportif ON Calendrier.ClubA=ClubSportif.CodeClub 
WHERE ClubSportif.region_cs=1
UNION
SELECT codematch, NBRBUTSCLUBA, NBRBUTSCLUBB, NBRESPECTATEURS, CODEARBITRE_m, CODESTADE_m FROM matchs 
NATURAL JOIN Calendrier 
JOIN ClubSportif ON Calendrier.ClubB=ClubSportif.CodeClub 
WHERE ClubSportif.region_cs=1);

ALTER TABLE Match_VM1 ADD CONSTRAINT pk_Match1 PRIMARY KEY (Codematch);

EXECUTE DBMS_REFRESH.REFRESH('Match_VM1');

SELECT * FROM Match_VM1;


-- ClubSportif : fragment par région et reconstitution de la table entière par une VM sur la  région centrale

-- Fragment ClubSportif 1

create table clubsportif1 as select * from clubsportif where region_cs=1;
alter table clubsportif1 add constraint pk_clubsportif1 primary key (Codeclub);
alter table clubsportif1 add constraint fk_clubsportif1_region foreign key (region_cs) references Bureau1(region);
alter table clubsportif1 add constraint fk_clubsportif1_dirigeant foreign key (dirigeant_cs) references Dirigeant1(Codedirigeant);

select * from clubsportif1;


-- ClubSportif VM Central (reconsitution des fragments clubsportif1 à 5)

CREATE MATERIALIZED VIEW ClubSportif_VM
REFRESH
NEXT sysdate + 1/1440
AS
Select * from ClubSportif1
UNION ALL
Select * from utilisateur2.ClubSportif2@U1toU2
UNION
Select * from utilisateur3.ClubSportif3@U1toU3
UNION
Select * from utilisateur4.ClubSportif4@U1toU4
UNION
Select * from utilisateur5.ClubSportif5@U1toU5;

ALTER TABLE ClubSportif_VM ADD CONSTRAINT pk_ClubSportifVM PRIMARY KEY (Codeclub);
alter table ClubSportif_VM add constraint fk_clubsportifvm_region foreign key (region_cs) references Bureau_VM(region);
alter table ClubSportif_VM add constraint fk_clubsportifvm_dirigeant foreign key (dirigeant_cs) references Dirigeant_VM(Codedirigeant);

EXECUTE DBMS_REFRESH.REFRESH('Clubsportif_VM');

SELECT * FROM Clubsportif_VM;

-- MAJ des foreign key

-- Equipe

ALTER TABLE Equipe DROP CONSTRAINT SYS_C004334;

ALTER TABLE Equipe ADD CONSTRAINT fk_codeclub_e FOREIGN KEY (codeclub_eq) REFERENCES ClubSportif_VM(codeclub);

--Palmares

ALTER TABLE Palmares DROP CONSTRAINT SYS_C004330;

ALTER TABLE Palmares ADD CONSTRAINT fk_codeclub_p FOREIGN KEY (codeclub_p) REFERENCES ClubSportif_VM(codeclub);

-- Staff Technique

ALTER TABLE StaffTechnique DROP CONSTRAINT SYS_C004338;

ALTER TABLE StaffTechnique ADD CONSTRAINT fk_StaffTechnique_codeclub FOREIGN KEY (codeclub_st) REFERENCES ClubSportif_VM(codeclub);


--Drop de la table ClubSportif

-- DROP TABLE ClubSportif;

-- Arbitre : table centrale avec des VM sur les arbitres par région

-- Arbitre VM1

CREATE MATERIALIZED VIEW Arbitre_VM1
REFRESH
NEXT sysdate + 1/1440
AS
SELECT CODE_A, NOM_a, PRENOM_a, DATEDENAISSANCE_a, region_a, CLUBPREFERE_a FROM Arbitre 
JOIN Matchs ON Arbitre.code_a=Matchs.Codearbitre_m JOIN Stade ON Matchs.codestade_m=Stade.codestade 
WHERE Stade.region_s=1;

ALTER TABLE Arbitre_VM1 ADD CONSTRAINT pk_Arbitre_1 PRIMARY KEY (code_a);
ALTER TABLE Arbitre_VM1 ADD CONSTRAINT fk_Arbitre1_region FOREIGN KEY (region_a) REFERENCES Bureau1(region);

EXECUTE DBMS_REFRESH.REFRESH('Arbitre_VM1');

SELECT * FROM Arbitre_VM1;


-- Staff technique : on crée un fragment par région et une VM central

-- Fragment staff tachnique 1

CREATE TABLE Stafftechnique1 AS SELECT CODE_ST, NOM_st, CODECLUB_ST, FONCTION_st FROM Stafftechnique JOIN clubsportif1 ON clubsportif1.codeclub = Stafftechnique.codeclub_st;

alter table Stafftechnique1 add constraint pk_code_st primary key (CODE_ST);
ALTER TABLE StaffTechnique1 ADD CONSTRAINT fk_StaffTechnique1_codeclub FOREIGN KEY (CODECLUB_ST) REFERENCES ClubSportif1(Codeclub);

select * from stafftechnique1;


-- StaffTechnique VM Central (reconsitution des fragments stafftechnique1 à 5)

CREATE MATERIALIZED VIEW StaffTechnique_VM
REFRESH
NEXT sysdate + 1/1440
AS
Select * from StaffTechnique1
UNION ALL
Select * from utilisateur2.StaffTechnique2@U1toU2
UNION
Select * from utilisateur3.StaffTechnique3@U1toU3
UNION
Select * from utilisateur4.StaffTechnique4@U1toU4
UNION
Select * from utilisateur5.StaffTechnique5@U1toU5;

alter table StaffTechnique_VM add constraint pk_code_st primary key (CODE_ST);
ALTER TABLE StaffTechnique_VM ADD CONSTRAINT fk_StaffTechnique_codeclub FOREIGN KEY (CODECLUB_ST) REFERENCES ClubSportif_VM(Codeclub);

EXECUTE DBMS_REFRESH.REFRESH('StaffTechnique_VM');

SELECT * FROM StaffTechnique_VM;

-- DROP de la table stafftechnique

--DROP TABLE Stafftehcnique;


-- Equipe : on crée un fragment par région et une VM central

-- Fragment Equipe 1

CREATE TABLE Equipe1 AS SELECT NumeroMaillot_eq, CodeClub_eq, CodeJoueur_eq, DateDebutContrat_eq, DateFinContrat_eq, Poste FROM Equipe NATURAL JOIN clubsportif1;

alter table Equipe1 add constraint pk_num_maillot primary key (NumeroMaillot_eq);
ALTER TABLE Equipe1 ADD CONSTRAINT fk_Equipe1_codeclub FOREIGN KEY (CODECLUB_eq) REFERENCES ClubSportif1(Codeclub);

select * from Equipe1;

-- Equipe VM Central (reconsitution des fragments Equipe 1 à 5)

CREATE MATERIALIZED VIEW Equipe_VM
REFRESH
NEXT sysdate + 1/1440
AS
Select * from Equipe1
UNION ALL
Select * from utilisateur2.Equipe2@U1toU2
UNION
Select * from utilisateur3.Equipe3@U1toU3
UNION
Select * from utilisateur4.Equipe4@U1toU4
UNION
Select * from utilisateur5.Equipe5@U1toU5;

alter table Equipe_VM add constraint pk_num_maillot primary key (NumeroMaillot_eq);
ALTER TABLE Equipe_VM ADD CONSTRAINT fk_Equipevm_codeclub FOREIGN KEY (CODECLUB_eq) REFERENCES ClubSportif_VM(Codeclub);

EXECUTE DBMS_REFRESH.REFRESH('Equipe_VM');

SELECT * FROM Equipe_VM;

--DROP MATERIALIZED VIEW Equipe_VM;

-- DROP de la table Equipe

--DROP TABLE Equipe;


--  Joueur : on crée un fragment par région et une VM central

-- Fragment Joueur 1

CREATE TABLE Joueur1 AS SELECT CODEJOUEUR,Nom_j, PRENOM_j, DATENAISSANCE_j, NATIONALITE_j, POIDS_j, TAILLE_j, CLASSE_j FROM Joueur 
JOIN Equipe1 ON Joueur.Codejoueur=Equipe1.CodeJoueur_eq;

alter table Joueur1 add constraint pk_codejoueur primary key (CODEjoueur);

select * from Joueur1;

-- Joueur VM Central (reconsitution des fragments joueurs 1 à 5)

CREATE MATERIALIZED VIEW Joueur_VM
REFRESH
NEXT sysdate + 1/1440
AS
Select * from Equipe1
UNION ALL
Select * from utilisateur2.Joueur2@U1toU2
UNION
Select * from utilisateur3.Joueur3@U1toU3
UNION
Select * from utilisateur4.Joueur4@U1toU4
UNION
Select * from utilisateur5.Joueur5@U1toU5;

alter table Joueur_VM add constraint pk_codejoueur primary key (CODEjoueur);

EXECUTE DBMS_REFRESH.REFRESH('Joueur_VM');

SELECT * FROM Joueur_VM;


-- TRIGGER : maj du calendrier

CREATE OR REPLACE TRIGGER maj_Calendrier
BEFORE INSERT OR UPDATE OR DELETE
ON Calendrier FOR EACH ROW
BEGIN
IF (INSERTING) THEN
INSERT INTO Calendrier_VM1 values
(:new.codeMatch_c,:new.Date_c,:new.heure,:new.clubA,:new.clubB,:new.stade_c);
INSERT INTO utilisateur2.Calendrier_VM2@U1toU2 values
(:new.codeMatch_c,:new.Date_c,:new.heure,:new.clubA,:new.clubB,:new.stade_c);
INSERT INTO utilisateur3.Calendrier_VM3@U1toU3 values
(:new.codeMatch_c,:new.Date_c,:new.heure,:new.clubA,:new.clubB,:new.stade_c);
INSERT INTO utilisateur4.Calendrier_VM4@@U1toU4 values
(:new.codeMatch_c,:new.Date_c,:new.heure,:new.clubA,:new.clubB,:new.stade_c);
INSERT INTO utilisateur5.Calendrier_VM5@U1toU5 values
(:new.codeMatch_c,:new.Date_c,:new.heure,:new.clubA,:new.clubB,:new.stade_c);
END IF;
IF UPDATING THEN
    update Calendrier_VM1 SET heure = :new.heure WHERE codematch_c=:old.codematch_c;
    update utilisateur2.Calendrier_VM2@U1toU2 SET heure = :new.heure WHERE codematch_c=:old.codematch_c;
    update utilisateur3.Calendrier_VM3@U1toU3 SET heure = :new.heure WHERE codematch_c=:old.codematch_c;
    update utilisateur4.Calendrier_VM4@U1toU4 SET heure = :new.heure WHERE codematch_c=:old.codematch_c;
    update utilisateur5.Calendrier_VM5@U1toU5 SET heure = :new.heure WHERE codematch_c=:old.codematch_c;
END IF;

IF DELETING THEN
DELETE FROM Calendrier_VM1 WHERE codematch_c=:old.codematch_c;
DELETE FROM Calendrier_VM2@U1toU2 WHERE codematch_c=:old.codematch_c;
DELETE FROM Calendrier_VM3@U1toU3 WHERE codematch_c=:old.codematch_c;
DELETE FROM Calendrier_VM4@U1toU4 WHERE codematch_c=:old.codematch_c;
DELETE FROM Calendrier_VM5@U1toU5 WHERE codematch_c=:old.codematch_c;
END IF;
END;


-- test du trigger


insert into matchs values(6, 5,5,1000,1,2);
insert into calendrier values(6, '01-01-2023','10:00', 1,2,2);

-- il apparait dans les calendrier vm1 et vm2 car les clubs appartiennent aux région 1 et 2