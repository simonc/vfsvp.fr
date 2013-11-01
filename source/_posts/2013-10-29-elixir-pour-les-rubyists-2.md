---
author: Simon Courtois (simonc)
layout: post
title: "Elixir pour les rubyists (partie 2)"
date: 2013-10-29 21:00
comment: true
categories:
- elixir
- ruby
---

Source: [Elixir for Rubyists part 2 par Nate West](http://www.natescottwest.com/blog/2013/09/26/elixir-for-rubyists-part-2/)

Voici une tentative de réponse aux questions de la [partie 1](/article/elixir-pour-les-rubyists-1).

## Immuable ??

Les variables d'Elixir sont immuables. Elles ne sont pas à assignation unique.
Je vous entends déjà dire "Mais Nate ! Si on réassigne une variable, n'est-ce
pas une mutation ?". Non !

## Elixir assure la transparence référentielle des variables

Transparence référentielle est une façon académique de dire "quand je fais
quelque chose qui modifie une valeur, je peux toujours revenir à la valeur
originale". Jessica Kerr ([@jessitron](https://twitter.com/jessitron)) appelle
cela "données en entrée, données en sortie" (_data in, data out_). Sous forme
de code :

<!-- more -->

``` elixir
name = "Nate"
# => "Nate"
String.upcase(name)
# => "NATE"
name
# => "Nate"
```
`String.upcase` est référentiellement transparent. Il retourne une nouvelle
valeur transformée mais ne modifie pas la valeur originale. On peut comparer
cela avec `String#upcase!` en Ruby.

``` ruby
name = "Nate"
# => "Nate"
name.upcase!
# => "NATE"
name
# => "NATE"
```

`String#upcase!` _n'est pas_ référentiellement transparent. Non seulement il
retourne une valeur transformée mais modifie également la valeur originale.

Avec Elixir, dans le contexte d'une fonction vous ne pourrez pas modifier la
valeur d'une variable.

``` elixir
name = "Nate"
# => "Nate"
capitalize = fn(string) -> string = String.upcase(string) end
# => #Function<6.80484245 in :erl_eval.expr/5>
capitalize.(name)
# => "NATE"
name
# => "Nate"
```

## En quoi la transparence référentielle est importante ?

Pour faire court, un code référentiellement transparent est simple à tester,
facile à comprendre et à rendre _threadsafe_. Si on a ceci en Ruby :

``` elixir
greeting = "Hello"
do_something_to_string(greeting)
print(greeting)
```

On s'attend à ce que `greeting` ait la valeur "Hello" lorsque l'on appelle
`print` mais `do_something_to_string` a pu modifier la valeur de `greeting`.
D'autant plus si `greeting` est transmis un peu partout dans l'application et
passe par toutes sortes de `do_somethings`. Au moment d'afficher `greeting`, il
pourrait tout aussi bien contenir "Game over !".

Pour en savoir plus :

* [Jessica Kerr’s Functional Principles (en)](http://confreaks.com/videos/2382-rmw2013-functional-principles-for-oo-development)
* [Ruby Rogues Podcast: Functional and OO Programming (en)](http://rubyrogues.com/115-rr-functional-and-object-oriented-programming-with-jessica-kerr/)
* Si vous pensez à d'autres ressources, dites le moi, je les ajouterai.

## Un piège...

Il est possible d'assigner une nouvelle valeur à une variable en se basant sur
sa valeur actuelle. Notez bien qu'ici `=` n'est pas un opérateur d'assignation.
C'est un opérateur de test de correspondance. Lorsque l'on utilise sur une
variable, on peut choisir de tester la valeur de la variable ou nous pouvons
l'autoriser à prendre une nouvelle valeur.

``` elixir
1 = 2 # la valeur 1 ne correspond pas à la valeur 2
# => ** (MatchError) aucune correspondance avec : 3
#    :erl_eval.expr/3

:a = 2 # la valeur :a, un atôme (un peu comme un symbole en Ruby),
       # ne correspond pas à la valeur 2
# => ** (MatchError) aucune correspondance avec : 3
#    :erl_eval.expr/3

num = 2 # num est une variable. Nous pouvons lui assigner 2 pour établir
        # une correspondance.
# => 2

^num = 3 # la valeur de num (2) ne correspond pas à la valeur 3
# => ** (MatchError) aucune correspondance avec : 3
#    :erl_eval.expr/3

num = 3 # ici on ne cherche pas de correspondance, on peut donc assigner la
        # valeur 3 à num
# => 3
```

Tel que je le comprends, cela fait parti d'Elixir pour des questions pratique
et est particulièrement utile pour écrire des macros. Les puristes de la
programmation fonctionnelle vont détester ça. Si c'est votre cas, vous pouvez
lire [cette discussion](https://groups.google.com/forum/#!searchin/elixir-lang-core/single$20assignment/elixir-lang-core/FrK7MQGuqWc/2aimbHDAAHMJ)
au sujet de la réassignation de variables dans Elixir et jeter un oeil au
commentaire de Joe Armstrong.

Encore une fois, cela ne change pas l'état de l'objet. Il n'y a pas d'objet dans
Elixir. `num` est un simple conteneur de données auquel vous pouvez donner une
nouvelle valeur. Lorsque vous le faites, l'ancienne valeur va être retirée du
contexte d'exécution afin de laisser la place libre pour stocker une nouvelle
valeur.

## Essayez donc de le briser

Vous aurez tout de même beaucoup de mal à écrire une fonction qui brise la
transparence référentielle. Si vous réassignez une variable dans une fonction,
vous ne changez sa valeur que pour le contexte de cette fonction.

``` elixir
defmodule Assignment do
  def change_me(string) do
    string = 2
  end
end

# lorsque vous compilez ce module, vous aurez un warning indiquant
# qu'une variable de type string n'est pas utilisée!

greeting = "Hi"
# => "Hi"
Assignment.change_me(greeting)
# => 2
greeting
# => "Hi"
```

## C'est tout pour aujourd'hui

Voici la fin de la partie 2. À bientôt pour la partie 3.
