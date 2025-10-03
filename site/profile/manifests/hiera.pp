## This is a hiera class

class { 'hiera':
  hierarchy => [
    'nodes/%{trusted.certname}',
    '%{environment}',
    'common',
  ],
}
