class users {

  user {'oneuser':
    ensure   => present,
    password => Sensitive("Password123"),
    groups   => ['users'],
  }
}
