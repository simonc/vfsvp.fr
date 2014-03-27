---
author: Simon Courtois (simonc)
layout: post
title: "Tri de dépendances en Ruby avec TSort"
date: 2014-03-27 16:00
comment: true
categories:
- ruby
---

Source: [Dependency Sorting in Ruby with TSort de Lawson Kurtz sur le blog de Viget](http://viget.com/extend/dependency-sorting-in-ruby-with-tsort)

Si vous utilisez Ruby, vous avez probablement eu l'occasion d'expérimenter les
miracles de la gestion de dépendances de [{l-en Bundler}](http://bundler.io/).
Ce que vous ne savez peut-être pas, c'est que vous pouvez utiliser les mêmes
mécanismes de tri de dépendances dans vos propres applications et dans d'autres
contextes.

<!-- more -->

## Hello TSort

[{l-en TSort}](http://www.ruby-doc.org/stdlib-2.0/libdoc/tsort/rdoc/TSort.html)
est un module Ruby, disponible dans la bibliothèque standard, qui permet de
faire du [tri topologique](http://fr.wikipedia.org/wiki/Tri_topologique).
{l-en Bundler} utilise {l-en TSort} pour démêler le sac de nœuds de dépendances
de vos {l-en gems}. La gestion de ces dépendances est la partie émergée de
l'iceberg en ce qui concerne les possibilités du tri topologique. Il est assez
facile de profiter de l'incroyable puissance de {l-en TSort} dans votre projet.

## Use Case : Ajouter des données d'exemple dans un base de données

Imaginons une tâche qui doit peupler une base de données avec plusieurs
enregistrements. Mais rien n'est jamais facile, nos enregistrements ont des
dépendances comme le montre l'exemple ci-dessous :

``` ruby
user_1 = User.create address: address_1

school_1 = School.create address: address_2, faculty: [user_1]
school_2 = School.create address: address_3

address_1 = Address.create zip_code: zip_code_1
address_2 = Address.create zip_code: zip_code_2
address_3 = Address.create zip_code: zip_code_2

zip_code_1 = ZipCode.create
zip_code_2 = ZipCode.create
```

### Le problème

Si on lance le pseudo-code précédent, il va bien sûr lever une exception
`NameError` puisque plusieurs enregistrements en référencent d'autres qui ne
sont pas encore créés.

Pour cet exemple simpliste, il serait facile de trier les lignes à la main, pour
que les insertions aient lieu dans le bon ordre. Mais comment faire quand les
relations dépendantes sont plus complexes ou quand le nombre d'enregistrements
est tout simplement trop important ? Trier à la main n'est simplement pas
envisageable (qui aime faire les choses à la main de toute façon ?).

### La solution

C'est ici que {l-en TSort} entre en scène. Nous pouvons l'utiliser pour
déterminer l'ordre dans lequel ces enregistrements doivent être insérés.

La façon la plus rapide d'utiliser {l-en TSort} est de créer puis trier un
{l-en hash} dans lequel chaque clé représente un objet et chaque valeur est un
tableau de références aux objets dont l'objet-clé dépend.

Si `skier` dépend de `neige` et `neige` dépend de `nuages` et `froid`, notre
{l-en hash} va ressembler à ceci :

``` ruby
{
  'nuages' => [],
  'froid'  => [],
  'skier'  => ['neige'],
  'neige'  => ['nuages', 'froid']
}
```

Nous listons seulement les dépendances de premier niveau, {l-en TSort} se
débrouillera tout seul pour déterminer le reste.

Pour faire un tri topologique sur ce {l-en hash} de dépendances, il nous faut
quelques fonctionnalités de {l-en TSort}. Le plus simple est de créer une classe
qui hérite de {l-en Hash} comme ceci :

``` ruby
require 'tsort'

class TsortableHash < Hash
  include TSort

  alias tsort_each_node each_key

  def tsort_each_child(node, &block)
    fetch(node).each(&block)
  end
end
```

Nous pouvons maintenant utiliser notre classe pour construire le {l-en hash} de
dépendances. Pour nos enregistrements du début, il va ressembler à ceci :

``` ruby
dependency_hash = \
TsortableHash[
  user_1     => [address_1],
  school_1   => [address_2, user_1],
  school_2   => [address_3],
  address_1  => [zip_code_1],
  address_2  => [zip_code_2],
  address_3  => [zip_code_2],
  zip_code_1 => [],
  zip_code_2 => []
]
```

Une fois notre {l-en hash} de dépendances {l-en tsortable} créé, le plus dur
est fait. {l-en TSort} s'occupe du reste et nous donne un tableau ordonné qu'il
nous suffit de suivre pour insérer les enregistrements sans problème.

``` ruby
dependency_hash.tsort
#=> [zip_code_1, address_1, user_1, zip_code_2, address_2, school_1, address_3, school_2]

# Si vous avez des dépendances circulaires, #tsort lèvera une exception TSort::Cyclic.
```

{l-en TSort} est un outil incroyablement puissant et simple pour ordonner des
relations dépendantes. La prochaine fois que vous avez du mal à gérer des
dépendances, rassurez-vous,
[TSort](http://ruby-doc.org/stdlib-2.0.0/libdoc/tsort/rdoc/TSort.html) est
disponible en un clic.
