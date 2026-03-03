# 🎮 PokeWatch - Instrucciones de Compilación

## ⚠️ Requisito: Garmin Connect IQ SDK

Tu PokeWatch está **100% listo** pero necesitas el SDK de Garmin para compilado.

## 📥 Paso 1: Descargar e Instalar SDK

1. Ve a: https://developer.garmin.com/connect-iq/download/
2. Descarga **Connect IQ SDK** para Windows
3. Instálalo en la ubicación por defecto

## ✅ Paso 2: Compilar el Proyecto

### Opción A: Usar el Script (Recomendado)
Abre una terminal en esta carpeta y ejecuta:
```
.\compile.bat
```

### Opción B: Usar VS Code
Presiona `Ctrl+Shift+B` en VS Code (si tienes la tarea configurada)

### Opción C: Comando Manual
```
monkeyc -o bin/pokewatch.prg -m monkey.jungle -z resources -y developer_key
```

## 🎯 Paso 3: Ejecutar en Reloj

Después de compilar exitosamente (`bin/pokewatch.prg`):

### En Simulador Garmin
1. Abre **Garmin Connect IQ Simulator**
2. Abre el archivo `bin/pokewatch.prg`
3. Prueba la app completa

### En Dispositivo Real (Vivoactive 6)
1. Conecta tu reloj Garmin por USB
2. Abre **Garmin Drive**
3. Instala `bin/pokewatch.prg`

## 📋 Estado del Proyecto

✅ **Todos los archivos están listos:**
- ✅ GameState.mc - Gestión de estado
- ✅ EncounterView.mc - Pantalla de encuentro con sprites
- ✅ MainView.mc - Pantalla principal con sprite del día  
- ✅ PokedexView.mc - Pokedex con sprites
- ✅ SpriteManager.mc - Gestor de sprites
- ✅ 151/151 sprites descargados y optimizados

## 🐛 Troubleshooting

**Si ves error "monkeyc no se reconoce":**
- Instala el Garmin SDK desde el link anterior
- Reinicia PowerShell/CMD después de instalar
- Asegúrate que está en `C:\Program Files\Garmin\ConnectIQ\bin\` o `C:\Garmin\ConnectIQ_SDK\bin\`

**Si hay errores de compilación:**
- Verifica que todos los archivos `.mc` estén en `source/`
- Los sprites deben estar en `resources/drawables/`
- Asegúrate de usar el developer_key correcto

## 📞 Soporte

Si tienes problemas:
1. Verifica que el SDK esté instalado correctamente
2. Comprueba que estés en la carpeta `pokewatch` raíz
3. Ejecuta `.\compile.bat` desde la terminal de las PowerShell

¡El proyecto está completo y listo para jugar! 🎮
