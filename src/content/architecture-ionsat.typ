= Architecture d'IonSat

== Composants hardware

=== Orientation et déplacement

L'orientation du satellite est cruciale pour garantir la bonne transmission des données de telemetrie et telecommande avec la station sol, pour l'acquisition d'images de la Terre et pour l'orientation des panneaux solaires vers le Soleil. Le satellites embarque pour ce faire de nombreux capteurs pour determine sont oritation : 
- Un accéléromètre pour mesurer les accélérations
- Un magnétomètre pour mesurer le champ magnétique terrestre
- Un gyroscope pour mesurer la rotation du satellite
- Des capteurs solaires pour déterminer l'orientation par rapport au Soleil

A l'aide de toutes ces données le système de contrôle d'attitude est capable de déterminer l'orientation du satellite dans l'espace et d'agir en conséquence pour maintenir une orientation optimale. Le systeme d'attitude dispose de plusieurs actionneurs, tels que des roues de réaction pour stopper la rotation et ajouter l'orientation, des magnetotorqeurs pour ajuster l'orientation du satellite grace au champ magnétique terrestre et un propulseurs pour ajuster l'orbite.

=== Communication avec le sol

Pour communiquer avec la station sol, le satellite utilise la Bande S, une bande de fréquence radio située entre 2 et 4 GHz. Cette bande est couramment utilisée pour les communications par satellite en raison de sa capacité à pénétrer l'atmosphère terrestre. Pour cela le satellite dispose d'une antenne Bande S et d'un transceiver pour generer et recevoir les signaux radio.

Le satellite envoie des données de telemetrie TM et recoit des commandes de telecommande TC qui suivent un format spécifique.

=== Electronique numerique

Pour controller l'ensemble des systems

=== Interconnection des composants

== Logiciel embarqué

=== FPGA

=== Logiciel de bord