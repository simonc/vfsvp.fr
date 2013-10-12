---
author: Simon Courtois (simonc)
layout: post
title: "6 façons de réduire la souffrance due aux tests fonctionnels avec Rails"
date: 2013-10-12 13:00
comment: true
categories:
- rails
- ruby
- tests
---

Source: [6 Ways to Remove Pain From Feature Testing in Ruby on Rails de Mitch Lloyd](http://gaslight.co/blog/6-ways-to-remove-pain-from-feature-testing-in-ruby-on-rails)

L'écriture des tests fonctionnels a été une des parts les plus douloureuses de
mon travail avec Ruby on Rails. Mais aujourd'hui c'est quelque chose que
j'apprécie et voici pourquoi :

## 1. Je n'utilise pas Cucumber

**Attention:** Le point de vue exprimé dans le paragraphe suivant ne reflète pas
forcement celui de l'équipe ou des partenaires de Gaslight Software, LLC.

Si vous avez installé Cucumber, supprimez-le. Les tests sont déjà assez
difficiles sans que l'on ait besoin de transformer le langage naturel en code
Ruby.

<!-- more -->

J'utilise :

* Rspec -- DSL spécialisé dans les tests
* FactoryGirl -- Constructeur de modèles
* Capybara -- DOM Dominator
* Database Cleaner - Nettoyeur de bases de données
* Spring - Accélérateur de démarrage

Et j'en suis très content. Écrivons une spec.

``` ruby
feature 'Navigating through workpapers' do
  let(:user) { create(:user) }
  let(:audit) { create(:audit, users: [user]) }

  scenario "User sees workpapers within an audit" do
    workpaper = create(:workpaper, audit: audit)

    visit '/'
    fill_in 'email', with: user.email
    fill_in 'password', with: 'password'
    click_on 'Log In'

    find('#audit-selector').select audit.name
    expect(page).to have_css?('.workpaper', text: workpaper.name)
  end
end
```

Tout cela est plutôt pas mal mais une _feature_ un peu plus complexe deviendrait
vite illisible. La logique de connexion va immanquablement être dupliquée entre
plusieurs tests. Même cette _feature_ n'est pas aussi lisible que je le
souhaiterais.

## 2. Utilisez des _Page Objects_

Les sélecteurs Capybara ont une forte probabilité de casser au fur et à mesure
que le développement avance. Le responsable du contenu décide que le bouton du
formulaire de connexion va maintenant indiquer "Connectez-vous à un monde où
tout est possible", vous devez maintenant corriger tous vos tests.

Les _page objects_ sont des interfaces spécifiques à votre DOM. Lorsque le HTML
change, vous saurez exactement où corriger cela dans vos tests.

Voici un _page objet_ "page de connexion" :

``` ruby
class LoginPage
  include Capybara::DSL

  def visit_page
    visit '/'
    self
  end

  def login(user)
    fill_in 'email', with: user.email
    fill_in 'password', with: 'password'
    click_on 'Log In'
  end
end
```

Voici un autre _page object_ "index des documents" :

``` ruby
class WorkpaperIndexPage
  include Capybara::DSL

  def select_audit(audit)
    find('#audit-selector').select audit.name
  end

  def has_workpaper?(workpaper)
    has_css?('.workpaper', text: workpaper.name)
  end
end
```

Et voici maintenant un test utilisant ces _page objects_ :

``` ruby
feature 'Navigating through workpapers' do
  let(:user) { create(:user) }
  let(:audit) { create(:audit, users: [user]) }
  let(:login_page) { LoginPage.new }
  let(:workpaper_page) { WorkpaperIndexPage.new }

  scenario "User sees workpapers within an audit" do
    workpaper = create(:workpaper, audit: audit)

    login_page.visit_page.login(user)
    workpaper_page.select(audit)
    expect(workpaper_page).to have_workpaper(workpaper)
  end
end
```

Considérons maintenant que quelqu'un modifie sans arrêt ce bouton de connexion.
Vous avez simplement à modifier `LoginPage` et utiliser un ID ou une entrée I18n
(ce qui aurait été une bonne idée dés le départ). Vous n'avez à vous inquiéter
d'aucun autre test, tout ce qui concerne cette page est contenu dans ce _page
object_.

Ces objets sont assez simples mais peuvent tout à fait grossir pour fournir des
fonctionnalités supplémentaires comme la vérification d'erreurs au fur et à
mesure que l'utilisateur au travers des pages (ou sections) du site. Le retour
sur investissement des _page objects_ est si rapide que j'utilise toujours ce
type d'objet dans mes tests fonctionnels. De la même façon que je n'écris jamais
de SQL dans mes vues Rails, je n'accède pas au DOM depuis un test fonctionnel
sans _page object_.

## 3. Créer des messages d'erreur utiles

Un test fonctionnel qui échoue peut être difficile à diagnostiquer. Mettons que
vous utilisez un _page object_ comme ceci :

``` ruby
expect(workpaper_page).to have_one_workpaper(workpaper)
```

    Failure/Error: expect(workpaper_page).to have_one_workpaper(workpaper)
      expected #has_one_workpaper?(workpaper) to return true, got false

L'erreur est lisible mais il serait plus facile de savoir si elle est provoquée
par l'absence du document ou si la présence d'autres documents.

En général, je lève une exception lorsque j'appelle ce genre de prédicat sur
un _page object_.

    Failure/Error: expect(workpaper_page).to have_one_workpaper(workpaper)
      PageExpectationNotMetError:
        expected one workpaper called "My Sweet Workpaper", but the following
        workpapers were on the page:
          * "Bogus Workpaper"
          * "My Sweet Workpaper"

J'utilise cette technique avec modération et je cherche toujours une approche
plus élégante. Cela me donne tout de même des messages d'erreur plus précis et
m'épargne quelques aller-retours avec le navigateur. Faites moi signe si vous
utilisez une autre technique de retour d'erreur dans vos tests.

## 4. Embrassez les tests asynchrones

Une grande part de la frustration relative aux tests automatisés dans un
navigateur est due aux assertions qui doivent attendre. Ajouter un `sleep` à vos
tests est passable si vous pensez que l'un de vos tests a un souci de timing
mais un `sleep` ne devrait jamais se trouver dans votre code de test final.

Les tests clignotants (ceux qui échouent de façon intermittente) tuent la
confiance que vous avez envers votre suite de tests. Ils devraient être corrigés
ou supprimés.

En général, je conseille surtout de bien apprendre l'API de Capybara. Voici
quelques pointeurs :

* `#all` n'attend pas, ce n'est dont probablement pas le _matcher_ que vous
  cherchez ;
* La méthode `#has_css?` peut prendre un compteur en paramètre de façon à
  indiquer combien d'éléments vous voulez attendre ;
* Écrire un test comme `expect(page).to_not have_css('.post')` est, en général,
  une mauvaise idée. Ce matcher attend l'apparition d'éléments `.post` pour
  passer ce qui peut engendrer un certain ralentissement. Dans ce genre de cas,
  il est préférable d'utiliser `expect(page).to have_no_css('.post')` qui
  passera immédiatement si les éléments sont absents de la page ou attendra
  leur disparition s'ils sont présents. Dans ce dernier cas, il vaut mieux
  s'assurer de leur présence au préalable.

Il peut arriver que vous souhaitiez attendre que quelque chose se produise en
dehors de Capybara. Pour cela, [ce helper](https://gist.github.com/mattwynne/1228927)
`eventually` est très pratique :

Le code suivant attend que le document soit _awesome_ et échoue si ce n'est pas le cas après deux secondes.

``` ruby
eventually { expect(workpaper).to be_awesome }
```

Quand pourriez-vous avoir besoin de ce type d'assertion en dehors de Capybara ?
Lisez la suite…

## 5. Prenez la construction de données au sérieux

Je me souviens avoir entendu un mantra pour les tests fonctionnels qui disait
"Tout faire du point de vue de l'utilisateur". Ce conseil visait à l'origine à
décourager les testeurs de manipuler les données directement dans les tests
fonctionnels. Je peux vous assurer que c'était un mauvais conseil. Il est juste
impensable d'inscrire un utilisateur et de passer au travers de vingt autres
étapes simplement pour le faire cliquer sur un bouton.

J'utilise beaucoup FactoryGirl pour mettre en place mes données de test. Cela
signifie que j'ai des factories permettant de générer des objets complexes.
Voici, par exemple, comment faire un document avec un workflow ayant des étapes
assignées à certains utilisateurs appelés `preparers` et `reviewers`.

``` ruby
FactoryGirl.define do
  factory :workpaper do
    sequence(:name) {|n| "workpaper #{n}"}

    factory :assigned_workpaper do
      ignore do
        preparer { create(:user) }
        reviewer { create(:user) }
      end

      after(:create) do |workpaper, evaluator|
        create(:assigned_workflow, workpaper: workpaper, preparer: evaluator.preparer, reviewer: evaluator.reviewer)
      end
    end
  end

  factory :workflow do
    factory :assigned_workflow do
      ignore do
        preparer { create(:user) }
        reviewer false
      end

      after(:create) do |workflow, evaluator|
        create(:step, workflow: workflow, user: evaluator.preparer)

        if evaluator.reviewer
          create(:step, workflow: workflow, user: evaluator.reviewer)
        end
      end
    end
  end

  factory :step
end
```

Cela me permet de créer de façon déclarative des objets spécifiques à mes tests.

``` ruby
create(:assigned_workpaper, preparer: first_user, reviewer: second_user)
```

Je crée toujours des instances de mes modèles via FactoryGirl dans mes tests
fonctionnels. Je suis fan de FactoryGirl mais je pense qu'il est possible de
faire encore mieux en ce qui concerne la construction de données complexes comme
celles-ci. Quel que soit l'outil utilisé, la mise en place des données de test
doit toujours être lisible et facilement exploitable.

Il est non seulement acceptable de mettre en place des données avant de
commencer vos tests mais il est également acceptable de vérifier les effets de
bord qui ne sont pas nécessairement visibles par l'utilisateur. Dans le monde
des applications en client riche par exemple, voir quelque chose à l'écran ne
signifie pas forcement que tout a été sauvegardé en base de données.

Tout comme nous avons des helpers pour construire nos données, nous devrions
avoir des helpers pour les inspecter. Ce test va s'assurer que le _preparer_
d'un document a été sauvegardé en base de données :

``` ruby
eventually { preparer_for(workpaper).should be(preparer) }
```

## 6. Créez moins de tests, affinez ceux existant

Lorsque j'ai commencé à écrire des tests fonctionnels avec Rails, on m'a donné
le conseil suivant "chaque test doit contenir une action et une assertion". J'ai
donc travaillé comme ceci :

* Écrire un scénario cucumber pour une fonctionnalité
* Faire fonctionner le code
* Écrire un scénario cucumber pour un autre aspect de la fonctionnalité
* Faire fonctionner le code

C'est une bonne méthodologie pour les tests unitaires mais c'est une mauvaise
idée en ce qui concerne les tests fonctionnels.

Prenons le test suivant :

``` ruby
scenario "assigning a reviewer to a workpaper" do
  user_visits_workpaper(user, workpaper)
  ui.begin_assigning_reviewer
  ui.assign_work_to(reviewer)
  eventually { expect(reviewer_for workpaper).to eq(other_tester) }
end
```

Lorsque l'on appelle `ui.begin_assigning_reviewer` une boite de dialogue
s'ouvre pour permettre à l'utilisateur de choisir qui qui sera le `reviewer`.
Cette fonctionnalité marche. Très bien.

Je veux maintenant m'assurer que le seuls les utilisateurs ayant le droit de
faire des relectures soient listés. Plutôt que de créer un nouveau test, je vais
affiner celui que je viens d'écrire :

``` ruby
scenario "assigning a reviewer to a workpaper" do
  user_visits_workpaper(user, workpaper)
  ui.begin_assigning_reviewer
  expect(ui).to have_excluded_user(non_reviewer)
  ui.assign_work_to(reviewer)
  eventually { expect(reviewer_for workpaper).to eq(other_tester) }
end
```

Je n'utiliserais bien sûr pas cette technique pour les tests unitaires mais elle
est efficace pour les tests fonctionnels dont le but est de guider votre
progression et détecter les régressions.

## Mais qui teste vos tests ?

Lorsque vos tests commencent à contenir beaucoup de logique, quelqu'un va finir
par vous dire "Mais qui teste vos tests ?" pour vous signifier que vos tests
sont trop compliqués, trop complexes. Votre code de production teste vos tests.
Ce n'est pas pour autant une excuse pour écrire de mauvais tests ou des tests
illisibles.

Les outils et techniques cités ci-dessus vont changer au fur et à mesure que le
temps passe mais j'ai augmenté ma sensibilité aux mauvais tests fonctionnels
pour toujours. Refactorez de façon agressive, concevez intelligemment et aimez
vos tests fonctionnels.
