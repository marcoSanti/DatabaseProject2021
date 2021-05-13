--creo il tipo di cittadino
create type cittadinoType AS enum ('Altro', 'Scolastico', 'Sanitario', 'Fragili');

--tipo di prenotazione effettuata
create type originePrenotazioneType as enum ('Web', 'App'); 

--tipo di medico
create type tipoDiMedicoType as enum ('Di Base', 'Altro');


create table Cittadino(
    Codice_Fiscale varchar(20) primary key not null,
    Nome varchar(20) not null,
    Cognome varchar(20) not null,
    Eta smallint not null,
    Citta_residenza varchar(20),
    Indirizzo_residenza varchar(30),
    Categoria cittadinoType not null,
    Precedente_positivita_covid boolean not null default false,
    Precedenti_reazioni_allergiche varchar(200)
);


create table Vaccino(
    Nome_Vaccino varchar(20) not null primary key,
    Efficacia smallint not null,
    Eta_Max_Somministrazione smallint check (Eta_Max_Somministrazione > Eta_Minima_Somministrazione), --non not null in quanto un vaccino potrebbe avere anche non limitazione sull'età
    Eta_Minima_Somministrazione smallint check (Eta_Minima_Somministrazione > 0),
    Intervallo_Somministrazione integer, --intervallo di ssomminitrazione in giorni se previsto
    Somministrazioni_Richieste integer not null default 1,

    constraint Vaccino_Num_Somministrazioni_contraint check (
        (Somministrazioni_Richieste >= 2 and Intervallo_Somministrazione is not null) or
        (Somministrazioni_Richieste = 1 and Intervallo_Somministrazione is null)
    )
);



create table Lotto(
    ID_Lotto varchar(10) not null primary key,
    Data_Produzione date not null,
    Data_Scadenza date not null check (Data_Scadenza > Data_Produzione)
);



create table CentroVaccinale(
    Citta varchar(20) not null,
    Indirizzo varchar(20) not null,
	primary key (Citta, Indirizzo)
);


create table Medico(
    Codice_Fiscale varchar(20) not null,
    Citta_Centro_Vaccinale varchar(20) not null,
    Indirizzo_Centro_Vaccinale varchar(20) not null,
    TipoDiMedico tipoDiMedicoType not null default 'Di Base',

    foreign key(Codice_Fiscale) references Cittadino(Codice_Fiscale),
    foreign key(Citta_Centro_Vaccinale , Indirizzo_Centro_Vaccinale) references CentroVaccinale (Citta, Indirizzo),

    primary key (Codice_Fiscale, Indirizzo_Centro_Vaccinale, Citta_Centro_Vaccinale)
);


create table Prenotazione(
    Codice_Fiscale varchar(20) not null,
    Numero_Telefono varchar(15), 
    Indirizzo_Mail varchar(20),
    Origine_Prenotazione originePrenotazioneType not null,

    foreign key(Codice_Fiscale) references Cittadino(Codice_Fiscale),
    primary key(Codice_Fiscale),

    constraint Prenotazione_tipo_prenotazione_constraint check( 
        (Origine_Prenotazione = 'Web' AND Indirizzo_Mail is not null and Numero_Telefono is null) 
        or
        (Origine_Prenotazione = 'App' AND Indirizzo_Mail is null and Numero_Telefono is not null) 
    )
);


create table Convocazione(
    Codice_Fiscale varchar(20) not null,
    Ora time(2) not null, --capire cosa intende la precisione
    Data date not null,
    Codice_Operatore varchar(5) not null,
    Citta_Centro_Vaccinale varchar(20) not null,
    Indirizzo_Centro_Vaccinale varchar(20) not null,
    Nome_Vaccino varchar(20) not null,

    foreign key(Codice_Fiscale) references Prenotazione(Codice_Fiscale),
    foreign key(Citta_Centro_Vaccinale, Indirizzo_Centro_Vaccinale) references CentroVaccinale(Citta, Indirizzo),
    foreign key(Nome_Vaccino) references Vaccino(Nome_Vaccino),

    primary key(Codice_Fiscale, Ora, Data)
);


create table Somministrazione(
    Codice_Fiscale varchar(20) not null,
    Data date not null,
    Ora time(2) not null,
    Medico_Codice_Fiscale varchar(20) not null,
    Medico_Citta_Centro_Vaccinale varchar(20) not null,
    Medico_Indirizzo_Centro_Vaccinale varchar(20) not null,
    Lotto_ID varchar(10) not null,

    foreign key(Codice_Fiscale, Data, Ora) references Convocazione(Codice_Fiscale, Data, Ora),
    foreign key(Medico_Codice_Fiscale, Medico_Citta_Centro_Vaccinale, Medico_Indirizzo_Centro_Vaccinale) references Medico(Codice_Fiscale, Citta_Centro_Vaccinale, Indirizzo_Centro_Vaccinale),
    foreign key(Lotto_ID) references Lotto(ID_Lotto),

    primary key (Codice_Fiscale, Data, Ora)
);


create table Fiala(
    Numero_Seriale varchar(30) not null,
    Vaccino_Nome_Vaccino varchar(20) not null,
    Lotto_ID varchar(10) not null,

    foreign key(Vaccino_Nome_Vaccino) references Vaccino(Nome_Vaccino),
    foreign key(Lotto_ID) references Lotto(ID_Lotto),

    primary key(Numero_Seriale, Vaccino_Nome_Vaccino)
);


create table ReportAllergie(
    Codice_Fiscale varchar(20) not null,
    Data date not null,
    Descrizione_Reazione text not null,
    Lotto_ID varchar(10) not null,
    Citta_Centro_Vaccinale varchar(20) not null,
    Indirizzo_Centro_Vaccinale varchar(20) not null,
    Medico_Codice_Fiscale varchar(20) not null,
    Medico_Citta_Centro_Vaccinale varchar(20) not null,
    Medico_Indirizzo_Centro_Vaccinale varchar(20) not null,

    foreign key(Codice_Fiscale) references Cittadino(Codice_Fiscale),
    foreign key(Medico_Codice_Fiscale, Medico_Citta_Centro_Vaccinale, Medico_Indirizzo_Centro_Vaccinale) references Medico(Codice_Fiscale, Citta_Centro_Vaccinale, Indirizzo_Centro_Vaccinale),
    foreign key(Lotto_ID) references Lotto(ID_Lotto),
    foreign key(Citta_Centro_Vaccinale, Indirizzo_Centro_Vaccinale) references CentroVaccinale(Citta, Indirizzo),

    primary key (Codice_Fiscale)
);


create table Disponibilita(
    Citta_Centro_Vaccinale varchar(20) not null,
    Indirizzo_Centro_Vaccinale varchar(20) not null,
    Fiala_Numero_seriale varchar(30) not null,
    Fiala_Vaccino_Nome_Vaccino varchar(20) not null,

    foreign key(Citta_Centro_Vaccinale, Indirizzo_Centro_Vaccinale) references CentroVaccinale(Citta, Indirizzo),
    foreign key(Fiala_Numero_seriale, Fiala_Vaccino_Nome_Vaccino) references Fiala(Numero_Seriale, Vaccino_Nome_Vaccino),

    primary key(Citta_Centro_Vaccinale, Indirizzo_Centro_Vaccinale, Fiala_Numero_seriale)
);


create table FialeSomministrate(
    Citta_Centro_Vaccinale varchar(20) not null,
    Indirizzo_Centro_Vaccinale varchar(20) not null,
    Fiala_Numero_seriale varchar(30) not null,
    Fiala_Vaccino_Nome_Vaccino varchar(20) not null,

    foreign key(Citta_Centro_Vaccinale, Indirizzo_Centro_Vaccinale) references CentroVaccinale(Citta, Indirizzo),
    foreign key(Fiala_Numero_seriale, Fiala_Vaccino_Nome_Vaccino) references Fiala(Numero_Seriale, Vaccino_Nome_Vaccino),

    primary key(Citta_Centro_Vaccinale, Indirizzo_Centro_Vaccinale, Fiala_Numero_seriale)
);



--inserimenti a database

insert into Cittadino values ('PPIBDA80A01L219Z', 'Pippo', 'Baudo', 50, 'Torino', 'Via roma 20', 'Scolastico', false, '');
insert into Cittadino values ('NCLTMB83H03L219S', 'Nicola', 'Trombosi', 48, 'Milano','Via milano 120', 'Sanitario' , false, '');
insert into Cittadino values ('LSSGGI81H03F205A', 'Alessandro', 'Gigio', 40, 'Milano', 'Via bazinga 69', 'Sanitario', false, '');
insert into Cittadino values ('LCUPSL76E52D969X', 'Lucia', 'Pensaldo', 45, 'Genova', 'Via del vento 100', 'Fragili', false, '');
insert into Cittadino values ('MSSBLD45L23L483O', 'Massimo', 'Boldi', 76, 'Udine', 'Via cipollina 16', 'Altro', true, '');

insert into Cittadino values ('PLLFRC80A41L219R', 'Federica', 'Pellegrini', 41, 'Torino', 'Via nuoto 1', 'Sanitario', false, '');
insert into Cittadino values ('GNTRMS00A41D969W', 'Artemisia', 'Gentileschi', 60, 'Genova', 'Via degli artisti poveri 69', 'Sanitario', false, '');
insert into Cittadino values ('CRSSNT95A41L483B', 'Samantha', 'Cristoforetti', 26, 'Udine', 'Via dei falchi 600', 'Sanitario' ,false, '');


insert into Vaccino values ('COVIDIN', 75, 99, 16, 20 ,2);
insert into Vaccino values ('FLUSTOP', 90, 99, 18, NULL, 1);
insert into Vaccino values ('CORONAX', 60, 99, 60, 20, 2);


insert into Lotto values ('COV_1234', TO_DATE('18/05/2021', 'DD/MM/YYYY'), TO_DATE('01/08/2021', 'DD/MM/YYYY'));
insert into Lotto values ('FLU_5678', TO_DATE('12/02/2021', 'DD/MM/YYYY'), TO_DATE('01/10/2021', 'DD/MM/YYYY'));
insert into Lotto values ('COR_0122', TO_DATE('14/03/2021', 'DD/MM/YYYY'), TO_DATE('31/08/2021', 'DD/MM/YYYY'));
insert into Lotto values ('COR_0123', TO_DATE('14/03/2021', 'DD/MM/YYYY'), TO_DATE('31/08/2021', 'DD/MM/YYYY'));


insert into CentroVaccinale values ('Torino', 'Corso palestro 12');
insert into CentroVaccinale values ('Milano', 'Corso Svizzera 92');
insert into CentroVaccinale values ('Genova', 'Via Roma 60');
insert into CentroVaccinale values ('Udine', 'Via Garibaldi 1');


insert into Medico values ('NCLTMB83H03L219S', 'Milano', 'Corso Svizzera 92', 'Altro');
insert into Medico values ('PLLFRC80A41L219R', 'Torino', 'Corso palestro 12', 'Altro');
insert into Medico values ('GNTRMS00A41D969W', 'Genova', 'Via Roma 60', 'Altro');
insert into Medico values ('CRSSNT95A41L483B', 'Udine', 'Via Garibaldi 1', 'Altro');


insert into prenotazione values ('PPIBDA80A01L219Z', null, 'pippobaudo@rai.it', 'Web');
insert into prenotazione values ('LSSGGI81H03F205A', null, 'agigio@gmail.com', 'Web');
insert into prenotazione values ('LCUPSL76E52D969X', 0123456789, null, 'App');
insert into prenotazione values ('MSSBLD45L23L483O', 9876543210,null, 'App');
insert into prenotazione values ('CRSSNT95A41L483B', null, 's.cristo@esa.eu', 'Web');


insert into Convocazione Values ('PPIBDA80A01L219Z', '11:20', TO_DATE('10/05/2021', 'DD/MM/YYYY'), 'OP123', 'Torino', 'Corso palestro 12', 'COVIDIN');
insert into Convocazione Values ('LSSGGI81H03F205A', '15:30', TO_DATE('20/05/2021', 'DD/MM/YYYY'), 'OP123', 'Milano', 'Corso Svizzera 92', 'CORONAX');
insert into Convocazione Values ('LCUPSL76E52D969X', '18:00', TO_DATE('11/04/2021', 'DD/MM/YYYY'), 'OP123', 'Genova', 'Via Roma 60', 'FLUSTOP' );
insert into Convocazione Values ('MSSBLD45L23L483O', '08:00', TO_DATE('10/06/2021', 'DD/MM/YYYY'), 'OP123', 'Udine' , 'Via Garibaldi 1', 'COVIDIN' );
insert into Convocazione values ('CRSSNT95A41L483B', '12:15', TO_DATE('12/03/2021', 'DD/MM/YYYY'), 'OP567', 'Udine', 'Via Garibaldi 1', 'COVIDIN');


insert into Somministrazione values ('LSSGGI81H03F205A', TO_DATE('20/05/2021', 'DD/MM/YYYY'), '15:30' , 'NCLTMB83H03L219S', 'Milano', 'Corso Svizzera 92', 'COV_1234' );
insert into Somministrazione values ('PPIBDA80A01L219Z', TO_DATE('10/05/2021', 'DD/MM/YYYY'), '11:20' , 'PLLFRC80A41L219R', 'Torino', 'Corso palestro 12', 'COR_0122' );
insert into Somministrazione values ('LCUPSL76E52D969X', TO_DATE('11/04/2021', 'DD/MM/YYYY'), '18:00', 'GNTRMS00A41D969W','Genova', 'Via Roma 60', 'FLU_5678' );
insert into Somministrazione values ('MSSBLD45L23L483O', TO_DATE('10/06/2021', 'DD/MM/YYYY'), '08:00', 'CRSSNT95A41L483B', 'Udine', 'Via Garibaldi 1', 'COR_0122');
insert into Somministrazione values ('CRSSNT95A41L483B', TO_DATE('12/03/2021', 'DD/MM/YYYY'), '12:15', 'CRSSNT95A41L483B', 'Udine', 'Via Garibaldi 1', 'COV_1234');

insert into Fiala values ('FCOV123', 'COVIDIN', 'COV_1234');
insert into Fiala values ('FCOV456', 'COVIDIN', 'COV_1234');
insert into Fiala values ('FCOV789', 'COVIDIN', 'COV_1234');
insert into Fiala values ('FCOR123', 'CORONAX', 'COR_0122');
insert into Fiala values ('FCOR456', 'CORONAX', 'COR_0122');
insert into Fiala values ('FCOR789', 'CORONAX', 'COR_0122');
insert into Fiala values ('FFLU123', 'FLUSTOP', 'FLU_5678');
insert into Fiala values ('FFLU456', 'FLUSTOP', 'FLU_5678');
insert into Fiala values ('FFLU789', 'FLUSTOP', 'FLU_5678');


insert into ReportAllergie values ('LSSGGI81H03F205A', TO_DATE('20/05/2021', 'DD/MM/YYYY'), 'gonfiore nella sede di inoculo.', 'COV_1234', 'Milano', 'Corso Svizzera 92','NCLTMB83H03L219S', 'Milano', 'Corso Svizzera 92');


insert into Disponibilita values('Milano', 'Corso Svizzera 92', 'FCOV456', 'COVIDIN');
insert into Disponibilita values('Milano', 'Corso Svizzera 92', 'FCOV789', 'COVIDIN');
insert into Disponibilita values('Milano', 'Corso Svizzera 92', 'FFLU123', 'FLUSTOP');
insert into Disponibilita values('Milano', 'Corso Svizzera 92', 'FCOR123', 'CORONAX');
insert into Disponibilita values('Milano', 'Corso Svizzera 92', 'FCOV123', 'COVIDIN');


--operazioni sql

--per ogni centro vaccinale elencare le fiale disponibili ancora
select Citta_Centro_Vaccinale Città_centro, Indirizzo_Centro_Vaccinale Indirizzo_Centro, count(*) Fiale_disponibili
from Disponibilita
group by Disponibilita.Indirizzo_Centro_Vaccinale, Disponibilita.Citta_Centro_Vaccinale;



--Numero di somministrazioni per categoria di Vaccinati

select cittadino.categoria Categoria, count(*) Somministrazioni_fatte
from Somministrazione join Cittadino on Cittadino.Codice_Fiscale = Somministrazione.Codice_Fiscale
group by Cittadino.Categoria;


--contare quante prenotazioni sono state fatte via web e via app

select Origine_Prenotazione, count(*) Conteggio
from prenotazione
group by Origine_Prenotazione;


--mostrare i report allergie fatti dal medico Federica pellegrini
select Cittadino.Nome, Cittadino.Cognome,  ReportAllergie.Descrizione_Reazione
from ReportAllergie join Cittadino on Cittadino.Codice_Fiscale = ReportAllergie.Codice_Fiscale
where ReportAllergie.Medico_Codice_Fiscale like 'PLLFRC%';



--mostrare quante somministrazioni sono state fatte per ogni lotto
select Lotto.id_lotto, COALESCE(count(Somministrazione.*), 0)
from Somministrazione right join Lotto on Lotto.id_lotto = Somministrazione.Lotto_ID
group by Lotto.id_lotto;