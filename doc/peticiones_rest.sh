#!/usr/bin/env bash

# Ejemplos para el perfil de desarrollo, sin autenticacion.
# Ejecutar: bash doc/peticiones_rest.sh <ejemplo>
# IDs esperados con una base H2 nueva y los datos de DataInitializer.
# Pueden cambiar si se modifica o vuelve a inicializar la base de datos.
BASE_URL=${BASE_URL:-http://localhost:8080}
USUARIO_ID=${USUARIO_ID:-2}        # Usuario demo: user
CLIENTE_ID=${CLIENTE_ID:-1}        # Cliente de prueba
FACTURA_ID=${FACTURA_ID:-1}        # Factura DEMO-001
FORMA_PAGO_ID=${FORMA_PAGO_ID:-1}  # Contado
TIPO_IVA_ID=${TIPO_IVA_ID:-1}      # IVA normal: 21%
# El inicializador no crea pagos; generar y consultar los pagos antes de usar este ID.
PAGO_ID=${PAGO_ID:-1}

ayuda() {
    cat <<'EOF'
Uso: bash doc/peticiones_rest.sh <ejemplo>

Ejemplos disponibles:
  salud
  usuarios_listar usuarios_obtener usuarios_crear usuarios_actualizar usuarios_eliminar
  clientes_listar clientes_buscar clientes_obtener clientes_crear clientes_actualizar
  formas_pago_listar formas_pago_activas formas_pago_obtener formas_pago_crear
  formas_pago_actualizar formas_pago_eliminar
  tipos_iva_listar tipos_iva_activos tipos_iva_obtener tipos_iva_crear
  tipos_iva_actualizar tipos_iva_eliminar
  facturas_listar facturas_por_cliente facturas_obtener facturas_crear
  facturas_actualizar facturas_generar_pagos
  pagos_listar pagos_por_cliente pagos_obtener pagos_actualizar_estado

Los IDs predeterminados corresponden a una base H2 nueva: usuario demo 2,
cliente 1, factura 1, forma de pago 1 e IVA 1. Se pueden ajustar mediante
las variables de entorno USUARIO_ID, CLIENTE_ID, FACTURA_ID, FORMA_PAGO_ID,
TIPO_IVA_ID y BASE_URL. Los ejemplos de escritura modifican datos.

No se crean pagos al iniciar: ejecutar primero facturas_generar_pagos y
consultar pagos_listar para obtener un PAGO_ID existente (por defecto, 1).
EOF
}

salud() { curl -i "$BASE_URL/health"; }

usuarios_listar() { curl -i "$BASE_URL/api/usuarios"; }
usuarios_obtener() { curl -i "$BASE_URL/api/usuarios/$USUARIO_ID"; }
usuarios_crear() {
    curl -i -X POST "$BASE_URL/api/usuarios" -H 'Content-Type: application/json' \
        -d '{"login":"ejemplo","password":"ejemplo123","nombre":"Usuario Ejemplo","email":"ejemplo@example.com"}'
}
usuarios_actualizar() {
    curl -i -X PUT "$BASE_URL/api/usuarios/$USUARIO_ID" -H 'Content-Type: application/json' \
        -d '{"login":"user","nombre":"Usuario actualizado","email":"user@example.com","rol":"USUARIO","activo":true}'
}
usuarios_eliminar() { curl -i -X DELETE "$BASE_URL/api/usuarios/$USUARIO_ID"; }

clientes_listar() { curl -i "$BASE_URL/api/clientes?usuarioId=$USUARIO_ID"; }
clientes_buscar() {
    curl -i -G "$BASE_URL/api/clientes" --data-urlencode "usuarioId=$USUARIO_ID" --data-urlencode 'patron=Cliente'
}
clientes_obtener() { curl -i "$BASE_URL/api/clientes/$CLIENTE_ID"; }
clientes_crear() {
    curl -i -X POST "$BASE_URL/api/clientes" -H 'Content-Type: application/json' \
        -d "{\"usuarioId\":$USUARIO_ID,\"nombre\":\"Cliente Ejemplo\",\"nif\":\"00000000T\",\"email\":\"cliente@example.com\"}"
}
clientes_actualizar() {
    curl -i -X PUT "$BASE_URL/api/clientes/$CLIENTE_ID" -H 'Content-Type: application/json' \
        -d "{\"usuarioId\":$USUARIO_ID,\"nombre\":\"Cliente actualizado\",\"nif\":\"00000000T\",\"email\":\"cliente@example.com\"}"
}

formas_pago_listar() { curl -i "$BASE_URL/api/formas-pago?usuarioId=$USUARIO_ID"; }
formas_pago_activas() { curl -i "$BASE_URL/api/formas-pago?usuarioId=$USUARIO_ID&soloActivas=true"; }
formas_pago_obtener() { curl -i "$BASE_URL/api/formas-pago/$FORMA_PAGO_ID"; }
formas_pago_crear() {
    curl -i -X POST "$BASE_URL/api/formas-pago" -H 'Content-Type: application/json' \
        -d "{\"usuarioId\":$USUARIO_ID,\"descripcion\":\"Transferencia\",\"numeroPagos\":1,\"periodicidadDias\":30,\"activa\":true}"
}
formas_pago_actualizar() {
    curl -i -X PUT "$BASE_URL/api/formas-pago/$FORMA_PAGO_ID" -H 'Content-Type: application/json' \
        -d "{\"usuarioId\":$USUARIO_ID,\"descripcion\":\"Transferencia actualizada\",\"numeroPagos\":1,\"periodicidadDias\":30,\"activa\":true}"
}
formas_pago_eliminar() { curl -i -X DELETE "$BASE_URL/api/formas-pago/$FORMA_PAGO_ID"; }

tipos_iva_listar() { curl -i "$BASE_URL/api/tipos-iva"; }
tipos_iva_activos() { curl -i "$BASE_URL/api/tipos-iva/activos"; }
tipos_iva_obtener() { curl -i "$BASE_URL/api/tipos-iva/$TIPO_IVA_ID"; }
tipos_iva_crear() {
    curl -i -X POST "$BASE_URL/api/tipos-iva" -H 'Content-Type: application/json' \
        -d '{"descripcion":"IVA de ejemplo","porcentaje":21.00,"activo":true}'
}
tipos_iva_actualizar() {
    curl -i -X PUT "$BASE_URL/api/tipos-iva/$TIPO_IVA_ID" -H 'Content-Type: application/json' \
        -d '{"descripcion":"IVA actualizado","porcentaje":21.00,"activo":true}'
}
tipos_iva_eliminar() { curl -i -X DELETE "$BASE_URL/api/tipos-iva/$TIPO_IVA_ID"; }

facturas_listar() { curl -i "$BASE_URL/api/facturas?usuarioId=$USUARIO_ID"; }
facturas_por_cliente() { curl -i "$BASE_URL/api/facturas?usuarioId=$USUARIO_ID&clienteId=$CLIENTE_ID"; }
facturas_obtener() { curl -i "$BASE_URL/api/facturas/$FACTURA_ID"; }
facturas_crear() {
    curl -i -X POST "$BASE_URL/api/facturas" -H 'Content-Type: application/json' \
        -d "{\"ejercicio\":2026,\"usuarioId\":$USUARIO_ID,\"clienteId\":$CLIENTE_ID,\"fechaEmision\":\"2026-01-15\",\"formaPagoId\":$FORMA_PAGO_ID,\"estado\":\"EMITIDA\",\"lineas\":[{\"concepto\":\"Servicio\",\"cantidad\":2,\"precioUnitario\":50,\"tipoIVAId\":$TIPO_IVA_ID}]}"
}
facturas_actualizar() {
    curl -i -X PUT "$BASE_URL/api/facturas/$FACTURA_ID" -H 'Content-Type: application/json' \
        -d "{\"ejercicio\":2026,\"usuarioId\":$USUARIO_ID,\"clienteId\":$CLIENTE_ID,\"fechaEmision\":\"2026-01-15\",\"formaPagoId\":$FORMA_PAGO_ID,\"estado\":\"EMITIDA\",\"comentarios\":\"Factura actualizada\",\"lineas\":[{\"concepto\":\"Servicio\",\"cantidad\":2,\"precioUnitario\":50,\"tipoIVAId\":$TIPO_IVA_ID}]}"
}
# Esta operacion sustituye los pagos existentes de la factura.
facturas_generar_pagos() { curl -i -X POST "$BASE_URL/api/facturas/$FACTURA_ID/generar-pagos"; }

pagos_listar() { curl -i "$BASE_URL/api/pagos?usuarioId=$USUARIO_ID"; }
pagos_por_cliente() { curl -i "$BASE_URL/api/pagos?usuarioId=$USUARIO_ID&clienteId=$CLIENTE_ID"; }
pagos_obtener() { curl -i "$BASE_URL/api/pagos/$PAGO_ID"; }
pagos_actualizar_estado() { curl -i -X PATCH "$BASE_URL/api/pagos/$PAGO_ID/estado?estado=PAGADO"; }

ejemplo=${1:-ayuda}
if declare -F "$ejemplo" >/dev/null; then
    "$ejemplo"
else
    printf 'Ejemplo desconocido: %s\n\n' "$ejemplo" >&2
    ayuda >&2
    exit 1
fi