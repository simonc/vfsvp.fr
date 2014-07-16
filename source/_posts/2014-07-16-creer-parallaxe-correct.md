---
author: Simon Courtois (simonc)
layout: post
title: "Créer un parallaxe correct"
description: Obtenir de bonnes performances avec un parallaxe est difficile. Voici comment s'y prendre.
date: 2014-07-16 20:00
comment: true
categories:
- javascript
---

Source: [Parallax Done Right de Dave Gamache](https://medium.com/@dhg/82ced812e61c)

Obtenir de bonnes performance avec un parallaxe est difficile. Voici comment s'y
prendre.

TL;DR Il existe un certain nombre de solutions faciles pour améliorer les
performances d'un parallaxe aux scroll. Jetez un œil à
[cette démo](http://www.davegamache.com/parallax) que j'ai créée pour voir ce
que ça donne.

<!-- more -->

Le parallaxe est devenu, pour le meilleur ou pour le pire, une tendance de plus
en plus populaire sur le web. Le premier site en parallaxe que j'ai vu est Ian
Coyle’s BetterWorld pour Nike. Je suis tombé amoureux. Je n'avais encore jamais
vu la technique à l'époque et cela m'a donné l'impression de quitter le web
statique quasi-PDF pour faire un pas vers le futur.

Depuis lors, le parallaxe a explosé. Il semble que chaque jour une nouvelle page
marketing utilise cette technique… et pour une bonne raison : correctement
effectué, ça peut avoir un rendu génial. Le problème est qu'une grande majorité
des sites utilisant le parallaxe souffrent de terribles performances au scroll.
Cela se ressent particulièrement sur les appareils avec une haute densité de
pixels comme le MacBook Pro Retina.

J'ai pas mal expérimenté les sites parallaxe et suis arrivé à une liste non
exhaustive de "Faire" et "Ne pas faire" qui vous aideront je l'espère à
rester sur les rails de la performance.

Avant de commencer, je vous encourage à regarder
[la démo](http://www.davegamache.com/parallax) si vous ne l'avez pas déjà fait.

## Quelques "Faire"

**Utilisez uniquement des propriétés dont l'animation est peu coûteuse pour le
navigateur.** À peu de choses près, la liste est : _translate3d_, _scale_,
_rotation_ et _opacity_. Si vous utilisez autre chose il sera probablement
difficile d'atteindre 60fps (frames per second).

``` javascript
$(animation.selector)
  .css({ 'transform': 'translate3d(' + translateX +'px, ' +   translateY + 'px, 0) scale('+ scale +')',
 'opacity' : opacity
})
```

**Utilisez window.requestAnimationFrame** lorsque vous lancez l'animation en
JS. Cela indique au navigateur d'animer les éléments avant le prochain
_repaint_ (calcul d'affichage des éléments). Préférez cela à l'ajustement
direct des propriétés.

``` javascript
window.requestAnimationFrame(animateElements);
```

**Arrondissez les valeurs.** Si vous déplacez un object de 100px pendant que
l'utilisateur scroll 200px (ce qui déplace l'objet à 50% de la vitesse normale),
ne le laissez pas prendre une valeur comme `54.2356345234578px`, arrondissez
cela au pixel le plus proche. Vous travaillez sur l'opacité ? Deux décimales
suffiront.

``` javascript
animationValue = +animationValue.toFixed(2)
```

**N'animez que les éléments dans le _viewport_**. Continuer de passer des
milliers de valeurs à des éléments non affichés durant le scroll n'a pas de sens
et peut rapidement être coûteux.

    Tous les exemples de code que j'ai essayé pour illustré ce point m'ont semblé
    artificiels. Le simple sera de regarder le code de la démo pour comprendre
    comment le faire.

**N'animez que les éléments en position absolute ou fixed.** Je ne suis pas 100%
sûr du pourquoi mais j'ai constaté un important gain de performance en animant
uniquement les éléments fixed/absolute. Dès que j'applique une animation à un
élément relative/static, les fps souffrent.

``` javascript
.parallaxing-element {
  position: fixed;
}
```

**Utilisez le scroll naturel de `<body>`**. Certains navigateurs, Safari en
particulier, subissent une réelle chute de performance lorsque l'on scroll un
autre élément que _body_. Honnêtement, je ne vois pas de bonne raison de le
faire. Même quand tous les éléments de la page sont en position _fixed_ et
qu'il n'y a donc pas de réelle hauteur de scroll, utilisez simplement JS pour
donner une hauteur correcte au body pour obtenir la hauteur de scroll dont vous
avez besoin pour effectuer votre parallaxe.

**Définissez toutes vos animations dans un objet** et non sous forme de code
spaghetti. Cela n'a pratiquement rien à voir avec les performances mais rend
les choses bien plus faciles.

``` javascript
keyframes = [
  {
    'duration' : '150%',
    'animations' : [
      {
        'selector' : '.parallaxing-element',
        'translateY' : -120,
        'opacity' : 0
      } , {
        'selector' : '.another-element',
        'translateY' : -100,
        'opacity' : 0
      }
    ]
  }
]
```

## Quelques "Ne pas faire"

**Évitez background-size:cover** à moins de vous être assuré que ça n'affecte
pas les performances. En général, ça passe tant que vous n'animez pas cet
élément mais si vous essayez par exemple de le translater, cela risque de poser
de sérieux problèmes. Si vous avez réellement besoin de faire du parallaxe avec
un élément à fond dynamique, essayez d'autres techniques.

**Ne vous attachez pas directement à l'événement scroll.** Utilisez un
intervalle pour mettre à jour la position des éléments. L'événement scroll est
appelé un nombre incroyable de fois par seconde et peut causer de sérieux
problèmes de performances. Préférez mettre à jour les positions des éléments
toutes les 10 ms ou quelque chose comme ça.

``` javascript
scrollIntervalID = setInterval(animateStuff, 10);
```

**N'animez pas de grosses images ou redimensionnez-les considérablement.**
Forcer le navigateur à redimensionner des images (surtout les grandes) peut être
très coûteux. Cela ne veux pas dire qu'utiliser _scale_ sur une image est mal -
d'après mon expérience ça fonctionne même plutôt bien - mais redimensionner une
image de 4000px à 500px n'a pas de sens et coûte juste cher.

**Évitez d'animer 100 choses en même temps** si vous constatez des chutes de
performance. Honnêtement, je n'ai jamais rencontré de problème en animant
beaucoup d'éléments (même en animant 15 choses en même temps), mais je vous
assure que cela peut arriver. J'ai également vu des soucis apparaitre lorsqu'un
élément parent et ses enfants sont animés en simultanément.

## Point rapide sur la démo

Quelle différence peuvent faire ces quelques règles ? Une énorme différence. En
ignorer ne serait-ce qu'une ou deux peut faire l'écart en du beurre et plus de
saccades qu'un film de Bruce Lee.

Notez cependant ceci, la démo :

* **est légèrement superficielle** et simple
* **est loin d'être parfaite** en termes d'organisation et de nombre de
  fonctionnalités
* **ignore complètement** la gestion des mobiles
* **peut planter** si vous scrollez comme un(e) malade parce que je n'ai pas
  implémenté de garde-fous (ce qui ne serait pas très dur cela-dit)
* **n'a pas été vraiment testée** sur différentes machines parce que je voyage
  et que je n'ai que mon MacBook Pro et le MacBook Air de ma copine. _Update:_
  quelqu'un sur internet m'a signalé que sur les machines Windows ça pouvait
  saccader, je corrige ça dès que je rentre de voyage, promis !
* est juste une démo à but éducatif, soyez sympas :)

Si vous voulez voir comment le code fonctionne, inspectez la page le code JS ou
[regardez le code sur Github](https://github.com/dhg/davegamache/tree/master/parallax).

Mieux encore, regardez le site marketing de Dropbox pour
[Carousel](http://www.carousel.com/). Ils ont suivi à peu près toutes ces
règles et ont gracieusement laissé
[leur code JS lisible](https://www.carousel.com/static/coffee/compiled/photos/carousel-static-site/index.js)
(il est assez simple à lire). La couche de vernis appliquée est assez
incroyable. Le site a une version mobile et ils ont même poussé jusqu'à adoucir
leur implémentation du scroll ce qui donne un effet presque liquide (pas
nécessaire pour atteindre 60 fps mais une touche intéressante et appréciable).
À noter également que certaines des règles ci-dessus me sont venues à la lecture
de leur code - un grand bravo à
[@destroytoday](https://twitter.com/destroytoday) qui l'a implémenté !

## Dernières notes

Voici quelques astuces supplémentaires qui vous intéresseront si vous souhaitez
vous lancer dans le développement de parallaxe.

* Jetez un oeil à l'article de Krister Kari sur
  [les performances avec parallaxe](http://kristerkari.github.io/adventures-in-webkit-land/blog/2013/08/30/fixing-a-parallax-scrolling-website-to-run-in-60-fps/).
  Il développe en profondeur certaines règles énoncées précédemment ;
* Utilisez l'Inspecteur Chrome et allez dans Timeline > Frames pour enregistrer
  les FPS de quelques actions ou visitez about:flags dans Chrome et activez le
  compteur de FPS (je préfère cependant la version de l'Inspecteur qui peut
  dépasser 60 fps) ;
* C'est une simple touche de design mais adoucir les valeurs plutôt que de
  sortir directement les valeurs linéaires apporte beauuuuucoup au succès d'un
  parallaxe. Regardez la fonction `easeInOutQuad`
  [du JS](https://github.com/dhg/davegamache/blob/master/parallax/js/picasso.js)
  si cela vous intéresse ;
* Attention, il s'agit d'une technique de parallaxe. Une autre technique
  performante (potentiellement plus performante) est l'utilisation des canvas.
  Je fuis cependant cette technique pour éviter la complexité qu'elle apporte.
  Cela dit, c'est une solution tout à fait viable. Cette technique est utilisée
  par exemple par [Medium](https://medium.com/@dhg/82ced812e61c) ;
* Souvenez-vous que tous les navigateurs/appareils ne seront pas capables de
  gérer le parallaxe. Pensez aux solutions de repli pour les appareils tactiles,
  les petits écrans ou encore les vieux navigateurs. Encore une fois, j'ai
  ignoré cet aspect dans la démo ;
* Enfin, bien que je sois fan de parallaxe, je vous encourage à vous demandez si
  cela a du sens pour votre site, s'il a une valeur ajoutée ou s'il est juste
  "cool". Ces deux raisons sont bonnes mais gardez toutefois en tête que le
  parallaxe ajoute une complexité à votre code.

Bien ! C'est tout ce que j'ai à vous dire. Si vous avez des questions, idées ou
corrections, je serais heureux d'en discuter. Venez me voir sur Twitter @dhg ou
laissez juste un commentaire sur [Medium](https://medium.com/@dhg/82ced812e61c).
