class system_users {

  user { 'myuser':
    ensure   => present,
    password => 'P@ssw0rd1',
    groups   => ['users'],
  }
}
