class { 'hiera':
  hierarchy => [
    'nodes/%{trusted.certname}',
    'common',
  ],
}
