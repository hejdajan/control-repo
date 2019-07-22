
class sqltest (
  Sensitive $sqlpassword = lookup('sqltest::sqlpassword'),
) {

  include chocolatey

  package { 'dotnet3.5':
    ensure   => 'present',
    provider => 'chocolatey',
    notify   => Reboot['dotnet_reboot'],
  }

  package { 'dotnet4.5':
    ensure   => 'present',
    provider => 'chocolatey',
    notify   => Reboot['dotnet_reboot'],
  }

  package { 'powershell':
    ensure   => 'present',
    provider => 'chocolatey',
    notify   => Reboot['dotnet_reboot'],
  }

  package { 'sql2014-powershell':
    ensure   => 'present',
    provider => 'chocolatey',
    notify   => Reboot['dotnet_reboot'],
  }

  reboot { 'dotnet_reboot':
    when => 'pending',
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
