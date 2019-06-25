class { 'hiera':
  hierarchy => [
    'nodes/%{trusted.certname}',
    '%{environment}',
    'common',
  ],
}
