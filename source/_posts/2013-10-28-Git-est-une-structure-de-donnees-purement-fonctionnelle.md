---
author: Simon Courtois (simonc)
layout: post
title: "Git est une structure de données purement fonctionnelle"
date: 2013-10-28 23:00
comment: true
categories:
- git
---

Source: [Git is a purely functional data structure de Philip Nilsson sur le blog de Jayway](http://www.jayway.com/2013/03/03/git-is-a-purely-functional-data-structure/)

Bien que les systèmes de gestion de versions décentralisés, comme Git, aient le
vent en poupe en ce moment, ils semblent toujours avoir la réputation d'être
plus complexes que leurs homologues centralisés, comme SVN. Je pense que l'une
des raisons est que l'on a tendance à expliquer Git par comparaison : lorsque tu
fait X avec SVN, tu fais Y avec Git.

Selon moi nous devrions plutôt présenter Git comme ce qu'il est : une structure
de données purement fonctionnelle. Devenir expert Git implique d'apprendre à
maitriser cette structure de données.

Si la notion de structure de données purement fonctionnelle vous est étrangère,
cela ne va pas vous être d'une grande aide. Il se trouve qu'un minimum de
connaissances sur le sujet suffit pour comprendre, nous allons donc passer
rapidement sur ce sujet avant de revenir à Git.

<!-- more -->

## Notions préliminaires

Une structure de données fonctionnelle est essentiellement une structure de
données immuable : ses valeurs ne changent jamais. Cependant, contrairement à la
`ReadOnlyCollection` de C# qui n'a pas d'opérations (insertion par exemple), les
structures de données fonctionnelles supportent les opération comme l'insertion
ou la suppression. Ces opérations sont effectuées en créant une nouvelle
structure mise à jour.

Par exemple, une liste classique ressemble à `[3,2,1]`. Si cette liste est
modifiable et que nous voulons insérer la valeur `4` en tête (_head_) de liste,
cette dernière ressemble maintenant à `[4,3,2,1]`. Elle a été directement
modifiée et l'ancienne valeur, `[3,2,1]` est perdue. Si quelqu'un d'autre
utilisait cette liste, il voit maintenant `[4,3,2,1]`. Si cette personne était
en pleine itération sur la liste, elle a maintenant une jolie exception.

Dans le modèle fonctionnel, ce genre de cas n'arrive pas. Lorsque l'on insert
`4` dans la liste, une nouvelle valeur `[4,3,2,1]` est créée, sans modifier la
liste originale. Les deux valeurs `[4,3,2,1]` et `[3,2,1]` existent et si
quelqu'un utilisait l'ancienne liste `[3,2,1]`, il a toujours accès à celle-ci.

Vous vous dites peut être que c'est une façon inefficace de fonctionner. Si nous
avons accès aux deux listes `[4,3,2,1]` et `[3,2,1]`, nous devons stocker ces
sept éléments en mémoire, non ? Même si nous n'avons pas besoin d'accéder à la
valeur `[3,2,1]`. En réalité, l'efficacité des structures de données
fonctionnelles dépend des opérations effectuées dessus et de comment leur
représentation interne est utilisée (tout comme les structures classiques mais
avec d'autres avantages, coûts et compromis).

Pour une liste (simplement chaînée), si tout ce que nous voulons est insérer de
nouveaux éléments en tête, nous pouvons le faire efficacement en stockant les
éléments comme ceci :

      +---+    +---+    +---+    +---+
      | 4 +--->+ 3 +--->+ 2 +--->+ 1 |
      +---+    +---+    +---+    +---+
        |        |
    new list  original

Nous ajoutons `4` dans une nouvelle cellule contenant un lien vers le reste de
la liste. Cette valeur originale est représentée par la référence existante,
en commençant à la cellule de valeur `3`. Si quelqu'un d'autre a une référence
sur cette cellule, il ne verra jamais que la liste a été mise à jour (ce qui ne
serait pas le cas pour une liste doublement chaînée). Nous pouvons donc affirmer
avoir un accès indépendant aux deux listes, `[4,2,3,1]` et `[3,2,1]`, quand bien
même elles partagent des éléments en mémoire. Sans opération de modification
directe, aucune différence n'est perceptible.

Nous pourrions aller encore plus loin : Si quelqu'un souhaite insérer la valeur
`9` en tête de la liste `[3,2,1]`, il peut le faire indépendamment de notre
utilisation de celle-ci, en utilisant les mêmes éléments.

                  +---+      +---+    +---+    +---+
    new list 1 -> | 4 +---+->+ 3 +--->+ 2 +--->+ 1 |
                  +---+  /   +---+    +---+    +---+
                        /      |
                  +---+/    original
    new list 2 -> | 9 +
                  +---+

Nous pourrions bien sûr stocker de cette façon une liste modifiable mais cela
pourrait être dangereux. Si, par exemple, nous mettions à jour la cellule `3`
dans la liste `[4,3,2,1]`, elle serait également mise à jour dans la liste
`[9,3,2,1]` ce qui pourrait ne pas être apprécié.

Mais… comment faire si je souhaite vraiment changer `3` en lui donnant la valeur
`5`, par exemple ? Comme nous ne pouvons pas effectuer de modification directe,
nous devons copier quelques cellules dans la liste mise à jour. Le résultat de
l'opération ressemble donc à ceci :

                    +---+    +---+
    updated list -> | 4 +--->+ 5 +----+
                    +---+    +---+     \
                                        \
                    +---+    +---+    +-+-+    +---+
      new list 1 -> | 4 +--->+ 3 +--->+ 2 +--->+ 1 |
                    +---+  / +---+    +---+    +---+
                          /    |
                    +---+/  original
      new list 2 -> | 9 +
                    +---+

En allant vers l'arrière à partir de chaque pointeur, nous pouvons voir que ceci
représente à la fois les listes `[4,5,2,1]`, `[4,3,2,1]`, `[9,3,2,1]` et
`[3,2,1]`. Si nous voulons stocker toutes ces valeurs en même temps, cette
représentation est bien plus efficace que plusieurs listes modifiables.

Les structures de données purement fonctionnelles sont très utiles en
programmation multi-thread puisque une modification effectuée dans un thread
n'impactera pas les autres.

## Comprendre Git

Voyons maintenant quel est le rapport entre tout ceci et Git. Avec un système de
gestion de versions, ce que l'on cherche à accomplir c'est :

* Mettre à jour notre code avec de nouvelles versions tout en gardant les
  anciennes disponibles ;
* Travailler à plusieurs sur un même code sans que les mises à jour
  n'interfèrent entre elles de façon imprévisible.

Une structure de données fonctionnelle permet de :

* Mettre à jour la structure tout en gardant un accès aux anciennes valeurs ;
* Mettre à jour la structure à un endroit sans interférer avec quelqu'un d'autre
  mettant également la structure à jour.

Si vous vous dites que les structures de données fonctionnelles sont une bonne
représentation pour un système de gestion de versions, vous êtes dans le vrai.
J'irais même plus loin en disant que Git est simplement une structure de données
purement fonctionnelle avec un client en ligne de commande permettant
d'effectuer des opérations dessus.

Pour compléter l'analogie, nous devons remplacer ce qui était précédemment une
suite de chiffres par des commits. Les commits Git sont des copies indépendantes
de l'état complet du code à un point donné dans le temps. Ce que jusque là nous
appelions liste est ce que l'on appelle historique en Git.

Soit un dépôt contenant, dans la branche `master` et dans l'ordre, les commits
A, B et C. Nous avons demandé trois fois à Git de stocker l'intégralité de
l'état de notre code.

Nous pouvons représenter cela sous la forme `[C,B,A]`. En réalité, chaque commit
a des meta-données, comme un message de commit, mais nous allons ignorer ce
fait pour une question de simplicité. Voici la version graphe :

    +---+    +---+    +---+
    + C +--->+ B +--->+ A |
    +---+    +---+    +---+
      |
    master

## Faire un commit

Si nous créons un nouveau commit, cela revient à l'ajouter en tête de
l'historique. Git utilise même le nom `HEAD` pour référencer le commit actif.

    +---+    +---+    +---+    +---+
    + D +--->+ C +--->+ B +--->+ A |
    +---+    +---+    +---+    +---+
      |        |
    master   master^

Lorsque Git créer un commit, il déplace le pointeur de la branche courante pour
nous et fait pointer `master` sur l'historique `[D,C,B,A]`. Nous pouvons
toujours faire référence à `[C,B,A]` en utilisant `master^`, le parent de
`master`. Si quelqu'un travaille avec cette historique, il ne verra pas nos
modifications.

## Corriger un commit

Si vous avez déjà utilisé Git, vous savez probablement que l'on peut modifier
son dernier commit grâce à `commit --amend`. Mais pouvez-vous réellement
modifier un commit ? En réalité, non. Git crée simplement un nouveau commit et
fait pointer votre branche dessus. L'ancien commit peut être retrouvé grâce à
`git reflog` et vous pouvez y faire référence via son _hash_ (j'ai ici utilisé
la valeur arbitraire `ef4d34`). L'état du dépôt est donc le suivant :

              +---+    +---+    +---+    +---+
    ef4d34 -> | D +--+>+ C +--->+ B +--->+ A |
              +---+ /  +---+    +---+    +---+
                   /     |
              +---+    master^
    master -> | E |
              +---+

## Les branches

Comme vous avez pu le voir juste avant, lorsque vous utilisez `commit --amend`,
vous créez en fait une nouvelle branche (il y a une fourche dans le graphe). La
seule différence lors de la création d'une branche est qu'un nouveau nom est
créé pour se référer aux commits. Nous pouvons même créer une branche à partir
du commit `ef4d34` grâce à la commande `git checkout -b branch ef4d34`.

              +---+    +---+    +---+    +---+
    branch -> | D +--+>+ C +--->+ B +--->+ A |
              +---+ /  +---+    +---+    +---+
                   /     |
              +---+  master^
    master -> | E |
              +---+

En général, lorsque l'on crée une branche dans Git, celle-ci pointe sur le
`HEAD` courant mais dés lors que l'on voit Git comme une structure de données
fonctionnelle, rien n'empêche de créer une branche à partir de n'importe quel
commit existant.

## Utiliser rebase

Dans les exemples sur les structures de données, lorsque nous modifions une
cellule à un certain point de l'historique, nous devions copier toutes les
cellules se trouvant à la suite de celle modifiée (la cellule `4` dans notre
exemple mais il aurait pu y en avoir plus). Dans Git, c'est ce que l'on appelle
rejouer les commits et la commande permettant de le faire est nommée `rebase`.
Pour mettre à jour un ancien commit, nous ajoutons l'option `-i` pour passer en
mode _interactif_.

Si nous souhaitons modifier le commit `C` et changer son message, nous faisons
un checkout sur le commit `B`

NOTE: Erreur dans le texte original B/D

    git checkout B
    git rebase -i C

Cette commande ouvre le même éditeur que celui utilisé par Git pour les messages
de commit avec un contenu similaire à cette liste de commandes :

```
pick cd3ff32 <message de commit de C>
pick a65a671 <message de commit de D>

# some helpful comments from git
```

Si nous changeons la commande du commit `C` pour `edit`, Git nous permet de
modifier ce commit avant de rejouer les commits suivants.

```
edit cd3ff32 <message de commit de C>
pick a65a671 <message de commit de D>
```

Lorsque nous sauvegardons le fichier et fermons l'éditeur, Git commence une
opération de _rebase_. Il s'arrête pour nous permettre de modifier le commit
`C`.

```
Stoppé à cd3ff32... <message de commit de C>
Vous pouvez modifier votre commit avec

        git commit --amend

Une fois satisfait de vos changements, lancez

        git rebase --continue
```

Le message est assez clair, nous pouvons modifier le commit comme bon nous
semble. Une fois cela fait nous appelons `commit --amend` pour créer le commit
mis à jour puis reprenons la liste des commandes de _rebase_ grâce à `rebase
--continue`. Les autres commits seront rejoués l'un après l'autre puisque nous
avons choisi la commande `pick`. En cas de conflit, Git s'arrête et vous laisse
corriger avant de continuer. Notre dépôt ressemble maintenant à ceci :

              +---+    +---+
    rebased ->| D'+--->+ C'+
              +---+    +---+\
                             \
              +---+    +---+  \ +---+    +---+
    branch -> | D +--+>+ C +--->+ B +--->+ A |
              +---+ /  +---+    +---+    +---+
                   /     |
              +---+  master^
    master -> | E |
              +---+

Ce graphe ne doit pas vous être inconnu. J'espère que vous comprenez maintenant
pourquoi la commande `rebase` crée de nouveaux commits. Git est une structure de
données fonctionnelle et ne peut donc pas modifier un commit existant.

Puisque `rebase` crée une nouvelle chaîne de commits, il semble normal de
pouvoir modifier ce que cette dernière contient et c'est le cas : `rebase -i`
nous permet de réordonner, fusionner ou supprimer des commits. Nous pouvons
également en créer de nouveaux à tout moment (pour couper un commit en deux par
exemple) ou commencer à un autre point de l'historique grâce à l'option
`--onto`. Le processus classique de reporter des changements locaux "au dessus"
de mise à jour d'une branche distante est simplement un cas d'application plus
spécifique de la puissance de `rebase`.

## Fusionner

Nous n'avons pas parlé de la fusion de commits (merging). Git nous permet de
fusionner deux branches en une.

            +---+
          --+ X |
    +---+/  +---+
    | M |
    +---+\  +---+
          --+ Y |
            +---+

Fusionner ajoute un peu de complexité à notre modèle. Notre historique n'est
plus vraiment un arbre, c'est un graphe acyclique. En réalité, cela ne change
pas grand chose mais il est amusant de noter que `rebase`, qui a la réputation
d'être plus complexe, introduit moins de complications conceptuelles que
`merge`.

Rebase peut se voir comme l'application de nouveaux commits dans une nouvelle
direction. Merge est une opération fondamentalement différente. Une structure de
données dans laquelle il est possible de combiner deux cellules en une a un
nom : c'est ce qu'on appelle une structure de données persistante confluante.
Une autre appellation des structures de données fonctionnelles est
structures de données persistantes. J'ai préféré éviter ce terme pour ne pas
entrainer de confusion avec la notion de stockage sur médias persistants comme
un disque dur par exemple.

## Conclusion

Git peut être assez justement perçu comme une simple structure de données
fonctionnelle. Plutôt que de présenter Git comme un outil gestion de versions, nous pouvons voir la gestion de versions comme une résultante de l'utilisation
de cette structure de données. Je pense qu'expliquer Git de cette façon exprime
mieux la simplicité et la puissance de Git que de comparer son fonctionnement
avec celui des systèmes centralisés.

Lorsque l'on voit cela sous cet angle, je trouve que finalement Git est bien
plus simple que SVN par exemple. La seule raison pour laquelle Git peut être
perçu comme plus complexe est que cette simplicité nous permet d'implémenter des
workflows plus intéressants.

Si vous avez toujours trouvé Git intimidant, gardez en mémoire sa structure
simple et le fait que dans toute structure de données fonctionnelle, rien n'est
jamais réellement perdu et peut être retrouvé (regardez `reflog`).
