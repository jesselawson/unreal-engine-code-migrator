<# 

UNREAL ENGINE PROJECT CODE MIGRATOR

-----------------------------------------------------------------------------
HOW TO USE:
-----------------------------------------------------------------------------

[1.] Create a folder somewhere outside of your Unreal Engine projects. Call it 
     something like "StagingArea". The name is not important, but for the rest 
     of these instructions, this folder will be referred to as the "Staging" folder.

[2.] Copy all the code you want to migrate into the Staging folder. 

[3.] Ensure this script is in the Staging folder along with all the code you want 
     to migrate.

[4.] Tell PowerShell to allow this script to run by setting PowerShell's execution policy
     to "Unrestricted." 

     [4.a.] To set PowerShell's remote execution policy to Unrestricted, you must open 
            a separate powershell window As Administrator. 

     [4.b.] In a PowerShell window As Administrator, execute the following:

            > Set-ExecutionPolicy Unrestricted

     [4.c.] When you execute that command, you'll be promoted to confirm that this is 
            what you want to do. "Yes To All" is the confirmation that I select. 

     [4.d.] You'll know you did it correctly when you can get your execution policy 
            and PowerShell tells you that it's "Unrestricted":

            > Get-ExecutionPolicy 

[5.] Configure the following variables based on your projects: #>

     $oldName = "Old"
     $newName = "New" 

     <# IMPORTANT: 
     
      |#| There are two kinds of strings we're replacing: 
     
        - Sentence-case strings, like the kind we find in a TSubClassOf<UObject> name
          (e.g., AOldPlayerController) and in the names of our files (e.g., OldPlayerController.h)

        - API strings, which are the ones we find in the class declarations
          (e.g., `class OLD_API AInteractableDataActor (etc)`

      |#| This script will automatically convert your $oldName and $newName to uppercase
          when replacing the API strings. 

        - For example, if $oldName is "MyGame" and $newName is "MyNewerGame", this script will 
          replace this -> `class MYGAME_API ASomeActor : public AActor`
             with this -> `class MYNEWERGAME_API ASomeActor : public AActor`

        - If this is NOT the behavior you want, DO NOT EXECUTE THIS SCRIPT until you 
          modify it to suit your needs. You may also create an issue in the public 
          repository with your specific use case and someone (probably me) may help you out. 
          
[6.] Execute this script by navigating to your Staging folder in PowerShell and executing
     the following command:

     > .\Migrate.ps1

[7.] When the script finishes, verify that the migration is complete by checking the 
     source files for accuracy. If things look good, continue to the next step. If 
     something seems off, please submit an issue in the public repository so that we
     can ensure this script is useful for as many devs as possible. 

[8.] With your newly migrated code in your Staging folder, manually move over your code 
     from the Staging folder into your new project's source directory. 


If you have any questions or feedback, please submit an Issue to the public repository
via the following link:

    https://github.com/jesselawson/unreal-engine-project-code-migrator

#>

#  ---------------------------------------------------------------------------
#    \
#     \
#      \
#    
#        Don't edit anything below this
#        unless you know what you are doing.
#      
#      /
#     /
#    /
#    ---------------------------------------------------------------------------

# Function to replace text in files
function Replace-TextInFile {
    param (
        [string]$filePath,
        [string]$searchText,
        [string]$replaceText
    )

    (Get-Content -Path $filePath) -replace $searchText, $replaceText | Set-Content -Path $filePath
}

# Function to rename files
function Rename-File {
    param (
        [string]$filePath,
        [string]$searchText,
        [string]$replaceText
    )

    $directory = [System.IO.Path]::GetDirectoryName($filePath)
    $fileName = [System.IO.Path]::GetFileName($filePath)
    $newFileName = $fileName -replace $searchText, $replaceText
    $newFilePath = [System.IO.Path]::Combine($directory, $newFileName)
    
    if ($newFilePath -ne $filePath) {
        Rename-Item -Path $filePath -NewName $newFileName
    }
}

# Main function to iterate over files and folders
function Process-FilesAndFolders {
    param (
        [string]$folderPath
    )

    $files = Get-ChildItem -Path $folderPath -Recurse -File
    $totalFiles = $files.Count
    $counter = 0

    foreach ($file in $files) {
        $counter++
        Write-Progress -Activity "Processing Files" -Status "$counter of $totalFiles" -PercentComplete (($counter / $totalFiles) * 100)

        # Replace text in file content

        # First, replace the API names:
        $oldName_API = $oldName.ToUpper()
        $newName_API = $newName.ToUpper()
        
        # Next, replace class declarations:
        Replace-TextInFile -filePath $file.FullName -searchText "class $oldName_API" -replaceText "class $newName_API"

        # Next, replace actor names:
        Replace-TextInFile -filePath $file.FullName -searchText "A$oldName" -replaceText "A$newName"

        # Next, replace any project-based include paths that use the old name:
        Replace-TextInFile -filePath $file.FullName -searchText "<$oldName" -replaceText "<$newName"

        # Finally, replace any filename in include paths that use the old name:
        Replace-TextInFile -filePath $file.FullName -searchText "/$oldName" -replaceText "/$newName"

        # You can add more replacements to file contents by adding your own call to Replace-TextInFile
        # here:

        

        # Replace old name with new name in the filenames:
        Rename-File -filePath $file.FullName -searchText "$oldName" -replaceText "$newName"
    }
}

# Start processing from the current directory
$currentDirectory = Get-Location
Process-FilesAndFolders -folderPath $currentDirectory