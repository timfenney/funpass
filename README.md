# funpass

## Rationale

This is just for fun! Seriously, this is a little utility to generate
passwords for all the accounts I have strewn about the ether. When
it comes to online passwords, there are a few options:

* short, cryptic passwords, which are difficult to remember and tend to be
insecure anyway (eg. a98sj2;H3K)
* longer, more memorable "wordy" passwords (eg. cowsdefenestrate17CATS;)
* passwords too long and too cryptic to remember, which are typically
difficult to manage

funpass takes a different tack on passwords, one suggested by a professor of
mine, [Dr. Dave Mason](http://www.sarg.ryerson.ca/~dmason/).

The idea is simple: generate passwords as a function of a secret key, and the
account which needs them. So if my secret key is '145', I can generate
password = f('145', 'my.email@example.com') and get the same result every
time.

This way, the only thing I need to do to get all my passwords on a new
machine is to install funpass, and plug in my secret key file.

## Usage

`ruby funpass.rb init` will init your ~/.funpass/secret file. You may destroy
it with `ruby funpass.rb scrunch`. After init'ing your secret key file,
you may generate new (or regenerate old!) passwords with
`ruby funpass.rb gen username@somedomain.com`. (Really, any argument may be
supplied to `gen`; but make sure you can supply the same argument next
time!)

## Security

What? You thought this was secure ? ;-)

Please don't use this for anything serious. In the future, it may be
possible to encrypt the secret using GPG or something.

## The Future

A future goal is to not only seed the Ruby Pseudo Random Number Generator
srand function, but to monkeypatch its ass out of town!

This should make it easier to use other libraries' code which may have
interesting types of passwords available. By preventing further
calls to srand & friends, we may ensure that the generated passwords
are a function of the secret key and the password attributes chosen.

Who knows, maybe soon funpass will even encrypt your secret key ;-)
