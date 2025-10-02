= Réalisation d'une IP CAN

== Introduction

Pour IonSat, le bus CAN est une composante essentielle puisqu'il relie l'ordinateur de bord à plusieurs systèmes critiques, notamment le propulseur et le système de contrôle d'attitude. Ces sous-systèmes sont indispensables à la survie du satellite : une défaillance de communication pourrait compromettre l'ensemble de la mission. Dans un environnement spatial marqué par les perturbations électromagnétiques et les radiations, la fiabilité de la communication est donc primordiale.  

L'ordinateur de bord d'IonSat intègre déjà un transceiver CAN pour générer les signaux électriques sur le bus. En revanche, il faut également un contrôleur CAN pour gérer le protocole. Celui-ci peut être implémenté de différentes manières : en utilisant une puce externe dédiée, via un contrôleur intégré au processeur, ou sous forme d'IP sur FPGA. Cette dernière approche, retenue pour IonSat, offre à la fois proximité avec le processeur, protection accrue contre les radiations et flexibilité dans l'implémentation.  

La première mission de mon stage a donc consisté à développer un IP CAN pour le FPGA Xilinx de l'ordinateur de bord.

== Le CAN

Le CAN (*Controller Area Network*), développé par Bosch, combine à la fois un bus de communication et un protocole, couvrant ainsi les deux couches basses du modèle OSI : la couche physique et la couche liaison de données. La norme de référence est l'ISO 11898, définissant la version 2 du protocole.

Très répandu dans l'automobile et le spatial, le CAN est apprécié pour sa robustesse, sa capacité à fonctionner sur de longues distances (jusqu'à 1 km, bien au-delà de l'I²C ou du SPI), et sa gestion avancée des erreurs. Ces qualités en font un protocole particulièrement adapté aux environnements contraints comme le spatial. Parmi ses caractéristiques principales, le CAN propose une communication multi-maître asynchrone, une tolérance élevée aux perturbations sur la ligne de transmission avec une détection avancée des erreurs et un débit pouvant atteindre 1 Mbit/s (débit brut, incluant les bits de trame).

=== Le bus CAN

La couche physique est définie par la norme ISO 11898-2 pour le CAN haute vitesse. Le bus est constitué d'une paire différentielle reliant l'ensemble des nœuds, chacun composé d'un contrôleur CAN et d'un transceiver. L'utilisation de deux fils (CAN H et CAN L) permet de transmettre deux niveaux logiques (dominant ou récessif) en réduisant considérablement l'impact des interférences électromagnétiques.  

La paire différentielle, CAN H et CAN L, nomme deux niveaux de tension pour transmettre soit 0 soit 1 : le niveau dominant (0) et le niveau recessif (1). Au niveau recessif les tension H et L sont a 2.5V et pour le niveaux dominant, CAN H vaut 3.5V et CAN L 1.5V.  Cette utilisation de la différence de potentiel permet de réduire les interférences électromagnétiques. En effet, si un bruit électromagnétique est capté par les deux fils, il sera capté de la même manière et donc ne changera pas la différence de potentiel. Cette propriété permet au bus CAN d'être très robuste.

Par défaut le bus est a un niveau recessif, jusqu'a ce qu'un des noeuds force un niveau dominant. Le bus etant de type "Wire AND" le niveau dominant prevau au niveau recessif et si un noeuds force le niveau dominant (quel que soit le niveau des autres noeuds) le niveau du bus sera dominan, ceci constitue la base du mécanisme d'arbitrage;  

Enfin le bus est toujours terminé par une resistance de 120 Ohms de chaque coté pour evite les reflextions et s'assusrer de l'impendance du bus.

#figure(
	image("../../../assets/images/CAN bus signal levels.png", height: 110mm),
	caption: [
		Composants externe et leur protocole de communication avec l'ordinateur de bord
	],
)

=== Le protocole CAN

Le protocole CAN organise les échanges sur le bus sans utiliser d'horloge commune ni de signal de contrôle. Il repose sur un mécanisme d'arbitrage permettant à plusieurs nœuds de partager le bus de manière déterministe, et sur une gestion avancée des erreurs garantissant la fiabilité des transmissions.  

Trois types de trames peuvent être transmises : trames de données, trames de requête et trames d'erreur. Les trames de données, les plus courantes, transportent entre 1 et 8 octets associés à un identifiant. Cet identifiant n'est pas une adresse mais un champ de priorité : plus il est faible, plus la trame est prioritaire lors de l'arbitrage.  

L'arbitrage se déroule au niveau de l'identifiant, bit par bit : si un nœud émet un niveau récessif mais lit un niveau dominant sur le bus, il interrompt sa transmission et devient récepteur. Ce mécanisme garantit qu'un seul nœud conserve le bus et évite les collisions.  

De nombreux mécanismes supplémentaires renforcent la robustesse du protocole, parmi lesquels l'insertion automatique de bits de synchronisation (*bit stuffing*), le calcul d'un CRC pour vérifier l'intégrité, et l'acquittement (ACK) obligatoire par au moins un récepteur. En cas d'anomalie, une trame d'erreur est générée et des compteurs internes (TEC et REC) ajustent l'état du nœud (actif, passif ou *bus-off*).

=== Trame de données

Les trames de données servent à transférer de l'information d'un nœud vers un ou plusieurs autres nœuds. Chaque trame contient entre 1 et 8 octets de données, associés à un identifiant. Contrairement à une adresse classique, cet identifiant n'est pas lié à un destinataire unique : il permet de définir la nature ou la priorité du message, et donc de diffuser la même information à plusieurs récepteurs en parallèle.  

Une trame de données est structurée de la manière suivante :  

#figure(
	image("../../../assets/images/CAN frames.png", height: 64mm),
	caption: [
		Structure des trames CAN
	],
)

Détail des champs :

- *SOF (Start of Frame)* : premier bit dominant signalant le début de la trame.  
- *Identifiant* : 11 bits définissant la donnée ou la priorité du message.  
- *SRR (Substitute Remote Request)* : champ réservé, à niveau récessif (uniquement dans les trames étendues).  
- *IDE (Identifier Extension)* : indique si l'identifiant est en format standard (11 bits) ou étendu (29 bits).  
- *Identifiant étendu* : 18 bits supplémentaires pour atteindre 29 bits en mode étendu.  
- *RTR (Remote Transmission Request)* : précise s'il s'agit d'une trame de données (0) ou d'une trame de requête (1).  
- *R1, R0* : bits réservés pour de futures versions du protocole (fixés à 1).  
- *DLC (Data Length Code)* : indique le nombre d'octets transportés (0 à 8).  
- *Data* : les données utiles, de 0 à 8 octets.  
- *CRC (Cyclic Redundancy Check)* : code de redondance pour vérifier l'intégrité de la trame.  
- *ACK (Acknowledgment)* : champ d'acquittement confirmant la bonne réception par au moins un récepteur.  
- *EOF (End of Frame)* : séquence de bits récessifs marquant la fin de la trame.  

Deux formats existent : le mode standard (identifiant de 11 bits) et le mode étendu (identifiant de 29 bits). L'utilisation du format est signalée par le bit IDE. Le format étendu permet d'identifier un plus grand nombre de messages, mais au prix d'une trame légèrement plus longue et donc un débit utile réduit. C'est ce format qui sera utilisé pour IonSat.

=== Trame de requête

Une trame de requête est similaire à une trame de données, à ceci près que le champ *Data* reste vide et que le bit RTR est positionné à 1. Le champ DLC peut néanmoins être utilisé pour indiquer la taille des données attendues en réponse. Cette trame peut être envoyée par n'importe quel nœud pour demander une donnée. Cette trame n'implique que la réponse à cette requête sera prioritaire, le prochain message sur le bus pourra être n'importe quel message.

=== Arbitrage

Le bus CAN étant multi-maître, plusieurs nœuds peuvent tenter d'émettre simultanément. Pour éviter les collisions, le protocole intègre un mécanisme d'arbitrage.  

Lorsque le bus est libre (au niveau récessif), un nœud peut initier une transmission en envoyant un SOF (bit dominant). Tous les autres nœuds passent alors en réception. Si plusieurs nœuds déclenchent un SOF au même instant, l'arbitrage s'effectue sur l'identifiant. Le principe repose sur la lecture simultanée du bus par chaque émetteur : après avoir transmis un bit, un nœud doit vérifier que le bus reflète bien ce qu'il a envoyé. Si un nœud émet un bit récessif mais observe un bit dominant (qui prévaut toujours), il abandonne immédiatement la transmission et devient récepteur.  

#v(5mm)

#figure(
	image("../../../assets/images/CAN bus arbitration.png", height: 70mm),
	caption: [
		Arbitrage sur le bus CAN
	],
)

L'arbitrage se poursuit tant que l'identifiant est en cours de transmission. Ainsi, l'identifiant le plus faible (le plus proche de 0) est prioritaire. À la fin de cette phase, le nœud qui reste en émission est assuré d'être le seul maître du bus et peut poursuivre la transmission de sa trame sans risque de collision.  

=== Synchronisation des horloges

Le CAN utilise une communication asynchrone, sans horloge commune. Chaque nœud dispose de sa propre horloge, qui peut légèrement différer des autres. Pour garantir une réception correcte des données, une synchronisation est nécessaire. Le CAN intègre un mécanisme de synchronisation basé sur la détection des fronts de bits. Chaque nœud divise le temps en segments, définis par son propre oscillateur. Lors de la réception, les nœuds ajustent leur timing en fonction des transitions détectées sur le bus. Cela permet de compenser les dérives d'horloge et d'assurer une lecture fiable des bits.

La vitesse de communication sur le bus est de 1 Mbit/s soit un bit toutes les 1 us. Cette durée est divisee en plusieurs segments pour permettre la synchronisation. Le premier segment est le segment de synchronisation (Sync Seg) qui dure 1 unité de temps. C'est dans ce segment que doivent se trouver les fronts. Ensuite viennent les segments de propagation (Prop Seg) et de phase (Phase Seg1 et Phase Seg2) qui permettent d'ajuster la synchronisation en fonction des retards de propagation et des variations d'horloge. La somme de ces segments doit être égale à la durée d'un bit (1 µs).

Lorsqu'un front est detecté en dehors du segment de synchronisation, le nœud ajuste son horloge en ajoutant ou en supprimant une unité de temps dans les segments de phase. Cela permet de réaligner la lecture des bits avec les transitions réelles sur le bus. Cette operation de synchronisation est effectuee en permanance pour compenser les dérives d'horloge et assurer la bonne lecture des données du bus.

#figure(
	image("../../../assets/images/CAN timings.png", height: 65mm),
	caption: [
		Synchronisation des horloges sur le bus CAN
	],
)

=== Gestion des erreurs

Le CAN intègre plusieurs mécanismes pour détecter et gérer les erreurs, garantissant ainsi la fiabilité des communications. Chaque nœud surveille en permanence le bus et utilise différents tests pour identifier les anomalies. Parmi les mécanismes de détection d'erreurs, on trouve :
- *Erreur de bit* : si un nœud émet un bit mais lit un niveau différent sur le bus, une erreur de bit est détectée.
- *Erreur de CRC* : le champ CRC permet de vérifier l'intégrité de la trame. Si le calcul du CRC ne correspond pas, une erreur de CRC est signalée.
- *Erreur de format* : si la structure de la trame ne respecte pas les spécifications (par exemple, un champ réservé mal positionné), une erreur de format est générée.
- *Erreur d'acquittement* : si aucun récepteur ne confirme la réception correcte de la trame (champ ACK), une erreur d'acquittement est détectée.
- *Erreur de bit stuffing* : si plus de cinq bits consécutifs identiques sont détectés, une erreur de bit stuffing est signalée.

Lorsqu'une erreur est détectée par un noeud celui-ci commence la transmission d'une trame d'erreur. Cette trame sera recu par tout les autres noeuds qui la detecteront comme une erreur de bit et genereront a leur tour une trame d'erreur. La trame d'erreur est composée de deux champs : le champ d'erreur (6 bits dominants) et le champ de délimitation (8 bits récessifs). Le champ d'erreur signale la présence d'une erreur, tandis que le champ de délimitation marque la fin de la trame d'erreur.

Chaque nœud maintient deux compteurs d'erreurs : le TEC (Transmit Error Counter) et le REC (Receive Error Counter). Ces compteurs sont incrémentés ou décrémentés en fonction des erreurs détectées ou des transmissions réussies. En fonction de la valeur de ces compteurs, un nœud peut se trouver dans l'un des trois états suivants :
- *État actif* : le nœud peut émettre et recevoir des trames normalement. (TEC < 128 et REC < 128)
- *État passif* : le nœud peut recevoir des trames mais ne peut plus émettre de trames d'erreur. (TEC >= 128 ou REC >= 128)
- *État bus-off* : le nœud est déconnecté du bus et ne peut plus émettre ni recevoir de trames. (TEC >= 256)

Lorsqu'un nœud entre en état bus-off, il doit attendre un certain temps (128 occurrences de 11 bits récessifs) avant de pouvoir tenter de se reconnecter au bus. Cette période permet de stabiliser le bus et d'éviter une surcharge due à des nœuds défaillants.

#v(5mm)

#figure(
	image("../../../assets/images/CAN error modes.png", height: 70mm),
	caption: [
		Modes d'erreur du CAN
	],
)