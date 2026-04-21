**********************************************************************************ESISTE UNA RELAZIONE TRA USO DI INTERNET E LA PARTECIPAZIONE POLITICA TRA ITALIA E SVEZIA?********************************* ********************************************************************

cd C:\Users\alice\Documents\STATA

log using presentazione_statistica.log, replace

//usiamo il Round 11 dell'European Social Survey quindi con dati che fanno riferimento al periodo post-covid per capire se le teorie si confermano anche dopo la pandemia. 

use ESS11e04_1

//vogliamo studiare che tipo di relazione esiste tra l'uso di internet e la partecipazione politica in Italia e in Svezia, studiando come cambia la relazione tra i singoli paesi. 

keep if cntry == "IT" | cntry == "SE"

//selezioniamo le variabili per uso di internet

lookfor internet
describe netusoft
codebook netusoft
tab netusoft, m

//identifichiamo i missing values 

replace netusoft = . if netusoft == .a
replace netusoft = . if netusoft == .b

tab netusoft, m 
drop if netusoft == .
tab netusoft,m

//creiamo la nuova variabile internet_use raggruppando i valori della variabile netusoft

gen internet_use = . 
replace internet_use = 1 if inlist(netusoft, 4,5)
replace internet_use = 2 if inlist(netusoft, 2,3)
replace internet_use = 3 if netusoft == 1
label variable internet_use "internet use frequency"
label define internet_use 1 "frequent user" ///
						  2 "occasional user" ///
						  3 "non-user" 
label value internet_use internet_use
						  
tab internet_use, m 

//definiamo le variabili per la partecipazione politica combinandole per creare un'indice che la identifichi 

codebook pstplonl sgnptit bctprd 

tab pstplonl, m
tab sgnptit, m
tab bctprd, m

//identifichiamo i missing values per ciascuna variabile
replace pstplonl = . if pstplonl == .a
replace pstplonl = . if pstplonl == .b
replace sgnptit = . if sgnptit == .a
replace sgnptit = . if sgnptit == .b
replace bctprd = . if bctprd == .a
replace bctprd = . if bctprd == .b
drop if pstplonl == .
drop if sgnptit == .
drop if bctprd == .

tab pstplonl, m
tab sgnptit,m
tab bctprd,m

//creo indice per la partecipazione politica 						
gen part_online = (pstplonl == 1)
gen part_petition = (sgnptit == 1)
gen part_boycott = (bctprd == 1)

gen pol_participation = part_online + part_petition + part_boycott
label variable pol_participation "Political partecipation index"
tab pol_participation,m 	  


*******************************************************************************
*******************ANALISI DESCRITTIVA MONOVARIATA*************************	  
						  
//osserviamo la variabile indipendente e dipendente separatamente per Italia e Svezia 

*Italia
tab internet_use if cntry == "IT", m 
asdoc tab internet_use if cntry =="IT", m replace label dec(2) ///
	title(Table 1: Internet Use - Italy) ///
	save(internet_use_Italy_R11.doc), replace
	
	
tab pol_participation if cntry == "IT", m 
asdoc tab pol_participation if cntry =="IT", m replace label dec(2) ///
	title(Table 2: Political Participation Index - Italy) ///
	save(Political_participation_Italy_R11.doc), replace

*Svezia
tab internet_use if cntry == "SE", m 
asdoc tab internet_use if cntry =="SE", m replace label dec(2) ///
	title(Table 3: Internet Use - Sweden) ///
	save(Internet_use_Sweden_R11.doc), replace
	
tab pol_participation if cntry == "SE", m 
asdoc tab pol_participation if cntry =="SE", m replace label dec(2) ///
	title(Table 4: Political Participation Index - Sweden) ///
	save(Political_participation_Sweden_R11.doc), replace
	
*grafico per la distribuzione dell' uso di internet per paese 

graph pie, over(internet_use) by(cntry) ///
	title("Internet use by country") ///
	pie(1, color(blue)) ///
	pie(2, color(ltblue)) ///
	pie(3, color(dknavy))
graph save grafico_internet.gph, replace

*grafico per la partecipazione politica per paese

graph pie, over(pol_participation) by(cntry) ///
    title("Political participation by country") ///
	pie(1, color(blue)) ///
	pie(2, color(ltblue)) ///
	pie(3, color(navy)) ///
	pie(4, color(dknavy))
graph save grafico_partecipazione.gph, replace


*******************************************************************************
********************ANALISI DESCRITTIVA BIVARIATA******************************

//relazione tra uso di internet e partecipazione nei due paesi

tab internet_use pol_participation if cntry == "IT", row
tab internet_use pol_participation if cntry == "SE", row

tab internet_use pol_participation if cntry == "IT", chi2
tab internet_use pol_participation if cntry == "SE", chi2

*Italia
asdoc tab internet_use pol_participation if cntry=="IT", ///
    row nof chi2 replace label dec(2) ///
    title(Table 5: Internet Use and Political Participation - Italy) ///
    save(bivariata_Italia_R11.doc), replace

*Svezia
asdoc tab internet_use pol_participation if cntry=="SE", ///
    row nof chi2 replace label dec(2) ///
    title(Table 6: Internet Use and Political Participation - Sweden) ///
    save(bivariata_svezia_R11.doc), replace

*relazione in Italia per non user
preserve
keep if cntry=="IT" & internet_use==3
graph bar (percent), over(pol_participation) ///
    title(Italy: Non Users) ///
    ytitle(Percent) ///
    blabel(bar, format(%4.1f))
graph save graf_IT_nonuser.gph, replace
restore

*relazione in Svezia per non user
preserve
keep if cntry=="SE" & internet_use==3
graph bar (percent), over(pol_participation) ///
    title(Sweden: Non Users) ///
    ytitle(Percent) ///
    blabel(bar, format(%4.1f))
graph save graf_SE_nonuser.gph, replace
restore

*relazione a confronto nei due paesi 
graph combine graf_IT_nonuser.gph graf_SE_nonuser.gph, ///
    ycommon title(Non Users: Italy vs Sweden)
graph save graf_nonuser_confronto.gph, replace


*relazione in Italia per frequent e occasional user
preserve
keep if cntry=="IT" & inlist(internet_use, 1, 2)
graph bar (percent), over(pol_participation) ///
    title(Italy: Internet Users) ///
    ytitle(Percent) ///
    blabel(bar, format(%4.1f))
graph save graf_IT_users.gph, replace
restore

*relazione in Svezia per frequent e occasional user
preserve
keep if cntry=="SE" & inlist(internet_use, 1, 2)
graph bar (percent), over(pol_participation) ///
    title(Sweden: Internet Users) ///
    ytitle(Percent) ///
    blabel(bar, format(%4.1f))
graph save graf_SE_users.gph, replace
restore

*relazione a confronto nei due paesi
graph combine graf_IT_users.gph graf_SE_users.gph, ///
    ycommon title(Internet Users: Italy vs Sweden)
graph save graf_users_confronto.gph, replace


*grafici a confronto divisi per paesi e per uso di internet
graph combine graf_IT_nonuser.gph graf_SE_nonuser.gph ///
              graf_IT_users.gph graf_SE_users.gph, ///
    ycommon ///
    title(Italy vs Sweden: Non Users and Internet Users) ///
    cols(2)
graph save graf_totale_confronto.gph, replace


//raggruppo la variabile pol_participation dividendo chi ha partecipato almeno in una forma da chi non ha mai partecipato per evidenziare i risultati 

gen part_bin = 0
replace part_bin = 1 if pol_participation > 0
label variable part_bin "Political participation"
label define part_bin 0 "Does not participate" 1 "Participates"
label value part_bin part_bin

* Italia - non user
preserve
keep if cntry=="IT" & internet_use==3
graph bar (percent), over(part_bin) ///
    title(Italy: Non Users) ytitle(Percent) ///
    blabel(bar, format(%4.1f))
graph save graf_IT_nonuser2.gph, replace
restore

* Italia - users
preserve
keep if cntry=="IT" & inlist(internet_use, 1, 2)
graph bar (percent), over(part_bin) ///
    title(Italy: Internet Users) ytitle(Percent) ///
    blabel(bar, format(%4.1f))
graph save graf_IT_users2.gph, replace
restore

* Svezia - non user
preserve
keep if cntry=="SE" & internet_use==3
graph bar (percent), over(part_bin) ///
    title(Sweden: Non Users) ytitle(Percent) ///
    blabel(bar, format(%4.1f))
graph save graf_SE_nonuser2.gph, replace
restore

* Svezia - users
preserve
keep if cntry=="SE" & inlist(internet_use, 1, 2)
graph bar (percent), over(part_bin) ///
    title(Sweden: Internet Users) ytitle(Percent) ///
    blabel(bar, format(%4.1f))
graph save graf_SE_users2.gph, replace
restore

* Combina tutti e quattro
graph combine graf_IT_nonuser2.gph graf_SE_nonuser2.gph ///
              graf_IT_users2.gph graf_SE_users2.gph, ///
    ycommon cols(2) ///
    title(Political Participation by Internet Use)
graph save graf_finale2.gph, replace


log close

