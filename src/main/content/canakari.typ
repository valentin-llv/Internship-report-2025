== Canakri : une version open-source

=== Description général

Afin de réduire le temps de développement et de validation, il a été décidé de partir d’une IP CAN open source existante et de l’adapter aux besoins de la plateforme IonSat. L’IP choisie, issue d’un projet universitaire, est complète et fonctionnelle. Elle implémente les modes de trames standard et étendues conformément à la norme ISO 11898-1.  

Les sources, disponibles en VHDL et en Verilog, étaient initialement prévues pour les FPGA Altera (Intel) et utilisaient le bus Avalon. L’IP ne disposait cependant d’aucun tests. Malgré cela, elle présentait l’avantage d’être autonome, sans nécessiter de composants externes, et donc facilement intégrable dans un FPGA.

=== Fonctionnement

L’IP *Canakari* est structurée en plusieurs blocs correspondant aux grandes fonctions décrites dans le protocole CAN : le *MAC* (Media Access Control), le *LLC* (Logical Link Control), le *Fault Confinement*, etc. Le fichier top-level `can.vhdl` assure l’interconnexion entre ces blocs et doit être instancié dans le projet FPGA pour intégrer l’IP.  

==== Interface

L’IP utilise le bus Avalon pour communiquer avec le processeur, ainsi que plusieurs signaux dédiés aux interruptions et au débogage.

TODO image

==== Signaux généraux

La fréquence d’horloge dépend du débit souhaité et de la valeur du *prescaler*. Par exemple, pour atteindre le débit maximal de 1 Mbit/s, l’IP nécessite une horloge d’entrée de 40 MHz avec un prescaler réglé à 4.

==== Interruptions

Trois interruptions sont disponibles. Elles sont signalées par des lignes top-level actives à l’état haut pendant un cycle d’horloge. Un registre permet de lire et de configurer les *flags* associés. Les interruptions sont désactivées par défaut.

==== Bus CAN

L’IP est reliée au transceiver CAN via les signaux numériques `RX` et `TX`.

==== Débogage

L’IP propose également des signaux de débogage, dont un signal contenant le status de la machine à états, un signal indiquant les ticks du prescaler.

=== Utilisation

L’accès aux registres via l’interface Avalon permet de configurer l’IP, de lancer des transmissions ou de lire les trames reçues.  

Banque de registres :

TODO image registres

==== Initialisation

Selon la documentation, l’initialisation suit la séquence suivante :  

1. Effectuer un *hard reset*, attendre 4 cycles d’horloge, puis patienter 2 cycles supplémentaires.  
2. Réaliser un *soft reset* en écrivant dans le registre prévu, puis attendre 4 cycles.  
3. Configurer les registres.  
4. Vérifier que le contrôleur est en état *idle* (`statedeb = 0x9`).  
5. Pour la réception, attendre une interruption.  
6. Pour la transmission, configurer les registres d’envoi.  

TODO image usage flow

== Adaptation et amélioration

=== Interface AXI

L’ordinateur de bord d’IonSat étant basé sur un FPGA Xilinx, il est nécessaire d’utiliser le protocole interne AXI (issu de l’AMBA d’ARM), différent du bus Avalon. L’IP a donc été adaptée pour remplacer son interface Avalon par une interface AXI4-Lite. La structure modulaire du code a facilité cette modification : seuls les blocs de gestion des signaux Avalon ont été remplacés par des blocs AXI, tandis que les multiplexeurs de lecture/écriture des registres ont été conservés. 

Une particularité d’AXI est la gestion des écritures partielles : bien que le bus soit de 32 bits, il permet par exemple de modifier seulement 8 bits d’un registre. Chaque registre a donc dû être adapté pour gérer correctement cette fonctionnalité.  

Chaque module modifié a ensuite été testé de manière unitaire (registres, contrôleur AXI) afin de garantir la validité des changements.

=== Corrections de bugs

Les premiers tests ont mis en évidence une erreur dans la gestion des registres de réception. Le registre associé contenait un bit permettant d’indiquer si le message reçu utilisait le format standard ou étendu. Dans la version d’origine, ce bit pouvait uniquement être écrit par l’utilisateur, et non par le contrôleur lui-même.  

Ce comportement incohérent a été corrigé en reliant directement le signal interne du MAC (indiquant le format reçu) au registre. Cette modification était également nécessaire pour permettre le filtrage correct des identifiants reçus.

=== Améliorations de la base de code

Le projet étant issu d’une université allemande et ayant connu plusieurs contributeurs étudiants, la base de code souffrait d’un manque de cohérence : fichiers mal nommés, commentaires partiellement en allemand, conventions de nommage hétérogènes.  

Un important travail de remise en forme a donc été effectué :  
- renommage des fichiers pour une organisation plus claire,  
- traduction des commentaires en anglais,  
- formatage homogène du code,  
- uniformisation des noms de signaux internes selon une convention définie préalablement.

== Validation et tests

Chaque modification a été validée par des tests unitaires, puis l’IP complète a été soumise à des campagnes de test plus larges. Étant donné le caractère critique du contrôleur CAN pour IonSat, il était indispensable de couvrir un maximum de scénarios, y compris des cas d’erreur volontairement introduits.  

Les tests se sont déroulés en trois étapes :  
1. simulation des composants internes modifiés (registres, interface AXI),  
2. simulation complète de l’IP,  
3. validation sur carte dans un réseau CAN comprenant plusieurs nœuds équipés de contrôleurs commerciaux.

=== Banc de tests

Un banc de test a été mis en place pour standardiser les validations. Il comprend l’IP CAN implémentée sur FPGA, un contrôleur CAN externe commercial de référence, une carte Arduino servant de maître de communication, ainsi qu’un analyseur logique pour observer les échanges sur le bus. 

TODO image banc de test

=== Différents tests réalisés

Chaque fonctionnalité de l'`IP` a été testée dans différents environnements et avec plusieurs configurations. Les tests se divisent en deux grandes catégories : tests positifs (conditions normales) et tests négatifs (conditions d’erreur).

==== Tests positifs

Ces tests valident le fonctionnement de l'`IP` dans des conditions d'utilisation normales, sans provoquer volontairement d'`erreurs` ou de comportements inattendus. Ils permettent de vérifier le bon fonctionnement général de l'`IP` :

- Vérification des registres de configuration (prescaler, bit timing, interruptions, filtres d’identifiants).  
- Transmission de trames de données et de requêtes en mode standard et étendu.  
- Réception correcte de trames de données et de requêtes.  
- Gestion correcte de l’arbitrage lors de la présence de plusieurs nœuds.  

==== Tests négatifs

Ces tests ont pour objectif de vérifier le comportement de l'`IP` dans des situations anormales ou imprévues, afin de s'assurer qu'elle réagit de manière appropriée et qu'elle ne génère pas d'`erreurs critiques` :

- Envoi de trames invalides (longueur incorrecte, absence de signal TX).  
- Détection d’erreurs de bit, de CRC, de format et d’acquittement.  
- Validation du passage automatique entre les modes d’erreur (actif, passif, bus-off) et du retour au mode normal après réinitialisation.  

== Empaquetage de l'IP

Une fois l’IP développée et validée, il restait à la rendre facilement réutilisable par d’autres ingénieurs. Pour cela, elle a été empaquetée sous la forme d’un module complet, accompagné de toute la documentation et des outils nécessaires à son intégration dans de futurs projets. L’objectif n’était plus uniquement de disposer d’un code fonctionnel, mais de livrer un produit final, exploitable et maintenable.

L’empaquetage inclut plusieurs éléments complémentaires :  
- une documentation utilisateur,  
- des pilotes logiciels (*device drivers*),  
- un exemple d’utilisation,  
- des tests,  
- ainsi que des scripts Vivado pour automatiser la génération de l’IP et la création d’un projet de démonstration.

=== Documentation

La documentation initiale fournie avec le projet open source décrivait essentiellement le fonctionnement interne des blocs matériels. Bien que pertinente pour comprendre l’architecture, elle n’était pas adaptée à un utilisateur souhaitant simplement intégrer l’IP. Une nouvelle documentation a donc été rédigée, en français et en anglais, en se concentrant sur l’usage pratique : description des registres accessibles, procédure d’initialisation, et guide pas à pas pour l’intégration dans un projet Vivado. Cette approche permet de considérer l’IP comme un composant fini, prêt à l’emploi.

=== Device drivers

Afin d’exploiter l’IP depuis la partie logicielle, des pilotes bas niveau (*device drivers*) ont été développés en langage C. Ces pilotes fournissent les adresses des registres ainsi que des fonctions pour effectuer les opérations essentielles : configuration du contrôleur, écriture et lecture des trames, gestion des interruptions. Ils constituent la couche d’abstraction minimale nécessaire pour interfacer proprement le matériel avec le logiciel embarqué.

=== Exemple

Pour faciliter la prise en main, un exemple complet d’émission et de réception de trames CAN a été fourni. Celui-ci illustre une configuration générique de l’IP et montre comment utiliser les pilotes pour initialiser le contrôleur, transmettre une trame et traiter les messages reçus. Cet exemple joue le rôle de démonstrateur et permet de valider rapidement l’intégration.

==== Script Vivado

Enfin, deux scripts Vivado ont été ajoutés pour automatiser le flux d’utilisation. Le premier permet de générer automatiquement le bloc IP à partir du code source VHDL, tandis que le second crée un projet d’exemple intégrant l’IP, ses pilotes et le code de démonstration. L’objectif est de réduire au maximum la manipulation manuelle et de proposer une intégration reproductible et rapide.
