[CmdletBinding()]
Param( $apppoolname, $sitename, $appname, $message, $binding
  )
  #Param(
  #  [Parameter(Mandatory = $True)]
  #[String]
  #  $apppoolname
  #)

Set-ExecutionPolicy Bypass -Scope Process

Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServer -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementScriptingTools -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementService -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET45 -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASP -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WindowsAuthentication -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementConsole -All
Enable-WindowsOptionalFeature -Online -FeatureName Application-Server-WebServer-Support -All
Enable-WindowsOptionalFeature -Online -FeatureName Application-Server-HTTP-Activation -All

Import-Module WebAdministration

New-Item -Path "IIS:\AppPools" -Name $apppoolname -Type AppPool
Set-ItemProperty -Path "IIS:\AppPools\$apppoolname" -name "managedRuntimeVersion" -value "v4.0"
Set-ItemProperty -Path "IIS:\AppPools\$apppoolname" -name "enable32BitAppOnWin64" -value $false
Set-ItemProperty -Path "IIS:\AppPools\$apppoolname" -name "autoStart" -value $true
Set-ItemProperty -Path "IIS:\AppPools\$apppoolname" -name "processModel" -value @{identitytype="ApplicationPoolIdentity"}
Set-ItemProperty -Path "IIS:\AppPools\$apppoolname" -name "managedPipelineMode" -value 0
if ([Environment]::OSVersion.Version -ge (new-object 'Version' 6,2)) {
    Set-ItemProperty -Path "IIS:\AppPools\$apppoolname" -name "startMode" -value "OnDemand"
}

New-Item -Path "C:\inetpub\wwwroot" -Name $sitename -ItemType "directory"

New-Item -Path "IIS:\Sites" -Name $sitename -Type Site -Bindings @{protocol="http";bindingInformation="*:${binding}:"}
Set-ItemProperty -Path "IIS:\Sites\$sitename" -name "applicationpool" -value $apppoolname
Set-ItemProperty -Path "IIS:\Sites\$sitename" -name "physicalPath" -value "C:\inetpub\wwwroot\$sitename"
Set-ItemProperty -Path "IIS:\Sites\$sitename" -Name "id" -Value 4
#New-ItemProperty -Path "IIS:\Sites\$sitename" -Name "bindings" -Value (@{protocol="http";bindingInformation="*:8022:"}, @{protocol="http";bindingInformation="*:8023:"})
Start-Website -Name "$sitename"

New-Item -Path "C:\inetpub\wwwroot\$sitename" -Name $appname -ItemType "directory"

New-Item -Path "IIS:\Sites\$sitename" -Name $appname -Type Application -Applicationpool $apppoolname
Set-ItemProperty -Path "IIS:\Sites\$sitename\$appname" -name "physicalPath" -value "C:\inetpub\wwwroot\$sitename\$appname"

New-Item -Path "C:\inetpub\wwwroot\$sitename\$appname" -Name "index.html" -ItemType "file" -Value "<HTML>
   <HEAD>
      <TITLE>
         Hello World!
      </TITLE>
   </HEAD>
<BODY>
   <H1>Hello World!</H1>
   <P>This website was deployed by Puppet and triggered from SMAX'.</P>
   <P>Custom message: $message</P>
</BODY>
</HTML>"
