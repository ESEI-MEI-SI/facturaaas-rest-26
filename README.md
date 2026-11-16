# FACTURAaaS Backend

Backend desarrollado en Spring Boot para la gestión de facturas del proyecto FACTURAaaS.

La especificación funcional de la herramienta se detalla en las [historias de usuario](doc/historias.md).

- Semana 2: API REST de FACTURAaaS: sobre capa de repositorios Spring Data y capa de servicios
   - El objetivo es mostrar una aplicación organizada en capas
   - La seguridad con Spring Security queda pendiente de desarrollar.

## 1. Qué se ha añadido

- `repository`: acceso a las entidades mediante Spring Data JPA y consultas específicas.
- `service`: operaciones de negocio, transacciones y conversión entre entidades y DTO.
- `controller`: exposición de las operaciones mediante endpoints HTTP.
- `dto`: objetos de entrada y salida de la API, con sus reglas de validación.
- `exception`: tratamiento centralizado de excepciones.
- `security`: configuración provisional para permitir las peticiones en desarrollo.
- [Ejemplos de peticiones con curl](doc/peticiones_rest.sh).

Las entidades siguen representando los datos persistidos. 
Los inicializadores preparan datos de ejemplo en desarrollo y un administrador en producción

**Detalles:** [README principal del proyecto `facturaaas-jpa`](https://github.com/ESEI-MEI-SI/facturaaas-jpa-26/blob/main/README.md).

## 2. Estructura de capas

```text
Petición HTTP
    -> controller -> service -> repository -> base de datos
Respuesta HTTP <- DTO <- service
```

1. **Controlador**: recibe la petición, extrae parámetros o el cuerpo JSON y devuelve una respuesta HTTP. Con `@Valid` solicita la validación de los DTO de entrada.
2. **Servicio**: coordina las operaciones, aplica la lógica de negocio y trabaja con entidades y repositorios. Por ejemplo, `FacturaService` calcula totales y genera pagos.
3. **Repositorio**: encapsula el acceso a la base de datos. Las interfaces extienden `JpaRepository` y pueden declarar consultas adicionales, como la búsqueda de clientes por usuario y patrón.

Por ejemplo, `GET /api/clientes?usuarioId=2` llega a `ClienteController`, que solicita los clientes a `ClienteService`. El servicio consulta `ClienteRepository` y transforma las entidades en `ClienteDTO` para la respuesta.

## 3. Decisiones de diseño

### DTO y validación

Los DTO definen los datos intercambiados con la API sin exponer directamente las entidades JPA. Esto permite adaptar las respuestas, evitar devolver campos como la contraseña del usuario y validar la entrada con anotaciones como `@NotBlank` y `@NotNull`. La conversión entre entidades y DTO se realiza en los servicios.

### Excepciones centralizadas

`GlobalExceptionHandler`, mediante `@RestControllerAdvice`, traduce excepciones a respuestas HTTP desde un único lugar. Los errores de validación devuelven un `400` con los mensajes por campo. Actualmente, las excepciones generales de tipo `RuntimeException` también devuelven `400`, incluso cuando se usan para indicar que no se encuentra una entidad; otras excepciones contempladas tienen respuestas específicas.

### Seguridad provisional

La API **no requiere autenticación en el perfil de desarrollo**: `SecurityConfig` permite todas las peticiones y desactiva CSRF. También usa un codificador de contraseñas sin protección, exclusivamente como solución provisional de desarrollo. No hay comprobaciones de roles ni de propiedad de los recursos en los controladores.

Esta configuración no es adecuada para producción. La configuración de desarrollo solo se activa fuera del perfil `prod`; antes de desplegar habría que establecer autenticación, autorización y almacenamiento seguro de contraseñas.

### Inyección con `@Autowired` en campos

Se utiliza `@Autowired` directamente en campos de controladores y servicios para mantener el ejemplo didáctico y centrarse en la separación de capas. Como contrapartida, las dependencias son menos explícitas y las pruebas aisladas pueden resultar más difíciles. En una aplicación de producción suele preferirse la inyección por constructor, que permite declarar dependencias obligatorias y facilita las pruebas.

## 4. Endpoints disponibles

| Recurso | Operaciones |
| --- | --- |
| `/api/usuarios` | Listar, consultar por ID, crear, actualizar y eliminar. |
| `/api/clientes` | Listar o buscar por usuario, consultar por ID, crear y actualizar. |
| `/api/formas-pago` | Listar por usuario, filtrar activas, consultar por ID, crear, actualizar y eliminar. |
| `/api/tipos-iva` | Listar, listar activos, consultar por ID, crear, actualizar y eliminar. |
| `/api/facturas` | Listar por usuario y opcionalmente cliente, consultar por ID, crear, actualizar y generar pagos. |
| `/api/pagos` | Listar por usuario y opcionalmente cliente, consultar por ID y actualizar el estado. |
| `/health` | Consultar el estado básico de la aplicación en desarrollo. |

## 5. Prueba manual de la API

Con la aplicación iniciada en el perfil de desarrollo, se puede consultar la lista de ejemplos y ejecutar uno:

```bash
bash doc/peticiones_rest.sh
bash doc/peticiones_rest.sh usuarios_listar
bash doc/peticiones_rest.sh clientes_listar
bash doc/peticiones_rest.sh facturas_listar
```

El script contiene ejemplos de peticiones y permite ajustar la URL y los identificadores mediante variables de entorno. Los identificadores predeterminados corresponden a los datos esperados en una base H2 nueva. Los pagos deben generarse antes de consultar un pago concreto; los ejemplos de escritura modifican los datos.