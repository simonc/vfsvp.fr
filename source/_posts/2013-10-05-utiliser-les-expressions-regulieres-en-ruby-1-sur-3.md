---
author: Simon Courtois (simonc)
layout: post
title: "Utiliser les Expressions Régulières en Ruby (1/3)"
date: 2013-10-05 12:00
categories:
- regex
- ruby
---

Voici la première partie d'une série sur les Expressions Régulières en Ruby.
Vous pouvez lire la
[deuxième partie ici](/post/utiliser-les-expressions-regulieres-en-ruby-2-sur-3) et la
[troisième partie ici](/post/utiliser-les-expressions-regulieres-en-ruby-3-sur-3).

## Introduction

Pour être honnête, la première fois que j'ai vu une expression régulière,
j'étais intimidée. Cela semblait si cryptique et mystérieux. Je peinais à voir
comment la comprendre et a fortiori en écrire une. Encore récemment, je
n'utilisais les expressions régulières qu'en cas d'absolue nécessité (une
validation d'email par ici, un remplacement basique par là). Cela m'a empêché
d'approfondir ma connaissance de leur utilisation en Ruby. Ruby travaille avec
les expressions régulière dans une harmonie, une symphonie de code. Pour
exploiter pleinement Ruby, je devais surpasser mon intimidation, ma peur des
expressions régulières.

J'ai dépassé cette peur. Comme toute chose dans la vie, les expressions
régulières semblent insurmontables jusqu'à ce qu'on les découpe. Je veux vous
aider à dépasser votre peur des expressions régulières. Pour cela, je vais les
découper, étape par étape, et vous guider au travers du concept d'expressions
régulières en Ruby et ce jusqu'aux techniques avancées. J'espère que vous verrez
la beauté, surpasserez votre intimidation et les adopterez dans votre code.


<!-- more -->

## Les Expressions Régulières

Une expression régulière est simplement un modèle. Un modèle auquel une chaîne
de caractères correspond ou non. Le livre _Programming Ruby 1.9_ de Dave Thomas
(plus connu sous le nom _Pickaxe Book_ [livre pic-à-glace]) regroupe en trois
catégories ce que l'on peut faire avec une expression régulière : tester,
extraire et modifier. Vous pouvez tester une chaîne de caractères pour voir si
elle correspond au modèle. Vous pouvez également modifier une chaîne de
caractères en remplaçant les parties correspondant au modèle par un autre texte.
Tester, extraire, modifier. Si simple et à la fois si puissant.

## Les Expressions Régulières en Ruby

Ruby vous permet de pousser les expressions régulières plus loin. En Ruby, tout
est objet. Cela inclus les expressions régulières. Vous pouvez envoyer des
messages aux objets, vous pouvez donc envoyer des messages aux expressions
régulières. Vous pouvez également les assigner à des variables, les passer à une
méthode et bien plus.

Depuis la version 1.9, Ruby utilise la bibliothèque d'expressions régulières
Oniguruma. Cette dernière fournit toutes les fonctionnalités standards des
expressions régulières ainsi qu'un certain nombre d'extensions. Elle supporte
parfaitement les caractères complexes comme les caractères japonais par exemple.
Une fonctionnalité que j'apprécie particulièrement est la possibilité d'utiliser
`\h` et `\H` comme raccourcis pour les chiffres hexadécimaux.

J'ai découvert récemment que Ruby 2.0 utilisait une bibliothèque différente,
Onigmo. Onigmo est un _fork_ d'Oniguruma et ajoute encore plus de
fonctionnalités exploitables par Ruby. Il sera intéressant de voir jusqu'où cela
peut aller.

Malgré les modifications apportées par Onigmo, les fondamentaux de l'utilisation
des expressions régulières ne changent pas. Vous testez vos chaînes de
caractères avec une expression régulière. Vous composez un modèle auquel la
chaîne doit correspondre.

## Test basique

Dans la plupart des cas en Ruby, j'utilise l'opérateur `=~`. C'est l'opérateur
de test basique. Lorsque j'utilise cet opérateur, je demande à Ruby "Est-ce que
cette chaîne de caractères contient ce modèle ?".

Voyons un premier exemple :

``` ruby
/force/ =~ "Use the force"
```

À gauche, on trouve une expression régulière qui représente le mot _force_. À
droite, une citation d'un de mes films préférés, Star Wars, "Use the force".
Lorsque je lance ce code, je demande à Ruby si mon modèle, à gauche, est présent
dans la chaîne de caractères située à droite.

Détail appréciable, je peux en inverser l'écriture si je le souhaite.

``` ruby
"Use the force" =~ /force/
```

Je peux mettre la chaîne à gauche et l'expression régulière à droite. Je fais le
même travail, simplement formulé autrement, "Est-ce que ma chaîne contient mon
expression régulière ?". Certains trouvent cette formulation plus lisible.

Lorsque je lance ce code, il retourne le numéro du caractère auquel la
correspondance commence. Ici, le modèle `/force/` est trouvé au huitième
caractère de ma chaîne.

``` ruby
"Use the force" =~ /force/
#=> 8
```

Je peux également tester si une chaîne **ne contient pas** un modèle en
utilisant l'opérateur `!~`. Cela retourne vrai (_true_) ou faux (_false_).

``` ruby
/dark side/ !~ "Use the force"
```

Si je lance ce code, je demande si l'expression `/dark side/` est absente de la
chaîne `"Use the force"`. Dans le cas présent, vrai est retourné.

``` ruby
/dark side/ !~ "Use the force"
#=> true
```

Les opérateurs sont parfaits pour la vérification simple, savoir si ma chaîne
correspond à mon expression régulière ou non paer exemple. Ruby fournit
cependant bien plus d'informations sur la correspondance. Tout ce que j'ai à
faire, c'est demander.

## MatchData

Le secret c'est de transformer ma correspondance en un objet `MatchData`. Je
peux créer cet objet avec la méthode `match`.

Soit la chaîne de caractères suivante :

``` ruby
string = "The force will be with you always"
```

Je veux savoir si cette chaîne contient le mot _force_. Je peux utiliser
l'expression régulière suivante :

``` ruby
/force/
```

J'appelle la méthode `match` sur mon expression régulière et lui passe ma
chaîne. Lorsque je lance ce code, il retourne une instance de la classe
`MatchData` pour ma correspondance.

``` ruby
my_match = /force/.match(string)
#=> #<MatchData "force">
```

Depuis Ruby 1.9, la correspondance ne se fait plus obligatoirement au début de
la chaîne. Je peux passer un second argument, un entier, qui indique que la
correspondance doit commencer à partir de ce numéro de caractère.

``` ruby
my_match = /force/.match(string, 5)
#=> nil
```

Ici, le code retourne `nil`. Pour trouver une correspondance au mot _force_, il
faudrait commencer plus tôt dans la chaîne.

Pour les exemples suivants, je me contenterai de passer simplement ma chaîne de
caractères :

``` ruby
my_match = /force/.match(string)
#=> #<MatchData "force">
```

J'ai accès à des méthodes qui fournissent **bien plus** d'informations sur ma
correspondance car c'est maintenant une instance de la classe `MatchData`.

Si j'appelle `to_s` sur ma correspondance, cela va retourner l'intégralité de
son texte :

``` ruby
my_match.to_s
#=> "force"
```

Si j'appelle `pre_match` dessus, cela retourne la partie de ma chaîne qui
**précède** ma correspondance :

``` ruby
my_match.pre_match
#=> "The "
```

Si j'appelle `post_match` dessus, cela retourne la partie de ma chaîne qui
**suit** ma correspondance :

``` ruby
my_match.post_match
#=> " will be with you"
```

Toutes ces méthodes (et il y en a d'autres) sont bien utiles. `MatchData`
montre cependant sa réelle utilité lorsque l'on parle de groupes de captures.
Les groupes de captures sont des sous expressions au sein d'une expression
régulière. Voici un exemple :

``` ruby
/(.*)force(.*)/
```

Pour qu'une chaîne de caractères contienne cette expression régulière, elle doit
avoir n'importe quel caractère zéro, une ou plusieurs fois (c'est la
signification de `.*`), suivi du mot _force_, suivi par n'importe quel caractère
zéro, une ou plusieurs fois.

Notez bien que la première et la dernière partie de l'expression sont en entre
parenthèses. C'est ce qu'on appelle des groupes. Lorsque que je lance ce modèle
sur ma chaîne, ce qui correspond à ces groupes va être mémorisé. Je peux ensuite
accéder à ces groupes et les utiliser dans d'autres parties de mon code.

``` ruby
my_match = /(.*)force(.*)/.match(string)
```

Si je souhaite voir tous ces groupes, mes groupes de captures, je peux appeler
la méthode `captures` sur ma correspondance.

``` ruby
my_match.captures
#=> ["The ", " will be with you always"]
```

Les objets `MatchData` sont très proches des tableaux. Je peux accéder à
chaque capture en utilisant les crochets, de la même façon que pour accéder aux
éléments d'un tableau.

Si j'appelle `my_match[1]`, j'obtiens le premier groupe de capture, `"The "`.

De la même manière, `my_match[2]` retourne mon second groupe de captures, `"
will be with you always"`.

Notez bien que je ne commence pas avec `my_match[0]` comme je le ferais pour un
tableau classique. Si j'appelle `my_match[0]`, plutôt que de récupérer le
premier groupe, j'obtiens la chaîne sur laquelle j'ai lancé le modèle.

``` ruby
my_match[0]
#=> "The force will be with you always"
```

Il est important de garder en mémoire que malgré leur ressemblance avec les
tableaux, les objets `MatchData` ne sont pas des tableaux.

Si j'essaie d'appeler une méthode de tableau comme `each` sur mon objet
`MatchData`, j'obtiens une erreur :

``` ruby
my_match.each do |m|
 puts m.upcase
end
#=> NoMethodError
```

Cependant, je peux facilement corriger cela en convertissant mon objet
`MatchData` en tableau grâce à la méthode `to_a`.

``` ruby
my_match.to_a.each do |m|
 puts m.upcase
end
#=> THE FORCE WILL BE WITH YOU ALWAYS THE WILL BE WITH YOU ALWAYS
```

[Lire le deuxième article de cette série](/post/utiliser-les-expressions-regulieres-en-ruby-2-sur-3)

## Note

Ceci est une traduction de l'article publié en anglais sur le
[blog de Blue Box](http://www.bluebox.net/about/blog/2013/02/using-regular-expressions-in-ruby-part-1-of-3/).

## L'auteur chez Blue Box

Nell Shamrell travaille chez Blue Box en tant qu'Ingénieur Développement
Logiciel. Elle siège également au conseil de Certification de Programmation
Ruby de l'Université de Washington et est spécialisée en Ruby, Rails et
Développement Dirigé par les Tests (TDD). Avant le développement, Nell a étudié
et travaillé dans le domaine du théâtre, une excellente préparation à
l'environnement dynamique de la création d'applications logicielles. Dans ces
deux mondes, elle s'efforce de créer une expérience unique. Sur son temps
libre, elle pratique l'art martial appelé Naginata.
