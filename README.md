This is my tweked version of [Nathalie Vialaneix's](http://tuxette.nathalievialaneix.eu/2013/09/extraire-son-arbre-du-mathematics-genealogy-project-avec-r/) mathematical genealogy tree. It uses data gathered by the [Mathematics Genealogy Project](https://www.mathgenealogy.org). 

To build your own, you need to tweak the R code and have [graphviz](https://www.graphviz.org) installed. (If you have a Mac with Homebrew it suffices to run ```brew install graphviz```.)

After that, all you need to do is to construct the ```starting.persons``` dataframe ```supervise``` and with you your links to a person that appears in the Mathematics Genealogy Project database. Each person has a unique ```id``` in our dataframe. The ```mgp.id``` is their ID in the database. For instance, [Carl Friedrich Gauß](https://www.mathgenealogy.org/id.php?id=18231) has the MPG ID number 18231, as written on the bottom of his page. For each person with an MPG ID, you can leave the name empty in ```starting.persons```, and it will be automatically retrieved. 

In my case, one of my supervisors appears in the MPG and has a ```mpg.id``` value. The other does not, so I have to include her supervisor's name and MPG IDs too. The program will use the MPG IDs to crawl up through the genealogy tree in the database.

The ```supervise``` matrix links a student's ID, in the first column to a supervisor's ID, in the second. In my case, my ID (1) appears twice on the first column because I have two supervisors, and not on the right column, because I haven't supervised anyone. My supervisors appear both on the right and left. Other people will appear both and the right and left, linking everyone in the tree.

I have also left an option to add the year of the first degree recorded in the Mathematics Genealogy Project after the name. This can be turned off by setting ```add_year = FALSE```.