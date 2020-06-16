/*
CF vacuum flanges for OpenSCAD
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

Based on blueprints from https://www.tracepartsonline.net/(S(c314dufymcnxxurthiwo4pow))/PartDetails.aspx?PartFamilyID=30-03062015-098588&PartID=30-03062015-098588 (the link is dead at the time of this PR to NopSCADlib), but should not be copyrightable, since CF is a de-facto standard + the stuff is made of simple geometrical shapes + the file has been created myself, looking at the blueprint.

*/

module cylRing(d1, d2, h) {
	if (d2 > 0) {
		difference() {
			cylinder(h = h, d = d1);
			cylinder(h = h, d = d2);
		}
	} else {
		cylinder(h = h, d = d1);
	}
}

module createRidgeTorus(ridgeH = 0.65, ridgeAngle = 70, dRidge = 115.3, dRidgeEnd = 120.65, ridgeDepth = 1.2) {
	rRidge = dRidge / 2;
	rRidgeEnd = dRidgeEnd / 2;
	rotate_extrude()
		polygon(points = [
			[0, 0],
			[0, -ridgeDepth],
			[rRidge - ridgeH * tan(90 - ridgeAngle), -ridgeDepth],
			[rRidge,  - (ridgeDepth - ridgeH)],
			[rRidgeEnd,  - (ridgeDepth - ridgeH + (rRidgeEnd - rRidge) / tan(ridgeAngle))],
			[rRidgeEnd, 0]
		]);
}

module createHoles(holeDiamiter = 8.5, holeCount = 8 * 2, holeTrDiameter = 130.3, flangeSize = 20) {
	for (i = [0 : holeCount - 1]) {
		rotate((i + 1 / 2) * 360 / holeCount, [0, 0, 1])
			translate([0, holeTrDiameter / 2])
				cylinder(d = holeDiamiter, h = flangeSize);
	}
}

module CFBlankFlange(flangeDiameter = 152, holeDiameter = 0, flangeSize = 20, holeTrDiameter = 130.3) {
	group() {
		difference() {
			cylRing(d1 = flangeDiameter, d2 = holeDiameter, h = flangeSize);
			createHoles(flangeSize = flangeSize, holeTrDiameter = holeTrDiameter);
			translate([0, 0, flangeSize])
				createRidgeTorus();
		}
	}
}

module CFFlange(partLen = 108.0,
	innerDiameter = 100,
	outerDiameter = 104,
	flangeDiameter = 152,
	flangeSize = 20,
	grooveRadius = 1.5,
	openingDepth = 9,
	openingDiameter = 106,
	holeDiameter = 0,
	holeTrDiameter = 130.3) {

	middleSegmentSize = partLen - flangeSize;

	group() {
		difference() {
			difference() {
				union() {
					cylRing(h = middleSegmentSize, d1 = outerDiameter, d2 = innerDiameter);
					translate([0, 0, middleSegmentSize])
						CFBlankFlange(flangeDiameter = flangeDiameter, holeDiameter = innerDiameter, flangeSize = flangeSize, holeTrDiameter = holeTrDiameter);
				}

				translate([0, 0, partLen - openingDepth])
					cylinder(d = openingDiameter, h = openingDepth);
			}
		}
	}
}

CFFlange();  // this file is meant to be imported, not included
