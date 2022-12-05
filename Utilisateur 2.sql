CREATE DATABASE LINK U2toU1 CONNECT TO utilisateur1 IDENTIFIED by password1 using 'localhost:1521/XE';

-- Fragment Bureau 2

CREATE TABLE Bureau2 AS SELECT * FROM utilisateur1.bureau@U2toU1 WHERE region=2;
ALTER TABLE Bureau2 ADD CONSTRAINT pk_bureau2 PRIMARY KEY (region);

SELECT * FROM bureau2;

--DROP TABLE Bureau2;


-- Fragment Dirigeant 2

CREATE TABLE Dirigeant2 AS 
SELECT CODEDIRIGEANT, NOM_d, PRENOM_d, PROFESSION_d FROM utilisateur1.dirigeant@U2toU1
JOIN utilisateur1.Clubsportif@U2toU1 ON dirigeant.codedirigeant=clubsportif.dirigeant_cs 
WHERE region_cs = 2;

ALTER TABLE Dirigeant2 ADD CONSTRAINT pk_Dirigeant2_codedirigeant PRIMARY KEY (codedirigeant);

SELECT * FROM Dirigeant2;


-- Fragment Stade 2

CREATE TABLE Stade2 AS SELECT * FROM utilisateur1.Stade@U2toU1 WHERE region_s=2;

alter table Stade2 add constraint pk_Stade2 primary key (Codestade);
alter table Stade2 add constraint fk_Stade2_region_s foreign key (region_s) references bureau2(region);

SELECT * FROM Stade2;


-- Fragment Personnel 2

create table personnel2 as select * from utilisateur1.personnel@U2toU1 where region_p=2;
alter table personnel2 add constraint pk_personnel2 primary key (Code_p);
alter table personnel2 add constraint fk_personnel2_region foreign key (region_p) references bureau2(region);

SELECT * FROM personnel2;

-- VM Calendrier 2

CREATE MATERIALIZED VIEW Calendrier_VM2
REFRESH
NEXT sysdate + 1/1440
AS SELECT CODEMATCH_c, DATE_c, HEURE, CLUBA, CLUBB, STADE_c FROM 
(SELECT * FROM utilisateur1.calendrier@U2toU1 
LEFT JOIN utilisateur1.Stade@U2toU1 
ON utilisateur1.Calendrier.stade_c@U2toU1=utilisateur1.STADE.codestade@U2toU1 
WHERE Stade.region_s=2) ;  -- 1min=1/24/60 ---

ALTER TABLE Calendrier_VM2 ADD CONSTRAINT pk_Calendrier2 PRIMARY KEY (codematch_c);

EXECUTE DBMS_REFRESH.REFRESH('Calendrier_VM2');

SELECT * FROM Calendrier_VM2;


-- VM Palmarès 2

CREATE MATERIALIZED VIEW Palmares_VM2
REFRESH
NEXT sysdate + 1/1440
AS SELECT CODECLUB_p, ANNEE_p, TROPHEE_p, NBRMATCHSGAGNES_p, NBRMATCHSPERDUS_p FROM 
(SELECT * FROM utilisateur1.Palmares@U2toU1 NATURAL JOIN utilisateur1.ClubSportif@U2toU1 WHERE ClubSportif.region_cs=2) ;  -- 1min=1/24/60 ---

ALTER TABLE Palmares_VM2 ADD CONSTRAINT pk_Palmares2 PRIMARY KEY (CODECLUB_p);

EXECUTE DBMS_REFRESH.REFRESH('Palmares_VM2');

SELECT * FROM Palmares_VM2;


-- Match VM2

CREATE MATERIALIZED VIEW Match_VM2
REFRESH
NEXT sysdate + 1/1440
AS SELECT * FROM (SELECT codematch, NBRBUTSCLUBA, NBRBUTSCLUBB, NBRESPECTATEURS, CODEARBITRE_m, CODESTADE_m FROM utilisateur1.matchs@U2toU1 
NATURAL JOIN utilisateur1.Calendrier@U2toU1 
JOIN utilisateur1.ClubSportif@U2toU1 ON Calendrier.ClubA=ClubSportif.CodeClub 
WHERE ClubSportif.region_cs=2
UNION
SELECT codematch, NBRBUTSCLUBA, NBRBUTSCLUBB, NBRESPECTATEURS, CODEARBITRE_m, CODESTADE_m FROM utilisateur1.matchs@U2toU1 
NATURAL JOIN utilisateur1.Calendrier@U2toU1 
JOIN utilisateur1.ClubSportif@U2toU1 ON Calendrier.ClubB=ClubSportif.CodeClub 
WHERE ClubSportif.region_cs=2);

ALTER TABLE Match_VM2 ADD CONSTRAINT pk_Match2 PRIMARY KEY (Codematch);

EXECUTE DBMS_REFRESH.REFRESH('Match_VM2');

SELECT * FROM Match_VM2;


-- Fragment ClubSportif 2

create table clubsportif2 as select * from utilisateur1.clubsportif@U2toU1 where region_cs=2;
alter table clubsportif2 add constraint pk_clubsportif2 primary key (Codeclub);
alter table clubsportif2 add constraint fk_clubsportif2_region foreign key (region_cs) references Bureau2(region);
alter table clubsportif2 add constraint fk_clubsportif2_dirigeant foreign key (dirigeant_cs) references Dirigeant2(Codedirigeant);

select * from clubsportif2;


-- VM Arbitre 2

CREATE MATERIALIZED VIEW Arbitre_VM2
REFRESH
NEXT sysdate + 1/1440
AS
SELECT CODE_A, NOM_a, PRENOM_a, DATEDENAISSANCE_a, region_a, CLUBPREFERE_a FROM utilisateur1.Arbitre @U2toU1
JOIN utilisateur1.Matchs@U2toU1 ON Arbitre.code_a=Matchs.Codearbitre_m 
JOIN utilisateur1.Stade@U2toU1 ON Matchs.codestadr_m=Stade.codestade 
WHERE Stade.region_s=2;

ALTER TABLE Arbitre_VM2 ADD CONSTRAINT pk_Arbitre_2 PRIMARY KEY (code_a);
ALTER TABLE Arbitre_VM2 ADD CONSTRAINT fk_Arbitre2_region FOREIGN KEY (region_a) REFERENCES Bureau2(region);

EXECUTE DBMS_REFRESH.REFRESH('Arbitre_VM2');

SELECT * FROM Arbitre_VM2;


-- Fragment staff tachnique 2

CREATE TABLE Stafftechnique2 AS SELECT CODE_ST, NOM_st, CODECLUB_ST, FONCTION_st FROM utilisateur1.Stafftechnique@U2toU1 JOIN clubsportif2 ON clubsportif2.codeclub = Stafftechnique.codeclub_st;

alter table Stafftechnique2 add constraint pk_code_st primary key (CODE_ST);
ALTER TABLE StaffTechnique2 ADD CONSTRAINT fk_StaffTechnique2_codeclub FOREIGN KEY (CODECLUB_ST) REFERENCES ClubSportif2(Codeclub);

select * from stafftechnique2;


-- Fragment Equipe 2

CREATE TABLE Equipe2 AS SELECT NumeroMaillot_eq, CodeClub_eq, CodeJoueur_eq, DateDebutContrat_eq, DateFinContrat_eq, Poste FROM utilisateur1.Equipe@U2toU1 NATURAL JOIN clubsportif2;

alter table Equipe2 add constraint pk_num_maillot primary key (NumeroMaillot_eq);
ALTER TABLE Equipe2 ADD CONSTRAINT fk_Equipe2_codeclub FOREIGN KEY (CODECLUB_eq) REFERENCES ClubSportif2(Codeclub);

select * from Equipe2;


-- Fragment Joueur 2

CREATE TABLE Joueur2 AS SELECT CODEJOUEUR,Nom_j, PRENOM_j, DATENAISSANCE_j, NATIONALITE_j, POIDS_j, TAILLE_j, CLASSE_j
FROM utilisateur1.Joueur@U2toU1 JOIN utilisateur1.Equipe_VM@U2toU1 ON Joueur.Codejoueur=Equipe_VM.CodeJoueur_eq WHERE Codeclub_eq=2;

alter table Joueur2 add constraint pk_codejoueur primary key (CODEjoueur);


select * from Joueur2;



