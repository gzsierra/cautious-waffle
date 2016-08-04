# Cautious-Waffle
Easy install of OpenHAB with MQTT, CoAP, Philips Hue

# Install
```
git clone https://github.com/gzsierra/cautious-waffle.git
```

# Usage
Default Use, for custom config please see [Custom config](#custom-config)
```
sudo ./OpenhabInstall.sh
```

After the installation, check if the service as started.
```
sudo service coapServer status
sudo service openhab status
```

If one of them (or both) hasn't start, start them.
```
sudo service coapServer start
sudo service openhab start
```

# Custom config
For more details on how to use MQTT or CoAP Server please follow the link below
* [MQTT](https://github.com/gzsierra/pytt)
* [CoAP](https://github.com/gzsierra/pycoap)
* [Philips Hue](http://steveyo.github.io/Hue-Emulator/)

The custom made configurations for default use can be found in the folder [file](../master/file). You can edit everything for your *own special* setup

In that folder you will found [CoAP Service](../master/file/coapServer), [default OpenHAB config file](../master/file/configurations), [default items](../master/file/configurations/items/demo.items) and the [default sitemaps](../master/file/configurations/sitemaps/demo.sitemap).

For the usage of Hue emulator please follow [here](https://github.com/openhab/openhab/wiki/Hue-Binding)
In the [config file](../master/file/configurations/openhab.cfg), there is a part that you have to edit for YOUR CASE.
The lines that you have to edit are at line 120 and 126. 

The default Openhab config file has been shorted for easy reading

# Issue
There may have some issue with the first launch with CoAP, since there is any data, in the log of OpenHAB you will see a bunch of fail coming from CoAP service.

Solution : You simply send data to the CoAP service and on the next periode it will be refresh.

# LICENCE
MIT
