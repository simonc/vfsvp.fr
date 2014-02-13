---
author: Simon Courtois (simonc)
layout: post
title: "Une introduction en profondeur à Ember.js"
date: 2014-01-16 12:00
comment: true
categories:
- ember
- javascript
---

Source:
[An In-Depth Introduction To Ember.js de Julien Knebel pour Smashing][ORIGINAL]

Maintenant que {l-en Ember.js 1.0} est sorti, il est temps d'y jeter un coup
d'oeil. Cet article s'adresse aux débutants qui souhaitent comprendre ce
{l-en framework}.

<!-- more -->

{% raw %}
Il est fréquent d'entendre les utilisateurs dire que la courbe d'apprentissage
est raide mais qu'une fois les difficultés surmontées, {l-en Ember.js} est
tout simplement phénoménal. Ça a été également le cas pour moi. Bien que les
[guides officiels][GUIDES] soient extrêment précis et parfaitement à jour
(vraiment !), cet article a pour but de rendre les choses encore plus aisées
pour les débutants.

Tout d'abord, nous allons éclaircir les principaux concepts du
{l-en framework}. Nous verrons ensuite, étape par étape, comment construire
une application avec {l-en Ember.js} et {l-en Ember-Data}, la couche de
stockage de données d'{l-en Ember}. Nous verrons ensuite comment les `views` et
les `components` aident à gérer les interactions utilisateurs.

![Une introduction en profondeur à Ember.js](/images/ember/emberjs-logo.png)<br />
La fameuse mascotte d'{l-en Ember}, {l-en Tomster}.
([Crédits](http://emberjs.com/))

La **démo non stylisée** ci-dessous, vous aidera à suivre chaque étape de ce
tutoriel. La **démo stylisée** est essentiellement la même mais avec bien plus
de CSS, d'animations et de réactivité sur petits écrans.

[Démo non stylisée][UNSTYLED_DEMO]
[Code source](https://github.com/jkneb/ember-crud)
[Démo stylisée][STYLED_DEMO]

## Sommaire

{{TOC}}

## Principaux concepts

Le schéma ci-dessous montre comment les routes, les contrôleurs, les vues, les
{l-en templates} et les modèles interagissent les uns avec les autres.

![ember-sketch](/images/ember/ember-sketch.png)

Voici une description de chacun des concepts. Pour en apprendre plus,
référez-vous à la section correspondante dans les guides officiels :

* [Modèles][GUIDES_MODELS]
* [Le Routeur](http://emberjs.com/guides/routing)
* [Contrôleurs][GUIDES_CONTROLLERS]
* [Vues](http://emberjs.com/guides/views)
* [Composants](http://emberjs.com/guides/components/)
* [Templates](http://emberjs.com/guides/templates/handlebars-basics)
* [Helpers](http://emberjs.com/guides/templates/writing-helpers)

### Modèles

Mettons que notre application gère une liste d'utilisateurs. Ces utilisateurs
et leurs informations seraient le modèle. Vous pouvez voir cela comme les
données stockées en base de données. Les modèles peuvent être récupérés et mis à
jour en implémentant des {l-en callbacks} AJAX dans vos routes ou vous pouvez
utiliser {l-en Ember-Data} (une couche d'abstraction de stockage de donnés)
pour simplifier la récupération, la mise à jour et la persistence des modèles
au travers d'une API REST.

### Le Routeur

Il y a le `Router` et, ensuite, les routes. Le `Router` est juste un synopsis de
toutes vos routes. Les routes sont la version URL des objects de votre
application (par exemple, une route `posts` correspond à un {l-en listing}
d'utilisateurs). Le but des routes est d'appeler le modèle, via leur
{l-en hook} `model`, pour qu'il soit accessible dans les contrôleurs et
{l-en templates}. Les routes peuvent également servir à valuer les propriétés
d'un contrôleur, à exécuter des événements ou des actions, ou encore connecter
un {l-en template} à un contrôleur spécifique. De plus, le {l-en hook}
`model` peut retourner une {l-en promise} ce qui permet d'implémenter une
`LoadingRoute` qui attend que le modèle soit récupéré de façon asynchrone.

### Contrôleurs

Un `controller` commence par récupérer le modèle d'une `route`. Il fait ensuite
le pont entre le modèle et la vue ou le {l-en template}. Mettons que vous ayez
besoin d'une fonction pour alterner entre le mode édition et le mode normal. Des
méthodes comme `goIntoEditMode()` et `closeEditMode()` seraient parfaites et
c'est exactement ce à quoi servent les contrôleurs.

{l-en Ember.js} génère automatiquement les contrôleurs si vous ne les
déclarez pas. Vous pouvez par exemple créer un {l-en template} `user` et
une `UserRoute` sans créer de `UserController` (parce que vous n'en avez pas
besoin), {l-en Ember.js} le créera pour vous en interne (en mémoire).
L'extension Chrome appelée [Ember Inspector][EMBER_INSPECTOR] peut vous aider à
trouver ces contrôleurs magiques.

### Vues

Les vues représentent les différentes parties de votre application (les parties
visibles par l'utilisateur dans le navigateur). Une `View` est associée à un
`Controller`, un `template` {l-en Handlebars} et une `Route`. La différence
entre vue et {l-en template} est particulière. Vous utiliserez une vue lorsque
vous voudrez gérer des événements ou des interactions utilisateurs qui ne
peuvent pas être pris en charge par un simple {l-en template}. Elle ont un
{l-en hook} bien pratique appelé `didInsertElement` au travers duquel vous
pouvez appeler jQuery très facilement et sont également très utiles pour créer
des vues réutilisables comme une {l-en modal}, une {l-en popover}, un
{l-en date-picker} ou encore un champ auto-complété.

### Components

Un `Component` est une `View` complètement isolée, qui n'a pas accès au context
dans lequel il est appelé. C'est un excellent moyen de créer un composant
réutilisable pour votre application. Ce [Button Twitter][TWITTER_BTN], ce
[select personnalisé][CUSTOM_SELECT] ou encore ces
[graphiques réutilisables](http://jsbin.com/odosoy/132/edit?html,js,output)
sont de très bons exemples de composants. Ce sont en fait de si bonnes idées que
le W3C travaille actuellement avec l'équipe {l-en Ember} sur la
[spécification d'éléments personnalisés][WEB_COMPONENTS].

### Templates

Pour faire simple, un {l-en template} est la partie HTML d'une vue. Il permet
d'afficher les données du modèle et se met automatiquement à jour lorsque ce
dernier change. {l-en Ember.js} utilise [Handlebars][HANDLEBARS], un mécanisme
léger de {l-en templating} également maintenu par l'équipe {l-en Ember}. Il
fournit les outils logiques habituels comme `if` et `else`, les boucles et les
`helpers` de formatage, ce genre de choses. Les {l-en templates} peuvent être
précompilés (si vous souhaitez les organiser en fichiers `.hbs` ou `.handlebars`
séparés) ou tout simplement écrits dans une balise
`<script type="text/x-handlebars"></script>` dans votre page HTML. Pour en
savoir plus sur le sujet, vous pouvez vous reporter à la section
[Précompiler ou non les {l-en templates}](#precompiler-ou-non-les-templates).

### Helpers

Les {l-en helpers} {l-en Handlebars} sont des fonctions qui modifient les
données avant leur affichage (par exemple, pour donner un meilleur format que
`Mon Jul 29 2013 13:37:39 GMT+0200 (CEST)` à une date). Si votre date est écrite
sous la forme `{{date}}` dans votre {l-en template} et que vous avez un
{l-en helper} `formatDate` (qui converti une date en quelque chose de plus
élégant, comme "Il y a un mois" ou "29 juillet 2013"), vous pouvez vous en
servir en utilisant `{{formatDate date}}`.

### Composants ? Helpers ? Vues ? Au secours !

Le forum {l-en Ember.js} a [une réponse][EMBER_FORUM], tout comme
[StackOverflow][STACKOVERFLOW], qui peuvent vous éviter les maux de crâne.

## Créons une application

Dans cette section, nous allons créer une véritable application, une simple
interface de gestion d'utilisateurs (une application de
[CRUD](http://en.wikipedia.org/wiki/Create,_read,_update_and_delete)). Voici ce
que nous allons faire :

* un tour de l'architecture que nous souhaitons mettre en place ;
* voir les dépendances, la structure de fichiers, etc ;
* mettre en place le modèle avec le `FixtureAdapter` d'{l-en Ember-Data} ;
* voir comment les routes, contrôleurs, vues et {l-en templates} interagissent ;
* et enfin, remplacer `FixtureAdapter` par `LSAdapter` pour stocker les données
  dans le {l-en local storage} du navigateur.

### Schéma de notre application

Nous avons besoin d'une vue assez simple qui affiche un groupe d'utilisateurs
(voir 1 ci-dessous). Il nous faut également une vue pour voir les informations
d'un utilisateur spécifique (2). Nous devons être capables de modifier et
supprimer ces informations (3). Nous devons enfin être à même de créer un nouvel
utilisateur, pour ce faire nous réutiliserons le formulaire de modification.

![app-sketch](/images/ember/app-sketch.png)

{l-en Ember.js} utilise beaucoup les conventions de nommage. Si vous voulez
avoir la page `/foo` dans votre application, vous aurez ce qui suit :

* un {l-en template} `foo` ;
* une route `FooRoute` ;
* un contrôleur `FooController` ;
* une vue `FooView`.

Pour en savoir plus, référez-vous à la section
[Naming conventions](http://emberjs.com/guides/concepts/naming-conventions)
dans les guides.

### Ce qu'il vous faut pour bien commencer

Vous aurez besoin de :

* jQuery ;
* {l-en Ember.js}, bien sûr ;
* {l-en Handlebars} le moteur de {l-en template} d'{l-en Ember} ;
* {l-en Ember-Data}, la couche d'abstraction de stockage d'{l-en Ember}.

``` html
/* /index.html
*/
 …
 <script src="//code.jquery.com/jquery-2.0.3.min.js"></script>
 <script src="//builds.emberjs.com/handlebars-1.0.0.js"></script>
 <script src="//builds.emberjs.com/tags/v1.1.2/ember.js"></script>
 <script src="//builds.emberjs.com/tags/v1.0.0-beta.3/ember-data.js"></script>
 <script>
   // votre code
 </script>
</body>
</html>
```

Le site d'{l-en Ember} a un section [Builds][EMBER_BUILDS] dans laquelle vous
pouvez trouver tous les liens vers {l-en Ember.js} et {l-en Ember-Data}. Pour
le moment, {l-en Handlebars} n'est pas présent sur la page, vous le trouverez
sur le [site officiel de Handlebars][HANDLEBARS].

Une fois les dépendances récupérées, nous pouvons commencer à créer notre
application. Nous allons tout d'abord créer un fichier nommé `app.js` dans
lequel nous allons initialiser {l-en Ember} :

``` javascript
/* /app.js
*/
window.App = Ember.Application.create();
```

Juste pour vérifier que tout fonctionne, vous devriez voir les {l-en logs} de
{l-en debug} dans la console du navigateur.

![console-log-1](/images/ember/console-log-1.png)

### Organisation de nos fichiers

Il n'y a pas vraiment de convention en ce qui concerne l'organisation des
fichiers et dossiers.
L'[App Kit Ember](https://github.com/stefanpenner/ember-app-kit) (un
environnement de démarrage d'application {l-en Ember} basé sur {l-en Grunt})
propose une sorte de standard puisqu'il est maintenu par l'équipe {l-en Ember}.
Pour faire encore plus simple, vous pourriez tout mettre dans le fichier
`app.js`. C'est à vous de voir.

Pour ce tutoriel, nous mettrons les contrôleurs dans un dossier `controllers`,
nos vues dans un dossier `views` et ainsi de suite.

    components/
    controllers/
    helpers/
    models/
    routes/
    templates/
    views/
    app.js
    router.js
    store.js

### Précompiler ou non les {l-en templates} ?

Il y a deux façons de déclarer les {l-en templates}. La plus simple est
d'ajouter une balise `script` spéciale dans votre fichier `index.html`.

``` html
<script type="text/x-handlebars" id="templatename">
  <div>Je suis un template</div>
</script>
```

Pour chaque {l-en template}, il vous faut une balise `script`. C'est simple et
rapide mais ça peut très vite devenir un gros désordre si vous avez beaucoup de
{l-en templates}.

L'alternative est de créer un fichier `.hbs` (ou `.handlebars`) pour chaque
{l-en template}. C'est ce qu'on appelle la "précompilation de {l-en templates}"
et une
[section entière](#quest-ce-que-la-precompilation-de-templates-handlebars) de
cet article y est dédiée.

Notre [démo non stylisée][UNSTYLED_DEMO] utilise
des balises `<script type="text/x-handlebars">` et tous les {l-en templates} de
notre [démo améliorée][STYLED_DEMO] sont stockés dans des fichiers `.hbs` qui
sont précompilés par une tâche [Grunt][GRUNT]. Vous pouvez ainsi
comparer les deux techniques.

### Créer notre modèle avec le {l-en FixtureAdapter} de {l-en Ember-Data}

{l-en Ember-Data} est une bibliothèque qui permet de récupérer les données
stockées sur le serveur, de les retenir dans un `Store`, de les mettre à jour
dans le navigateur et enfin des les renvoyer au serveur pour sauvegarde. Le
`Store` peut être configuré avec différents {l-en adapters} (par exemple, le
`RESTAdapter` qui interagit avec une API JSON ou le `LSAdapter` qui stocke les
données dans le {l-en local storage} du navigateur).
Une [section entière](#quest-ce-quember-data) de cet article est dédiée à
{l-en Ember-Data}.

Nous allons utiliser `FixtureAdapter`. Nous commençons donc par l'instancier :

``` javascript
/* /store.js
*/
App.ApplicationAdapter = DS.FixtureAdapter;
```

Dans les versions précédentes d'{l-en Ember}, il fallait hériter de `DS.Store`.
Ce n'est plus nécessaire pour instancier les {l-en adapters}.

`FixtureAdapter` est un très bon moyen de démarrer avec {l-en Ember.js} et
{l-en Ember-Data}. Il vous permet de travailler avec des données en
développement. Nous passerons au
[LocalStorage adapter][LSAdapterGihub]
(ou `LSAdapter`) en fin de parcours.

Commençons par définir notre modèle. Un utilisateur aura un nom `name`, une
adresse `email`, une courte `bio`, un avatar `avatarUrl` et une date de création
`creationDate`.

``` javascript
/* /models/user.js
*/
App.User = DS.Model.extend({
  name         : DS.attr(),
  email        : DS.attr(),
  bio          : DS.attr(),
  avatarUrl    : DS.attr(),
  creationDate : DS.attr()
});
```

Ajoutons ensuite quelques données d'exemple dans notre `Store`. Vous pouvez
ajouter autant d'utilisateurs que vous le souhaitez :

``` javascript
/* /models/user.js
*/
App.User.FIXTURES = [{
  id: 1,
  name: 'Sponge Bob',
  email: 'bob@sponge.com',
  bio: 'Lorem ispum dolor sit amet in voluptate fugiat nulla pariatur.',
  avatarUrl: 'http://jkneb.github.io/ember-crud/assets/images/avatars/sb.jpg',
  creationDate: 'Mon, 26 Aug 2013 20:23:43 GMT'
}, {
  id: 2,
  name: 'John David',
  email: 'john@david.com',
  bio: 'Lorem ispum dolor sit amet in voluptate fugiat nulla pariatur.',
  avatarUrl: 'http://jkneb.github.io/ember-crud/assets/images/avatars/jk.jpg',
  creationDate: 'Fri, 07 Aug 2013 10:10:10 GMT'
}
…
];
```

Pour en savoir plus sur les modèles, consultez
[la documentation][GUIDES_MODELS].

### Instancier le Router

Définissons notre `Router` avec les routes dont nous avons besoin (basées sur le
[diagramme vu précédemment](#schema-de-notre-application)).

``` javascript
/* /router.js
*/
App.Router.map(function(){
  this.resource('users', function(){
    this.resource('user', { path:'/:user_id' }, function(){
      this.route('edit');
    });
    this.route('create');
  });
});
```

Le `Router` va générer les routes suivantes :

URL                  | Route Name   | Controller            | Route            | Template
---------------------|--------------|-----------------------|------------------|------------
N/A                  | N/A          | ApplicationController | ApplicationRoute | application
/                    | index        | IndexController       | IndexRoute       | index
N/A                  | users        | UsersController       | UsersRoute       | users
/users               | users.index  | UsersIndexController  | UsersIndexRoute  | users/index
N/A                  | user         | UserController        | UserRoute        | user
/users/:user_id      | user.index   | UserIndexController   | UserIndexRoute   | user/index
/users/:user_id/edit | user.edit    | UserEditController    | UserEditRoute    | user/edit
/users/create        | users.create | UsersCreateController | UsersCreateRoute | users/create

La partie `:user_id` est appelée segment dynamique. L'{l-en ID} de l'utilisateur
sera injecté dans l'URL à cet emplacement. Cela aura donc la forme
`/users/3/edit`, `3` représentant l'utilisateur d'{l-en ID} 3.

Vous pouvez définir soit une `route`, soit une `resource`. Une `resource` est un
groupe de routes et permet d'imbriquer d'autres routes.

Une `resource` réinitialise également la convention de nommage de la ressource
précédente. Cela signifie qu'au lieu d'avoir `UsersUserEditRoute`, nous aurons
`UserEditRoute`. En d'autres termes, si vous avez une ressource imbriquée dans
une autre ressource, les noms de nos fichiers seraient :

* `UserEditRoute` au lieu de `UsersUserEditRoute` ;
* `UserEditControler` au lieu de `UsersUserEditController` ;
* `UserEditView` au lieu de `UsersUserEditView` ;
* pour les {l-en templates}, `user/edit` au lieu de `users/user/edit`.

Vous pouvez en [apprendre plus sur les routes][ROUTES_GUIDES] dans les guides.

### Le {l-en template} de l'application

Chaque application {l-en Ember.js} nécéssite un {l-en template} `Application`
contenant une balise `{{outlet}}` qui permet de contenir tous les autres
{l-en templates}.

``` html
/* /templates/application.hbs
*/
<div class="main">
  <h1>Hello World</h1>
  {{outlet}}
</div>
```

Si vous suivez ce tutorial sans précompiler vos {l-en templates}, voici ce à
quoi devrait ressembler votre `index.html` :

``` html
/* /index.html
*/
  …
  <script type="text/x-handlebars" id="application">
    <div class="main">
      <h1>Hello World</h1>
      {{outlet}}
    </div>
  </script>

  <script src="dependencies.js"></script>
  <script src="your-app.js"></script>
</body>
</html>
```

### La route {l-en users}

Cette route est liée à notre liste d'utilisateurs. Comme nous l'avons vu
[précédemment](#le-routeur) dans les définitions, une route est chargée
d'appeler le modèle. Les routes ont un {l-en hook} `model` au travers duquel
nous pouvons effectuer une requête AJAX (pour récupérer les données lorsque
l'on n'utilise pas {l-en Ember-Data}) ou faire appel au `Store` (si l'on utilise
{l-en Ember-Data}). Si vous souhaitez savoir comment récupérer les données sans
{l-en Ember-Data}, vous pouvez consulter la [section](#sans-utiliser-ember-data)
dans laquelle j'explique brièvement comment le faire.

Créons maintenant notre `UsersRoute` :

``` javascript
/* /routes/usersRoute.js
*/
App.UsersRoute = Ember.Route.extend({
  model: function(){
    return this.store.find('user');
  }
});
```

Vous pouvez en savoir plus sur
[comment utiliser le {l-en hook} `model` des routes][ROUTE_MODEL] dans les
guides.

Si vous visitez votre application à l'URL `http://localhost/#/users`, rien ne se
produit, nous avons d'abord besoin du {l-en template} `users`. Le voici :

``` html
/* /templates/users.hbs
*/
<ul class="users-listing">
  {{#each user in controller}}
    <li>{{user.name}}</li>
  {{else}}
    <li>pas d'utilisateurs… :-(</li>
  {{/each}}
</ul>
```

La boucle `each` parcourt la collection d'utilisateurs, `controller` vaut ici
`UsersController`. Notez que la boucle `{{#each}}` contient un `{{else}}` de
façon à ce que, lorsque le modèle est vide, `pas d'utilisateurs… :-(` soit
affiché.

Comme nous suivons la convention de nommage d'{l-en Ember}, nous pouvons nous
passer de déclarer `UsersController`. {l-en Ember} devine que l'on gère une
collection car nous avons utilisé la forme plurielle de "user".

### ObjectController vs. ArrayController

Un `ObjectController` est lié à un seul objet et un `ArrayController` est lié à
un groupe d'objets (comme une collection). Comme nous venons de le voir, nous
n'avons pas besoin de déclarer de `ArrayController`. Juste pour cet article,
nous allons cependant le déclarer pour lui attribuer quelques propriétés :

``` javascript
/* /controllers/usersController.js
*/
App.UsersController = Ember.ArrayController.extend({
  sortProperties: ['name'],
  sortAscending: true // false = descending
});
```

Nous avons simplement trié nos utilisateurs par ordre alphabétique. Consultez
les guides pour en [apprendre plus sur les contrôleurs][GUIDES_CONTROLLERS].

### Afficher le nombre d'utilisateurs

Utilisons `UsersController` pour créer notre première propriété calculée
([computed property][COMPUTED_PROPERTY]). Celle-ci affichera le nombre
d'utilisateurs pour que nous puissions voir un changement lors de l'ajout ou de
la suppression d'un utilisateur.

Dans le {l-en template}, il nous suffit d'utiliser ceci :

``` html
/* /templates/users.hbs
*/
…
<div>Utilisateurs: {{usersCount}}</div>
…
```

Déclarons ensuite la propriété `usersCount` dans `UsersController` à la
différence que ce n'est pas une propriété classique puisqu'elle dépend de la
longueur du modèle.

``` javascript
/* /controllers/usersController.js
*/
App.UsersController = Em.ArrayController.extend({
  …
  usersCount: function(){
    return this.get('model.length');
  }.property('@each')
});
```

Pour faire simple, `usersCount` utilise la méthode `.property('@each')` qui
indique à {l-en Ember.js} que cette fonction est une propriété qui observe tout
changement sur l'un des modèles de la collection (ici les utilisateurs). Nous
verrons ensuite `usersCount` s'incrémenter ou se décrémenter chaque fois que
nous ajouterons ou supprimerons un utilisateur.

### Propriétés calculées

Les propriétés calculées sont puissantes. Elles permettent de déclarer des
fonctions en tant que propriétés. Voyons comment elles fonctionnent.

``` javascript
App.Person = Ember.Object.extend({
  firstName: null,
  lastName: null,

  fullName: function() {
    return this.get('firstName') + ' ' + this.get('lastName');
  }.property('firstName', 'lastName')
});

var ironMan = App.Person.create({
  firstName: "Tony",
  lastName:  "Stark"
});

ironMan.get('fullName') // "Tony Stark"
```

Dans l'exemple ci-dessus, l'objet `Person` a deux propriétés statiques,
`firsName` et `lastName`. Il a également une propriétés calculées `fullName` qui
concatène le prénom et le nom pour créer un nom complet. Notez que l'appel à
`.property('firsName', 'lastName')` indique que la fonction est de nouveau
exécutée lorsque `firsName` ou `lastName` change.

Les propriétés (statiques ou calculées) sont récupérables grâce à la méthode
`.get('property')` et peuvent être assignées via `.set('property', newValue)`.

Si vous avez besoin d'assigner plusieurs propriétés, il y a mieux que de le
faire une par une. Vous pouvez utiliser `.setProperties({})` plutôt que
plusieurs appels à `.set()`. Au lieu de ceci :

``` javascript
this.set('propertyA', 'valueA');
this.set('propertyB', valueB);
this.set('propertyC', 0);
this.set('propertyD', false);

Utilisez plutôt cela :

this.setProperties({
  'propertyA': 'valueA',
  'propertyB': valueB,
  'propertyC': 0,
  'propertyD': false
});
```

La documentation contient beaucoup d'informations sur comment lier les données
grâce aux [propriétés calculées][COMPUTED_PROPERTY], aux
[observers](http://emberjs.com/guides/object-model/observers) et aux
[bindings](http://emberjs.com/guides/object-model/bindings).

### Rediriger depuis la page Index

Si vous visitez la page d'accueil de votre application (`http://localhost/`),
rien ne se passe. Cela est dû au fait que nous consultons la page `index` et que
nous n'avons pas de {l-en template} `index`, nous allons donc en ajouter un que
nous appellerons `index.hbs`.

{l-en Ember.js} sait que vous créez un {l-en template} `index` pour la route
`IndexRoute`, vous n'avez donc rien à indiquer dans le `Router` pour que
tout fonctionne. C'est ce que l'on appelle une route initiale. Il en existe
trois : `ApplicationRoute`, `IndexRoute` et `LoadingRoute`. Consultez
[les guides][INITIAL_ROUTES] pour en savoir plus.

Ajoutons un lien vers la page des utilisateurs avec le {l-en block helper}
`{{#link-to}}…{{/link-to}}`. Pourquoi un {l-en block helper} ? Parce que vous
pouvez écrire du texte entre les balises comme s'il s'agissait de balises HTML.

``` html
/* /templates/index.hbs
*/
{{#link-to "users"}} Go to the users page {{/link-to}}
```

Le premier argument est le nom de la route vers laquelle pointe le lien. Le
deuxième argument, optionnel, est un modèle. Le résultat est un `<a>` classique
mais {l-en Ember} gère automatiquement la classe `active` en fonction de la
route active. `link-to` est parfait pour une menu par exemple. Vous pouvez en
apprendre plus [dans les guides](http://emberjs.com/guides/templates/links).

Une autre approche pourrait être de dire à `IndexRoute` de rediriger vers
`UsersRoute`. Encore une fois, c'est assez simple :

``` javascript
/* /routes/indexRoute.js
*/
App.IndexRoute = Ember.Route.extend({
  redirect: function(){
    this.transitionTo('users');
  }
});
```

Lorsque l'on visite la page d'accueil, on est immédiatement redirigé vers
`/#/users`.

### Route d'un utilisateur spécifique

Avant de gérer les segments dynamiques, nous devons créer un lien vers chaque
utilisateur depuis le {l-en template} `users`. Utilisons le {l-en block helper}
`{{#link-to}}` dans une boucle `each` qui parcourt les utilisateurs.

``` html
/* /templates/users.hbs
*/
…
{{#each user in controller}}
  <li>
    {{#link-to "user" user}}
      {{user.name}}
    {{/link-to}}
  </li>
{{/each}}
```

Le deuxième argument passé à `link-to` est le modèle à passer à `UserRoute`.

Occupons-nous maintenant du {l-en template} d'un utilisateur spécifique. Il
ressemble à ceci :

``` html
/* /templates/user.hbs
*/
<div class="user-profile">
  <img {{bind-attr src="avatarUrl"}} alt="Avatar de l'utilisateur" />
  <h2>{{name}}</h2>
  <span>{{email}}</span>
  <p>{{bio}}</p>
  <span>Création {{creationDate}}</span>
</div>
```

Notez que vous ne pouvez pas utiliser `<img src="{{avatarUrl}}">`, les données
attachées à un attribut doivent utiliser le {l-en helper} `bind-attr`. Vous
pouvez par exemple écrire `<img {{bind-attr height="imgHeight"}}>` avec
`imgHeight` qui serait une propriété calculée dans le contrôleur.

Vous trouverez tout ce dont vous avez besoin sur les
[attributs][GUIDES_ATTRIBUTES] et les
[classes HTML][BINDING_ELEMENT_CLASS_NAMES] dans les guides.

Jusque là, tout va bien mais rien ne se passe lorsque l'on clique sur le lien
d'un utilisateur. Cela est dû au fait que nous avons dit au `Router` que nous
voulions imbriquer `UserRoute` dans `UsersRoute`. Nous avons donc besoin d'un
`{{outlet}}` dans lequel afficher le {l-en template} d'un utilisateur.

``` html
/* /templates/users.hbs
*/
…
{{#each user in controller}}
…
{{/each}}

{{outlet}}
```

`{{outlet}}` est une sorte d'espace réservé dans lequel les autres
{l-en templates} peuvent être injectés lorsque l'on clique sur un
`{{#link-to}}`. Cela permet d'imbriquer les vues.

Vous devriez maintenant voir le {l-en template} d'un utilisateur s'afficher dans
la page lorsque vous visitez l'URL `/#/users/1`.

Attendez une minute ! Nous n'avons déclaré ni `UserRoute` ni `UserController` et
pourtant tout fonctionne ! Comment est-ce possible ? `UserRoute` est la version
singulière de `UsersRoute`, {l-en Ember} génère donc la route et le contrôleur
pour nous (en mémoire). Merci aux conventions de nommage !

Pour une question de consistance, nous allons les déclrarer, juste pour voir à
quoi il ressemblent :

``` javascript
/* /routes/userRoute.js
*/
App.UserRoute = Ember.Route.extend({
  model: function(params) {
    return this.store.find('user', params.user_id);
  }
});

/* /controllers/userController.js
*/
App.UserController = Ember.ObjectController.extend();
```

Pour en apprendre plus sur les [segments dynamiques][DYNAMIC_SEGMENTS],
rendez-vous dans les guides.

### Modifier un utilisateur

Passons maintenant au formulaire de modification d'un utilisateur, imbriqué dans
la page de ce dernier. Le {l-en template} ressemble à ceci :

``` html
/* /templates/user/edit.hbs
*/
<div class="user-edit">
  <label>Choisissez votre avatar</label>
  {{input value=avatarUrl}}

  <label>Nom de l'utilisateur</label>
  {{input value=name}}

  <label>Email de l'utilisateur</label>
  {{input value=email}}

  <label>Bio de l'utilisateur</label>
  {{textarea value=bio}}
</div>
```

Arrêtons-nous une minute sur ces balises [`{{input}}`][INPUT_HELPER]. Le but de
ce formulaire est de permettre la modification des données d'un utilisateur et
ces balises `input` prennent en paramètre les propriétés du modèle pour s'y
attacher.

Notez bien que l'on écrit `value=model`, sans les `" "`. Le {l-en helper}
`{{input}}` est un raccourcis pour `{{Ember.TextField}}`. {l-en Ember.js}
propose plusieurs
[vues prédéfinies](http://emberjs.com/guides/views/built-in-views), en
particulier pour les éléments de formulaires.

Si vous visitez l'URL `/#/users/1/edit` de votre application, rien ne se passe.
Nous avons de nouveau besoin d'un `{{outlet}}` pour imbriquer le {l-en template}
du formulaire dans celui de l'utilisateur.

``` html
/* /templates/user.hbs
*/
…
{{outlet}}
```

Le {l-en template} est maintenant injecté dans la page mais les champs sont
toujours vides. Nous devons dire à la route quel modèle utiliser.

``` javascript
/* /routes/userEditRoute.js
*/
App.UserEditRoute = Ember.Route.extend({
  model: function(){
    return this.modelFor('user');
  }
});
```

La méthode
[modelFor](http://emberjs.com/api/classes/Ember.Route.html#method_modelFor) vous
permet d'utiliser le modèle d'une autre route. Nous avons indiqué à
`UserEditRoute` d'utiliser le modèle de `UserRoute`. Les champs sont maintenant
remplis correctement avec les données du modèle. Essayez de les modifier, vous
pourrez voir les modifications reportées en direct dans le {l-en template}
parent !

### Notre première action

Ok, nous avons besoin d'un bouton sur lequel cliquer pour être redirigé de
`UserRoute` vers `UserEditRoute`.

``` html
/* /templates/user.hbs
*/
<div class="user-profile">
  <button {{action "edit"}}>Modifier</button>
  …
```

Nous venons d'ajouter un simple `button` qui lance notre première `{{action}}`.
Les actions sont des événements qui lancent les méthodes associées dans le
contrôleur courant.  Si aucune méthode n'est trouvée, l'action remonte
({l-en bubble}) les routes jusqu'à trouver quelque chose. Ce mécanisme est très
bien expliqué [dans les guides][ACTION_BUBBLING].

En d'autres termes, si nous cliquons (`click`) sur le `button`, il va lancer
l'action `edit` qui se trouve dans le contrôleur. Ajoutons-la à
`UserController` :

``` javascript
/* /controllers/userController.js
*/
App.UserController = Ember.ObjectController.extend({
  actions: {
    edit: function(){
      this.transitionToRoute('user.edit');
    }
  }
});
```

Les actions, que ce soit dans un contrôleur ou une route, sont stockées dans
le {l-en hash} `actions`. Ce n'est cependant pas le cas des actions par défaut
comme `click`, `doubleClick`, `mouseLeave` ou `dragStart`. Le site
d'{l-en Ember.js} contient la
[liste complète](http://emberjs.com/api/classes/Ember.View.html#toc_event-names)
de ces actions.

Notre action `edit` dit simplement "Va sur la route `user.edit`". C'est à peu
près tout.

### TransitionTo ou TransitionToRoute ?

Notez que la transition depuis une route est différente de la transition depuis
un contrôleur :

``` javascript
// depuis une route
this.transitionTo('your.route')
// depuis un contrôleur
this.transitionToRoute('your.route')
```

### Sauvegarder les modifications apportées à l'utilisateur

Voyons maintenant comment sauvegarder nos modifications après avoir changé la
valeur des données de l'utilisateur. Par sauvegarder, j'entends rendre
persistant. Avec {l-en Ember-Data}, cela signifie d'appeler `save()` sur le
`Store` et de sauvegarder le nouveau `record` correspondant à l'utilisateur.
Le `Store` va ensuite dire à l'`adapter` d'effectuer une requête AJAX {l-en PUT}
(si vous utilisez `RESTAdapter`).

Dans notre application, il s'agit d'un `button` "OK" qui sauvegarde les
modifications et retourne à la route parente. Nous allons à nouveau utiliser
une `{{action}}`.

``` html
/* /templates/user/edit.hbs
*/
<button {{action "save"}}> ok </button>
```

``` javascript
/* /controllers/userEditController.js
*/
App.UserEditController = Ember.ObjectController.extend({
  actions: {
    save: function(){
      var user = this.get('model');
      // cela indique à Ember-Data de sauvegarder le nouvel enregistrement
      user.save();
      // puis transite vers l'utilisateur courant
      this.transitionToRoute('user', user);
    }
  }
});
```

Notre mode "modification" fonctionne bien. Passons maintenant à la suppression
d'un utilisateur.

### Supprimer un utilisateur

Nous pouvons ajouter un `button` "Supprimer" à côté du bouton "Modifier" dans le
{l-en template} d'un utilisateur. Cette fois nous aurons une `{{action}}`
`delete` définie dans `UserController`.

``` html
/* /templates/user.hbs
*/
<button {{action "delete"}}>Supprimer</button>
```

``` javascript
/* /controllers/userController.js
*/
…
actions: {
  delete: function(){
    // ceci indique à Ember-Data de supprimer l'utilisateur courant
    this.get('model').deleteRecord();
    this.get('model').save();
    // puis transite vers la route users
    this.transitionToRoute('users');
  }
}
```

Lorsque l'on clique sur le bouton "Supprimer", l'utilisateur est directement
supprimé. Un peu direct ; un message de confirmation comme "Êtes-vous sûr ?"
avec des boutons "Oui" et "Non" seraient bienvenus. Pour ce faire, nous devons
modifier notre `{{action "delete"}}` pour afficher `confirm-box` plutôt que de
supprimer immédiatement l'utilisateur. Et, bien sûr, nous devons mettre
`confirm-box` dans le {l-en template} `user`.

``` html
/* /templates/user.hbs
*/
{{#if deleteMode}}
<div class="confirm-box">
  <h4>Sûr ?</h4>
  <button {{action "confirmDelete"}}> oui </button>
  <button {{action "cancelDelete"}}> non </button>
</div>
{{/if}}
```

Nous venons d'écrire notre premier `{{if}}` avec {l-en Handlebars}. Il n'écrit
`div.confirm-box` que lorsque la propriété `deleteMode` est à `true`. Nous
devons définir `deleteMode` dans le contrôleur et modifier l'action `delete`
pour qu'il passe `deleteMode` à `true` ou `false`. Notre `UserController`
ressemble maintenant à ceci :

``` javascript
/* /controllers/userController.js
*/
App.UserController = Ember.ObjectController.extend({
  // la propriété deleteMode est à false par défaut
  deleteMode: false,

  actions: {
    delete: function(){
      // notre méthode delete change uniquement la valeur de deleteMode
      this.toggleProperty('deleteMode');
    },
    cancelDelete: function(){
      // remet deleteMode à false
      this.set('deleteMode', false);
    },
    confirmDelete: function(){
      // ceci indique à Ember-Data de supprimer l'utilisateur courant
      this.get('model').deleteRecord();
      this.get('model').save();
      // puis transite vers la route users
      this.transitionToRoute('users');
      // et remet deleteMode à false
      this.set('deleteMode', false);
    },
    // le méthode edit reste la même
    edit: function(){
      this.transitionToRoute('user.edit');
    }
  }
});
```

La suppression fonctionne maintenant comme il faut avec les boutons "Oui" et
"Non". Génial ! Il ne reste plus que la route de création à écrire.

### Créer un utilisateur

Pour la création de l'utilisateur, essayons quelque chose de fun : réutilisons
le {l-en template} `edit`. Au final, le formulaire est exactement le même que
celui de modification d'un utilisateur. Commençons par déclarer la route qui va
retourner un objet vide dans son {l-en hook} `model` :

``` javascript
/* /routes/usersCreateRoute.js
*/
App.UsersCreateRoute = Ember.Route.extend({
  model: function(){
    // le modèle de cette route est un nouvel Ember.Object vide
    return Em.Object.create({});
  },

  // dans le cas présent (la route create), nous pouvons réutiliser le template
  // user/edit associé avec usersCreateController
  renderTemplate: function(){
    this.render('user.edit', {
      controller: 'usersCreate'
    });
  }
});
```

La méthode `renderTemplate` nous permet d'associer un {l-en template} spécifique
à une route. Nous indiquons à `UsersCreateRoute` d'utiliser le {l-en template}
`user.edit` avec `UsersCreateController`. Vous pouvez en apprendre plus sur
`renderTemplate`
[dans les guides](http://emberjs.com/guides/routing/rendering-a-template/).

Définissons maintenant une autre action `save`, mais dans
`UsersCreateController` cette fois (souvenez-vous qu'une `action` va d'abord
chercher une méthode correspondante dans le contrôleur _courant_).

``` javascript
/* /controllers/usersCreateController.js
*/
App.UsersCreateController = Ember.ObjectController.extend({
  actions: {
    save: function(){
      // nous donnons une date de création juste avant la sauvegarde
      this.get('model').set('creationDate', new Date());

      // crée un nouvel enregistrement et le sauvegarde dans le Store
      var newUser = this.store.createRecord('user', this.get('model'));
      newUser.save();

      // redirige vers l'utilisateur lui-même
      this.transitionToRoute('user', newUser);
    }
  }
});
```

Ajoutons maintenant un `{{#link-to}}` dans le {l-en template} `users` pour
pouvoir accéder au formulaire de création :

``` html
/* /templates/users.hbs
*/
{{#link-to "users.create" class="create-btn"}} Ajouter un utilisateur {{/link-to}}
…
```

C'est tout ce dont nous avons besoin pour créer des utilisateurs !

### Formater les données avec les {l-en helpers}

Nous avons [déjà vu](#helpers) ce que sont les {l-en helpers}. Voyons maintenant
comment en créer un qui nous permette de formater une date toute moche en
quelque chose de plus propre. La bibliothèque [Moment.js][MOMENTJS] est
exactement ce dont nous avons besoin.

Récupérez [Moment.js][MOMENTJS] et chargez le dans la page. Nous allons ensuite
définir notre premier {l-en helper} :

``` javascript
/* /helpers/helpers.js
*/
Ember.Handlebars.helper('formatDate', function(date){
  return moment(date).fromNow();
});
```

Modifions le {l-en template} `user` pour qu'il fasse appel au {l-en helper}
`formatDate` sur la propriété `{{creationDate}}` :

``` html
/* /templates/user.hbs
*/
…
<span>Création {{formatDate creationDate}}</span>
…
```

C'est tout ! Les dates devraient s'afficher sous la forme "2 days ago" (il y a
deux jours), "One month ago" (il y a un mois), etc.

<abbr title="Note du traducteur">NDT</abbr> : Moment.js permet d'utiliser
d'autres langues que l'anglais, tout est expliqué
[dans la documentation](http://momentjs.com/docs/#/i18n/).

### Formater les données avec un {l-en BoundHelper}

Dans le cas précédent, la date est fixe et ne risque pas de changer. Si nous
avons par contre des données qui doivent être mises à jour (par exemple un
prix formaté), il faut utiliser un `BoundHelper` au lien d'un {l-en helper}
classique.

``` javascript
/* /helpers/helpers.js
*/
Ember.Handlebars.registerBoundHelper('formatDate', function(date){
  return moment(date).fromNow();
});
```

Un `BoundHelper` sait se mettre à jour automatiquement lorsque les données
changent. Vous pouvez en apprendre plus sur le sujet
[dans les guides][BOUND_HELPER].

### Passer au {l-en LocalStorage Adapter}

Notre application fonctionne bien, nous sommes donc prêts à passer aux choses
sérieuses. Nous pourrions utiliser le `RESTAdapter` mais nous aurions du coup
besoin d'un server REST sur lequel effectuer des requêtes `GET`, `PUT`, `POST`
et `DELETE`. Nous allons plutôt utiliser le `LSAdapter`, un {l-en adapter}
externe que vous pouvez [télécharger sur GitHub][LSAdapter]. Ajoutez-le dans
votre page (juste après {l-en Ember-Data}), commentez toutes les données
`FIXTURE` et changez `ApplicationAdapter` pour `DS.LSAdapter` :

``` javascript
/* /store.js
*/
App.ApplicationAdapter = DS.LSAdapter;
```

Les données de vos utilisateurs seront maintenant stockées dans le
{l-en local storage} (stockage local du navigateur). C'est tout ! Sérieusement,
c'est aussi simple que ça. Pour vous en assurer, ouvrez les
{l-en Developer Tools} dans votre navigateur et rendez-vous dans le panneau
"Ressource". Dans l'onglet "Local Storage" vous devriez trouver une entrée pour
`LSAdapter` avec toutes les données de vos utilisateurs.

![console-localstorage](/images/ember/console-localstorage.png)

## Jouer avec les vues

Jusque là, nous n'avons déclaré aucune vue dans notre application, seulement des
{l-en templates}. Pourquoi nous soucier des vues ? Et bien, elles sont très
puissantes pour gérer des événements, des animations ou des composants
réutilisables.

### jQuery et {l-en didInsertElement}

Que devons-nous faire pour utiliser jQuery comme d'habitude avec les vues
{l-en Ember.js} ? Chaque vue ou composant a un {l-en hook} `didInsertElement`
qui nous indique que la vue a effectivement été chargée dans le DOM. Cela vous
assure un accès aux éléments de la page depuis jQuery.

``` javascript
App.MyAwesomeComponent = Em.Component.extend({
  didInsertElement: function(){
    // this = la vue
    // this.$() = $(la vue)
    this.$().on('click', '.child .elem', function(){
      // quelque chose utilisant jQuery
    });
  }
});
```

Si vous avez des événements du style jQuery enregistrés dans `didInsertElement`,
vous pouvez utiliser `willDestroyElement` pour les retirer après la suppression
d'une vue dans le DOM, comme ceci :

``` javascript
App.MyAwesomeComponent = Em.Component.extend({
  didInsertElement: function(){
    this.$().on('click', '.child .elem', function(){
      // quelque chose utilisant jQuery
    });
  },
  willDestroyElement: function(){
    this.$().off('click');
  }
});
```

### Panneaux latéraux avec className dynamique

La combinaison des propriétés calculées et de classes (`className`) dynamiques
peut sembler une technique un peu folle mais ce n'est pas si terrible en
réalité. L'idée est simplement d'ajouter ou de retirer une classe CSS sur un
élément en fonction d'une propriété qui peut être `true` ou `false`. La classe
CSS contient bien sûr une transition CSS.

Mettons que nous avons une `div` cachée dans le DOM. Lorsque cette `div` a la
classe `opened`, elle s'affiche en glissant. Lorsqu'elle a la classe `closed`,
elle glisse de nouveau pour se cacher. Un panneau latéral est l'exemple parfait,
nous allons donc en écrire un.

Voici un JS Bin pour que vous puissiez tester le code :

<a class="jsbin-embed" href="http://emberjs.jsbin.com/utimiZI/88/embed?js,output">Panneaux latérales réutilisables avec Ember.js - Smashing</a>

Voici le détail de chaque onglet :

* **JavaScript**<br />
  Nous commençons par déclarer notre `SidePanelComponent` avec des `classNames`
  par défaut. Nous utilisons ensuite `classNameBindings` pour déterminer si
  `isOpen` est à `true` ou `false` de façon à retourner `opened` ou `closed` en
  fonction. Notre `component` a une action `toggleSidepanel` qui passe `isOpen`
  à `true` ou `false`.
* **HTML**<br />
  Les balises du panneau latéral. Vous remarquerez le bloc
  `{{#side-panel}}…{{/side-panel}}`, nous pouvons placer n'importe quoi dedans
  ce qui rend notre panneau latéral extrêmement puissant et réutilisable. Le
  bouton `btn-toggle` appelle l'action `toggleSidepanel` située dans le
  composant. Le `{{#if isOpen}}` ajoute un peu de logique en vérifiant la valeur
  de la propriété `isOpen`.
* **CSS**<br />
  Ici le but principal est de masquer le panneau latéral. La classe `opened`
  le fait glisser en position ouverte et la classe `closed` le fait glisser dans
  l'autre sens. L'animation est rendue possible parce que nous utilisons
  `translate2D` (`transition:transform .3s ease`).

Les guides contiennent de nombreux exemples sur comment lier des classes
[dans les composants][COMPONENTS_ELEMENT] ou
[dans les {l-en templates}][BINDING_ELEMENT_CLASS_NAMES].

### {l-en Modals} avec {l-en layout} et remontée d'événements

Cette technique est bien plus compliquée que la précédente. Elle implique bien
plus de fonctionnalités d'{l-en Ember.js}. L'idée est de faire remonter un
événement d'une vue jusqu'à la route pour changer une propriété située dans un
contrôleur quelque part dans l'application. Nous allons utiliser une `View`
plutôt qu'un `Component` (pour mémoire, un composant est simplement une vue
isolée).

<a class="jsbin-embed" href="http://emberjs.jsbin.com/aKUWUF/55/embed?js,output">Modals réutilisables avec Ember.js - Smashing</a>

* **JavaScript**<br />
  `modalView` est le `layout` par défaut pour toutes nos {l-en modals}. Elle
  contient deux méthodes, `showModal` et `hideModal`. La méthode `showModal` est
  appelée par une `action` qui remonte, en passant par le contrôleur puis par
  les routes, jusqu'à trouver l'action `showModal` correspondante. Nous avons
  placé `showModal` dans la route la plus haute possible, `applicationRoute`.
  Son seul but est de valuer la propriété `modalVisible` dans le contrôleur
  passé en second argument de l'`action`. Et oui, créer une propriété en même
  temps qu'on lui donne sa valeur est possible.
* **HTML**<br />
  Chaque {l-en modal} a son propre {l-en template} et nous utilisons le bloc
  `{{#view App.ModalView}}…{{/view}}` pour les encapsuler dans `modal_layout`.
  Les contrôleurs liés aux {l-en modals} ne sont même pas déclarés,
  {l-en Ember.js} les a en mémoire. Notez que le {l-en helper} `{{render}}`
  accepte des arguments : le nom du {l-en template} et le contrôleur généré pour
  ce {l-en template}. Nous appelons par exemple le {l-en template} `modal01` et
  le contrôleur `modal01` (auto-généré).
* **CSS**<br />
  Pour cet exemple, les {l-en modals} doivent être présentes dans le DOM. Cela
  peut sembler contraignant mais réduit le coût d'affichage. Sans cela,
  {l-en Ember.js} doit les injecter et les supprimer à chaque appel. Le second
  avantage concerne les transitions CSS. La classe `shown` applique deux
  transition : tout d'abord, la position verticale (la {l-en modal} étant en
  dehors de l'écran par défaut), puis, après un court délai, l'opacité (ce qui
  [réduit][SPDECK_HW_ACCELERATION] encore le [coût][CSS_TRICKS_HW_ACCELERATION]
  d'affichage durant la transition).

Vous trouverez bien d'autres informations sur les
[événements](http://emberjs.com/guides/views/handling-events),
[la remontée d'événements][EVENTS_BUBBLING], les
[layouts](http://emberjs.com/guides/views/adding-layouts-to-views) et le
{l-en helper} [{{render}}][RENDER_HELPER] dans les guides.

## Qu'est-ce qu'{l-en Ember-Data}

{l-en Ember-Data} est en beta au moment où j'écris ces lignes, faites donc
attention si vous décidez de l'utiliser.

C'est une bibliothèque qui permet de récupérer les données
stockées sur le serveur, de les retenir dans un `Store`, de les mettre à jour
dans le navigateur et enfin des les renvoyer au serveur pour sauvegarde. Le
`Store` peut être configuré avec différents {l-en adapters} en fonction de votre
{l-en back-end}. Voici un schéma de l'architecture d'{l-en Ember-data}.

![ember-data-sketch](/images/ember/ember-data-sketch.png)

### Le {l-en store}

Le `Store` retient les informations chargées depuis le serveur (les
enregistrements). Les routes et contrôleurs peuvent effectuer des requêtes sur
le `Store` pour récupérer des enregistrements ({l-en records}). Lorsqu'un
enregistrement est appelé pour la première fois, le `Store` demande à
l'{l-en adapter} de le charger au travers du réseau. Le `Store` le garde ensuite
en {l-en cache} pour les prochains appels.

### Les {l-en adapters}

L'application effectue des requêtes sur le `Store` et l'{l-en adapter} effectue
des requêtes sur le {l-en back-end}. Chaque {l-en adapter} est fait pour un
{l-en back-end} particulier. On trouve par exemple le `RESTAdapter` qui permet
de communiquer avec un API JSON et le `LSAdapter` qui permet d'utiliser le
{l-en local storage} du navigateur.

L'idée derrière {l-en Ember-Data} est de pouvoir changer de {l-en back-end} en
changeant simplement l'{l-en adapter} sans changer le code de votre application.

* {l-en FixtureAdapter}<br />
  Le `FixtureAdapter` est parfait pour tester {l-en Ember} et {l-en Ember-Data}.
  Les {l-en fixtures} sont des données d'exemple avec lesquelles vous pouvez
  travailler jusqu'à ce que votre application soit prête pour la production.
  Nous avons vu [plus tôt dans cet article][FIXTURE_ADAPTER] comment le
  configurer.
* {l-en RESTAdapter}<br />
  Le `RESTAdapter` est l'{l-en adapter} par défaut dans {l-en Ember-Data}. Il
  permet d'effectuer des requêtes `GET`, `PUT`, `POST` et `DELETE` sur une API
  REST. Il repose sur un certain nombre de
  [conventions JSON spécifiques][JSON_CONVENTIONS]. Utiliser cet {l-en adapter}
  se fait comme ceci :

  `App.ApplicationAdapter = DS.RESTAdapter.extend({
    host: 'https://your.api.com'
  });`<br />

  Il y a bien plus à découvrir sur le `RESTAdapter`
  [dans les guides](http://emberjs.com/guides/models/the-rest-adapter).

* {l-en Adapter} personnalisé<br />
  Vous pouvez utiliser un autre {l-en adapter} que les deux par défaut
  (`FixtureAdapter` et `RESTAdapter`). On en trouve bon nombre
  [sur Github](https://github.com/search?q=ember+adapter&amp;ref=reposearch).
  Il y a, par exemple, l'[{l-en adapter} LocalStorage][LSAdapterGihub] dont on
  peut trouver une démo dans la
  [{l-en Todo}](http://emberjs.com/guides/getting-started/using-other-adapters)
  d'exemple des guides. Je l'utilise également dans la [démo][STYLED_DEMO].

### Sans utiliser {l-en Ember-Data}

Dans cet article, j'ai choisi de parler d'{l-en Ember-Data} parce qu'il est
presque prêt et que c'est un des trucs les plus cool qui ont lieu dans le monde
JavaScript en ce moment. Vous vous demandez peut être s'il est possible de s'en
passer. La réponse est oui ! En fait, utiliser {l-en Ember.js} sans
{l-en Ember-Data} est assez facile.

Il y a deux façons de le faire.

Vous pouvez utiliser d'autres bibliothèques pour prendre en charge la
récupération et la persistance de vos modèles.
[Ember-Model](https://github.com/ebryn/ember-model),
[Ember-Resource](https://github.com/zendesk/ember-resource),
[Ember-Restless](https://github.com/endlessinc/ember-restless) et, plus
récemment, [EPF](http://epf.io/) sont de bonnes alternatives. {l-en EmberWatch}
a rédigé un petit articles qui liste les
"[Alternatives à {l-en Ember-Data}][ALTERNATIVES_TO_ED]".

Une autre façon de faire pourrait être de ne pas utiliser de bibliothèque. Dans
ce cas, vous devez implémenter les méthodes de récupération des modèles via
requêtes AJAX. "[{l-en Ember Without Ember-Data}][EMBER_WO_ED]", par Robin Ward
(le mec derrière [Discourse](http://www.discourse.org/)), est une lecture
intéressante. "[{l-en Getting Into Ember.js, Part 3}][TUTPLUS_EMBER]", par Rey
Bango sur Nettuts+ traite en particulier des modèles.

Voici par exemple comment définir une méthode statique sur un modèle en
utilisant `reopenClass` :

``` javascript
/* /models/user.js
*/
// our own findStuff method inside the User model
App.User.reopenClass({
  findStuff: function(){
    // utilise une requête AJAX / Promises classique
    return $.getJSON("http://your.api.com/api").then(function(response) {
      var users = [];
      // crée de nouveaux Ember Objects et les stocke dans le tableau users
      response.users.forEach(function(user){
        users.push( App.User.create(user) );
      });
      // retourne le tableau plein d'Ember Objects
      return users;
    });
  }
});
```

Vous pouvez ensuite utiliser la méthode `findStuff` dans le {l-en hook} `model`
de nos routes :

``` javascript
/* /routes/usersRoute.js
*/
App.UsersRoute = Em.Route.extend({
  model: function(){
    return App.User.findStuff();
  }
});
```

## Qu'est-ce que la précompilation de {l-en templates} {l-en Handlebars} ?

Pour faire simple, précompiler les {l-en templates} veut dire prendre tous les
{l-en templates} et les transposer en chaines de caractères JavaScript puis les
stocker dans `Ember.TEMPLATES`. Cela veut également dire qu'il y a un fichier en
plus, contenant la version compilée de tous vos {l-en templates}
{l-en Handlebars}, à charger dans votre page.

Pour une application assez simple, la précompilation peut être évitée. Si vous
avez cependant trop de {l-en templates} `<script type="text/x-handlebars">` dans
votre principal fichier HTML, la précompilation vous permettra de mieux
organiser votre code.

De plus, précompiler vos {l-en templates} vous permet d'utiliser la version
{l-en runtime} de {l-en Handlebars} qui est plus légère que la version
classique. Vous pouvez trouver les deux versions (standard et {l-en runtime})
sur le [site de {l-en Handlebars}][HANDLEBARS].

### Conventions de nommage des {l-en templates}

Les [partials][GUIDES_PARTIALS] doivent commencer par un `_`. Vous devez donc
déclarer un fichier `_yourpartial.hbs` ou, si vous ne précompilez pas vos
{l-en templates}, une balise
`<script type="text/x-handlebars" id="_yourpartial">`.

Les [composants][GUIDES_PARTIALS]
doivent commencer par `components/`. Vous devez donc les stocker dans un dossier
`components/` ou, si vous ne précompilez pas vos {l-en templates}, une
balise `<script type="text/x-handlebars" id="components/votre-composant">`. Vous
devez utiliser un tiret comme séparateur dans le nom des composants.

Vous pouvez cependant utiliser une propriété `templateName` dans les vues pour
spécifier quel {l-en template} associer avec une vue. Voici une déclaration de
{l-en template} :

``` javascript
<script type="text/x-handlebars" id="folder/some-template">
  Un template
</script>
```

Que vous pouvez associer à une vue particulière :

``` javascript
App.SomeView = Em.View.extend({
  templateName: 'folder/some-template'
});
```

### Précompiler avec {l-en Grunt}

Si vous utilisez [Grunt][GRUNT], vous vous en servez probablement pour d'autres
tâches liées à la construction (concatenation, compression, ce genre de choses).
Dans ce cas, vous devez connaitre le fichier `package.json` qui vient avec
{l-en Node.js} et les modules {l-en Node}. Je vais considérer que vous
connaissez déjà Grunt.

Au moment où j'écris ceci, deux {l-en plugins} Grunt sont disponibles pour
transposer vos fichiers `.hbs` en fichier `templates.js` :
[grunt-ember-handlebars](https://github.com/yaymukund/grunt-ember-handlebars) et
[grunt-ember-templates](https://github.com/dgeb/grunt-ember-templates). Le
deuxième semble un peu plus à jour que le premier.

J'ai écris un {l-en Gist} pour chacun d'eux, pour vous aider avec la
configuration :

* [Voir le {l-en Gist} pour {l-en grunt-ember-handlebars}][GRUNT_EMBER_HB] ;
* [Voir le {l-en Gist} pour {l-en grunt-ember-templates}][GRUNT_EMBER_TPL].

Une fois configurés, vous devriez être à même de lancer `grunt` en ligne de
commande et cela devrait produire le fichier `templates.js`. Chargez-le dans
`index.html` (après `ember.js`) puis rendez-vous dans la console du navigateur
et tapez `Em.TEMPLATES`. Vous devriez voir un {l-en hash} contenant tous les
{l-en templates} compilés.

Notez qu'{l-en Ember.js} n'a pas besoin du chemin complet vers un
{l-en template} ni l'extension du fichier. En d'autres termes, le nom du
{l-en template} devrait être `users/create` et non
`/assets/js/templates/users/create.hbs`.

Les deux {l-en plugins} fournissent des options pour gérer cela. Référez-vous
aux guides respectifs ou jetez un oeil aux {l-en Gists} ci-dessus. Vous devriez
obtenir quelque chose dans ce genre :

![console-templates](/images/ember/console-templates.png)

Exactement ce qu'il nous faut pour que tout marche correctement. C'est tout ce
dont vous avez besoin pour précompiler avec {l-en Grunt}.

### Précompiler avec {l-en Rails}

Précompiler avec {l-en Rails} est la façon la plus simple de faire. La
[{l-en gem} Ember-Rails](https://github.com/emberjs/ember-rails) se charge d'à
peu près tout. Il fonctionne _presque_ {l-en out-of-the-box}. Suivez
attentivement les instructions d'installation du `readme` sur GitHub et tout
devrait bien se passer. Selon moi, {l-en Rails} a la meilleure intégration
{l-en Ember}/{l-en Handlebars} pour le moment.

## Outils, astuces et ressources

### L'Extension Chrome {l-en Ember}

L'[Extension {l-en Ember}][EMBER_INSPECTOR] pour Chrome est très pratique. Une
fois installée, un onglet "{l-en Ember}" apparait près de l'onglet "Console".
Vous pouvez ensuite naviguer à travers vos contrôleurs, routes et vues. L'onglet
"{l-en Data}" vous permettra d'explorer vos enregistrements très simplement si
vous utilisez {l-en Ember-Data}.

[![console-ember-extension][EXT_SMALL]][EXT_BIG]<br />
_Exploring your app’s objects has never been so easy._

### {l-en Ember App Kit}

Le [Ember App Kit](http://iamstef.net/ember-app-kit/), maintenu par l'équipe
{l-en Ember}, vous permet de créer très rapidement une application {l-en Ember}.
Il contient [Grunt][GRUNT] pour compiler les {l-en assets}, le lanceur de tests
[Kharma](http://karma-runner.github.io/0.10/index.html),
[Bower](http://bower.io/) et le support des
[modules ES6](http://wiki.ecmascript.org/doku.php?id=harmony:modules).

### {l-en Ember Tools}

Le projet {l-en GitHub} [Ember Tools](https://github.com/rpflorence/ember-tools)
est un outils en ligne de commande pour créer des applications {l-en Ember}.
Prenez une minute pour regarder le {l-en GIF} animé dans le `readme` et vous
comprendrez pourquoi c'est si cool.

### Développement et version minifié

Utilisez toujours le {l-en development build} durant le développement, il
contient beaucoup de commentaires, de tests unitaires et un tas de messages
d'erreur utiles qui ont été supprimés dans la version minifié. Vous trouverez un
lien vers chaque version sur le [site d'{l-en Ember.js}][EMBER_BUILDS].

### Astuces pour le {l-en debug}

{l-en Ember.js} fournit généralement des erreur humainement lisibles dans la
console du navigateur (si vous utilisez bien la version de développement). Il
peut être cependant difficile de deviner d'où vient l'erreur. Quelques méthodes
bien pratiques sont `{{log something}}` et `{{controller}}` qui affiche le
`controller` courant pour le {l-en template} dans lequel nous appelons le
{l-en helper}.

Ou vous pouvez afficher chaque transition du `Router` comme ceci :

``` javascript
window.App = Ember.Application.create({
  LOG_TRANSITIONS: true
});
```

Les guides contiennet une
[liste exhaustive](http://emberjs.com/guides/understanding-ember/debugging) de
ces petites methodes bien pratiques.

### Commenter correctement dans {l-en Handlebars}

Celui-là peut être frustrant. Ne commentez __jamais__ une balise
{l-en Handlebars} avec un commentaire HTML classique. Si vous le faites, vous
risquez de complètement casser l'application sans même savoir pourquoi.

    // ne faites jamais ça
    <!-- {{foo}} -->

    // faites plutôt ça
    {{!foo}}

## Conclusion

J'espère que ce long article vous a permis de mieux comprendre cet excellent
{l-en framework}. Mais pour tout vous dire, on a à peine vu la partie émergée de
l'iceberg. Il y a tellement plus à voir. Il y a par exemple le `Router` et sa
nature asynchrone qui permet de gérer les modèles avec des {l-en promises} (ce
qui permet de créer très facilement un {l-en spinner} de chargement). Il y a
également le modèle objet, avec son héritage de classes ou d'instances, ou
encore les {l-en mixins}, {l-en observers}, filtres, macros, `collectionViews`
et composants, ou encore la gestion de dépendances entre contrôleurs et le
paquet pour les tests. Et bien plus encore !

Je ne pouvais bien sûr pas vous parler de tout ça. Heureusement, les guides
vous aideront sur tous ces sujets.

{l-en Happy Ember.js coding, folks!}

### Ressources

* [Guides {l-en Ember.js}][GUIDES]<br />
  Le meilleur endroit pour apprendre {l-en Ember.js}
* [Ember.js Cookbook](http://emberjs.com/guides/cookbook/)<br />
  Une nouvelle section des guides qui résout plein de problèmes spécifiques
* [{l-en EmberWatch}](http://emberwatch.com)<br />
  Agrégation de toutes les ressources importantes
* [{l-en Ember Weekly}](http://emberweekly.com/issues.html)<br />
  Parfait pour rester à jour
* [Forum de discussion {l-en Ember.js}](http://discuss.emberjs.com)<br />
  C'est ici que les discussions prennent place (et c'est fait avec {l-en Ember})

### Remerciements

Un immense merci à [Mathieu Breton](https://twitter.com/MatBreton) et
[Philippe Castelli](https://twitter.com/ficastelli) qui m'ont tous deux transmis
tout ce qu'ils savaient sur {l-en Ember.js} durant mon apprentissage. Et un
grand merci à [Tom Dale](https://twitter.com/tomdale), qui m'a aidé à la
relecture de ce bien long article.
{% endraw %}

<script src="http://static.jsbin.com/js/embed.js"></script>

[ACTION_BUBBLING]: http://emberjs.com/guides/templates/actions/#toc_action-bubbling
[ALTERNATIVES_TO_ED]: http://blog.emberwatch.com/2013/06/19/alternatives-ember-data.html
[BINDING_ELEMENT_CLASS_NAMES]: http://emberjs.com/guides/templates/binding-element-class-names
[BOUND_HELPER]: http://emberjs.com/api/classes/Ember.Handlebars.html#method_registerBoundHelper
[COMPONENTS_ELEMENT]: http://emberjs.com/guides/components/customizing-a-components-element
[COMPUTED_PROPERTY]: http://emberjs.com/guides/object-model/computed-properties/
[CSS_TRICKS_HW_ACCELERATION]: http://css-tricks.com/w3conf-ariya-hidayat-fluid-user-interface-with-hardware-acceleration
[CUSTOM_SELECT]: http://pixelhandler.com/blog/2013/08/25/create-a-custom-select-box-using-ember-component/
[DYNAMIC_SEGMENTS]: http://emberjs.com/guides/routing/specifying-a-routes-model/#toc_dynamic-models
[EMBER_BUILDS]: http://emberjs.com/builds
[EMBER_FORUM]: http://discuss.emberjs.com/t/whats-the-difference-between-ember-helpers-components-and-views/2201/2
[EMBER_WO_ED]: http://eviltrout.com/2013/03/23/ember-without-data.html
[GUIDES]: http://emberjs.com/guides/
[GUIDES_ATTRIBUTES]: http://emberjs.com/guides/templates/binding-element-attributes/
[GUIDES_CONTROLLERS]: http://emberjs.com/guides/controllers
[GUIDES_MODELS]: http://emberjs.com/guides/models
[GUIDES_PARTIALS]: http://emberjs.com/guides/templates/rendering-with-helpers/
[HANDLEBARS]: http://handlebarsjs.com
[EMBER_INSPECTOR]: https://chrome.google.com/webstore/detail/ember-inspector/bmdblncegkenkacieihfhpjfppoconhi
[EVENTS_BUBBLING]: http://emberjs.com/guides/understanding-ember/the-view-layer/#toc_event-bubbling
[FIXTURE_ADAPTER]: #creer-notre-modele-avec-le-fixtureadapter-de-ember-data
[GRUNT]: http://gruntjs.com
[GRUNT_EMBER_HB]: https://gist.github.com/jkneb/6072299
[GRUNT_EMBER_TPL]: https://gist.github.com/jkneb/6599001
[INITIAL_ROUTES]: http://emberjs.com/guides/routing/defining-your-routes/#toc_initial-routes
[INPUT_HELPER]: http://emberjs.com/api/classes/Ember.Handlebars.helpers.html#method_input
[JSON_CONVENTIONS]: http://emberjs.com/guides/models/the-rest-adapter/#toc_json-conventions
[LSAdapterGihub]: https://github.com/rpflorence/ember-localstorage-adapter
[LSAdapter]: https://github.com/rpflorence/ember-localstorage-adapter/blob/master/localstorage_adapter.js
[MOMENTJS]: http://momentjs.com
[ORIGINAL]: http://coding.smashingmagazine.com/2013/11/07/an-in-depth-introduction-to-ember-js/
[RENDER_HELPER]: http://emberjs.com/guides/templates/rendering-with-helpers/#toc_the-code-render-code-helper
[ROUTES_GUIDES]: http://emberjs.com/guides/routing/defining-your-routes
[ROUTE_MODEL]: http://emberjs.com/guides/routing/specifying-a-routes-model
[SPDECK_HW_ACCELERATION]: https://speakerdeck.com/ariya/fluid-user-interface-with-hardware-acceleration?slide=36
[STACKOVERFLOW]: http://stackoverflow.com/questions/18593424/views-vs-components-in-ember-js
[STYLED_DEMO]: http://jkneb.github.io/ember-crud
[TUTPLUS_EMBER]: http://net.tutsplus.com/tutorials/javascript-ajax/getting-into-ember-js-part-3
[TWITTER_BTN]: http://jsbin.com/OMOgUzo/1/edit?html,js,output
[UNSTYLED_DEMO]: http://jkneb.github.io/ember-crud/unstyled
[WEB_COMPONENTS]: https://dvcs.w3.org/hg/webcomponents/raw-file/tip/spec/custom/index.html

[EXT_BIG]: /images/ember/console-ember-extension1.png
[EXT_SMALL]: /images/ember/console-ember-extension1-300x156.png
