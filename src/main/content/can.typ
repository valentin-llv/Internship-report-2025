= Réalisation d'une IP CAN

== Introduction

Pour IonSat, le CAN est une composante essentiel pour la communication de plusieurs system critique. Il relie l'ordinateur de bord, le propulseur, et le system de control d'attitude. C'est system sont cruciaux pour la survie du satellite et les communication doivent être gérer correctement pour prevenir les erreurs dû au perturbation electronique ou aux radiations spatiales.

Le PCB étant déjà existant, l'ordinateur de bord dispose d'un transceiver CAN pour la generation des signaux electroique sur le bus mais il faut aussi disposer d'un controller CAN pour le protocole. Ce controlleur peut etre implementer es plusieurs facon, soit par un puce dédié externe, soit si le CPU dispose d'n controlleur integré ou sous forme d'IP pour FPGA. L'avantage des deux derniers solutions est que le controlleur est ainsi au plus proche du CPU et protogé contre les radiations. L'utilisation d'un FPGA apporte plus de flexibilité dans l'implentation et les fonctionnalitées.

La premiere partie du stage à ainsi consisté en la realisation d'une IP CAN pour FPGA Xilinx.

== Le CAN

Tout d'abord, il convient d'expliquer brievement comment fonctionne le CAN. Le CAN, developé par Bosh, correspond a deux choses : un bus de communication et un protocole, il correspond donc au deux couches basse du model de communication OSI : la couche physique et la couche liaison de données. Le CAN est défini dans plusieurs norme ISO, dont la norme ISO 11898 de 2016 qui definie la version 2 du protocol de communication et qui est celle avec laquelle j'ai travaillé.

Très largement utilisé dans l'automobile, le CAN est particulièrement apprécié pour sa capacité à fonctionner sur de longues distances, supérieures à celles du SPI ou de l'I2C (jusqu'à 1 kilomètre de câble). Il se distingue également par sa robustesse face aux perturbations et sa gestion avancée des erreurs

Parmi ses principaux avantages, le protocole offre :
- une communication multi-maître asynchrone,
- une tolérance élevée aux erreurs
- un débit pouvant atteindre 1 Mbit/s (ceci inclut les bits de trame ; le débit utile est donc inférieur).

=== Le bus CAN

Le couche physique du bus CAN est définie par la norme ISO 11898-2 pour le CAN haute vitesse. Le bus de donnée se compose d'une simple paire différentiel auquel sont connecté tous les neouds sur le bus. Un noeuds CAN est composé d'un controlleur CAN pour la gestion du protocol et d'un transceiver pour la lecture et generation des niveaux de tensions sur le bus.

La paire différentielle, CAN H et CAN L, nomme deux niveaux de tension pour transmettre soit 0 soit 1 : le niveau dominant (0) et le niveau recessif (1). Au niveau recessif les tension H et L sont a 2.5V et pour le niveaux dominant, CAN H vaut 3.5V et CAN L 1.5V.  Cette utilisation de la différence de potentiel permet de réduire les interférences électromagnétiques. En effet, si un bruit électromagnétique est capté par les deux fils, il sera capté de la même manière et donc ne changera pas la différence de potentiel. Cette propriété permet au bus CAN d'être très robuste.

Par défaut le bus est a un niveau recessif, jusqu'a ce qu'un des noeuds force un niveau dominant. Le bus etant de type "Wire AND" le niveau dominant prevau au niveau recessif et si un noeuds force le niveau dominant (quel que soit le niveau des autres noeuds) le niveau du bus sera dominant.

Enfin le bus est toujours terminé par une resistance de 120 Ohms de chaque coté pour evite les reflextions et s'assusrer de l'impendance du bus.

TODO image, potentiollement de ce site : https://se1.isc.heia-fr.ch/lecture/mcu/can/#couche-physique

=== Le protocole CAN

Le protocol CAN est assez complexe a cause de la simplicite du bus (pas de clock, ni de signal de control) mais aussi car il permet un tres bonne gestion des erreurs. Le bus etant aussi multi-maitre, le protocol inclue aussi la gestion d'abitration du bus et de priorité.

Un controller peut transmettre trois type de trame sur le bus : 
- une trame de données
- une trame de requette
- une trame d'erreur

=== Trame de données

Les trame de données, servent a transferer de l'information a un ou plusieurs autre noeuds, cette données d'entre 1 et 8 octets est associé a un identifiant. L'utilisation d'un identifiant de données permet de transmettre une meme information a plusieurs noeuds, ce n'est pas l'adresse du destinataire.

Une trame de données est formatté comme suit : 

TODO image trame de données, celle la est bien https://se1.isc.heia-fr.ch/lecture/mcu/can/#trame-can

Detail des champs : 
- SOF : Start of Frame, premier bit dominant pour indiquer le debut d'un transfert
- Identifier : 11 bit d'identifiant pour la données
- SSR : champ réservé, à niveau récessif (présent uniquement dans les trames étendues).
- IDE : identifier extension, indiquant si l'identifiant est standard (11 bits) ou étendu (29 bits)
- Identifier 2 : 18 bit supplémentaire d'identifiant pour la données sur utilisation du mode etendu
- RTR : remote transmission request, indiquant une trame de données 1 ou de requette 0
- R1 : reservé pour d'autre version du protocol, forcé a 1
- R0 : reservé pour d'autre version du protocol, forcé a 1
- DLC : Data Length Code, indiquant la taille des données (0 à 8 octets)
- Data : les données a transmettre, de 0 a 8 octets
- CRC : Cyclic Redundancy Check, utilisé pour détecter les erreurs dans la trame
- ACK : Acknowledgment, utilisé pour confirmer la réception d'une trame par les autre noeuds
- EOF : End of Frame, dernier bit dominant pour indiquer la fin d'un transfert

Les trames de noeuds peuvent utiliserr des modes : le mode standar ou etendu. En mode etendu, la taile de l'identifiant passe a 29 bit au total (11 + 18). L'utilisation de ce mode est indiqué par le bit IDE.

=== Trame de requette

Une trame de requette est composé comme une trame de données a ceci pres que le champ de données reste vide et que le bit RTR est à 1. Toutefois le champ DLC peut etre non nul pour indiquer la taille des données attendues.

=== Arbitrage

Le bus etant multi-maitre, chaque noeuds pour vouloir parler sur le bus a tous moment. Pour eviter les conflit et ne pas erroner des trames ou perdre des données, le protocol implemente une phase d'arbitrate pour données le main sur le bus a un seul noeuds.

Dans le cas ou le bus est a niveau recessif (et qu'un transmission n'est pas en cours), un noeuds pour commencer une transmission avec le SOF (bit dominant) pour prendre le bus. Tout les autres noeuds vont alors se mettre en mode reception et attendre que le bus soit libre pour envoyer des données. Si toutefois deux noeuds ou plus venait a transmettre un SOF en même temps aucun de ces noeuds pourrai s'assurer qu'il a bien la main sur le bus, c'est l'identifian de 11 qui va permettre d'effectuer l'arbitrage.

Le protocol indique que chaque noeuds doit parallement pouvoir etre et lire sur le bus. Ainsi chaque noeuds est tenu de lire le niveau du bus apres avoir transmis un bit. Le niveau dominant etant prevalant, si un noeuds transmet un niveau recessif mais que le bus reste dominant, alors un autre noeuds est lui aussi en train de transmettre. Dans ce cas, e noeuds transmettant un bit recessif arrette sa transmission est devient un recepteur. La phase d'abitration dure pendant toute la transmission de l'identifiant, l'identifiant le plus proche de 0 est ainsi le plus prioritaire.

A la fin de la transmission de l'identifiant, comme deux noeuds ne peuvent pas transmettre deux identifiants identique (mais peuvent transmettre plusieurs identifiant différent), le noeuds restant en mode transmission est sur d'être seul sur le bus a ce moment la est peut commencer a transmettre la suite de la trame.

TODO image

=== Synchronisation

Le bus ne disposant pas de signal d'horloge, les noeuds recepteur doivent se synchroniser sur l'emmetteur pour lire les données. Le protocol définie des mode de synchronisation basé sur un découpage temporel des transmission. Ainsi protocole CAN repose sur une synchronisation bit à bit, qui s'appuie sur les transitions du signal, des fronts récessif <-> dominant. Ces fronts servent de repères pour corriger les décalages d'horloge.

==== Bit timing

Le `bit timing` (ou `nominal bit time`) correspond à la durée de transmission d'un bit sur le bus. Il fixe donc le débit de transmission : plus cette durée est courte, plus le débit dans le bus est élevé.

Le `bit time` est divisé en plusieurs segments pour permettre l'échantillonnage et la correction de phase.

==== Time Quantum (TQ)

Le `Time Quantum (TQ)` est l'unité élémentaire de temps utilisée pour diviser le `bit time`. Un `bit time` est donc composé d'un nombre entier de TQ : `bit time = N x TQ`

Le bit time est découpé en 4 segments :

- SYNC_SEG : toujours 1 TQ — utilisé pour détecter les transitions.
- PROP_SEG : compense les délais de propagation (entre 1 et 8 TQ).
- PHASE_SEG1 (aussi appelé BUFFER_SEG1) : avant l'échantillonnage (entre 1 et 8 TQ), permet une correction positive de phase.
- PHASE_SEG2 (BUFFER_SEG2) : après l'échantillonnage (entre 2 et 8 TQ), permet une correction négative de phase.

TODO image

Tous les nœuds du bus doivent partager la même configuration du bit timing, notamment les longueurs de TQ et des différents segments.

==== SYNC SEG

Le segment SYNC (1 TQ) marque le début de chaque bit et doit contenir un front descendant (récessif → dominant). Si ce front n'est pas détecté, une re-synchronisation peut être déclenchée pour réaligner le timing.

==== PROP SEG

Cette phase permet de compenser les retards dus à la conversion des signaux (ADC/DAC) et à la propagation dans les fils. Sa durée est fixée lors de la configuration et est généralement calculée en fonction de la longueur du bus.

==== BUFFER SEG 1

Segment avant l'échantillonnage du bit. Sa durée initiale est fixe, mais elle peut être temporairement augmentée si une re-synchronisation le nécessite.

Une plus grande valeur (en nombre de TQ) de `BS1` offre une meilleure tolérance aux décalages entre les horloges des nœuds.

Le sample point, où la valeur du bit est lue, se trouve à la fin du `BS1`.

==== BUFFER SEG 2

Segment après l'échantillonnage du bit. Il est également utilisé pour ajuster le timing en cas de décalage, mais à l'inverse du `BS1`, il peut être réduit lors d'une re-synchronisation.

Sa durée est comprise entre 2 et 8 TQ. Selon la norme ISO 11898, certaines contraintes s'appliquent :
- `BS2` ne doit pas être inférieur à `2 TQ`.
- `BS2` ne peut pas être ajusté lors d'une synchronisation "hard" (changement de bit).
- `BS1` doit être supérieur ou égal à `BS2` dans certaines implémentations matérielles.

==== Modes de synchronisation

Il existe deux types de synchronisation : la synchronisation forcée (*hard synchronization*) et la re-synchronisation (*re-synchronization*).

===== Hard synchronisation

La synchronisation forcée intervient dans deux cas :
- Lors de la détection d'un Start of Frame (SOF).
- Lorsqu'un front récessif → dominant est détecté pendant le `SYNC_SEG`.

Dans ces cas, le `bit time` en cours est immédiatement abandonné, et un nouveau comptage commence à la fin du `SYNC_SEG`, juste après le front détecté. Cela permet de réaligner parfaitement les horloges sur un front fiable.

===== Re-synchronisation

La re-synchronisation a lieu lorsqu'un front récessif → dominant est détecté en dehors du `SYNC_SEG`. Dans ce cas, on ajuste dynamiquement la durée des segments `BS1` et `BS2` pour corriger le décalage temporel.

===== L'erreur de phase

L'erreur de phase `e` est calculée comme la différence entre la position réelle du front et la fin théorique du `SYNC_SEG` :
- Si le front est en avance, alors `e > 0`.
- Si le front est en retard, alors `e < 0`.

Le front est considéré en retard s'il intervient avec le point d'échantillonnage et en avance s'il intervient après celui-ci mais avant le `SYNC_SEG`.

`e` s'exprime en nombre de TQ.

===== Max Jump Width (RJW)

Le `RJW` est une valeur définie pour limiter l'amplitude des corrections de phase.  
Elle est calculée ainsi : `RJW = min(4, BS1)`

===== Application du décalage

L'ajustement des segments se fait comme suit :
- Si `e > 0`, on allonge `BS1` de `min(e, RJW)`.
- Si `e < 0`, on raccourcit `BS2` de `min(|e|, RJW)`.

Ces modifications assurent un réalignement progressif des horloges sans perturber l'échantillonnage.

=== CRC (Cyclic Redundancy Check)

Le CRC est utilisé pour vérifier l'intégrité des données transmises.  
L'émetteur calcule un CRC à partir du contenu de la trame, et l'insère dans le champ `CRC`.

Les récepteurs effectuent le même calcul à réception de la trame.  
Si la valeur reçue diffère de la valeur calculée, une erreur CRC est détectée (cf. Gestion des erreurs).

=== ACK

L'acquittement utilise les deux bits du champ `ACK` :

- Le premier bit est laissé récessif par l'émetteur. Tous les récepteurs qui ont bien reçu la trame et qui n'ont détecté aucune erreur forcent ce bit à l'état dominant.
- Le deuxième bit, appelé ACK delimiter, est toujours récessif.

Si aucun récepteur ne force le bit dominant, l'émetteur considère que l'envoi a échoué (ACK error).

=== Bit stuffing

Pour garantir la présence régulière de fronts sur le bus (utiles à la synchronisation), un bit de stuffing est inséré automatiquement après 5 bits consécutifs de même valeur.

Exemple :  
`11111` devient `111110` (un bit de valeur opposée est inséré).

TODO image

=== Intertrame

Une période de repos appelée intertrame est imposée entre deux trames (données ou requêtes).

Elle dure au minimum 3 bits récessifs consécutifs. Ce délai permet aux récepteurs de traiter la trame précédente et au bus de se stabiliser.

Si aucune nouvelle trame n'est envoyée, le bus reste au niveau récessif (idle).

Note : Dans le cas d'un nœud en mode d'erreur passive venant de transmettre un message, un champ de suspension de transmission doit être ajouté juste après l'intermission. Ce champ dure 7 bits récessifs en plus des 3 bits d'intertrame.  TODO check 7

=== Bit monitoring

Le bit monitoring consiste à lire les bits envoyés pour vérifier leur cohérence avec ce qui est transmis.

Cela permet de :
- Détecter une perte d'arbitrage (par exemple si un bit récessif est lu dominant).
- Vérifier que le contrôleur CAN transmet correctement, via son module de réception indépendant.

=== Gestion des erreurs

Il existe 5 types d'erreurs possibles sur le bus CAN :

1. Bit Error : L'émetteur lit un bit différent de celui qu'il a envoyé.  
*Exceptions* :
- Pendant l'arbitrage.
- Si personne ne répond à l'ACK.

2. Stuffing Error : Plus de 5 bits consécutifs identiques détectés (hors champs exclus).

3. CRC Error : Le CRC reçu ne correspond pas à celui calculé localement.

4. Field Delimiter Error : Un champ de délimitation (`ACK delimiter`, `CRC delimiter`) n'est pas récessif.

5. ACK Slot Error : L'émetteur ne détecte pas de bit dominant à l'emplacement de l'ACK, indiquant que personne n'a acquitté la trame.

==== Trame d'erreur

En cas d'une erreur quelconque détectée par l'un des terminaux, celui-ci doit immédiatement transmettre une trame d'erreur.

Une trame d'erreur est composée de 2 champs :
- `flag error` (sur 6 bits) : peut être un flag `passif` ou `actif`
- `error frame delimiter` (8 bits) : forcé à un niveau `récessif`

==== Mode erreur actif et mode passif

Chaque terminal possède deux compteurs :
- `TEC` (Transmit Error Counter)
- `REC` (Receive Error Counter)

Ils déterminent l'état du terminal :

TODO table format

| État des compteurs         | Mode d'erreur |
|----------------------------|---------------|
| `TEC` ≤ 127 et `REC` ≤ 127 | Actif         |
| `TEC` > 127 ou `REC` > 127 | Passif        |
| `TEC` > 255                | Bus Off       |

- En mode actif, le terminal émet une trame d'erreur avec 6 bits dominants.
- En mode passif, le terminal émet une trame d'erreur avec 6 bits récessifs.
- En mode Bus Off, le terminal se déconnecte du bus (ne participe plus aux échanges). Il ne peut revenir qu'après un reset logiciel ou matériel.

TODO image

==== Valeur des flags d'erreur

- En mode passif, le terminal envoie un Passive Error Flag : 6 bits de niveau récessif.
- En mode actif, il envoie un Active Error Flag : 6 bits de niveau dominant.

==== Transmission d'une trame d'erreur

Dès qu'une erreur est détectée par un terminal, celui-ci doit, à partir du bit time suivant, émettre une trame d'erreur composée :
- d'un champ Error Flag (actif ou passif selon l'état du terminal),
- suivi d'un Error Delimiter de 8 bits récessifs.

Note : À chaque détection d'une erreur CRC, la transmission d'un drapeau d'erreur commence au bit suivant le délimiteur ACK, sauf si un drapeau d'erreur pour une autre condition a déjà été commencé.

==== Reset du bus

Le bus peut être réinitialisé si 128 séquences de 11 bits récessifs sont lues sur le bus. Tous les compteurs d'un nœud en mode bus off sont remis à 0.