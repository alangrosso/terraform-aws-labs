# **Terraform y AWS: IAM y S3**

Objetivo: Garantizar el aprovisionamiento automatizado de buckets de S3 dedicados para la ingesta de datos, considerando permisos de lectura y escritura a los usuarios específicos asignados

## **Requisitos**

- Instalar Terraform.
- Instalar AWS-CLI.
- Opcional: Configurar usuario de AWS (ejemplo: USUARIO_MANAGER) para no utilizar usuario root.

Verificar instalación:

```bash
terraform -v
aws --version
```

## **Estructura del Proyectos**

Aunque podrías poner todo en un solo `main.tf`, la buena práctica es dividir el código en archivos dentro del directorio de cada servicio y de esta manera Terraform gestiona los recursos de forma modular:

```bash
# crear directorio de proyecto
mkdir 02_iam_s3
cd 02_iam_s3

# archivos y directorios root
touch main.tf outputs.tf providers.tf variables.tf terraform.tfvars README.md
mkdir modules documents

# directorio que contiene ficheros que se subirán a S3
cd documents
touch conexion.txt
echo "Prueba de vínculo exitosa" > conexion.txt
mkdir datos
cd datos
touch archivo_1.txt archivo_2.csv archivo_3.xlsx archivo_4.parquet

# crear directorios de recursos en módulos
cd ../../modules
mkdir iam s3
cd iam
touch main.tf outputs.tf variables.tf
cd ../s3
touch main.tf outputs.tf variables.tf
```

```bash
# tree
├── documents
│   ├── conexion.txt
│   └── datos
│       ├── archivo_1.txt
│       ├── archivo_2.csv
│       ├── archivo_3.xlsx
│       └── archivo_4.parquet
├── main.tf
├── modules
│   ├── iam
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── s3
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── outputs.tf
├── providers.tf
├── README.md
├── terraform.tfvars
└── variables.tf
```

## **Determinar servicios**

Editar ficheros de acuerdo a los servicios requeridos. Tener en cuenta vinculación entre servicios.

### Módulo S3 (/modules/s3)

Este módulo no solo debe crear el bucket, sino asegurar el cumplimiento regulatorio (cifrado y bloqueo de Acceso Público).

- `main.tf`: Definición del bucket, configuración de seguridad, cifrado (encriptación), versionado (para evitar pérdida accidental de datos de riesgo).
- `variables.tf`: Definir variables que se utilizarán en el bucket.
- `outputs.tf`: Exportar los valores necesarios para que el módulo de IAM pueda usarlos.

### Módulo IAM (/modules/iam)

En lugar de usuarios, crearemos Roles específicos para los perfiles definidos.

- `main.tf`: Crear roles, para por ejemplo, Data Engineer (DE) y Data Scientists (DS), generar keys de acceso, caracteristicas del login, definir políticas (full access, restringido), vincular las políticas a los roles.
- `variables.tf`: Definir variables que se utilizarán en los perfiles y los datos de los buckets creados en el módulo S3 para realizar la vinculación sobre ellos.
- `outputs.tf`: Exportar los nombres de los roles para su uso en la consola de AWS.

### Root

- `providers.tf`: Contiene la configuración de AWS y la región.
- `main.tf`: Aquí es donde conectas ambos módulos. Es el "orquestador".
- `terraform.tfvars`: Valores de variables para la ejecución.
- `variables.tf`: Declaración de las variables definidias en el fichero `.tfvars` y que usará Terraform para parametrizar el despliegue.
- `outputs.tf`: Valores que Terraform devolverá al final de la ejecución.

## **Ejecución**

Ejecutar comandos de Terraform (en root)

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out="v1_aws_iam_s3"
terraform apply "v1_aws_iam_s3"
```

- En s3: terraform init y apply crean el bucket y el estado.
- En iam: terraform init y apply leen el estado de s3 y crea el usuario.

## **Verificación**

- Verificar outputs del provisionamiento de servicios:

```bash
terraform show
```

- Verificación estado de servicios mediante AWS CLI utlizando usuario manager:

```bash
# Listar buckets
aws s3 ls --profile USUARIO_MANAGER

# Listar usuarios
aws iam list-users --profile USUARIO_MANAGER
```

- Comprobar que los usuarios creados tienen las políticas adjuntas:

```bash
# Ver las políticas adjuntas al usuario
aws iam list-user-policies --user-name NOMBRE_USUARIO --profile USUARIO_MANAGER

aws iam list-attached-user-policies --user-name NOMBRE_USUARIO --profile USUARIO_MANAGER
```

- Resultado esperado: Deberías ver el nombre de las políticas definidos en `iam/main.tf`. Esto confirma que el usuario "lleva consigo" el permiso para entrar al bucket.

## **Ejecución**

Simulación de uso: la mejor forma de saber si los servicios están vinculados es actuar como el usuario creado. Para ello se debe configurar sus credenciales y tratar de interactuar con el bucket.

- Obtener las credenciales (`access_key_id` y `secret_access_key`): como se marcó el secreto como `sensitive`, se píde este valor a Terraform directamente:

```bash
terraform output
terraform output -json
terraform output NOMBRE_OUTPUT
```

- Configurar un perfil temporal:

```bash
# Ingresa el ID, el Secret, región (us-east-1), format (json)
aws configure --profile USUARIO_TEMPORAL

# Verificar usuario configurado
aws configure list-profiles

# Verificar que las credenciales de ese perfil son válidas y tienen conectividad con AWS
aws sts get-caller-identity --profile USUARIO_TEMPORAL

# Login
aws login

# Verificar permisos de cada perfil
# action-names: DeleteObject, GetObject, PutObject
aws iam simulate-principal-policy \
    --policy-source-arn arn:aws:iam::ACCOUNT_ID:user/USUARIO_MANAGER \
    --action-names s3:NOMBRE_ACCION \
    --resource-arn arn:aws:s3:::NOMBRE_BUCKET
```

- Test de lectura y escritura: confirmar el vínculo de los servicios:

```bash
# Obtener nombre del bucket
# cd s3
terraform output -json  NOMBRE_BUCKET

# Ver el contenido del bucket
aws s3 ls s3://NOMBRE_BUCKET/ --profile USUARIO_TEMPORAL

aws s3api head-object --bucket NOMBRE_BUCKET --key conexion.txt --profile USUARIO_TEMPORAL
```

- Subir información:

```bash
cd documents

# Archivo
aws s3 cp conexion.txt s3://NOMBRE_BUCKET/ --profile USUARIO_TEMPORAL

# Subir toda una carpeta local al bucket
aws s3 sync ./datos s3://NOMBRE_BUCKET/ --profile USUARIO_TEMPORAL
```

¿Qué pasa si falla? Si recibes un error de `AccessDenied`:

- Revisa el ARN: Asegúrate de que en la política de IAM el recurso termina en `/*` para los permisos de `PutObject` y `GetObject` (esto permite actuar sobre los *archivos* dentro del bucket).

- Consistencia: Verifica que el nombre del bucket en el comando `aws s3 cp` sea exactamente el mismo que creó Terraform.

## **Eliminación de Servicios**

- Para optimizar la agilidad durante el desarrollo sin comprometer la integridad de los datos institucionales, la destrucción del Data Lake está condicionada dinámicamente mediante la propiedad `force_destroy = var.environment == "POC" ? true : false`. En entornos de pruebas (**POC**), esta regla permite que `terraform destroy` vacíe y elimine de forma automática el bucket y sus archivos residuales para facilitar iteraciones rápidas. Sin embargo, en entornos críticos y productivos (**PROD**), la regla se evalúa automáticamente como `false`, activando la protección nativa de AWS que impide la eliminación accidental de cualquier bucket que contenga información financiera histórica.

- Tener en cuenta que AWS no permite borrar un bucket que no esté vacío para evitar pérdida de datos accidental, por lo que se debe eliminar la información del bucket previamente:

```bash
# Eliminar objetos actuales
aws s3 rm s3://NOMBRE_BUCKET/ --recursive --profile USUARIO_TEMPORAL

# Eliminar versiones y marcadores de eliminación (Si tienes Versioning)
aws s3api delete-objects \
    --bucket NOMBRE_BUCKET \
    --delete "$(aws s3api list-object-versions \
        --bucket NOMBRE_BUCKET \
        --query '{Objects: [?Versions].Versions[].{Key: Key, VersionId: VersionId} || [?DeleteMarkers].DeleteMarkers[].{Key: Key, VersionId: VersionId}}' \
        --output json \
        --profile USUARIO_MANAGER)"
```

- Opcional: Borrar los plugins y archivos de estado en ambos directorios

```bash
rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup aws_iam_s3
```

- Después de eliminar los archivos, destruir servicios:

```bash
# root del proyecto
terraform destroy
```

- Verificar estado de servicios: no deberían encontrarse los servicios eliminados.

```bash
aws s3 ls --profile USUARIO_MANAGER
aws iam list-users --profile USUARIO_MANAGER
```

## **Nota**

Utilizar el archivo `terraform.tfvars.examples` como template para `terraform.tfvars`.

## **Fin**
