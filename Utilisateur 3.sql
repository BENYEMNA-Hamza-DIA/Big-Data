CREATE DATABASE LINK U3toU1 CONNECT TO utilisateur1 IDENTIFIED by password1 using 'localhost:1521/XE';

-- Fragment bureau 3

CREATE TABLE Bureau3 AS SELECT * FROM utilisateur1.bureau@U3toU1 WHERE region=3;
ALTER TABLE Bureau3 ADD CONSTRAINT pk_bureau3 PRIMARY KEY (region);

SELECT * FROM bureau3;

-- Fragment Dirigeant 3

CREATE TABLE Dirigeant3 AS 
SELECT CODEDIRIGEANT, NOM_d, PRENOM_d, PROFESSION_d FROM utilisateur1.dirigeant@U3toU1
JOIN utilisateur1.Clubsportif@U3toU1 ON dirigeant.codedirigeant=clubsportif.dirigeant_cs 
WHERE region_cs = 3;

ALTER TABLE Dirigeant3 ADD CONSTRAINT pk_Dirigeant3_codedirigeant PRIMARY KEY (codedirigeant);

SELECT * FROM Dirigeant3;


-- Fragment Stade 3

CREATE TABLE Stade3 AS SELECT * FROM utilisateur1.Stade@U3toU1 WHERE region_s=3;

alter table Stade3 add constraint pk_Stade3 primary key (Codestade);
alter table Stade3 add constraint fk_Stade3_region_s foreign key (region_s) references bureau3(region);

SELECT * FROM Stade3;


-- Fragment Personnel 3

create table personnel3 as select * from utilisateur1.personnel@U3toU1 where region_p=3;
alter table personnel3 add constraint pk_personnel3 primary key (Code_p);
alter table personnel3 add constraint fk_personnel3_region foreign key (region_p) references bureau3(region);

SELECT * FROM personnel3;

-- VM Calendrier 3

CREATE MATERIALIZED VIEW Calendrier_VM3
REFRESH
NEXT sysdate + 1/1440
AS SELECT CODEMATCH_c, DATE_c, HEURE, CLUBA, CLUBB, STADE_c FROM (SELECT * FROM utilisateur1.calendrier@U3toU1 
LEFT JOIN utilisateur1.Stade@U3toU1 
ON utilisateur1.Calendrier.stade_c@U3toU1=utilisateur1.STADE.codestade@U3toU1 
WHERE Stade.region_s=3) ;  -- 1min=1/24/60 ---

ALTER TABLE Calendrier_VM3 ADD CONSTRAINT pk_Calendrier3 PRIMARY KEY (codematch_c);

EXECUTE DBMS_REFRESH.REFRESH('Calendrier_VM3');

SELECT * FROM Calendrier_VM3;



-- VM Palmarès 3

CREATE MATERIALIZED VIEW Palmares_VM3
REFRESH
NEXT sysdate + 1/1440
AS SELECT CODECLUB_p, ANNEE_p, TROPHEE_p, NBRMATCHSGAGNES_p, NBRMATCHSPERDUS_p FROM 
(SELECT * FROM utilisateur1.Palmares@U3toU1 NATURAL JOIN utilisateur1.ClubSportif@U3toU1 WHERE ClubSportif.region_cs=3) ;  -- 1min=1/24/60 ---

ALTER TABLE Palmares_VM3 ADD CONSTRAINT pk_Palmares3 PRIMARY KEY (CODECLUB_p);

EXECUTE DBMS_REFRESH.REFRESH('Palmares_VM3');

SELECT * FROM Palmares_VM3;


-- Match VM3

CREATE MATERIALIZED VIEW Match_VM3
REFRESH
NEXT sysdate + 1/1440
AS SELECT * FROM (SELECT codematch, NBRBUTSCLUBA, NBRBUTSCLUBB, NBRESPECTATEURS, CODEARBITRE_m, CODESTADE_m FROM utilisateur1.matchs@U3toU1 
NATURAL JOIN utilisateur1.Calendrier@U3toU1 
JOIN utilisateur1.ClubSportif@U3toU1 ON Calendrier.ClubA=ClubSportif.CodeClub 
WHERE ClubSportif.region_cs=3
UNION
SELECT codematch, NBRBUTSCLUBA, NBRBUTSCLUBB, NBRESPECTATEURS, CODEARBITRE_m, CODESTADE_m FROM utilisateur1.matchs@U3toU1 
NATURAL JOIN utilisateur1.Calendrier@U3toU1 
JOIN utilisateur1.ClubSportif@U3toU1 ON Calendrier.ClubB=ClubSportif.CodeClub 
WHERE ClubSportif.region_cs=3);

ALTER TABLE Match_VM3 ADD CONSTRAINT pk_Match3 PRIMARY KEY (Codematch);

EXECUTE DBMS_REFRESH.REFRESH('Match_VM3');

SELECT * FROM Match_VM3;


-- Fragment ClubSportif 3

create table clubsportif3 as select * from utilisateur1.clubsportif@U3toU1 where region_cs=3;
alter table clubsportif3 add constraint pk_clubsportif3 primary key (Codeclub);
alter table clubsportif3 add constraint fk_clubsportif3_region foreign key (region_cs) references Bureau3(region);
alter table clubsportif3 add constraint fk_clubsportif3_dirigeant foreign key (dirigeant_cs) references Dirigeant3(Codedirigeant);

select * from clubsportif3;


-- VM Arbitre 3

CREATE MATERIALIZED VIEW Arbitre_VM3
REFRESH
NEXT sysdate + 1/1440
AS
SELECT CODE_A, NOM_a, PRENOM_a, DATEDENAISSANCE_a, region_a, CLUBPREFERE_a FROM utilisateur1.Arbitre @U3toU1
JOIN utilisateur1.Matchs@U3toU1 ON Arbitre.code_a=Matchs.Codearbitre_m 
JOIN utilisateur1.Stade@U3toU1 ON Matchs.codestade_m=Stade.codestade 
WHERE Stade.region_s=3;

ALTER TABLE Arbitre_VM3 ADD CONSTRAINT pk_Arbitre_3 PRIMARY KEY (code_a);
ALTER TABLE Arbitre_VM3 ADD CONSTRAINT fk_Arbitre3_region FOREIGN KEY (region_a) REFERENCES Bureau3(region);

EXECUTE DBMS_REFRESH.REFRESH('Arbitre_VM3');

SELECT * FROM Arbitre_VM3;


-- Fragment staff tachnique 3

CREATE TABLE Stafftechnique3 AS SELECT CODE_ST, NOM_st, CODECLUB_ST, FONCTION_st FROM utilisateur1.Stafftechnique@U3toU1 JOIN clubsportif3 ON clubsportif3.codeclub = Stafftechnique.codeclub_st;

alter table Stafftechnique3 add constraint pk_code_st primary key (CODE_ST);
ALTER TABLE StaffTechnique3 ADD CONSTRAINT fk_StaffTechnique3_codeclub FOREIGN KEY (CODECLUB_ST) REFERENCES ClubSportif3(Codeclub);

select * from stafftechnique3;


-- Fragment Equipe 3

CREATE TABLE Equipe3 AS SELECT NumeroMaillot_eq, CodeClub_eq, CodeJoueur_eq, DateDebutContrat_eq, DateFinContrat_eq, Poste FROM utilisateur1.Equipe@U3toU1 NATURAL JOIN clubsportif3;

alter table Equipe3 add constraint pk_codeclub_equipe primary key (CODECLUB_eq);
ALTER TABLE Equipe3 ADD CONSTRAINT fk_Equipe3_codeclub FOREIGN KEY (CODECLUB_eq) REFERENCES ClubSportif3(Codeclub);

select * from Equipe3;


-- Fragment Joueur 3

CREATE TABLE Joueur3 AS SELECT CODEJOUEUR,Nom_j, PRENOM_j, DATENAISSANCE_j, NATIONALITE_j, POIDS_j, TAILLE_j, CLASSE_j
FROM utilisateur1.Joueur@U3toU1 JOIN utilisateur1.Equipe_VM@U3toU1 ON Joueur.Codejoueur=Equipe_VM.CodeJoueur_eq WHERE Codeclub_eq=3;

alter table Joueur3 add constraint pk_codejoueur primary key (CODEjoueur);

select * from Joueur3;
