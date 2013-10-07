---
author: Simon Courtois (simonc)
layout: post
title: Les méthodes pack et unpack en Ruby
date: 2013-10-07 10:00
comments: true
categories:
- rails
- ruby
---

Source: [Ruby Pack Unpack de Neeraj Singh sur le blog de BigBinary](http://blog.bigbinary.com/2011/07/20/ruby-pack-unpack.html)

Le langage C permet aux développeurs d'accéder directement à la mémoire où sont
stockées les variables. Ruby ne le permet pas. Il est cependant des cas dans
lesquels on peut avoir besoin d'accéder aux bits et octets contenus dans cette
mémoire tout en travaillant avec Ruby. Ce dernier fournit deux méthods `pack` et
`unpack` pour cela.

Voici un exemple :

``` ruby
'A'.unpack('b*')
#=> ["10000010"]
```

<!-- more -->

Dans le cas ci-dessus, `'A'` est une chaîne de caractères stockée et, grâce à
`unpack` je tente d'en lire la valeur binaire. La table ASCII indique que la
valeur de `'A'` est 65 et la représentation binaire de 65 est `10000010`.

Un autre exemple :

``` ruby
'A'.unpack('B*')
#=> ["01000001"]
```

Notez bien le changement de résultat entre les deux exemples. Quelle est la
différence entre `b*` et `B*` ? Pour le comprendre nous devons d'abord parler
de _MSB_ et _LSB_.

## Bit de poids fort et bit de poids faible

Tous les bits ne sont pas créés égaux. `'C'` a la valeur ASCII 67. La
représentation binaire de 67 est `1000011`.

Parlons d'abord du style _MSB_ (most significant bit, bit de poids fort). Si
vous utilisez le style _MSB_, et lisez donc de gauche à droite (en lisant tout
le temps de gauche à droite), le bit de poids le plus fort est donc le premier.
Puisque le bit de poids le plus fort vient en premier, nous pouvons ajouter un
`0` devant pour obtenir huit bits. Après avoir ajouté un `0` la représentation
binaire est donc `01000011`.

Pour convertir cette valeur en _LSB_ (least significant bit, bit de poids
faible), nous devons stocker le bit de poids faible en premier (à gauche). Nous
pouvons voir ci-dessous comment les bits vont être déplacés lors de la
convertion de _MSB_ vers _LSB_. Notez qu'ici la position 1 indique le bit le
plus à gauche.

* déplacer la valeur 1 de la position _MSB_ 8 à la position _LSB_ 1
* déplacer la valeur 1 de la position _MSB_ 7 à la position _LSB_ 2
* déplacer la valeur 0 de la position _MSB_ 6 à la position _LSB_ 3
* et ainsi de suite

Une fois l'exercice terminé, la valeur sera `11000010`.

Nous avons effectué cette transformation à la main pour bien comprendre la
différence entre bit de poids fort et bit de poids faible. La méthode `unpack`
est cependant capable de donner les deux représentations. Cette méthode peut
prendre `b*` ou `B*` en entrée, voici leur différence selon la documentation de
Ruby :

    B | bit string (MSB first) | représentation binaire (bit de poids fort en premier)
    b | bit string (LSB first) | représentation binaire (bit de poids faible en

Voyons maintenant deux exemples.

``` ruby
'C'.unpack('b*')
#=> ["11000010"]

'C'.unpack('B*')
#=> ["01000011"]
```

`b*` et `B*` voient tous les deux là même donnée. Ils représentent simplement
cette donnée différemment.

## Différentes façons de représenter une même donnée

Disons que je souhaite la représentation binaire de la chaîne `hello`. D'après
ce que nous avons vu précédemment cela devrait être assez facile :

``` ruby
"hello".unpack('B*')
#=> ["0110100001100101011011000110110001101111"]
```

Nous pouvons également obtenir le résultat suivant

``` ruby
"hello".unpack('C*').map {|e| e.to_s 2}
#=> ["1101000", "1100101", "1101100", "1101100", "1101111"]
```

Voyons un exemple similaire mais en découpant les étapes cette fois.

``` ruby
"hello".unpack('C*')
#=> [104, 101, 108, 108, 111]
```

La directive `C*` retourne les caractères sous la forme d'un entier non signé
tenant sur 8 bits. On peut voir que la valeur ASCII de `h` est 104 et celle de
`e` est 101, etc.

En utilisant la technique vu précédemment, nous pouvons obtenir une
représentation hexadécimale de notre chaîne :

``` ruby
"hello".unpack('C*').map {|e| e.to_s 16}
#=> ["68", "65", "6c", "6c", "6f"]
```

Il est toutefois possible d'obtenir directement cette valeur hexadécimale :

``` ruby
"hello".unpack('H*')
#=> ["68656c6c6f"]
```

## High nibble first vs Low nibble first

Observez la différence entre les deux cas suivants :

``` ruby
"hello".unpack('H*')
#=> ["68656c6c6f"]

"hello".unpack('h*')
#=> ["8656c6c6f6"]
```

La documentation Ruby indique

    H | hex string (high nibble first) | représentation hexadécimale (moitié haute en premier)
    h | hex string (low nibble first)  | représentation hexadécimale (moitié basse en premier)

Un octet est composé de 8 bits. Une moitié contient donc 4 bits. Un octet
donc deux moitiés. La valeur ASCII de `h` est 104. 104 en hexadécimale s'écrit
68. Ce nombre 68 est stocké en deux moitiés. La première contient la valeur 6
sur 4 bits et la seconde contient la valeur 8. En général on utilise la notation
moitié haute puis moitié basse, de gauche à droite, la valeur 6 pour la
valeur 8.

Si cependant vous devez utiliser la notation moitié basse puis moitié haute, la
valeur 8 prendra la première place suivie de la valeur 6. La notation _moitié
basse en premier_ donne donc 86.

Cette notation est utilisée pour chaque octet. Pour cette raison, la version
_moitié basse en premier_ de `68 65 6c 6c 6f` est `86 56 c6 c6 f6`.

## Mélanger les directives

Dans les exemples précédents, nous avons utilisé le caractère `*`. Cela indique
de traiter autant de caractères que possible. Par exemple :

A single C will get a single byte.

``` ruby
"hello".unpack('C')
#=> [104]
```

Vous pouvez ajouter plus de `C` si vous le souhaitez.

``` ruby
"hello".unpack('CC')
#=> [104, 101]

"hello".unpack('CCC')
#=> [104, 101, 108]

"hello".unpack('CCCCC')
#=> [104, 101, 108, 108, 111]
```

Plutôt que de répéter ces directives, nous pouvons utiliser un nombre pour
indiquer combien de fois la directive doit être répétée.

``` ruby
"hello".unpack('C5')
#=> [104, 101, 108, 108, 111]
```

Nous pouvons utiliser `*` pour capturer toutes les octets restants.

``` ruby
"hello".unpack('C*')
#=> [104, 101, 108, 108, 111]
```

Voyons un exemple dans lequel nous mélangeons les notations _MSB_ et _LSB_ :

``` ruby
"aa".unpack('b8B8')
#=> ["10000110", "01100001"]
```

## pack est l'inverse de unpack

La méthode `pack` est utilisée pour lire les données stockées. Voyons quelques
exemples d'utilisation :

``` ruby
[1000001].pack('C')
#=> "A"
```

Dans le code ci-dessus, le valeur binaire est interpretée comme un entier non
signé sur 8 bits et le résultat est `'A'`.

``` ruby
['A'].pack('H')
#=> "\xA0"
```

Ici, l'entrée `'A'` n'est pas le `A` ASCII mais le `A` hexadécimale. C'est
la version hexadécimale à cause de la directive `H`. Cette dernière indique à
`pack` de traiter l'entrée comme une valeur hexadécimale. Comme `H` utilise la
notation _moitié haute en premier_, puisque l'entrée ne contient qu'une moitié,
cela signifie que la deuxième moitié, la moitié basse, a la valeur `0`. L'entrée
est donc vue comme `'A0'`.

Comme la valeur hexadécimale `A0` ne correspond à rien dans la table ASCII, le
résultat final est laissé tel quel et vaut donc `'\xA0'`. Le préfix `\x` indique
qu'il s'agit d'une valeur hexadécimale.

En hexadécimale, `a` a la même valeur que `A`. Nous pouvons donc remplacer `A`
par `a` dans notre exemple précédent et le résultat reste inchangé. Essayons
pour voir :

``` ruby
['a'].pack('H')
#=> "\xA0"
```

Un autre exemple :

``` ruby
['a'].pack('h')
#=> "\n"
```

Dans le code ci-dessus, il y a une différence notable dans le résultat. Nous
avons changé la directive de `H` à `h`. Comme `h` indique d'utiliser la notation
_moitié basse en premier_ et que l'entrée ne contient qu'une moitié, la moitié
basse vaut `0` et l'entrée est donc `0a`. Le résultat est `\x0A` et si l'on
regarde dans la table ASCII, `0A` vaut 10 et le caractère correspondant est
`NL`, _new line_ soit un saut de ligne. C'est pour cela que nous voyons
s'afficher `\n` qui représente un saut de ligne.

## Utilisation de unpack dans le code de Rails

J'ai cherché un peu dans le code source de Rails et trouvé les utilisations
suivantes de la méthode `unpack` :

``` ruby
email_address_obfuscated.unpack('C*')
'mailto:'.unpack('C*')
email_address.unpack('C*')
char.unpack('H2')
column.class.string_to_binary(value).unpack("H*")
data.unpack("m")
s.unpack("U*")
```

Nous avons déjà vu les directives `C*` et `H`, les directives `m` et `U` sont
cependant nouvelles. La première sert à donner une représentation encodée en
base64 de la valeur, la seconde retourne le caractère UTF-8 correspondant. Voici
un exemple :

``` ruby
"Hello".unpack('U*')
#=> [72, 101, 108, 108, 111]
```

## Versions de test

Les exmples de code précédents ont été testés avec la version _1.9.2_ de Ruby.

NDT: J'ai testé avec les versions 1.9.3 et 2.0.0, les exemples sont toujours
valides.
