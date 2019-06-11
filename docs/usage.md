# NopSCADlib usage

## Requirements
1. OpenSCAD 2019.05 or later, download it from here: https://www.openscad.org/downloads.html
1. Python 2.7+ or 3.6+ from https://www.python.org/downloads/
1. ImageMagick www.imagemagick.org

These are all cross platform tools so NopSCADlib should work on any platform that supports them.
They all need to be added to the executable search path so that they work from the command line.

### Python packages

The following Python modules are used and can be installed with pip:

```
pip install colorama

```

## Installation

OpenSCAD it has to be setup to find libraries by setting the ```OPENSCADPATH``` environment variable to where you want to file your libaries and NopSCADlib needs to be installed
in the directory it points to. This can be done with ```git clone https://github.com/nophead/NopSCADlib.git``` while in that directory or by downloading
https://github.com/nophead/NopSCADlib/archive/master.zip and unzipping it to a directory called NopSCADlib if you don't want to use GIT.

The ```NopSCADlib/scripts``` directory needs to be added to the executable search path.

The installation can be tested by opening ```NopSCADlib/libtest.scad``` in the GUI. It should render all the objects in the library in about 1 minute.

Running ```tests``` from the command line will run all the tests in the ```tests``` directory and build the ```readme.md``` catalog.

## Directory structure

| Path | Usage |
|:-----|:------|
| ```NopSCADlib``` | Top level scad files and printed parts |
| ```NopSCADlib/doc``` | Documentation like this that is not automatically generated |
| ```NopSCADlib/examples``` | Example projects |
| ```NopSCADlib/gallery``` | Pictures of items that have been made with the library |
| ```NopSCADlib/scripts``` | Python scripts |
| ```NopSCADlib/tests``` | A stand alone test for each type of vitamin and most of the utilities |
| ```NopSCADlib/utils```   | Utilitity scad files |
| ```NopSCADlib/utils/core``` | Core utilities used by nearly everything |
| ```NopSCADlib/vitamins``` | Generally a pair of .scad files for each type of vitamin |


## Making a project

Each project has its own directory and that is used to derive the project's name. There should be a main scad file which contains the main assembly. A skeleton looks like this: -

```OpenSCAD
//!
include <NopSCADlib/lib.scad>
