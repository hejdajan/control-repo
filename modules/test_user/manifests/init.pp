class test_user {

  user { 'user123':
    ensure => present,
    password => Sensitive("Password1"),
    groups   => ['users'],
  }
}
