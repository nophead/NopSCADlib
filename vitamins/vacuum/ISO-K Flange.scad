/*
ISO-K vacuum flanges for OpenSCAD
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <https://unlicense.org/>

Based on blueprints from https://www.tracepartsonline.net/(S(c314dufymcnxxurthiwo4pow))/PartDetails.aspx?PartFamilyID=30-03062015-098588&PartID=30-03062015-098588 (the link is dead at the time of this PR to NopSCADlib), but should not be copyrightable, since based on a standard + the stuff is made of simple geometrical shapes + the file has been created myself, looking at the blueprint.

*/

module ISOKFlange(partLen = 108.0,
	innerDiameter = 102,
	outerDiameter = 108,
	ringWidth = 2.4,
	flangeDiameter = 130,
	flangeSize = 12,
	ridgeDepth = 2,
	grooveRadius = 1.5,
	grooveOffset = 5.0) {
	
	flangeInnerSize = flangeSize-ridgeDepth;
	middleSegmentSize=partLen-flangeInnerSize;

	group() {
		group() {
			difference() {
				difference() {
					cylinder(h = partLen, d = flangeDiameter, center = false);
					cylinder(h = partLen, d = innerDiameter, center = false);
					translate([0,0,partLen-grooveOffset]) {
						rotate_extrude()
						translate([flangeDiameter/2,0,0])
						circle(r = grooveRadius);
					}
				}
				difference() {
					union() {
						cylinder(h = middleSegmentSize, d = flangeDiameter-ringWidth, center = false);
						cylinder(h = partLen-flangeSize, d = flangeDiameter);
					}
					cylinder(h = middleSegmentSize, d = outerDiameter);
				}
			}
		}
	}
}
ISOKFlange(10);  // this file is meant to be imported, not included
