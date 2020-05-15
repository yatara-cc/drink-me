#!/usr/bin/env python3

import re
import csv
import sys
import logging
import argparse
from pathlib import Path
from collections import defaultdict



LOG = logging.getLogger("stencil")



class ParseError(Exception):
    pass



def bom_digikey(out, sch_path):
    re_component = re.compile(r"\$Comp(.*?)\$EndComp", re.M | re.S)
    re_id = re.compile(r"^U \d+ \d+ (\w+)$")
    re_reference = re.compile(r"^F 0 \"(.+?)\"")
    re_field = re.compile(r"^F \d+ \"(.+?)\" .* \"(\w+)\"$")

    bom = defaultdict(int)

    for match in re_component.finditer(sch_path.read_text()):
        id_ = None
        reference = None
        field_dict = {}

        for line in match.group(0).splitlines():

            id_match = re_id.match(line)
            if id_match:
                if id_:
                    raise ParseError("Multiple ID values")
                id_ = id_match.group(1)

            reference_match = re_reference.match(line)
            if reference_match:
                if reference:
                    raise ParseError("Multiple REFERENCE values")
                reference = reference_match.group(1)

            field_match = re_field.match(line)
            if field_match:
                (value, key) = field_match.groups()
                if key in field_dict:
                    raise ParseError("Multiple FIELD values")
                field_dict[key] = value

        if not id_:
            raise ParseError("No component ID")
        if not reference:
            raise ParseError("No component ID")

        digikey_reference = field_dict.get("BomReferenceDigiKey", None)
        if digikey_reference:
            bom[digikey_reference] += 1
        else:
            LOG.warning(
                f"Component `{reference}`/`{id_}` has no `BomReferenceDigiKey` field data")

    writer = csv.writer(out)
    for key, quantity in bom.items():
        writer.writerow((key, quantity))



def main():
    logs = (LOG, )
    for log in logs:
        log.addHandler(logging.StreamHandler())

    parser = argparse.ArgumentParser(description="stencil.")
    parser.add_argument(
        "--verbose", "-v",
        action="count", default=0,
        help="Print verbose information for debugging.")
    parser.add_argument(
        "--quiet", "-q",
        action="count", default=0,
        help="Suppress warnings.")

    parser.add_argument(
        "sch_path",
        metavar="SCH",
        type=Path,
        help="Path to KiCAD schema file.")

    args = parser.parse_args()

    level = (logging.ERROR, logging.WARNING, logging.INFO, logging.DEBUG)[
        max(0, min(3, 1 + args.verbose - args.quiet))]
    for log in logs:
        log.setLevel(level)

    bom_digikey(sys.stdout, args.sch_path)



if __name__ == "__main__":
    main()
