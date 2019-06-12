# NopSCADlib usage

## Requirements
1. OpenSCAD 2019.05 or later, download it from here: https://www.openscad.org/downloads.html
1. Python 2.7+ or 3.6+ from https://www.python.org/downloads/
1. ImageMagick 7 www.imagemagick.org

These are all cross platform tools so NopSCADlib should work on any platform that supports them.
They all need to be added to the executable search path so that they work from the command line.

### Python packages

The following Python modules are used and can be installed with pip:

```
pip install colorama
pip install codespell
pip install markdown
```

## Installation

OpenSCAD it has to be setup to find libraries by setting the ```OPENSCADPATH``` environment variable to where you want to file your libraries and NopSCADlib needs to be installed
in the directory it points to. This can be done with ```git clone https://github.com/nophead/NopSCADlib.git``` while in that directory or by downloading
https://github.com/nophead/NopSCADlib/archive/master.zip and unzipping it to a directory called NopSCADlib if you don't want to use GIT.

The ```NopSCADlib/scripts``` directory needs to be added to the executable search path.

The installation can be tested by opening ```NopSCADlib/libtest.scad``` in the OpenSCAD GUI. It should render all the objects in the library in about 1 minute.

Running ```tests``` from the command line will run all the tests in the ```tests``` directory and build the ```readme.md``` catalog and render it to ```readme.html```.

## Directory structure

| Path | Contents |
|:-----|:------|
| ```NopSCADlib``` | Top level scad files, e.g. ```lib.scad``` |
| ```NopSCADlib/doc``` | Documentation like this that is not automatically generated |
| ```NopSCADlib/examples``` | Example projects |
| ```NopSCADlib/gallery``` | Pictures of items that have been made with the library |
| ```NopSCADlib/printed``` | Scad files for making reusable printed parts |
| ```NopSCADlib/scripts``` | Python scripts |
| ```NopSCADlib/tests``` | A stand alone test for each type of vitamin and most of the utilities |
| ```NopSCADlib/utils```   | Utilitity scad files |
| ```NopSCADlib/utils/core``` | Core utilities used by nearly everything |
| ```NopSCADlib/vitamins``` | Generally a pair of .scad files for each type of vitamin |


## Making a project

Each project has its own directory and that is used to derive the project's name. There should also be a subdirectory called ```scad``` and a main scad file which contains the main
 assembly.
A skeleton project looks like this: -

    //! Project description in Markdown format before the first include.
    include <NopSCADlib/lib.scad>

    ...

    //! Assembly instructions in Markdown format in front of each module that makes an assembly.
    module main_assembly()
    assembly("main") {
        ...
    }

    if($preview)
        main_assembly();

Other scad files can be added in the scad directory and included or used as required.

* Subassemblies can be added in the same format as ```main_assembly()```, i.e. a module called ```something_assembly()```, taking no parameters and calling ```assembly("something")``` with
the rest of its contents passed as children. Assembly instructions should be added directly before the module definition.

* Any printed parts should be made by a module called ```something_stl()```, taking no parameters and calling ```stl("something")``` so they appear on the BOM.

* Any routed parts should be made by a module called ```something_dxf()```, taking no parameters and calling ```dxf("something")``` so they appear on the BOM.

When ```make_all``` is run from the top level directory of the project it will create the following sub-directories and populate them:-

| Directory | Contents |
|:----------|:---------|
| assemblies | For each assembly: an assembled view and an exploded assembly view, in large and small formats |
| bom | A flat BOM in ```bom.txt``` for the whole project, flat BOMs in text format for each assembly and a hierarchical BOM in JSON format, ```bom.json```.|
| deps | Dependency files for each scad file in the project, so that subsequent builds can be incremental |
| dxfs | DXF files for all the routed parts in the project and small PNG images of them |
| stls | STL files for all the printed parts in the project and small PNG images of them |

It will also make a Markdown assembly manual called ```readme.md``` suitable for GitHub, a version rendered to HTML for viewing locally called ```readme.html``` and a second
HTML version called ```printme.html```. This has page breaks instead of horizontal rules and can be converted to PDF using Chrome to make a stand alone manual.

Each time OpenSCAD is run to produce STL files, DXF files or assembly views the time it takes is recorded and compared with the previous time. At the end the times are printed with the delta
 from the last run and coloured red or green if they have got significantly faster or slower. This is useful for optimising the scad code for speed.

When PNG files are made they are compared with the previous version and only updated if they have changed. When that happens a PNG difference file is created, so you can
review the changes graphically. They will be deleted on the next run.
