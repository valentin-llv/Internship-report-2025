/* Architecture d'IonSat */
#include "architecture-ionsat.typ"

/* CAN */
#include "can.typ"

/* Canakari */
#include "canakari.typ"

= Architecture hardware de IonSat

Ma seconde mission a consisté à élaborer une première version de l'architecture matérielle FPGA, se rapprochant autant que possible de la configuration finale. L'objectif était de fournir aux équipes logicielles une plateforme de test réaliste leur permettant de poursuivre le développement et de valider l'intégration avec les différentes IPs FPGA.

Pour cela, je me suis appuyé dans un premier temps sur l'architecture développée pour le satellite *EyeSat* du CNES. Ce projet, reposant sur une plateforme similaire, a servi de base de travail : nous avons repris son hardware afin de l'adapter progressivement aux besoins spécifiques de IonSat.

== Hardware EyeSat

Le satellite EyeSat intègre un ensemble d'IPs, dont certaines ont été développées par des étudiants de la *Nanolab Academy*, tandis que d'autres proviennent de projets antérieurs du CNES. Grâce aux sources et aux scripts fournis par le CNES, il a été possible de recréer l'environnement matériel dans Vivado. L'architecture embarque notamment des IPs dédiées à la génération des signaux TM et au décodage des TC en bandes S et X, à la gestion des mémoires Flash, ainsi qu'à divers protocoles de communication tels que *SpaceWire* et *I²C*. Elle comprend également des IPs spécialisées pour le contrôle du GPS et du tracker solaire, ainsi que pour la gestion des erreurs et le suivi des versions.

== Besoins d'IonSat

Toutes les IPs présentes dans l'architecture d'EyeSat n'étaient pas nécessaires pour la mission IonSat. La plateforme a donc été adaptée afin de ne conserver que les blocs pertinents, à savoir :
- l'IP de gestion des TM/TC en bande S,
- une IP I²C dédiée au contrôle des composants externes,
- une IP I²C pour la gestion des composants internes de l'ordinateur de bord.
- une IP de gestion des erreurs mémoire.
- une IP de gestion des versions.

== Automatisation du projet

Pour faciliter l'évolution de l'architecture FPGA, l'outil Vivado offre la possibilité d'utiliser des scripts afin d'automatiser les opérations répétitives, telles que l'importation des IPs, leur interconnexion et la compilation. Ces scripts permettent notamment de simplifier les mises à jour, qu'il s'agisse de corriger le code d'une IP ou de modifier un paramètre interne, en évitant une manipulation manuelle fastidieuse via l'interface graphique. Ils constituent également un moyen efficace de partager le projet, puisqu'il suffit de diffuser les sources et les scripts de génération, sans avoir à transmettre l'ensemble des fichiers d'état produits par Vivado.

L'adaptation de la plateforme matérielle pour IonSat a nécessité plusieurs ajustements aux scripts d'origine, principalement pour retirer les composants non utilisés dans la mission et pour optimiser l'allocation des ressources logiques.

== Portage vers la plateforme de développement

La carte *Ninano*, destinée aux tests en salle blanche, est trop coûteuse pour être utilisée en plusieurs exemplaires. Afin de disposer d'un environnement de travail quotidien, les développements et validations initiales ont donc été réalisés sur une carte *Xilinx Zybo*, plus accessible. Bien que moins performante, cette carte repose sur le même processeur que la Ninano dans une version réduite. Elle constitue ainsi une plateforme de test pratique pour développer les partitions logicielles et vérifier leur interaction avec les composants matériels, avant leur déploiement sur la véritable carte de vol en salle blanche.

=== Contraintes d'optimisation

La Zybo, en raison de ses ressources logiques limitées, ne permet pas d'intégrer l'ensemble des IPs prévues pour IonSat. Afin de réaliser malgré tout les tests logiciels, plusieurs variantes du hardware ont été générées, chacune contenant un sous-ensemble spécifique d'IPs. Cette étape a nécessité un important travail d'optimisation et de validation afin d'exploiter au maximum les capacités de la Zybo tout en conservant un environnement représentatif pour le développement logiciel.

== Conclusion

Le portage de l'architecture matérielle FPGA d'EyeSat vers IonSat a constitué une étape importante pour le développement du satellite. L'adaptation et l'optimisation de la plateforme existante ont permis de fournir à l'équipe logicielle une première version fonctionnelle, servant de support pour valider les interactions entre matériel et logiciel et préparer l'intégration finale sur la carte de vol Ninano. L'automatisation du projet par des scripts a par ailleurs amélioré l'efficacité du flux de développement et renforcé la traçabilité des évolutions de l'architecture matérielle.

Cette deuxième mission m'a permis d'acquérir une réelle maîtrise des scripts d'automatisation Vivado, qu'il s'agisse de la génération de projets, de l'intégration d'IPs ou de la compilation. Elle m'a également offert l'occasion d'approfondir mes connaissances des IPs utilisées dans le domaine spatial, notamment pour la communication, la gestion des mémoires et les protocoles embarqués.