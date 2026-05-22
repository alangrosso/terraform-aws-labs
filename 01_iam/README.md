# **Terraform y AWS: IAM**

Objetivo: crear un usuario para que pueda ser utilizado en conjunto con otros servicios.

## **Instalar**

Instalar Terraform y AWS para el manejo de infraestructura como código en MacOS.

```bash
# Terraform
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# AWS
brew install awscli
```

Verificar

```bash
terraform -v
aws --version
```

## **Estructura del Proyectos**

Crear directorio para desarrollo del proyecto. En este caso solo utilizaremos un servicio: IAM. 

```bash
mkdir iam
```

Por lo general se recomienda que cada servicio vaya en un directorio específico.

## **Archivos de Terraform**

Los principales archivos de Terraform son:

`variables.tf`: Define el esquema y metadatos de, por ejemplo, el usuario, los parámetros (ej. la región o el nombre del servidor), los valores que cambian (como el tipo de instancia).
`terraform.tfvars`: Asigna valores reales a las variables.
`main.tf`: El cuerpo (los recursos de AWS). Ejemplo, la infraestructura (VPC, Instancias). Vinculado a variables.tf.
`providers.tf`: La interfaz entre Terraform y las APIs de la nube (AWS, GCP, Azure). Contiene la configuración de AWS y la región.
`outputs.tf`: Lo que quieres que Terraform te devuelva al final (ej. la IP del servidor).

```bash
cd iam
touch variables.tf terraform.tfvars main.tf providers.tf outputs.tf
```

## **Lista de Comandos de Terraform**

`terraform init`: Descarga los plugins.
`terraform fmt`: Formatea tu código automáticamente (limpieza visual).
`terraform validate`: Revisa que no tengas errores de sintaxis.
`terraform plan`: Genera un plan.
`terraform plan -out=v1_plan`: Generar un plan y guardarlo. Revisar qué se va a crear.
`terraform apply`: Actualizar infraestructura.
`terraform apply "v1_plan"`: Aplica exactamente lo que revisaste en el paso anterior (al ejecutar `terraform plan -out=v1.plan`).
`terraform show`: Ver recursos creados.
`terraform destroy`: Limpiar recursos.

Al generar los servicios con Terraform debemos tener en cuenta el manejo del "State" (el cerebro de Terraform):

- Terraform crea un archivo llamado `terraform.tfstate`.
- Este archivo contiene información sensible (como contraseñas en texto plano).
- Buena práctica: Nunca lo subas a GitHub. Agrega *.tfstate* a tu archivo `.gitignore`.
- Eventualmente, configura un S3 Backend para guardar este estado de forma remota y segura en AWS, no en local.
- Si el `providers.tf` de IAM no está bien configurado, no podrá autenticarse para leer el archivo de estado `.tfstate` ni para crear el usuario.

## **Configurar AWS**

### Usuario Manager

Crear usuario IAM (Identity and Access Management) desde consola de AWS con el fin de no utilizar el usuario root. El usuario creado será el "manager" de Terraform que permitirá crear otros servicios para cualquier proyecto. En este proyecto, este usuario es el "principal" que permitirá que Terraform cree cualquier usuario "secundario".

1. Ir a la consola de AWS -> IAM -> Users.
2. Crea un usuario manager (ejemplo: `manager-terraform`).
3. En Permissions policies, asígnale la política `AdministratorAccess`.
4. En Security Credentials, crea un "Access Key" y un "Secret Access Key" y descarga el CSV. Estos datos serán utilizados por la CLI de AWS.
5. En la terminal configurar y crear un perfil para la labor que desees realizar e ingresa esas llaves. Se puede manejar múltiples perfiles (uno para cada proyecto) usando `profile`. Ejemplo:

```bash
aws configure --profile default
aws configure --profile manager-terraform
```

Ingresar los datos requeridos:

- Access Key ID: El del usuario manager-terraform.
- Secret Access Key: El del usuario manager-terraform.
- Region: us-east-1.
- Format: json.

En el caso que tengamos varios usuarios, podemos determinar el usuario por defecto:

```bash
export AWS_PROFILE=manager-terraform
```

## Creación de Serivicios: IAM

Para lograr el objetivo del proyecto se creará un usuario IAM secundario para utilizarlo con otros servicios. 

Generar recursos:

```bash
terraform init
terraform fmt
terraform validate
terraform plan -out="aws_iam"
terraform apply "aws_iam"
terraform show
```

Consideraciones al utilizar `outputs.tf`: podemos obtener los valores configurados en este fichero con los siguientes comandos:

```bash
terraform output -json
terraform output -json [NOMBRE_DEL_OUTPUT]
```

- Como queremos usar este nuevo usuario en el futuro, necesitamos que Terraform nos "entregue" sus llaves al terminar. Por este motivo se utiliza outputs.
- Tener en cuenta que al crear un usuario con `aws_iam_access_key`, la llave secreta se guardará en texto plano dentro de tu archivo `terraform.tfstate`.
- Como marcamos el `secret_access_key` como sensitive, Terraform no lo mostrará directamente en la pantalla por seguridad. Para verlo después del terraform apply, debes ejecutar:

```bash
terraform output -json secret_access_key
```

## Eliminar servicios desde Terraform:

```bash
terraform destroy
```

Verificar estado de servicios: no deberían encontrarse los servicios eliminados.

```bash
aws iam list-users --profile manager-terraform
```

## **Fin**
