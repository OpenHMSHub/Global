# Global project
The Global project is a core Ignition Perspective module that provides shared components, styles, and scripts used across multiple related applications in the OpenHMSHub ecosystem.

## Purpose
This project contains reusable UI components, named queries, scripts, stylesheets, and resources that are imported by other modules such as:

* RITI

* Discovery

* WinterShelterPortal

It helps standardize functionality and ensures a consistent user experience throughout all OpenHMSHub-based projects.

## How to Use
Make sure the Global project is cloned into your Ignition project directory:

`/usr/local/bin/ignition/data/projects`     # Linux

`C:\Program Files\Inductive Automation\Ignition\data\projects`     # Windows

Restart the Ignition Gateway if needed to detect the new project.

Other Perspective projects should reference this project in their project settings under Project Library Inheritance.

## Requirements
`Ignition 8.1.45 or later`

## Related Projects
[RITI](https://github.com/OpenHMSHub/RITI)

[WinterShelterPortal](https://github.com/OpenHMSHub/WinterShelterPortal)

[Discovery](https://github.com/OpenHMSHub/Discovery)
