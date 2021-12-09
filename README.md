# Green Pass decoder
## Shiny web app per decifrare il contenuto di un green pass

Il file `gp_app.r` contiene una web app capace di decodificare un green pass mediante un'interfaccia grafica; in particolare per usare l'app bisogna incollare nel campo indicato la stringa ottenuta usando una qualunque app per leggere codici qr. 
La lettura della stringa viene effettuata mediante lo script python `gp.py` (ispirato da [questo codice di Tobias Girstmair](https://git.gir.st/greenpass.git/blob_plain/master:/greenpass.py)), che può essere usato indipendentemente importando la funzione `green_pass_decoder` al suo interno; in `gp_app.r` quest'ultima viene importata mediante `reticulate::import`.

La stringa viene elaborata così:
- vengono rimossi i primi 4 caratteri, che rappresentano un header irrilevante al fine di leggere il green pass;
- viene decodificata la stringa risultante secondo lo standard base45 mediante `base45.b45decode`;
- viene decompressa la stringa risultante mediante `zlib.decompress`;
- infine viene decompresso secondo lo standard CBOR il risultato mediante `flynn.decompress`.

L'app Shiny è da considerarsi solo un proof-of-concept, in quanto mancano le seguenti funzioni che mi piacerebbe aggiungere:
- una spiegazione dettagliata comprensibile a tutti di cosa venga svolto dal codice e perché;
- una traduzione completa in termini umani dell'output grezzo di `gp.green_pass_decoder`, da effettuare usando i documenti dell'UE [1](https://ec.europa.eu/health/sites/default/files/ehealth/docs/covid-certificate_json_specification_en.pdf) e [2](https://ec.europa.eu/health/sites/default/files/ehealth/docs/digital-green-certificates_dt-specifications_en.pdf). Nel codice ne è presente un abbozzo, ma è incompleto;
- riguardo al punto precedente: l'abbozzo è hard-coded, mentre bisognerebbe progettare un meccanismo per scaricare i json aggiornati dell'UE ed usarli per effettuare una annotazione "al passo coi tempi";
- potrebbe essere interessante aggiungere la possibilità di decifrare direttamente il QR code, anziché la stringa che si ottiene mediante app. Si potrebbe ad esempio usare `shiny::fileInput` in un'altra scheda e un ulteriore script python e Pillow/OpenCV/ZBar/eccetera.

Nonostante le mancanze di cui sopra l'app è funzionante quanto basta, in quanto in grado di restituire tutte le informazioni contenute nel green pass (che comunque vanno confrontante con quanto scritto in [1](https://ec.europa.eu/health/sites/default/files/ehealth/docs/covid-certificate_json_specification_en.pdf) per essere comprese).
Preferisco evitare il deployment in quanto caricare dati sensibili su internet è in generale una pessima idea; pertanto per eseguire l'app bisogna clonare la repository e lavorare localmente. A tale scopo bisogna avere una installazione di R (con le librerie tidyverse, shiny, shinythemes, reticulate) e di python (con base45 e flynn installate ad esempio mediante pip), con reticulate configurato in modo da trovare l'environment python su cui vengano installate le librerie necessarie.

L'app è stata testata su R 4.1.1 e python 3.9.7, ma dovrebbe funzionare con versioni qualunque purché relativamente recenti (stesso dicasi per le versioni delle librerie necessarie).

Infine anche se quest'app è innocua purché eseguita con green pass fittizi/localmente non mi assumo nessuna responsabilità riguardo eventuali utilizzi impropri della stessa.
