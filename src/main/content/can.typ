= Réalisation d'une IP CAN

== Introduction

Pour IonSat, le CAN est une composante essentiel pour la communication de plusieurs system critique. Il relie l'ordinateur de bord, le propulseur, et le system de control d'attitude. C'est system sont cruciaux pour la survie du satellite et les communication doivent être gérer correctement pour prevenir les erreurs dû au perturbation electronique ou aux radiations spatiales.

Le PCB étant déjà existant, l'ordinateur de bord dispose d'un transceiver CAN pour la generation des signaux electroique sur le bus mais il faut aussi disposer d'un controller CAN pour le protocole. Ce controlleur peut etre implementer es plusieurs facon, soit par un puce dédié externe, soit si le CPU dispose d'n controlleur integré ou sous forme d'IP pour FPGA. L'avantage des deux derniers solutions est que le controlleur est ainsi au plus proche du CPU et protogé contre les radiations. L'utilisation d'un FPGA apporte plus de flexibilité dans l'implentation et les fonctionnalitées.

La premiere partie du stage à ainsi consisté en la realisation d'une IP CAN pour FPGA Xilinx.

== Le CAN

Tout d'abord, il convient d'expliquer brievement comment fonctionne le CAN. Le CAN, developé par Bosh, correspond a deux choses : un bus de communication et un protocole, il correspond donc au deux couches basse du model de communication OSI : la couche physique et la couche liaison de données. Le CAN est défini dans plusieurs norme ISO, dont la norme ISO-11898 de 2016 qui definie la version 2 du protocol de communication et qui est celle avec laquelle j'ai travaillé.

Très largement utilisé dans l'automobile, le CAN est particulièrement apprécié pour sa capacité à fonctionner sur de longues distances, supérieures à celles du SPI ou de l'I2C (jusqu'à 1 kilomètre de câble). Il se distingue également par sa robustesse face aux perturbations et sa gestion avancée des erreurs

Parmi ses principaux avantages, le protocole offre :
- une communication multi-maître asynchrone,
- une tolérance élevée aux erreurs
- un débit pouvant atteindre 1 Mbit/s (ceci inclut les bits de trame ; le débit utile est donc inférieur).

=== Le bus CAN

Description générale du bus CAN, son intérêt dans les systèmes embarqués et particulièrement dans le spatial (robustesse, tolérance aux erreurs, faible consommation de ressources).

=== Le protocole CAN

Présentation des principes de fonctionnement du protocole : format des trames, modes d'arbitrage, gestion des erreurs, priorisation des messages, etc.

== Canakri : une version open-source

=== Fonctionnement général de '

Présentation de l'IP open-source choisie comme base de travail, ses caractéristiques principales et ses limites dans le contexte du projet.

== Adaptation et amélioration de '

=== Interface AXI

Intégration d'une interface AXI4-Lite pour rendre l'IP compatible avec l'architecture FPGA/SoC d'IonSat.

=== Corrections de bugs

Identification et correction des dysfonctionnements rencontrés dans le code source.

=== Améliorations de la base de code

Refactorisation, ajout de commentaires, traduction et mise au propre de la base de code pour la rendre plus compréhensible et maintenable.

== Validation et tests

Présentation de la méthodologie de test adoptée et de son importance pour garantir la fiabilité de l'IP dans un environnement critique.

=== Banc de tests

Description du banc de test utilisé (simulation, Modelsim, etc.), et de son organisation.

=== Différents tests réalisés

Détails des scénarios de test : émission, réception, arbitrage, gestion d'erreurs, performance, etc.

== Empaquetage de l'IP

Présentation du processus de mise à disposition de l'IP :  
- exemples de code d'utilisation,  
- drivers logiciels,  
- documentation technique.  

== Conclusion

Résumé des apports de cette mission et importance de cette IP CAN dans l'architecture d'IonSat.