
class sqltest (
  Sensitive $sqlpassword = lookup('sqltest::sqlpassword'),
) {

  include chocolatey

  package { 'dotnet3.5':
    ensure   => 'present',
    provider => 'chocolatey',
    notify   => Reboot['dotnet reboot'],
  }

  package { 'dotnet4.5':
    ensure   => 'present',
    provider => 'chocolatey',
    notify   => Reboot['dotnet reboot'],
  }

  reboot { 'dotnet reboot':
    refreshonly => 'true',
  }

  file { 'C:\\MSSQLSERVER':
    ensure => 'directory',
  }

  file { 'C:\\MSSQLSERVER\\backupdir':
    ensure => 'directory',
  }

  file { 'C:\\MSSQLSERVER\\tempdbdir':
    ensure => 'directory',
  }

  file { 'C:\\MSSQLSERVER\\datadir':
    ensure => 'directory',
  }

  sqlserver_instance{ 'MSSQLSERVER':
    ensure                  => 'present',
    source                  => 'E:/',
    features                => ['SQL'],
    security_mode           => 'SQL',
    sa_pwd                  => $sqlpassword,
    sql_sysadmin_accounts   => ['administrator'],
    install_switches        => {
      'TCPENABLED'          => 1,
      'SQLBACKUPDIR'        => 'C:\\MSSQLSERVER\\backupdir',
      'SQLTEMPDBDIR'        => 'C:\\MSSQLSERVER\\tempdbdir',
      'INSTALLSQLDATADIR'   => 'C:\\MSSQLSERVER\\datadir',
      'INSTANCEDIR'         => 'C:\\Program Files\\Microsoft SQL Server',
      'INSTALLSHAREDDIR'    => 'C:\\Program Files\\Microsoft SQL Server',
      'INSTALLSHAREDWOWDIR' => 'C:\\Program Files (x86)\\Microsoft SQL Server',
    }
  }

  package { 'sql-server-management-studio':
    ensure   => 'present',
    provider => 'chocolatey',
  }

}
