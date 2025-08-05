= Sujet et contexte du stage

== Les nanosatellites - CubeSats

Un CubeSat est un petit satellite répondant à un format standardisé, basé sur un cube de 10 cm de côté pesant environ 1 kg. Plusieurs unités (ou « U ») peuvent être assemblées pour former des satellites plus grands : par exemple, un satellite 3U mesurera 30 x 10 x 10 cm. Chaque unité supplémentaire permet d'embarquer davantage de charges utiles, des composants plus volumineux et, par conséquent, d'augmenter les capacités du satellite. Toutefois, cette augmentation de taille implique également un coût de lancement plus élevé.

L'intérêt principal du format CubeSat réside dans sa capacité à démocratiser l'accès à l'espace. En effet, il permet à des universités, des laboratoires et des petites entreprises de concevoir, développer et lancer leurs propres satellites à un coût réduit, en s'appuyant sur des composants commerciaux standards disponibles sur le marché. Le coût de lancement d'un CubeSat reste généralement bien inférieur à celui des satellites conventionnels, notamment parce qu'ils sont conçus pour être lancés en groupes, mutualisant ainsi les coûts logistiques.

En général, les satellites universitaires embarquent plusieurs missions scientifiques - appelées charges utiles - qui donnent tout leur intérêt au projet. Ces missions sont souvent menées en partenariat avec d'autres universités, entreprises ou laboratoires, ce qui permet de renforcer la portée scientifique et pédagogique des CubeSats tout en offrant aux partenaires une opportunité d'envoyer leurs expériences dans l'espace de manière plus accessible et économique.

La durée de vie d'un CubeSat peut varier de quelques mois à plusieurs années, selon sa conception, son orbite et la nature de sa mission. Ces satellites sont souvent pensés pour être opérationnels sur une période limitée, au terme de laquelle ils entrent dans une phase de désorbitation contrôlée.

Les CubeSats peuvent être lancés sur différentes orbites, selon les objectifs du projet. Cependant, ils sont majoritairement déployés en orbite basse terrestre (LEO), entre 200 et 2 000 km d'altitude. Cette configuration permet non seulement de répondre à de nombreux besoins scientifiques et techniques, mais aussi de limiter la durée de vie orbitale du satellite après la fin de la mission, contribuant ainsi à la réduction des débris spatiaux.

== Context du stage

=== Le projet IonSat

À la suite du succès de son premier satellite, le CSEP a lancé en 2017 un nouveau projet de nanosatellite : IonSat. Il s'agit d'un CubeSat de format 6U, mesurant 30 x 20 x 10 cm, destiné à être placé en orbite terrestre très basse (VLEO), à environ 300 km d'altitude.

IonSat embarquera plusieurs charges utiles, dont la principale est un moteur à ions. En règle générale, les CubeSats ne disposent pas de moyen de propulsion, mais uniquement de systèmes d'orientation. Toutefois, en VLEO, la traînée atmosphérique est bien plus importante qu'à plus haute altitude, ce qui entraîne une perte progressive d'altitude. Afin de prolonger la durée de vie du satellite, le moteur à ions permettra d'effectuer des manœuvres de correction d'orbite, évitant ainsi une désorbitation prématurée.

Parmi les autres charges utiles, on compte :
- un capteur d'oxygène atomique,
- une caméra embarquée,
- une antenne radioamateur,
- un capteur mesurant l'effet de l'iode sur les panneaux solaires,
- TODO : vérifier la liste complète.

Le lancement d'IonSat est actuellement prévu pour courant 2026, mais cette date reste à confirmer en fonction de l'avancement du projet.

=== L'équipe du projet IonSat

L'équipe permanente en charge du projet IonSat est composée de cinq ingénieurs :

- Directeur du CSEP : Luca Bucciantini
- Chef de projet : Borhane Bendaci
- Ingénieur électronique & logiciel embarqué : Ahmed Ghoulli
- Ingénieur AIT (Assembly, Integration and Testing) : Nicolas Lequette
- Ingénieur télécommunications : Tony Colin

En complément, durant mon stage, quatre autres stagiaires travaillaient aux côtés des ingénieurs permanents, notamment sur le logiciel embarqué, les campagnes de tests, ainsi que sur la mise en place de la station sol. De plus, au cours de six dernières années de développement, de nombreux autres stagiaires et étudiants ont contribué au projet au travers de leurs stages et projets.

=== Phases de développement du projet

Le développement d'un satellite suit un processus normé, structuré en plusieurs phases successives, comme présenté dans le tableau ci-dessous. Le projet IonSat se trouve actuellement en phase D, la plus longue, mais aussi la dernière étape avant le lancement. Cette phase concentre la majeure partie du travail de développement d'intégration électronique et logicielle pour relier tous les sous-systèmes du satellite.

#align(center)[#table(
	columns: (auto, auto),
	inset: 10pt,
	align: left + horizon,

	table.header(
		[*Phase*], [*Description*],
		[Phase 0], [Analyse de la mission – Identification des besoins],
		[Phase A], [Étude de faisabilité],
		[Phase B], [Définition préliminaire],
		[Phase C], [Définition détaillée],
		[Phase D], [Production / Intégration / Qualification au sol],
		[Phase E], [Opérations en orbite],
		[Phase F], [Fin de vie / Retrait de service]
	),
)]

== Sujets et objectifs du stage

Dans le cadre du projet IonSat, mon stage d'ingénieur s'est inscrit dans le développement des systèmes électroniques embarqués du satellite. Plus précisément, en tant que stagiaire en électronique numérique spécialisé en FPGA, j'ai été chargé de deux missions principales.

La première mission portait sur la conception et l'implémentation d'un contrôleur CAN (Controller Area Network) sous forme d'IP matérielle dédiée, entièrement développée en VHDL. Ce composant a pour rôle de gérer les communications entre différents sous-systèmes du satellite via le bus CAN, un protocole robuste couramment utilisé dans les environnements embarqués pour ses performances en temps réel et sa tolérance aux erreurs.

La seconde mission consistait à intégrer plusieurs IPs sur la plateforme FPGA destinée à la mission. Ce travail comprenait la compréhension des IPs fournies par le CNES et l'adaptation de ces composants pour les adapter aux spécificités du projet IonSat. L'objectif était de garantir que toutes les IPs fonctionnent de manière cohérente et efficace, en assurant la communication entre elles et avec les autres sous-systèmes du satellite.