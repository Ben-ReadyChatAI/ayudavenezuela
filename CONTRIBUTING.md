# Contribuir / Contributing — Ayuda Venezuela

Gracias por ayudar. Este es un directorio comunitario de recursos para personas afectadas por el terremoto en Venezuela. / Thank you for helping. This is a community resource hub for people affected by the earthquake in Venezuela.

## La forma más fácil: sugerir un recurso / The easiest way

Abre un **issue** con el formulario de sugerencia — no necesitas saber programar:
👉 **https://github.com/Ben-ReadyChatAI/ayudavenezuela/issues/new?template=resource.yml**

Sirve para: agregar un recurso nuevo, corregir un dato o reportar un enlace caído.

## Para desarrolladores / For developers

Todo el contenido vive en archivos de datos — no hay que tocar componentes para actualizar enlaces:

- `src/data/resources.json` — enlaces por categoría (personas, mascotas, hospitales, seguridad, donaciones, apoyo psicológico, información oficial).
- `src/data/supplies.json` — lista de insumos requeridos por categoría.
- `src/data/site.json` — textos, números de emergencia y datos del evento.

Flujo: haz un fork → edita el JSON → abre un Pull Request a `main`.

```bash
npm install
npm run dev      # previsualizar en http://localhost:4321
npm run build    # generar el sitio estático en dist/
```

## Reglas de calidad (importante) / Quality rules

Es un sitio de crisis: la información incorrecta puede hacer daño. Antes de agregar o aprobar un recurso:

1. **Verifica que esté activo** (el enlace abre y funciona).
2. **Verifica que sea legítimo.** Las crisis atraen estafas — desconfía de campañas que piden cripto, tarjetas de regalo o billeteras anónimas. Prefiere organizaciones registradas con trayectoria.
3. **Protege la privacidad.** En registros de personas, comparte la mínima información personal; marca con precaución los que manejan datos sensibles (menores, ubicaciones).
4. **Cita la fuente.** Las verificaciones de contenido se documentan en [`docs/SOURCES.md`](docs/SOURCES.md), para revisión del administrador del proyecto.

Las cifras del sismo son preliminares y cambian; re-verifica antes de actualizarlas.

## Despliegue / Deployment

Los cambios en `main` se publican en el servidor (Coolify). Detalles técnicos en [`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md).
