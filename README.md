# Global project
The Global project is a core Ignition Perspective module that provides shared components, styles, and scripts used across multiple related applications in the OpenHMSHub ecosystem.

## Purpose
This project contains reusable UI components, named queries, scripts, stylesheets, and resources that are imported by other modules such as:

* RITI

* Discovery

* WinterShelterPortal

It helps standardize functionality and ensures a consistent user experience throughout all OpenHMSHub-based projects.

## Requirements
`Ignition 8.1.45 or later`

## Installation

[Installation Guide](https://github.com/OpenHMSHub/Documentation/wiki/Instalation-Guide)

**Important:** The Global project should be cloned first as it is the parent project for other modules.

Clone the repository into your Ignition projects folder:

Linux: `/usr/local/bin/ignition/data/projects`

Windows: `C:\Program Files\Inductive Automation\Ignition\data\projects`

```bash
git clone https://github.com/OpenHMSHub/Global.git
```

Restart your Ignition Gateway.

Ensure that the Global project is present and correctly set as a parent project in the RITI project settings.
In the Ignition Gateway `(http://localhost:8088)`, go to `Config` > `System` > `Projects`, and verify that Global is listed as a parent (`Inheritable` - True) project.

## How to Use
Make sure the Global project is cloned into your Ignition project directory:

`/usr/local/bin/ignition/data/projects`     # Linux

`C:\Program Files\Inductive Automation\Ignition\data\projects`     # Windows

**Note:** The Global project is not runnable on its own, as it serves as the parent project.

Restart the Ignition Gateway if needed to detect the new project.

Other Perspective projects should reference this project in their project settings under Project Library Inheritance.

## Related Projects
[RITI](https://github.com/OpenHMSHub/RITI)

[WinterShelterPortal](https://github.com/OpenHMSHub/WinterShelterPortal)

[Discovery](https://github.com/OpenHMSHub/Discovery)
