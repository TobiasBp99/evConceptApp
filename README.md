# evConceptApp
Aplicación móvil para interactuar con un vehículo, oreintado especialmente en vehículos eléctricos o híbridos.

## About
Proyecto desarrolado durante la cursada para la materia **Desarrollo de Aplicaciones para Dispositivos Móviles** _Introducción al Diseño de Circuitos Impresos_.

## About
El diseño de la aplicación fue totalmente libre, únicamente se debía implementar:
- Autenticación de usuario
- Visión de una lista de objetos
- Modificación de objetos
<p>
</p>

Además la app cuenta con manejo de:

- Comunicación BLE mediante librería [flutter_blue_plus](https://pub.dev/packages/flutter_blue_plus/)
- Interacción con la cámara


## Peripheral
El dispositivo que genera los datos, fue implementado mediante un _ESP32_.
El programa está basado en el ejemplo [ESP32 Bluetooth Low Energy Tutorial with ESP-IDF](https://innovationyourself.com/esp32-bluetooth-low-energy-tutorial/)
<p>
</p>
El periférico se encarga de generar los datos que se muestran en las pantallas de detalle del vehículo.
También se controla un _gpio_ desde la aplicación.

## Uso
Se comparten capturas del funcionamiento de la aplicación

### Login


<img src="https://github.com/TobiasBp99/evConceptApp/raw/master/gifs/VID-20240629-WA0003.gif" width="160" height="320" />

### Login


<img src="https://github.com/TobiasBp99/evConceptApp/raw/master/gifs/VID-20240629-WA0003.gif" width="160" height="320" />
<img src="https://github.com/TobiasBp99/evConceptApp/raw/master/gifs/VID-20240629-WA0001.gif" width="160" height="320" />

### View

<img src="https://github.com/TobiasBp99/evConceptApp/raw/master/gifs/VID-20240629-WA0003.gif" width="160" height="320" />

### BLE

<img src="https://github.com/TobiasBp99/evConceptApp/raw/master/gifs/VID-20240629-WA0005.gif" width="160" height="320" />
<img src="https://github.com/TobiasBp99/evConceptApp/raw/master/gifs/VID-20240629-WA0002.gif" width="160" height="320" />
