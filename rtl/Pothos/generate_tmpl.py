# Copyright (c) 2014-2014 Josh Blum
# SPDX-License-Identifier: BSL-1.0

import os
import sys
from Cheetah.Template import Template

if __name__ == '__main__':
    in_path = sys.argv[1]
    out_path = sys.argv[2]
    tmpl = open(in_path, 'r').read()
    code = str(Template(tmpl))
    open(out_path, 'w').write(code)
