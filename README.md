# Unreal Engine Code Migrator

A PowerShell script to migrate your Unreal Engine project's C++ code to some other project.

## How to use

Follow the directions in the script, `Migrate.ps1`. 

**Be sure** to update the following variables in the script:

```powershell
$oldName = "Old"
$newName = "New" 
```

For example, if you are migrating from a project where the default 
player controller is `AJLG2PlayerController` to a project where 
the default player controller should be `ANewProjPlayerController`, 
you would configure the variables as follows:

```powershell
$oldName = "JLG2"
$newName = "NewProj" 
```

## Contributing

Contributions are welcome. Feel free to submit a pull request here. 

This repository is a mirror from my private Gitea instance. Accepted PRs 
will be merged and then this repo will be updated, and you will receive 
appropriate attribution here in the README. 

## Support

- [Buy me a coffee](https://buymeacoffee.com/jesselawson).