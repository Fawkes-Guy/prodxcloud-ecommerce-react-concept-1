# Terraform EKS Cluster Project

Este proyecto utiliza Terraform para desplegar un clúster de EKS en AWS.

## Prerrequisitos

* AWS CLI v2 (versión actualizada recomendada).
* Terraform.
* Una cuenta de AWS con acceso a IAM Identity Center (SSO).

## Autenticación en AWS (SSO)

Para que Terraform pueda interactuar con tu cuenta de AWS, necesita credenciales temporales. El siguiente método es la forma estándar y recomendada para iniciar una sesión de trabajo.

Sigue esta secuencia cada vez que inicies una nueva sesión en la terminal:

1.  **Inicia sesión en AWS SSO:**
    Este comando abrirá tu navegador para que te autentiques. Reemplaza `TuNombreDePerfil` con el nombre de tu perfil (ej: `CRomero`).
    ```bash
    aws sso login --profile TuNombreDePerfil
    ```

2.  **Exporta y Carga las Credenciales en el Entorno:**
    Elige **uno** de los siguientes métodos. El **Método 1** es el más rápido y recomendado.

    ### Método 1: Carga Automática (Formato `env`)
    Este comando extrae las credenciales y las carga en tu sesión actual automáticamente. Es compatible con todas las versiones del AWS CLI v2.
    ```bash
    eval $(aws configure export-credentials --profile TuNombreDePerfil --format env)
    ```

    ### Método 2: Carga Manual (Formato `json`)
    Este método es útil si necesitas ver o depurar las credenciales. Requiere una versión actualizada del AWS CLI.

    **Paso 2.1: Exporta las credenciales a formato JSON.**
    ```bash
    aws configure export-credentials --profile TuNombreDePerfil --format json
    ```
    La salida será un objeto JSON. Copia los valores de `AccessKeyId`, `SecretAccessKey` y `SessionToken`.

    **Paso 2.2: Establece las variables de entorno manualmente.**
    ```bash
    export AWS_ACCESS_KEY_ID="VALOR_DE_AccessKeyId"
    export AWS_SECRET_ACCESS_KEY="VALOR_DE_SecretAccessKey"
    export AWS_SESSION_TOKEN="VALOR_DE_SessionToken"
    ```

## Uso de Terraform

Una vez autenticado, puedes usar los comandos estándar de Terraform desde el directorio `eks-tf`.

1.  **Inicializar el proyecto:**
    ```bash
    terraform init
    ```

2.  **Planificar los cambios:**
    ```bash
    terraform plan
    ```

3.  **Aplicar los cambios:**
    ```bash
    terraform apply
    ```

---

## Troubleshooting

#### Error: `InvalidClientTokenId` durante `terraform init`

* **Síntoma:** `terraform init` falla con un error de autenticación a pesar de haber ejecutado `aws sso login` con éxito y de que comandos como `aws sts get-caller-identity` funcionan correctamente.

* **Causa Raíz:** Se ha identificado una inconsistencia en cómo algunas versiones del proveedor de Terraform para AWS leen las credenciales del caché de SSO (`~/.aws/sso/cache`). El proveedor puede fallar en usar las credenciales que el AWS CLI sí puede leer y validar sin problemas.

* **Solución:** La solución es no depender del mecanismo "automático" de Terraform para encontrar las credenciales. El flujo de trabajo descrito en la sección de **Autenticación en AWS (SSO)** resuelve este problema al forzar las credenciales en el entorno de la terminal, un método que Terraform siempre prioriza y entiende correctamente.