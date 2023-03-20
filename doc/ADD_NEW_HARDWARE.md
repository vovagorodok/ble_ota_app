# Add new hardware

## Staps
1. Create your hardware json
2. Add link to your hardware json in `resources\hardwares.json`

## Hardware json
Example in `resources\example_hardware_esp32.json`.\
Required fields:
```
{
    "hardware_name": ...,
    ...
    "softwares": [
        {
            
            "software_name": ...,
            "software_version": ...,
            "software_path": ...,
            ...
        }
        ...
    ]
}
```