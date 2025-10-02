# Terraform EKS Cluster Project

Este proyecto utiliza Terraform para desplegar un clúster de EKS en AWS y automatiza el despliegue de aplicaciones a través de GitHub Actions.

## Prerrequisitos

* AWS CLI v2 (versión actualizada recomendada).
* Terraform.
* **GitHub CLI (gh)**.
* Una cuenta de AWS con acceso a IAM Identity Center (SSO).

---
## Actualización de Secretos para GitHub Actions

El pipeline de CI/CD en GitHub Actions necesita credenciales temporales de AWS para ejecutarse. Como estas credenciales expiran, deben actualizarse manualmente antes de cada sesión de trabajo. El siguiente proceso utiliza el **GitHub CLI (`gh`)** para actualizar los secretos de forma segura y automatizada desde la terminal.

### Configuración Única (Primera Vez)

1.  **Instalar GitHub CLI:** (Ejemplo para macOS con Homebrew)
    ```bash
    brew install gh
    ```

2.  **Autenticar GitHub CLI:**
    Este comando abrirá tu navegador para que inicies sesión en tu cuenta de GitHub. Sigue los pasos interactivos.
    ```bash
    gh auth login
    ```

### Flujo de Trabajo para Actualizar Secretos

Sigue esta secuencia cada vez que necesites ejecutar el pipeline de GitHub Actions.

1.  **Navega a la Carpeta Raíz del Proyecto.**

2.  **Inicia Sesión en AWS SSO:**
    Reemplaza `TuNombreDePerfil` con el nombre de tu perfil (ej: `CRomero`).
    ```bash
    aws sso login --profile TuNombreDePerfil
    ```

3.  **Carga las Credenciales en tu Terminal:**
    Este comando carga las nuevas credenciales como variables de entorno en tu sesión actual.
    ```bash
    eval $(aws configure export-credentials --profile TuNombreDePerfil --format env)
    ```
    Para confirmar que las variables se establecieron, se puede ejecutar:
    ```bash
    printenv | grep AWS
    ```
    
4.  **Envía las Credenciales a los Secretos de GitHub:**
    Estos comandos toman las variables de tu terminal y las envían de forma segura a los secretos de tu entorno `production` en GitHub.
    ```bash
    gh secret set AWS_ACCESS_KEY_ID --env production --body "$AWS_ACCESS_KEY_ID"
    gh secret set AWS_SECRET_ACCESS_KEY --env production --body "$AWS_SECRET_ACCESS_KEY"
    gh secret set AWS_SESSION_TOKEN --env production --body "$AWS_SESSION_TOKEN"
    ```
Después de completar estos pasos, puedes ir a la pestaña "Actions" de tu repositorio y ejecutar el workflow.

---
## Autenticación Local (Para Terraform)

Si solo necesitas ejecutar comandos de Terraform en tu máquina local, sigue estos pasos.

1.  **Inicia sesión en AWS SSO:**
    Reemplaza `TuNombreDePerfil` con tu perfil (ej: `CRomero`).
    ```bash
    aws sso login --profile TuNombreDePerfil
    ```

2.  **Carga las Credenciales en el Entorno:**
    ```bash
    eval $(aws configure export-credentials --profile TuNombreDePerfil --format env)
    ```

## Uso de Terraform (Local)

Una vez autenticado localmente, puedes usar los comandos estándar de Terraform desde el directorio `eks-tf`.

1.  **Inicializar:** `terraform init`
2.  **Planificar:** `terraform plan`
3.  **Aplicar:** `terraform apply`

---

## Troubleshooting

#### Error: `InvalidClientTokenId` durante `terraform init`

* **Síntoma:** `terraform init` o el workflow de GitHub Actions fallan con un error de autenticación, incluso después de un `aws sso login` exitoso.
* **Causa Raíz:** Las credenciales temporales de SSO han expirado. En el caso del workflow, también puede deberse a un error al copiar/pegar manualmente los secretos.
* **Solución:** Sigue el flujo de trabajo correspondiente para actualizar las credenciales:
    * Para ejecuciones locales, sigue la sección **"Autenticación Local"**.
    * Para el pipeline de CI/CD, sigue la sección **"Actualización de Secretos para GitHub Actions"**.