---
author: Simon Courtois (simonc)
layout: post
title: "Guide de migration vers Capistrano 3"
date: 2014-01-13 11:05
comment: true
categories:
- ruby
---

Source: [Capistrano 3 Upgrade Guide de Darko Fabijan sur le blog de Semaphore ](https://semaphoreapp.com/blog/2013/11/26/capistrano-3-upgrade-guide.html)

Nous avons récemment reçu des demandes de support pour Capistrano 3. Pour
fournir un service de support de qualité, il faut connaitre le sujet, je me suis
donc lancé dans la quête de migrer scripts de déploiement de Capistrano 2 à
Capistrano 3. Comme toujours, cela a pris un peu plus de temps que prévu mais au
final le code est plus propre.

Je dois dire que j'ai eu un flashback remontant à deux ans, lorsque je mettais
en place Capistrano pour la première fois : la documentation est incomplète
et il faut jongler entre le
[{l-en readme}](https://github.com/capistrano/capistrano),
le [wiki](https://github.com/capistrano/capistrano/wiki) et
[la page d'accueil officielle](http://www.capistranorb.com/). Mais c'est un
projet open-source et les participations pour améliorer cela sont les
bienvenues.

Je vais tenter de vous faciliter la migration en vous montrant notre nouvelle
configuration en parallèle de l'ancienne, étape par étape.

<!-- more -->

## Mettre en place la nouvelle configuration

### Gemfile

La première étape est d'installer de nouvelles gems. Capistrano 2 ne supportait
pas les configurations {l-en multistage}, il fallait pour cela
utiliser la gem `capistrano-ext`. Capistrano 3 supporte le
{l-en multistage} en standard. Il est indépendant de tout {l-en framework},
vous devez donc utiliser `capistrano-rails` si vous comptez déployer une
application {l-en Rails}. Suivez l'exemple ci-dessous pour mettre votre
{l-en Gemfile} à jour, lancez ensuite `bundle install` et vous êtes prêt pour la
migration.

Capistrano 2 :

``` ruby
group :development do
  gem "capistrano"
  gem "capistrano-ext"
end
```

Capistrano 3 :

``` ruby
group :development do
  gem "capistrano-rails"
end
```

### Ajouter Capistrano 3 à votre projet

Comme le conseille
[le guide officiel de mise à jour](http://www.capistranorb.com/documentation/upgrading/),
il est préférable de copier les anciens fichiers Capistrano dans un endroit sûr,
au cas où, et d'ajouter les nouveaux fichiers générés à la main. Voici une
astuce pour le faire :

``` ruby
mkdir old_cap
mv Capfile old_cap
mv config/deploy.rb old_cap
mv config/deploy/ old_cap
```

Une fois cela fait, vous êtes prêt à mettre le nouveau Capistrano en place pour
votre projet :

    bundle exec cap install

## Capfile

Parmi les fichiers fraichement générés, vous devriez trouver le nouveau
{l-en Capfile}. Ci-dessous, l'ancienne version de notre {l-en Capfile} suivie
de la nouvelle :

Capistrano 2 :

``` ruby
load "deploy"
load "deploy/assets"
Dir["vendor/gems/*/recipes/*.rb","vendor/plugins/*/recipes/*.rb"].each { |plugin| load(plugin) }
load "config/deploy"
```

Capistrano 3 :

``` ruby
require "capistrano/setup"
require "capistrano/deploy"

require "capistrano/bundler"
require "capistrano/rails/assets"
require "capistrano/rails/migrations"
require "whenever/capistrano"

Dir.glob("lib/capistrano/tasks/*.cap").each { |r| import r }
```

Votre nouveau {l-en Capfile} va contenir deux lignes commentées à propos du
support pour `rvm` et `rbenv`. Nous n'utilisons ni l'un ni l'autre pour gérer
Ruby sur nos serveurs je ne peux pas donc vous en dire long sur le sujet.

``` ruby
require "capistrano/rvm"
require "capistrano/rbenv"
```

## Configuration multistage

Comme vous pouvez le voir ci-dessous, la configurations des {l-en stages} ne
change pas vraiment. Il y a cependant une chose à laquelle vous devez prêter
particulièrement attention. La façon de signifier à Capistrano une révision à
déployer a changé. Si vous faites du déploiement continu avec Capistrano, vous
avez probablement déjà vu la ligne suivante :

    bundle exec cap -S revision=$REVISION production deploy

`REVISION` est une variable d'environnement que Semaphore exporte durant le
déploiement et Capistrano 2 l'utilisait comme paramètre. Avec Capistrano 3, cela
n'est plus possible et vous devez donner à la variable `branch` la révision ou
la branche que vous souhaitez déployer. Il était déjà possible de spécifier une
branche en configuration :

``` ruby
set :branch, ENV["BRANCH_NAME"] || "master"
```

Il nous suffit donc d'ajouter `ENV["REVISION"]` à la liste.

``` ruby
set :branch, ENV["REVISION"] || ENV["BRANCH_NAME"] || "master"
```

Cela fait partie des choses non documentées et il faut fouiller les sources ou
poser la question pour le savoir. L'un dans l'autre, le changement est assez
simple.

Le fichier suivant est notre `config/deploy/production.rb`.

Capistrano 2 :

``` ruby
server "server1.example.com", :app, :web, :db, :primary => true, :jobs => true
server "server2.example.com", :app, :web, :jobs => true

set :branch, ENV["BRANCH_NAME"] || "master"
```

Capistrano 3 :

``` ruby
set :stage, :production

server "server1.example.com", user: "deploy_user", roles: %w{web app db}
server "server2.example.com", user: "deploy_user", roles: %w{web app}

set :branch, ENV["REVISION"] || ENV["BRANCH_NAME"] || "master"
```

## Configuration principale - `config/deploy.rb`

C'est ici que les plus gros changements auront lieu. Voici ce à quoi il faut
faire attention :

1. Vous n'avez plus besoin d'appeler `capistrano/ext/multistage` ou
   `bundler/capistrano`. Le {l-en multistage} est supporté en standard et le
   support de Bundler est fait dans le fichier Capfile.
2. Il n'est pas nécessaire de lister les {l-en stages} disponible ou celui par
   défaut.
3. La variable pour régler l'url de dépôt source a changé de `repository` à
   `repo_url`.
4. `deploy_via :remote_cache` n'est plus nécessaire. La façon dont Capistrano
   gère les dépôts a beaucoup changé, il maintient maintenant un mirroir du
   dépôt sur votre serveur.
5. L'option PTY est activée par défaut.
6. `ssh_options` a un peu changé je crois mais les réglages de base sont à peu
   près les mêmes.
7. Capistrano prend maintenant en charge les liens symboliques dont vous avez
   besoin. Il vous suffit de lui dire de parcourir `linked_files` and
   `linked_dirs`.
8. Si vous n'utilisez ni `rvm` ni `rbenv`, vous devez surcharger les commandes
   `rake` et `rails` (voyez le fichier deploy.rb de Capistrano 3).

L'écriture de {l-en tasks} a également changé et il est nécessaire de fouiller
la documentation pour écrire ce que vous voulez. La bibliothèque utilisée en
dessous est [SSHKit](https://github.com/capistrano/sshkit) qui semble bien
sympathique.

**Astuce :** avec Capistrano 2 vous pouviez écrire `var_name` et obtenir sa
valeur. Avec la nouvelle version, vous devez toujours utiliser
`fetch(:var_name)`. Il m'a fallut un certain temps pour le comprendre alors que
je reprenais une {l-en task} que l'on utilise pour gérer nos {l-en workers}.

Capistrano 2 :

``` ruby
require "capistrano/ext/multistage" #1
require "bundler/capistrano"

set :application, "webapp"
set :stages, %w(production staging)
set :default_stage, "staging" #2

set :scm, :git
set :repository,  "git@github.com:example/webapp.git" #3
set :deploy_to, "/home/deploy_user/webapp"
set :deploy_via, :remote_cache #4

default_run_options[:pty] = true #5
set :user, "deploy_user"
set :use_sudo, false

ssh_options[:forward_agent] = true #6
ssh_options[:port] = 3456

set :keep_releases, 20

namespace :deploy do

  desc "Restart application"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  desc "Prepare our symlinks" #7
  task :post_symlink, :roles => :app, :except => { :no_release => true } do
    ["config/database.yml", "config/config.yml"].each do |path|
      run "ln -fs #{shared_path}/#{path} #{release_path}/#{path}"
    end
  end

end

after  "deploy",                   "deploy:post_symlink"
after  "deploy:restart",           "deploy:cleanup"
before "deploy:assets:precompile", "deploy:post_symlink"
```

Capistrano 3 :

``` ruby
set :application, "webapp"

set :scm, :git
set :repo_url,  "git@github.com:example/webapp.git"
set :deploy_to, "/home/deploy_user/webapp"

set :ssh_options, {
  forward_agent: true,
  port: 3456
}

set :log_level, :info

set :linked_files, %w{config/database.yml config/config.yml}
set :linked_dirs, %w{bin log tmp vendor/bundle public/system}

SSHKit.config.command_map[:rake]  = "bundle exec rake" #8
SSHKit.config.command_map[:rails] = "bundle exec rails"

set :keep_releases, 20

namespace :deploy do

  desc "Restart application"
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join("tmp/restart.txt")
    end
  end

  after :finishing, "deploy:cleanup"

end
```

## Conclusion

Le code que vous obtenez au final et plus propre et Capistrano 3/SSHKit semble
un mélange puissant. Quoi qu'il en soit, certaines bibliothèques comme
`whenever` et `bugsnag` ne supportent pas encore Capistrano 3, vous devrez donc
écrire leurs règles vous-même.
