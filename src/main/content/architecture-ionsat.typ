= Architecture d'IonSat

== Composants matériels

En plus des éléments dédiés aux charges utiles, le satellite embarque de nombreux autres composants nécessaires à son bon fonctionnement dans l'espace et tout au long de la mission. Ces sous-systèmes incluent principalement les équipements de télécommunication, de contrôle d'attitude et d'orbite, de gestion de puissance, ainsi que l'ordinateur de bord.

=== Télécommunications

Pour communiquer avec la station de contrôle au sol, le satellite utilise une bande de fréquences radio située entre 2 et 4 GHz, appelée *bande S*. Cette bande est couramment employée pour les communications satellitaires, notamment grâce à sa bonne capacité de pénétration de l'atmosphère terrestre.  

À cette fin, IonSat est équipé :
- d'une antenne en bande S pour l'émission et la réception,
- ainsi que d'un transceiver externe, fourni par le CNES, entièrement dédié à cette tâche.  

Dans le vocabulaire spatial, le satellite transmet des données de *télémétrie* (TM) et reçoit des *télécommandes* (TC). Ces échanges suivent le format normalisé par le CCSDS (*Consultative Committee for Space Data Systems*), garantissant l'interopérabilité et la fiabilité des communications espace <-> sol.

=== Orientation et déplacement

L'orientation du satellite est essentielle pour plusieurs fonctions critiques : assurer une liaison stable en TM/TC avec la station sol, orienter les panneaux solaires vers le Soleil afin d'optimiser la production d'énergie, et pointer les capteurs vers la Terre pour l'acquisition d'images.  

Pour cela, IonSat dispose de nombreux capteurs permettant de déterminer son attitude :  
- un accéléromètre pour mesurer les accélérations,  
- un magnétomètre pour caractériser le champ magnétique terrestre,  
- un gyroscope pour suivre la rotation du satellite,  
- des capteurs solaires pour identifier la direction du Soleil.  

L'ensemble de ces informations est exploité par le *système de contrôle d'attitude* (ADCS), capable de calculer l'orientation du satellite et d'agir en conséquence. Plusieurs actionneurs sont intégrés : des roues de réaction pour annuler ou ajuster les vitesses de rotation, des magnétorquer pour exploiter le champ magnétique terrestre, ainsi qu'un petit propulseur pour modifier l'orbite et effectuer des corrections de trajectoire.

=== Gestion de puissance

Le satellite est alimenté par deux panneaux solaires déployables (repliés lors du lancement afin de réduire l'encombrement). Ces panneaux fournissent l'énergie nécessaire au fonctionnement de l'ensemble des systèmes et rechargent les batteries.  

La gestion de la distribution électrique est assurée par deux cartes électroniques : une carte de gestion de puissance, responsable de l'alimentation des sous-systèmes, et une carte de passivation, permettant de déconnecter les batteries lors de la mise en service du satellite ou lors de son désorbitage en fin de vie.  

=== Ordinateur de bord

Le pilotage central de l'ensemble des sous-systèmes est confié à l'ordinateur de bord. Celui-ci est construit autour d'une puce FPGA SoC *Xilinx Zynq-7030*, intégrant deux cœurs ARM. En pratique, l'ordinateur de bord assure plusieurs fonctions critiques. Il orchestre la communication entre les différents sous-systèmes et supervise l'ensemble des séquences de mission, c'est également lui qui gère les communications de télécommande et de télémétrie. Enfin, il surveille en permanence l'état de santé du satellite en collectant des mesures issues des capteurs et en prenant, si nécessaire, des décisions correctives automatiques.  

Grâce à cette architecture, l'ordinateur de bord constitue le centre d'IonSat, garantissant la cohérence et la fiabilité de l'ensemble des opérations, depuis le lancement jusqu'à la fin de vie du satellite. De plus, dû aux conditions difficile de l'espace, la carte est renforcée contre les radiations afin de garantir un fonctionnement fiable dans l'environnement spatial tout au long de la mission.

=== Interconnexion des composants

Tous les sous-systèmes sont reliés à l'ordinateur de bord, qui assure leur contrôle et la coordination des échanges. Le choix du protocole de communication dépend de plusieurs facteurs tels que le volume de données à transmettre, la criticité des échanges, la vitesse de transfert requise ou encore la disposition matérielle des cartes électroniques.  

Ainsi, les composants jugés critiques, comme le propulseur ou le contrôleur d'attitude, s'appuient sur le bus *CAN*, réputé pour sa robustesse et sa tolérance aux erreurs, ce qui en fait un standard particulièrement adapté aux environnements contraints. Les charges utiles, quant à elles, exploitent d'autres protocoles plus légers, tels que *I²C*, *SPI* ou *OneWire*, mieux adaptés à des échanges de moindre volume et permettant une intégration plus simple.  

== Logiciel embarqué

=== FPGA

Très répandus dans le domaine spatial, les FPGA jouent un rôle essentiel en soulageant le processeur central des tâches les plus exigeantes. Leur architecture reconfigurable permet de traiter efficacement des opérations qui seraient trop coûteuses en ressources CPU ou qui nécessitent une précision temporelle difficile à atteindre avec un processeur classique.  

Dans le cadre d'IonSat, le FPGA est utilisé pour implémenter des contrôleurs dédiés à certains protocoles de communication non pris en charge nativement par le SoC. Il intervient également dans la gestion et le transfert des données entre sous-systèmes, ainsi que dans le codage et le décodage des trames de télémétrie et de télécommande. Ces fonctions sont critiques, car elles conditionnent à la fois la fiabilité des échanges avec la station sol et la bonne coordination interne du satellite.  

Pour accomplir ces missions, le FPGA est configuré à l'aide de plusieurs blocs matériels décrits en VHDL, appelés *IPs*, qui sont intégrés dans la logique programmable. Ces IPs constituent des briques modulaires permettant d'optimiser le traitement matériel, tout en offrant une grande souplesse de reconfiguration en cas d'évolution des besoins de la mission. Cette flexibilité rend le FPGA bien plus adaptable qu'un circuit ASIC figé.

=== Logiciel de bord

Enfin, le logiciel de bord constitue l'élément central qui coordonne l'ensemble des sous-systèmes et assure le déroulement des différentes missions du satellite. Il collecte en continu les données des capteurs, organise leur traitement puis les transmet à la station de contrôle via le système de télécommunication. Au-delà de ce rôle de supervision, il prend également en charge l'exécution des procédures automatiques essentielles, telles que les corrections d'orbite pour ajuster l'altitude, les manœuvres d'orientation vers la Terre ou vers le Soleil, ainsi que la gestion des modes de consommation d'énergie en fonction du niveau de charge des batteries.  

Le logiciel embarqué est une composante à la fois cruciale et particulièrement complexe : la moindre défaillance pourrait compromettre la mission dans son ensemble. Pour limiter les risques, son architecture est conçue de manière modulaire. Chaque fonctionnalité est isolée dans une partition logicielle distincte, de sorte qu'en cas d'erreur, seule la partie concernée peut être redémarrée sans interrompre les autres services. Cette approche renforce la robustesse du système et garantit une continuité de fonctionnement, condition indispensable au succès d'une mission spatiale de longue durée.