@echo off
@echo on
setlocal enabledelayedexpansion

:: Configuration
set ORG=<git-organization-name>
set TEMPLATE_PATH=<path-to-template-file>
set WORKFLOW_DIR=.github\workflows
set WORKFLOW_FILE=%WORKFLOW_DIR%\<workflow-filename>
set BRANCH_NAME=<branch-name>
set COMMIT_MESSAGE=<commit-message>
set REPO_LIST=<path-to-repo-list>

:: Vérifier que le fichier template existe
if not exist "%TEMPLATE_PATH%" (
    echo ❌ ERREUR: Le fichier template "%TEMPLATE_PATH%" n'existe pas !
    exit /b 1
)

:: Vérifier que le fichier contenant la liste des repos existe
if not exist "%REPO_LIST%" (
    echo ❌ ERREUR: Le fichier "%REPO_LIST%" contenant la liste des dépôts n'existe pas !
    exit /b 1
)

:: Lire la liste des dépôts depuis le fichier des repos
for /f "tokens=*" %%R in (%REPO_LIST%) do (
    echo 📥 Clonage du dépôt : %%R...
    gh repo clone %ORG%/%%R
    cd %%R

    :: Créer le dossier du workflow
    mkdir %WORKFLOW_DIR% 2>nul

    :: Copier le fichier template
    copy "%TEMPLATE_PATH%" "%WORKFLOW_FILE%" /Y

    :: Ajouter, commit et push
    git checkout -b %BRANCH_NAME%
    git add %WORKFLOW_FILE%
    git commit -m %COMMIT_MESSAGE%
    :: git push --set-upstream origin %BRANCH_NAME%
    git push -f

    :: Nettoyage
    cd ..
    rmdir /s /q %%R
)

echo ✅ Ajout du workflow terminé pour tous les dépôts !
