//
// NopSCADlib Copyright Chris Palmer 2018
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// This file is part of NopSCADlib.
//
// NopSCADlib is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version 3 of
// the License, or (at your option) any later version.
//
// NopSCADlib is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
// without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with NopSCADlib.
// If not, see <https://www.gnu.org/licenses/>.
//

//
//! Bill Of Materials generation via echo and the ```bom.py``` script. Also handles exploded assembly views and posing. Assembly instructions can precede the module
//! definition that makes the assembly.
//!
//! The example below shows how to define a vitamin and incorporate it into an assembly with sub-assemblies and make an exploded view. The resulting flat BOM is shown but
//! heirachical BOMs are also generated for real projects.
//
function bom_mode(n = 1) = $_bom >= n && (is_undef($on_bom) || $on_bom);  //! Current BOM mode, 0 = none, 1 = printed and routed parts and assemblies, 2 includes vitamins as well
function exploded() = is_undef($exploded_parent) ? $exploded : 0;   //! Returns the value of ```$exploded``` if it is defined, else ```0```
function show_supports() = !$preview || exploded();                 //! True if printed support material should be shown

module no_explode() let($exploded_parent = true) children();        //! Prevent children being exploded
module no_pose() let($posed = true) children();                     //! Force children not to be posed even if parent is

module explode(d, explode_children = false, offset = [0,0,0]) {     //! Explode children by specified Z distance or vector ```d```, option to explode grand children
    v = is_list(d) ? d : [0, 0, d];
    o = is_list(offset) ? offset : [0, 0, offset];
    if($exploded && is_undef($exploded_parent) && norm(v)) {
        translate(o)                                                // Draw the line first in case the child is transparent
            color("yellow") hull() {
                sphere(0.2);

                translate(v * $exploded)
                    sphere(0.2);
            }

        translate(v * $exploded)
            let($exploded_parent = explode_children ? undef : true)
                children();
    }
    else
        children();
}

module pose(a = [55, 0, 25], t = [0, 0, 0], exploded = undef)       //! Pose an STL or assembly for rendering to png by specifying rotation ```a``` and translation ```t```, ```exploded = true for``` just the exploded view or ```false``` for unexploded only.
    if(is_undef($pose) || !is_undef($posed) || (!is_undef(exploded) && exploded != !!exploded()))
        children();
    else
        let($posed = true) // only pose the top level
            rotate([55, 0, 25])
                rotate([-a.x, 0, 0])
                    rotate([0, -a.y, 0])
                        rotate([0, 0, -a.z])
                            translate(-t)
                                children();

module pose_hflip(exploded = undef)       //! Pose an STL or assembly for rendering to png by flipping around the Y axis, ```exploded = true for``` just the exploded view or ```false``` for unexploded only.
    if(is_undef($pose) || !is_undef($posed) || (!is_undef(exploded) && exploded != !!exploded()))
        children();
    else
        let($posed = true) // only pose the top level
            hflip()
                children();

module pose_vflip(exploded = undef)       //! Pose an STL or assembly for rendering to png by flipping around the X axis, ```exploded = true for``` just the exploded view or ```false``` for unexploded only.
    if(is_undef($pose) || !is_undef($posed) || (!is_undef(exploded) && exploded != !!exploded()))
        children();
    else
        let($posed = true) // only pose the top level
            vflip()
                children();


module assembly(name) {                 //! Name an assembly that will appear on the BOM, there needs to a module named ```<name>_assembly``` to make it
    if(bom_mode())
        echo(str("~", name, "_assembly{"));

    no_pose()
        if(is_undef($child_assembly))
            let($child_assembly = true)
                children();
        else
            no_explode()
                children();

    if(bom_mode())
        echo(str("~}", name, "_assembly"));
}

module stl(name) {                      //! Name an stl that will appear on the BOM, there needs to a module named ```<name>_stl``` to make it
    if(bom_mode())
        echo(str("~", name, ".stl"));
}

module dxf(name) {                      //! Name a dxf that will appear on the BOM, there needs to a module named ```<name>_dxf``` to make it
    if(bom_mode())
        echo(str("~", name, ".dxf"));
}

function value_string(value) = is_string(value) ? str("\"", value, "\"") : str(value); //! Convert ```value``` to a string or quote it if it is already a string

function arg(value, default, name = "") =   //! Create string for arg if not default, helper for ```vitamin()```
    value == default ? ""
                     : name ? str(", ", name, " = ", value_string(value))
                            : str(", ", value_string(value));

module vitamin(description) {                //! Describe a vitamin for the BOM entry and precede it with a module call that creates it, eg. "wigit(42): Type 42 widget"
    if(bom_mode(2))
        echo(str("~", description, !is_undef($hidden) ? " - not shown" : ""));
}

module not_on_bom(on = false)               //! Specify the following child parts are not on the BOM, for example when they are on a PCB that comes assembled
    let($on_bom = on)
        children();

module hidden()                             //! Make item invisible, except on the BOM
    scale(1 / sqr(1024))
        let($hidden = true)
            children();
