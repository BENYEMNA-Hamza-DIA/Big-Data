CREATE DATABASE LINK U4toU1 CONNECT TO utilisateur1 IDENTIFIED by password1 using 'localhost:1521/XE';

-- Fragment bureau 4

CREATE TABLE Bureau4 AS SELECT * FROM utilisateur1.bureau@U4toU1 WHERE region=4;
ALTER TABLE Bureau4 ADD CONSTRAINT pk_bureau4 PRIMARY KEY (region);

SELECT * FROM bureau4;

-- Fragment Dirigeant 4

CREATE TABLE Dirigeant4 AS 
SELECT CODEDIRIGEANT, NOM_d, PRENOM_d, PROFESSION_d FROM utilisateur1.dirigeant@U4toU1
JOIN utilisateur1.Clubsportif@U4toU1 ON dirigeant.codedirigeant=clubsportif.dirigeant_cs 
WHERE region_cs = 4;

ALTER TABLE Dirigeant4 ADD CONSTRAINT pk_Dirigeant4_codedirigeant PRIMARY KEY (codedirigeant);

SELECT * FROM Dirigeant4;

-- Fragment Stade 4

CREATE TABLE Stade4 AS SELECT * FROM utilisateur1.Stade@U4toU1 WHERE region_s=4;

alter table Stade4 add constraint pk_Stade4 primary key (Codestade);
alter table Stade4 add constraint fk_Stade4_region_s foreign key (region_s) references bureau4(region);

SELECT * FROM Stade4;

-- Fragment Personnel 4

create table personnel4 as select * from utilisateur1.personnel@U4toU1 where region_p=4;
alter table personnel4 add constraint pk_personnel4 primary key (Code_p);
alter table personnel4 add constraint fk_personnel4_region foreign key (region_p) references bureau4(region);

SELECT * FROM personnel4;

-- VM Calendrier 4

CREATE MATERIALIZED VIEW Calendrier_VM4
REFRESH
NEXT sysdate + 1/1440
AS SELECT CODEMATCH_c, DATE_c, HEURE, CLUBA, CLUBB, STADE_c FROM (SELECT * FROM utilisateur1.calendrier@U4toU1 
LEFT JOIN utilisateur1.Stade@U4toU1 
ON utilisateur1.Calendrier.stade_c@U4toU1=utilisateur1.STADE.codestade@U4toU1 
WHERE Stade.region_s=4) ;  -- 1min=1/24/60 ---

ALTER TABLE Calendrier_VM4 ADD CONSTRAINT pk_Calendrier4 PRIMARY KEY (codematch_c);

EXECUTE DBMS_REFRESH.REFRESH('Calendrier_VM4');

SELECT * FROM Calendrier_VM4;


-- VM Palmarès 4

CREATE MATERIALIZED VIEW Palmares_VM4
REFRESH
NEXT sysdate + 1/1440
AS SELECT CODECLUB_p, ANNEE_p, TROPHEE_p, NBRMATCHSGAGNES_p, NBRMATCHSPERDUS_p FROM 

(SELECT * FROM utilisateur1.Palmares@U4toU1 NATURAL JOIN utilisateur1.ClubSportif@U4toU1 WHERE ClubSportif.region_cs=4) ;  -- 1min=1/24/60 ---

ALTER TABLE Palmares_VM4 ADD CONSTRAINT pk_Palmares4 PRIMARY KEY (CODECLUB_p);

EXECUTE DBMS_REFRESH.REFRESH('Palmares_VM4');

SELECT * FROM Palmares_VM4;


-- Match VM4

CREATE MATERIALIZED VIEW Match_VM4
REFRESH
NEXT sysdate + 1/1440
AS SELECT * FROM (SELECT codematch, NBRBUTSCLUBA, NBRBUTSCLUBB, NBRESPECTATEURS, CODEARBITRE_m, CODESTADE_m FROM utilisateur1.matchs@U4toU1 
NATURAL JOIN utilisateur1.Calendrier@U4toU1 
JOIN utilisateur1.ClubSportif@U4toU1 ON Calendrier.ClubA=ClubSportif.CodeClub 
WHERE ClubSportif.region_cs=4
UNION
SELECT codematch, NBRBUTSCLUBA, NBRBUTSCLUBB, NBRESPECTATEURS, CODEARBITRE_m, CODESTADE_m FROM utilisateur1.matchs@U4toU1 
NATURAL JOIN utilisateur1.Calendrier@U4toU1 
JOIN utilisateur1.ClubSportif@U4toU1 ON Calendrier.ClubB=ClubSportif.CodeClub 
WHERE ClubSportif.region_cs=4);

ALTER TABLE Match_VM4 ADD CONSTRAINT pk_Match4 PRIMARY KEY (Codematch);

EXECUTE DBMS_REFRESH.REFRESH('Match_VM4');

SELECT * FROM Match_VM4;


-- Fragment ClubSportif 4

create table clubsportif4 as select * from utilisateur1.clubsportif@U4toU1 where region_cs=4;
alter table clubsportif4 add constraint pk_clubsportif4 primary key (Codeclub);
alter table clubsportif4 add constraint fk_clubsportif4_region foreign key (region_cs) references Bureau4(region);
alter table clubsportif4 add constraint fk_clubsportif4_dirigeant foreign key (dirigeant_cs) references Dirigeant4(Codedirigeant);

select * from clubsportif4;


-- VM Arbitre 4

CREATE MATERIALIZED VIEW Arbitre_VM4
REFRESH
NEXT sysdate + 1/1440
AS
SELECT CODE_A, NOM_a, PRENOM_a, DATEDENAISSANCE_a, region_a, CLUBPREFERE_a FROM utilisateur1.Arbitre @U4toU1
JOIN utilisateur1.Matchs@U4toU1 ON Arbitre.code_a=Matchs.Codearbitre_m 
JOIN utilisateur1.Stade@U4toU1 ON Matchs.codestade_m=Stade.codestade 
WHERE Stade.region_s=4;

ALTER TABLE Arbitre_VM4 ADD CONSTRAINT pk_Arbitre_4 PRIMARY KEY (code_a);
ALTER TABLE Arbitre_VM4 ADD CONSTRAINT fk_Arbitre4_region FOREIGN KEY (region_a) REFERENCES Bureau4(region);

EXECUTE DBMS_REFRESH.REFRESH('Arbitre_VM4');

SELECT * FROM Arbitre_VM4;


-- Fragment staff tachnique 4

CREATE TABLE Stafftechnique4 AS SELECT CODE_ST, NOM_st, CODECLUB_ST, FONCTION_st FROM utilisateur1.Stafftechnique@U4toU1 JOIN clubsportif4 ON clubsportif4.codeclub = Stafftechnique.codeclub_st;

alter table Stafftechnique4 add constraint pk_code_st primary key (CODE_ST);
ALTER TABLE StaffTechnique4 ADD CONSTRAINT fk_StaffTechnique4_codeclub FOREIGN KEY (CODECLUB_ST) REFERENCES ClubSportif4(Codeclub);

select * from stafftechnique4;


-- Fragment Equipe 4

CREATE TABLE Equipe4 AS SELECT NumeroMaillot_eq, CodeClub_eq, CodeJoueur_eq, DateDebutContrat_eq, DateFinContrat_eq, Poste FROM utilisateur1.Equipe@U4toU1 NATURAL JOIN clubsportif4;

alter table Equipe4 add constraint pk_codeclub_equipe primary key (CODECLUB_eq);
ALTER TABLE Equipe4 ADD CONSTRAINT fk_Equipe4_codeclub FOREIGN KEY (CODECLUB_eq) REFERENCES ClubSportif4(Codeclub);

select * from Equipe4;


-- Fragment Joueur 4

CREATE TABLE Joueur4 AS SELECT CODEJOUEUR,Nom_j, PRENOM_j, DATENAISSANCE_j, NATIONALITE_j, POIDS_j, TAILLE_j, CLASSE_j
FROM utilisateur1.Joueur@U4toU1 JOIN utilisateur1.Equipe_VM@U4toU1 ON Joueur.Codejoueur=Equipe_VM.CodeJoueur_eq WHERE Codeclub_eq=4;

alter table Joueur4 add constraint pk_codejoueur primary key (CODEjoueur);

select * from Joueur4;