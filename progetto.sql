--creo il tipo di cittadino
create type cittadinoType AS enum ('Altro', 'Scolastico', 'Sanitario', 'Fragili');

--tipo di prenotazione effettuata
create type originePrenotazioneType as enum ('Web', 'App'); 


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
    Somministrazioni_Richieste integer not null default 1

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

    foreign key(Codice_Fiscale) references Cittadino(Codice_Fiscale),
    foreign key(Citta_Centro_Vaccinale , Indirizzo_Centro_Vaccinale) references CentroVaccinale (Citta, Indirizzo),

    primary key (Codice_Fiscale, Indirizzo_Centro_Vaccinale, Citta_Centro_Vaccinale)
);


create table Prenotazione(
    Codice_Fiscale varchar(20) not null,
    Numero_Telefono varchar(15), --INSERIRE VINCOLO CHE O NUM TELEFONO O EMAIL
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