#
# NopSCADlib Copyright Chris Palmer 2021
# nop.head@gmail.com
# hydraraptor.blogspot.com
#
# This file is part of NopSCADlib.
#
# NopSCADlib is free software: you can redistribute it and/or modify it under the terms of the
# GNU General Public License as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# NopSCADlib is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with NopSCADlib.
# If not, see <https://www.gnu.org/licenses/>.
#
"""
Make a directory for tmp files.
"""
import os
import time

def mktmpdir(top_dir):
    tmp_dir = top_dir + 'tmp'
    if not os.path.isdir(tmp_dir):
        time.sleep(0.1)
        os.makedirs(tmp_dir)
    else:
        for file in os.listdir(tmp_dir):
            os.remove(tmp_dir + '/' + file)
    return tmp_dir

def reltmp(dir, target):
    return dir if os.path.isabs(dir) else '../../' + dir if target else '../' + dir

def rmtmpdir(tmp_dir):
    os.rmdir(tmp_dir)
    while os.path.isdir(tmp_dir):
        time.sleep(0.1)
