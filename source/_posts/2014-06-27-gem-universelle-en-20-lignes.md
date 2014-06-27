---
author: Simon Courtois (simonc)
layout: post
title: "Une gem Ruby universelle en 20 lignes de code"
date: 2014-06-27 12:00
comment: true
categories:
- opal
- ruby
- rubymotion
---

Source: [Universal Ruby Gems in 20 Lines of Code de Michal Taszycki](http://blog.crossplatformruby.com/universal-ruby-gems-in-20-lines-of-code)

Les gems Ruby sont les blocs essentiels à la création d'applications Ruby Cross-Plateformes. Nous les utilisons pour encapsuler la logique de nos applications et extraire des fonctionnalités réutilisables sur différentes plateformes.

Je vais vous montrer comment préparer une gem Ruby pour qu'elle fonctionne avec __Ruby__, __Opal.rb__ et __RubyMotion__ sans aucune modification. De cette façon vous pourrez l'utiliser dans vos applications Rails/iOS/OSX/Android/Navigateur Client.

<!-- more -->

Nous avons tout d'abord besoin d'un gem d'exemple...

## La gem pig_latin

La gem pig_latin est un simple utilitaire de traduction. Elle convertit n'importe quel mot anglais en son équivalent [pig latin](http://en.wikipedia.org/wiki/Pig_Latin).

Nous pouvons l'utiliser comme ceci :

``` ruby
PigLatin.translate("cross platform ruby")
#=> "osscray atformplay ubyray"
```

La gem pig_latin est disponible sur [github](https://github.com/crossplatformruby/pig_latin) vous pouvez donc en lire le code ou l'essayer.

C'est une petite gem toute bête avec laquelle on peut s'amuser. Elle a cependant un aspect qui la rend particulièrement intéressante.

Voyons ce qu'il se passe lorsque nous ajoutons la ligne suivante au Gemfile d'une application Rails ou RubyMotion.

``` ruby
gem 'pig_latin', git: 'git@github.com:crossplatformruby/pig_latin.git'
```

Et bien...

## Cela fonctionne partout !

Que vous utilisiez Rails, RubyMotion ou même une application en ligne de commande, ça fonctionne tout seul. Si vous utilisez Opal.rb dans votre application, vous pouvez appeler `require` dessus et l'utiliser dans votre navigateur.

Essayez-la.

### Rails

``` ruby
class TranslationsController < ApplicationController
  def show
    @phrase = params[:phrase]
    @translation = PigLatin.translate(@phrase)
  end
end
```

![Pig Latin avec Rails](/images/universal_gems/rails.png)

### Opal.rb

``` ruby
require "opal"
require "opal_ujs"
require "pig_latin"

puts PigLatin.translate("cross platform ruby")
```

![Pig Latin dans un navigateur](/images/universal_gems/opal.png)

### iOS

``` ruby
class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    alert = UIAlertView.new
    alert.message = PigLatin.translate("cross platform ruby")
    alert.show
  end
end
```

![Pig Latin sur iOS](/images/universal_gems/ios.png)

### OSX

``` ruby
class AppDelegate
  def applicationDidFinishLaunching(notification)
    buildMenu
    buildWindow

    alert = NSAlert.new
    alert.messageText = PigLatin.translate("cross platform ruby")
    alert.runModal
  end

  def buildWindow
    # (...) details omis pour plus de clareté
  end
end
```

![Pig Latin sur OS X](/images/universal_gems/osx.png)

### Android (bientôt)

Dans les mois qui viennent, RubyMotion permettra la création d'applications Ruby pour Android. Je mettrais à jour cet article quand ce sera possible. Il semble cependant qu'aucun réglage additionnel ne sera nécessaire.

## Comment cela fonctionne-t-il ?

Lorsque l'on parle d'écrire une gem, la principale différence entre les plateformes est la façon dont les fichiers sont appelés.

RubyMotion et Opal.rb ne permettent pas l'usage de `require` au runtime. Nous devons donc nous assurer que tous les fichiers de notre gem sont appelés en amont.

En Ruby Cross-Plateforme, le fichier faisant office de point d'entrée devient le manifeste de la gem.

### 1. Faire fonctionner la gem avec Ruby

Si votre seule plateforme est MRI ou Rubinius, votre point d'entrée, `pig_latin.rb`, doit ressembler à ceci :

``` ruby
require "pig_latin/version"
require "pig_latin/word_translator"
require "pig_latin/phrase_translator"
require "pig_latin/class_methods"
```

Aucun code spécifique à la gem ne doit être présent dans ce fichier, uniquement une suite d'appels à `require`, c'est important pour plus tard.

### 2. Supporter Opal.rb

Il est facile de faire fonctionner notre manifeste sous Opal. Collez simplement le code ci-dessous n'importe où dans `pig_latin.rb`.

``` ruby
if defined?(Opal) && defined?(File)
  Opal.append_path File.expand_path('.', File.dirname(__FILE__))
end
```

Il est plus difficile de comprendre pourquoi ça fonctionne.

Lorsque Opal compile les fichiers, il transforme les appels à `require` en directives `Sprockets`. Cela veut dire qu'au moment où l'on appelle `application.rb`, il comprend les `require` mais ne sait pas où trouver les fichiers.

C'est pour cette raison que nous devons ajouter le chemin du dossier contenant notre point d'entrée grâce à `Opal#append_path`.

Cela veut dire que notre manifeste est lancé deux fois :

1. En Ruby, lorsque la gem est appelée pour informer Opal des chemins à charger ;
2. En Opal.rb pour traduire les `require` en directives `Sprockets`.

### 3. Compiler pour RubyMotion

RubyMotion ne permet pas d'appeler `require` au runtime. Nous devons donc lui fournir la liste des fichiers à compiler. Il serait cependant plus intéressant de conserver notre succession de `require` et de nous en servir pour générer cette liste.

Puisque notre manifeste est lancé avec Ruby, nous pouvons le faire en utilisant la technique suivante.

Commençons par redéfinir la méthode `require` :

``` ruby
if defined?(Motion::Project::Config)
  def rubymotion_require(filename)
    @files_to_require ||= []
    @files_to_require << filename
  end

  alias :old_require :require
  alias :require :rubymotion_require
end
```

Nous appelons ensuite `require` comme d'habitude.

Pour finir, nous construisons la liste des fichiers à compiler et remettons `require` en place une fois terminé.

``` ruby
if defined?(Motion::Project::Config)
  alias :require :old_require

  Motion::Project::App.setup do |app|
    paths_to_require = @files_to_require.map do |file|
      File.join(File.dirname(__FILE__), file + ".rb")
    end

    app.files.unshift(*paths_to_require)
  end
end
```

## En résumé

En utilisant quelques astuces et une organisation intelligente des fichiers, nous avons réussi à créer une gem qui fonctionne sur les serveurs, dans les applications lourdes, dans les navigateurs et sur mobiles. Cela permet de partager du code entre plusieurs applications.

Vous pouvez très facilement adapter ces techniques à vos propres gems. Cela prend littéralement 20 lignes de code pour les rendre universelles.
