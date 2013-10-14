---
author: Simon Courtois (simonc)
layout: post
title: "Utiliser les Expressions Régulières en Ruby (2/3)"
date: 2013-10-05 12:00
categories:
- regex
- ruby
---

Source: [Using Regular Expressions in Ruby de Nell Shamrell sur le blog de Blue Box](http://www.bluebox.net/about/blog/2013/03/using-regular-expressions-in-ruby-part-2-of-3/)

Voici la seconde partie dans une série sur les Expressions Régulières en Ruby.
Vous pouvez lire la
[première partie ici](/article/utiliser-les-expressions-regulieres-en-ruby-1-sur-3) et la
[troisième partie ici](/article/utiliser-les-expressions-regulieres-en-ruby-3-sur-3).

## Les LookArounds

Les lookarounds me permettent d'aller plus loin que la simple comparaison avec
un modèle. En effet, ils offrent la possibilité de donner un contexte à cette
comparaison. Une expression contenant un lookaround ne retourne un résultat que
lorsqu'elle est effectuée dans ce contexte.

<!-- more -->

Soit une nouvelle chaîne de caractère, une autre citation d'Obiwan Kenobi dans
Star Wars.

``` ruby
string = "Who's the more foolish?  The fool or the fool who follows him?"
```

Je veux connaître tous les emplacements du mot "fool" dans cette chaîne. Je vais
donc utiliser l'expression régulière `/fool/`. Dans ce cas précis, je vais
utiliser la méthode `scan` sur ma chaîne. Cette méthode retourne toutes les
occurrences de mon expression dans la chaîne :

``` ruby
string.scan(/fool/)
#=> ["fool", "fool", "fool"]
```

Comme on peut le voir, scan retourne une partie du mot "foolish" et les deux
occurrences du mot "fool".

Comment fait-on si l'on souhaite que notre modèle `/fool/` retourne un résultat
seulement s'il fait partie du mot "foolish" ? Pour ce cas j'utiliserais un
_lookahead positif_ (recherche vers l'avant). Cela indique à mon expression
régulière de trouver toutes les correspondances à mon modèle directement suivies
d'une correspondance à un autre modèle. En Ruby, un lookahead positif est
exprimé grâce à l'opérateur `?=` :

``` ruby
/fool(?=ish)/
```

Voici mon expression modifiée. Comme vous pouvez le voir, j'ai mon modèle
contenant le mot "fool" directement suivi du modèle lookahead "ish".

``` ruby
string.scan(/fool(?=ish)/)
>=> ["fool"]
```

Cette fois-ci, la méthode `scan` retourne un seul résultat, la seule occurrence
de "fool" suivie de "ish".

De nouveau, utilisons la méthode `gsub` pour modifier notre chaîne. Remplaçons
chaque occurrence de "fool" (suivie de "ish") par le mot "self" :

``` ruby
string.gsub(/fool(?=ish)/, "self")
#=> "Who's the more selfish?  The fool or the fool who follows him?"
```

Nos excuses à Obiwan Kenobi, nous avons changé la ligne pour _"Who's the more
selfish?  The fool or the fool who follows him?"_.

Techniquement, c'est ce que l'on appelle une _zero-width, positive lookahead
assertion_ (recherche positive vers l'avant de taille zéro). Facile à prononcer
n'est-ce pas ? Dans le livre _The Well Grounded Rubyist_, David Black
l'explique comme ceci :

Zero-width
:    (taille zéro) signifie que le modèle lookahead ("ish" dans notre cas) ne
     consomme pas de caractères. Cela veut dire que la correspondance est
     cherchée mais n'est pas retournée. Seule la présence d'une correspondance
     est retournée, vrai ou faux.

Positive
:    signifie que le modèle doit être présent, obligatoirement.

Lookahead
:    veut dire que cette expression est recherchée après le modèle principal.

Assertion
:    indique que seule la présence d'une correspondance est retournée sous la
     forme true/false (vrai/faux).

Quelles sont mes autres possibilité ? Si par exemple je souhaite trouver toutes
les occurrences du mot "fool" qui ne sont **pas** suivies des lettres "ish" ?
Dans ce cas, je dois utiliser un lookahead négatif. Techniquement, c'est ce que
l'on appelle une _zero-width, negative lookahead assertion_ (recherche négative
vers l'avant de taille zéro). Négative signifie qu'aucune correspondance à ce
modèle ne doit être trouvée. Pour effectuer un lookahead négatif, uilisez
l'opérateur `?!`.

Je vais de nouveau appeler `scan` sur ma chaîne en utilisant cette fois un
lookahead négatif dans mon expression régulière. Je veux trouver toutes les
occurrences de "fool" qui ne font pas partie du mot "foolish" :

``` ruby
string.scan(/fool(?!ish)/)
#=> ["fool", "fool"]
```

Deux correspondances sont retournées, les deux fois où le mot "fool" apparait
sans faire partie de "foolish".

Utilisons maintenant la méthode `gsub`. À chaque fois que nous
trouvons le mot "fool" (non suivi des lettres "ish"), nous allons le remplacer
pas le mot "self" :

``` ruby
string.gsub(/fool(?!ish)/, "self")
#=> "Who's the more foolish?  The self or the self who follows him?"
```
Encore une fois j'ai changé une réplique classique. On peut maintenant lire
"Who's the more foolish?  The self or the self who follows him?"

Les lookaheads sont très pratiques lorsque l'on souhaite trouver une
correspondance en prenant en compte ce qui la suit. Allons de nouveau un peu
plus loin. Comment dois-je m'y prendre si je souhaite trouver une correspondance
à partir de ce qui la précède ? Pour faire cela, je dois utiliser une _positive
lookbehind assertion_ (recherche positive vers l'arrière). Cela signifie que je
veux trouver toutes les correspondances à mon modèle précédées d'un autre
modèle.

Utilisons une autre citation de Star Wars, une de Yoda cette fois-ci :

``` ruby
string = "For my ally is the force, and a powerful ally it is."
```

The modèle principal que je souhaite chercher est le mot "ally", je vais donc
utiliser l'expression régulière `/ally/`. J'aimerais cependant trouver le mot
"ally" uniquement s'il est directement précédé du mot "powerful". C'est le cas
parfait pour un _positive lookbehind_ (recherche positive vers l'arrière). Les
lookbehinds positifs utilisent l'opérateur `?<=`. Utilisons le dans notre
expression régulière :

``` ruby
/(?<=powerful )ally/
```

Cette expression régulière relève le mot "ally" chaque fois qu'il est
directement précédé du mot "powerful". Comme vous pouvez le remarquer, le
lookbehind est positionné avant le modèle principal. Cela montre bien que le mot
"powerful" doit est devant le mot "ally".

Je vais maintenant utiliser la méthode `gsub` sur ma chaîne. Chaque fois que le
mot "ally" est précédé par le mot "powerful", je veux le remplacer par le mot
"friend" :

``` ruby
string.gsub(/(?<=powerful )ally/, "friend")
#=> For my ally is the force, and a powerful friend it is.
```

Cela change quelque peu les mots de Yoda : "For my ally is the force, and a
powerful friend it is."

Comment dois-je m'y prendre si je souhaite faire le contraire ? Si par exemple
je veux toutes les occurrences du mot "ally" qui ne sont **pas** précédées du
mot "powerful". Dans ce cas, je dois utiliser un _negative lookbehind_
(recherche négative vers l'arrière). Pour cela on trouve l'opérateur `?<!`.
Utilisons-le dans notre expression régulière :

``` ruby
/(?<!powerful )ally/
```

Utilisons maintenant `gsub` sur notre chaîne pour remplacer chaque occurence du
mot "ally", non précédée du mot "powerful", par le mot "friend" :

``` ruby
string.gsub(/(?<!powerful )ally/, "friend")
#=> "For my friend is the force, and a powerful ally it is."
```

J'ai de nouveau changé les paroles de Yoda : "For my ally is the force, and a
powerful friend it is.".

Les lookarounds donnent une puissance incroyable à vos expressions régulières en
leur apportant un contexte. Plutôt que d'utiliser un modèle strict qui
correspond ou non, vos expressions régulières deviennent puissantes, flexibles
et capables de trouver bien plus de choses.

[Lire le troisième article de cette série](/article/utiliser-les-expressions-regulieres-en-ruby-3-sur-3)

## L'auteur chez Blue Box

Nell Shamrell travaille chez Blue Box en tant qu'Ingénieur Développement
Logiciel. Elle siège également au conseil de Certification de Programmation
Ruby de l'Université de Washington et est spécialisée en Ruby, Rails et
Développement Dirigé par les Tests (TDD). Avant le développement, Nell a étudié
et travaillé dans le domaine du théâtre, une excellente préparation à
l'environnement dynamique de la création d'applications logicielles. Dans ces
deux mondes, elle s'efforce de créer une expérience unique. Sur son temps
libre, elle pratique l'art martial appelé Naginata.
