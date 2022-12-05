CREATE DATABASE LINK U5toU1 CONNECT TO utilisateur1 IDENTIFIED by password1 using 'localhost:1521/XE';

-- Fragment bureau 5
CREATE TABLE Bureau5 AS SELECT * FROM utilisateur1.bureau@U5toU1 WHERE region=5;
ALTER TABLE Bureau5 ADD CONSTRAINT pk_bureau5 PRIMARY KEY (region);

SELECT * FROM bureau5;

-- Fragment Dirigeant 5

CREATE TABLE Dirigeant5 AS 
SELECT CODEDIRIGEANT, NOM_d, PRENOM_d, PROFESSION_d FROM utilisateur1.dirigeant@U5toU1
JOIN utilisateur1.Clubsportif@U5toU1 ON dirigeant.codedirigeant=clubsportif.dirigeant_cs 
WHERE region_cs = 5;

ALTER TABLE Dirigeant5 ADD CONSTRAINT pk_Dirigeant5_codedirigeant PRIMARY KEY (codedirigeant);

SELECT * FROM Dirigeant5;


-- Fragment Stade 5

CREATE TABLE Stade5 AS SELECT * FROM utilisateur1.Stade@U5toU1 WHERE region_s=5;

alter table Stade5 add constraint pk_Stade5 primary key (Codestade);
alter table Stade5 add constraint fk_Stade5_region_s foreign key (region_s) references bureau5(region);

SELECT * FROM Stade5;


-- Fragment Personnel 5

create table personnel5 as select * from utilisateur1.personnel@U5toU1 where region_p=5;
alter table personnel5 add constraint pk_personnel5 primary key (Code_p);
alter table personnel5 add constraint fk_personnel5_region foreign key (region_p) references bureau5(region);

SELECT * FROM personnel5;

-- VM Calendrier 5

CREATE MATERIALIZED VIEW Calendrier_VM5
REFRESH
NEXT sysdate + 1/1440
AS SELECT CODEMATCH_c, DATE_c, HEURE, CLUBA, CLUBB, STADE_c FROM 
(SELECT * FROM utilisateur1.calendrier@U5toU1 LEFT JOIN utilisateur1.Stade@U5toU1 
ON utilisateur1.Calendrier.stade_c@U5toU1=utilisateur1.STADE.codestade@U5toU1 
WHERE Stade.region_s=5) ;  -- 1min=1/24/60 ---

ALTER TABLE Calendrier_VM1 ADD CONSTRAINT pk_Calendrier1 PRIMARY KEY (codematch_c);

EXECUTE DBMS_REFRESH.REFRESH('Calendrier_VM5');

SELECT * FROM Calendrier_VM5;


-- VM Palmarès 5

CREATE MATERIALIZED VIEW Palmares_VM5
REFRESH
NEXT sysdate + 1/1440
AS SELECT CODECLUB_p, ANNEE_p, TROPHEE_p, NBRMATCHSGAGNES_p, NBRMATCHSPERDUS_p FROM 
(SELECT * FROM utilisateur1.Palmares@U5toU1 NATURAL JOIN utilisateur1.ClubSportif@U5toU1 WHERE ClubSportif.region_cs=5) ;  -- 1min=1/24/60 ---

ALTER TABLE Palmares_VM5 ADD CONSTRAINT pk_Palmares5 PRIMARY KEY (CODECLUB_p);

EXECUTE DBMS_REFRESH.REFRESH('Palmares_VM5');

SELECT * FROM Palmares_VM5;


-- Match VM4

CREATE MATERIALIZED VIEW Match_VM5
REFRESH
NEXT sysdate + 1/1440
AS SELECT * FROM (SELECT codematch, NBRBUTSCLUBA, NBRBUTSCLUBB, NBRESPECTATEURS, CODEARBITRE_m, CODESTADE_m FROM utilisateur1.matchs@U5toU1 
NATURAL JOIN utilisateur1.Calendrier@U5toU1 
JOIN utilisateur1.ClubSportif@U5toU1 ON Calendrier.ClubA=ClubSportif.CodeClub 
WHERE ClubSportif.region_cs=5
UNION
SELECT codematch, NBRBUTSCLUBA, NBRBUTSCLUBB, NBRESPECTATEURS, CODEARBITRE_m, CODESTADE_m FROM utilisateur1.matchs@U5toU1 
NATURAL JOIN utilisateur1.Calendrier@U5toU1 
JOIN utilisateur1.ClubSportif@U5toU1 ON Calendrier.ClubB=ClubSportif.CodeClub 
WHERE ClubSportif.region_cs=5);

ALTER TABLE Match_VM5 ADD CONSTRAINT pk_Match5 PRIMARY KEY (Codematch);

EXECUTE DBMS_REFRESH.REFRESH('Match_VM5');

SELECT * FROM Match_VM5;


-- Fragment ClubSportif 5

create table clubsportif5 as select * from utilisateur1.clubsportif@U5toU1 where region_cs=5;
alter table clubsportif5 add constraint pk_clubsportif5 primary key (Codeclub);
alter table clubsportif5 add constraint fk_clubsportif5_region foreign key (region_cs) references Bureau5(region);
alter table clubsportif5 add constraint fk_clubsportif5_dirigeant foreign key (dirigeant_cs) references Dirigeant5(Codedirigeant);

select * from clubsportif5;


-- VM Arbitre 5

CREATE MATERIALIZED VIEW Arbitre_VM5
REFRESH
NEXT sysdate + 1/1440
AS
SELECT CODE_A, NOM_a, PRENOM_a, DATEDENAISSANCE_a, region_a, CLUBPREFERE_a FROM utilisateur1.Arbitre @U5toU1
JOIN utilisateur1.Matchs@U5toU1 ON Arbitre.code_a=Matchs.Codearbitre_m 
JOIN utilisateur1.Stade@U5toU1 ON Matchs.codestade_m=Stade.codestade 
WHERE Stade.region_s=5;

ALTER TABLE Arbitre_VM5 ADD CONSTRAINT pk_Arbitre_5 PRIMARY KEY (code_a);
ALTER TABLE Arbitre_VM5 ADD CONSTRAINT fk_Arbitre5_region FOREIGN KEY (region_a) REFERENCES Bureau5(region);

EXECUTE DBMS_REFRESH.REFRESH('Arbitre_VM5');

SELECT * FROM Arbitre_VM5;


-- Fragment staff tachnique 5

CREATE TABLE Stafftechnique5 AS SELECT CODE_ST, NOM_st, CODECLUB_ST, FONCTION_st FROM utilisateur1.Stafftechnique@U5toU1 JOIN clubsportif5 ON clubsportif5.codeclub = Stafftechnique.codeclub_st;

alter table Stafftechnique5 add constraint pk_code_st primary key (CODE_ST);
ALTER TABLE StaffTechnique5 ADD CONSTRAINT fk_StaffTechnique5_codeclub FOREIGN KEY (CODECLUB_ST) REFERENCES ClubSportif5(Codeclub);

select * from stafftechnique5;


-- Fragment Equipe 5

CREATE TABLE Equipe5 AS SELECT NumeroMaillot_eq, CodeClub_eq, CodeJoueur_eq, DateDebutContrat_eq, DateFinContrat_eq, Poste FROM utilisateur1.Equipe@U5toU1 NATURAL JOIN clubsportif5;

alter table Equipe5 add constraint pk_codeclub_equipe primary key (CODECLUB_eq);
ALTER TABLE Equipe5 ADD CONSTRAINT fk_Equipe5_codeclub FOREIGN KEY (CODECLUB_eq) REFERENCES ClubSportif5(Codeclub);

select * from Equipe5;


-- Fragment Joueur 5

CREATE TABLE Joueur5 AS SELECT CODEJOUEUR,Nom_j, PRENOM_j, DATENAISSANCE_j, NATIONALITE_j, POIDS_j, TAILLE_j, CLASSE_j
FROM utilisateur1.Joueur@U5toU1 JOIN utilisateur1.Equipe_VM@U5toU1 ON Joueur.Codejoueur=Equipe_VM.CodeJoueur_eq WHERE Codeclub_eq=5;

alter table Joueur5 add constraint pk_codejoueur primary key (CODEjoueur);

select * from Joueur5;