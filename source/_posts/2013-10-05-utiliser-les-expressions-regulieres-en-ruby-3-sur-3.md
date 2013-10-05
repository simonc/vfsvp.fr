---
author: Simon Courtois (simonc)
layout: post
title: "Utiliser les Expressions Régulières en Ruby (3/3)"
date: 2013-10-05 12:00
categories:
- regex
- ruby
---

Source: [Using Regular Expressions in Ruby de Nell Shamrell sur le blog de Blue Box](http://www.bluebox.net/about/blog/2013/03/using-regular-expressions-in-ruby-part-3-of-3/)

Voici la seconde partie dans une série sur les Expressions Régulières en Ruby.
Vous pouvez lire la
[première partie ici](/article/utiliser-les-expressions-regulieres-en-ruby-1-sur-3) et la
[deuxième partie ici](/article/utiliser-les-expressions-regulieres-en-ruby-2-sur-3).

## Le comportement des Expressions Régulières

Les expressions régulières sont puissantes. Comme un célèbre super-héros l'a dit
un jour "with great power comes great responsibility" (à grands pouvoirs,
grande responsabilité). Pour éviter qu'une expression régulière ne cause une
catastrophe, vous devez être capable d'en contrôler le comportement.

<!-- more -->

Les expressions régulières ont trois comportements distincts : greedy
(gourmande), lazy (fainéante) et possessive. Ces termes peuvent sembler
négatifs mais ne sont pas pour autant de mauvaises attitudes pour vos
expressions. Ce sont simplement des descriptions des différentes façon d'agir
que peuvent utiliser vos expressions et que vous pouvez contrôler. Je vais vous
expliquer comment.

Pour comprendre ces comportements, il nous faut d'abord comprendre les
quantificateurs. Ils permettent de dire au moteur d'expressions régulières
combien de fois un caractère ou un groupe de caractères doit apparaitre dans
notre chaîne.

Un des quantificateurs que j'utilise le plus souvent est le `+`. Lorsque je le
place derrière un caractère, j'indique que ce dernier doit apparaitre au moins
une fois. Il peut apparaitre autant de fois qu'il le souhaite mais doit être au
minimum présent une fois.

Prenons l'expression suivante :

``` ruby
/.+/
```

Celle-ci trouverait une correspondance pour tout caractère apparaissant au moins
une fois. Elle garantie donc la présence d'un caractère dans la chaîne.

Les quantificateurs sont à la base même du comportement de votre expression, à
savoir gourmande, fainéante ou possessive. Par défaut, elle est gourmande.

Un quantificateur gourmand tente de trouver la correspondance la plus longue
possible au sein de la chaîne. Il attrape autant de caractères que ses petites
mains gourmandes le lui permettent et tente de trouver une correspondance. Si
toute la chaîne ne correspond pas, il prend un caractère de moins et tente de
nouveau la recherche. Il recommence ce processus jusqu'à ce qu'il ne trouve
plus de caractères à tester.

Les quantificateurs gourmands fournissent un effort maximum pour un retour
maximum. Un quantificateur gourmand essaie autant de cas que possible pour
trouver une correspondance et retourne le maximum de caractères en faisant
partie.

Pour l'exemple suivant, je vais changer de science fiction et emprunter une
citation de _Star Trek: First Contact_ :

``` ruby
string = "There's no time to talk about time we don't have the time"
/.+time/
```

Cette expression régulière capture tout caractère apparaissant au moins une
fois, le tout suivi du mot "time". Si je fais appel à la méthode `match` sur
mon expression régulière en lui passant ma chaîne en paramètre :

``` ruby
/.+time/.match(string)
#=> "There's no time to talk about time we don't have the time"
```

Toute la chaîne correspond.

Lorsque cette expression analyse la chaîne, elle tente d'abord de trouver la
première partie du modèle, `.+`. Cela correspond à toute la chaîne. Elle essaie
ensuite de trouver la deuxième partie, le mot `time`. Comme toute la chaîne a
été consommée, elle cherche "time" après la fin de cette dernière et ne trouve
rien. Elle recule donc d'un caractère (_backtrack_) et retente le test pour
trouver une correspondance. Une fois celle-ci trouvée, elle est retournée. Dans
notre cas, cela représente toute la chaîne.

Les quantificateurs gourmands tentent de faire correspondre toute la chaine puis
reculent progressivement. Ce recule progressif signifie que, si notre chaîne ne
correspond pas du tout au modèle, l'expression va tenter autant que possible de
trouver une correspondance. Elle doit garder en mémoire les possibilités déjà
tentées ce qui peut prendre beaucoup de ressources systèmes, en particulier
lorsque vous avez plusieurs tests effectués sur un texte long.

Oniguruma a certaines optimisations qui rendent le recule progressif plus
rapide. Patrick Shaughnessy a écrit un fantastique article sur son blog qui
détail comment Oniguruma gère le recul progressif. Malgré les optimisations, une
expression régulière gourmande consommera tout de même beaucoup de ressources.

Lorsque vous souhaitez une recherche plus réduite et qui consomme moins de
ressources, vous devez utiliser un quantificateurs fainéant. Également appelé
quantificateur réticent, celui-ci va commencer sa recherche au tout début
de la chaîne et tenter de faire correspondre le premier caractère. Si cela ne
suffit pas, il va consommer un caractère supplémentaire. En dernier ressort il
tentera de consommer toute la chaîne.

Un quantificateur fainéant fournit l'effort minimum pour un retour minimum. Il
retourne le moins de caractères possible pour une correspondance. S'il trouve ce
qu'il cherche avec le premier caractère de la chaîne, il va simplement retourner
celui-ci. Il est fainéant, il fait le minimum demandé et rien de plus.

Pour utiliser un quantificateur fainéant, il suffit de lui ajouter un point
d'interrogation.

``` ruby
/.+?time/
```

Si j'appelle la méthode `match` sur ma chaîne en utilisant un quantificateur
fainéant

``` ruby
/.+?time/.match(string)
#=> "There's no time"
```

Je récupère seulement "There's no time". La recherche a commencé au tout début
de la chaîne et retourne la correspondance minimum. Les expressions régulière
fainéantes utilisent beaucoup moins de recul progressif et, par conséquent,
moins de ressources que les expressions gourmandes.

Comment faire lorsque l'on souhaite récupérer un maximum de caractères tout en
limitant le recul progressif et la consommation de ressources ? Pour cela, il
existe un troisième quantificateur, le quantificateur possessif. Il fonctionne
sur le principe de tout ou rien, soit il trouve une correspondance au premier
essai soit il échoue. Comme le gourmand, il consomme le plus de caractères possibles (la chaîne entière) et tente la correspondance. Si cette tentative
échoue, il n'y aura ni recul ni nouvel essai.

Les quantificateurs possessifs utilisent un effort minimum pour un retour
maximum. Ils tentent de retournent autant de caractères que possible en en
faisant le moins possible (ils tentent une fois puis abandonnent).

Pour rendre un quantificateur possessif, il suffit de lui ajouter un plus `+` :

``` ruby
/.++time/
```

Lançons la méthode `match` sur notre chaîne en lui passant cette expression
possessive :

``` ruby
/.++time/.match(string)
#=> nil
```

Cet appel retourne `nil` car le test a échoué. Pourquoi cet échec ? Il semble
pourtant que notre chaîne corresponde à l'expression. La raison est qu'aucun
recul progressif n'est effectué.

L'expression va d'abord tenter de trouver `.++` ce qui va consommer tout la
chaîne. Lorsqu'elle tente de trouver le mot `time`, il ne reste plus de
caractère à consommer. L'expression ne peut pas reculer à cause du
quantificateur possessif et va donc échouer.

Le principal avantage des quantificateurs possessifs est l'échec rapide.
L'absence de recul consomme très peu de ressources. Un quantificateur gourmand
va tenter tout ce qui est possible pour trouver une correspondance. En cas
d'échec, tout ce travail et toutes ces ressources n'auront servi à rien. Un
quantificateur possessif évite cela, si aucune correspondance n'existe l'échec
sera rapide.

En général, l'utilisation de quantificateurs possessifs se limite à des
expressions très courte, lorsque vous avez une petite sous-expression au sein
d'une expression plus large. Ils sont très utiles mais à utiliser avec
précaution.

## Conclusion

Les expressions régulières peuvent sembler extrêmement complexes. Lorsque j'ai
appris à aller plus loin que les bases, au delà des petites astuces de
validation d'email par exemple, j'ai trouvé que cela m'aidait de les voir comme
un sous-programme dans un langage différent. En réalité c'est exactement ça.
Vous écrivez un programme, au sein d'un autre programme, au sein de Ruby
lui-même.

Comme tout langage de programmation, il est plus simple d'écrire vos expressions
par petites parties. Lorsque j'écris un _lookbehind_, j'écris d'abord le modèle
principal, m'assure qu'il fonctionne. J'écris ensuite le modèle du lookbehind,
séparément, et m'assure qu'il fonctionne également. Une fois cela fait, je
joins les deux modèles pour valider qu'ils fonctionnent ensemble.

[Rubular](http://rubular.com/) est un site fantastic pour écrire et tester vos
expressions régulières. Testez le, utilisez le, il m'a vraiment facilité la vie.

Comme tout programme informatique, les expressions régulières s'écrivent en
plusieurs fois. Lorsque vous concevez une expression, il est tout à fait normal
que celle-ci soit laide au début. Faites la fonctionner et après seulement
tentez de la rendre plus lisible. C'est le même processus rouge, vert,
réusinage (red, green, refector) qui est utilisé dans le développement dirigé
par les tests.

Les expressions régulières sont puissantes. Si puissantes qu'elles font peur à
beaucoup d'entre-nous. Cette peur peut être surpassée. Aussi obscures qu'elle
peuvent paraître, elles ont une structure logique et réfléchie. Utilisez-les,
lancez Rubular et essayez quelques _lookaheads_ et _lookbehinds_. Tentez les
quantificateurs gourmands, fainéants et possessifs. Explorez la fantastique
intégration des expressions régulières dans Ruby, je pense que vous en serez
surpris ce que vous trouverez.

## L'auteur chez Blue Box

Nell Shamrell travaille chez Blue Box en tant qu'Ingénieur Développement
Logiciel. Elle siège également au conseil de Certification de Programmation
Ruby de l'Université de Washington et est spécialisée en Ruby, Rails et
Développement Dirigé par les Tests (TDD). Avant le développement, Nell a étudié
et travaillé dans le domaine du théâtre, une excellente préparation à
l'environnement dynamique de la création d'applications logicielles. Dans ces
deux mondes, elle s'efforce de créer une expérience unique. Sur son temps
libre, elle pratique l'art martial appelé Naginata.
