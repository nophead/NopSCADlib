
# Python scripts
These are located in the ```scripts``` subdirectory, which needs to be added to the program search path.

They should work with both Python 2 and Python 3.

| Script  | Function  |
|:--|:--|
| ```bom.py``` | Generates BOM files for the project. |
| ```c14n_stl.py``` | OpenSCAD produces randomly ordered STL files. This script re-orders them consistently so that GIT can tell if they have changed or not. |
| ```doc_scripts.py``` | Makes this document and doc/usage.md. |
| ```dxfs.py``` | Generates DXF files for all the routed parts listed on the BOM or a specified list. |
| ```gallery.py``` | Finds projects and adds them to the gallery. |
| ```make_all.py``` | Generates all the files for a project by running ```bom.py```, ```stls.py```, ```dxfs.py```, ```render.py``` and ```views.py```. |
| ```render.py``` | Renders STL and DXF files to PNG for inclusion in the build instructions. |
| ```set_config.py``` | Sets the target configuration for multi-target projects that have variable configurations. |
| ```stls.py``` | Generates STL files for all the printed parts listed on the BOM or a specified list. |
| ```svgs.py``` | Generates SVG files for all the routed parts listed on the BOM or a specified list. |
| ```tests.py``` | Runs all the tests in the tests directory and makes the readme file with a catalog of the results. |
| ```views.py``` | Generates exploded and unexploded assembly views and scrapes build instructions to make readme.md, readme.html and printme.html files for the project. |
