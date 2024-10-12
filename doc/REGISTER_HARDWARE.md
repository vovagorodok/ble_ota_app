# Register hardware

## Staps
1. Create your hardware jsons for each device
2. Create your hardwares json that contain links to your hardware jsons
3. Add link to your hardwares json in `resources/manufactures.json`
4. Push change in `resources/manufactures.json` to this repo

## Hardware json
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

General fields:
- required `hardware_name` - string
- required `softwares` - list
- optional `hardware_icon` - string contains url to icon
- optional `hardware_text` - string contains url to text about hardware in markdown
- optional `hardware_page` - string contains url to hardware web page

Software fields:
- required `software_name` - string
- required `software_version` - list of ints contains \[major, minor, patch\]
- required `software_path` - string contains url to bin file
- optional `software_icon` - string contains url to icon
- optional `software_text` - string contains url to text about software in markdown
- optional `software_page` - string contains url to software web page
- optional `hardware_version` - specific version of hardware that software is for
- optional `min_hardware_version` - min version of hardware that software is for
- optional `max_hardware_version` - max version of hardware that software is for

## Examples
### ArduinoBleOTA
Files:
- hardwares json: `example_hardwares.json`
- hardware jsons: `example_hardware_esp32.json` and `example_hardware_samd.json`

Link: https://github.com/vovagorodok/ArduinoBleOTA/tree/main/tools/release_builder.
