---
author: Simon Courtois (simonc)
layout: post
title: "Elixir pour les rubyists (partie 1)"
date: 2013-10-27 18:30
comment: true
categories:
- elixir
- ruby
---

Source: [Elixir for Rubyists part 1 par Nate West](http://www.natescottwest.com/blog/2013/09/26/elixir-for-rubyists/)

Elixir est mon nouveau langage préféré. Cet article est le premier d'une série
de longueur indéterminée sur Elixir. En tant que rubyist, la syntaxe d'Elixir va
vous sembler familière. Je vais donc vous montrer beaucoup de code pour
vous expliquer comment il marche. Elixir est fonctionnel et amusant
(FUNctional).

Elixir est un langage fonctionnel qui tourne sur la VM Erlang mais ressemble
beaucoup à Ruby.

<!-- more -->

``` elixir
2 + 2
# => 4

IO.puts "Hello!"
# => Hello!
#    :ok

String.downcase("JE NE CRIE PAS")
# => "je ne crie pas"

defmodule Numbers do
  def add_to(num) do
    if is_number(num) do
      num + 2
    else
      raise(ArgumenError, message: "L'argument doit etre un nombre")
    end
  end
end

Numbers.add_to(4)
# => 6
Numbers.add_to("Nate")
# => ** (ArgumenError) L'argument doit etre un nombre
```

Elixir utilise la détection par motif (_pattern matching_) pour effectuer des
comparaisons et assigner des valeurs aux variables.

``` elixir
a = 2
# => 2

2 = a
# => 2

{ success, string } = { :ok, "Hey Joe, tu sais quoi ?" }
# => {:ok, "Hey Joe, tu sais quoi ?"}
success
# => :ok
string
# => "Hey Joe, tu sais quoi ?"
```

Elixir est fonctionnel, les variables sont donc immuables. Cependant,
contrairement à Erlang, ces dernières ne sont pas limitées à une seule
assignation. Si vous voulez détecter le motif de la valeur d'une variable, vous
devez utiliser un circonflexe `^`. Sans le circonflexe vous pouvez assigner une
nouvelle valeur à la variable.

``` elixir
a = 2
# => 2
^a = 3
# => ** (MatchError) aucune correspondance avec : 3
#    :erl_eval.expr/3
a = 3
# => 3
```

Comme tout langage fonctionnel, Elixir traite les fonctions comme des citoyens
de premier ordre. Vous pouvez assigner une fonction à une variable pour une
évaluation différée. Notez l'interpolation de chaîne dans l'exemple suivant,
une autre ressemblance à Ruby.

``` elixir
greeter = fn (name) -> IO.puts "Hello #{name}" end
# => #Function<6.80484245 in :erl_eval.expr/5>
greeter.("Nate")
# => Hello Nate
#    :ok
```

Vous pouvez écrire des fonctions qui retournent des fonctions.

``` elixir
defmodule FunctionExamples do
  def build_greeter(kind) do
    case kind do
      :hello -> fn (name) -> "Coucou, #{name}!" end
      :goodbye -> fn (name) -> "A plus, #{name}!" end
      _ -> fn (name) -> "Je ne sais pas quoi te dire, #{name}." end
    end
  end
end

say_hello = FunctionExamples.build_greeter(:hello)
# => #Function<0.63189797 in FunctionExamples.build_greeter/1>
say_hello.("Nate")
# => Coucou, Nate!
#    :ok

wat = FunctionExamples.build_greeter(:something_else)
# => #Function<2.63189797 in FunctionExamples.build_greeter/1>
wat.("Nate")
# => "Je ne sais pas quoi te dire, Nate."
#    :ok
```

Comme dans d'autres langages fonctionnels, plutôt que de reposer sur des
boucles, Elixir utilise énormément la récursivité. Cela dit, le module `Enum`
fournit quelques fonctions bien connues des rubyists, comme `each` par exemple.

``` elixir
Enum.each(["Joe", "Matz", "Jose"], fn (name) -> IO.puts(name) end)
# => Joe
# => Matz
# => Jose
# => :ok

defmodule RecursionExamples do
  def recurse([]) do
    :ok
  end
  def recurse([head|tail]) do
    IO.puts head
    recurse(tail)
  end
end

RecursionExamples.recurse(["Joe", "Matz", "Jose"])
# => Joe
# => Matz
# => Jose
# => :ok
```

C'est tout pour cette première partie. À bientôt pour [la deuxième](/article/elixir-pour-les-rubyists-2).
