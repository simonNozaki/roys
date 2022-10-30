# Roys
[Rails tutorial](https://railstutorial.jp/) "Toys"!

* Ruby version
```
$ ruby -v
ruby 2.6.10p210 (2022-04-12 revision 67958) [x86_64-darwin19]
```

* System dependencies

```
$ rails -v
Rails 6.1.7
```

## Requirements
```
$ gem install bundler

$ bundle install
```

Install package for language server suport
```
$ gem install solarpgraph
```

Migration of sqlite
```
$ rails db:migrate
```

```
$ rails webpacker:install
```

## Unit test
Only model test
```
$ rails test:models
```

Only integration tests
```
$ rails test:integration
```
