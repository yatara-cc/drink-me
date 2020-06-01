SHELL := /bin/bash

VERSION := v1.0
VERSION_FLAT := $(shell echo $(VERSION) | sed 's/\W/-/g')
VENV := .venv

.PHONY : stl gerber


all : stl gerber

clean :
	rm -rf \
	  kicad/drink-me/gerber \
	  gerber \
	  stl


stl : \
	stl/drink-me.$(VERSION).case.stl \
	stl/drink-me.$(VERSION).base.stl \
	stl/drink-me.$(VERSION).back.stl \
	stl/drink-me.$(VERSION).rest.stl

install-python :
	virtualenv --python python3 --system-site-packages $(VENV)
	$(VENV)/bin/pip install \
	  sexpdata \
	  -e git+https://github.com/johnbeard/kiplot#egg=kiplot \
	  -e git+https://github.com/ianmackinnon/geotk#egg=geotk

uninstall-python :
	rm -rf .venv*


print-measurements :
	mkdir -p stl /tmp/drink-me/
	openscad -o /tmp/drink-me/null.stl \
	    -D debug_measurements=true \
	    openscad/drink-me.scad 2>&1 | \
	  sed 's/ECHO: \("\(.*\)"\)\?$$/\2/'

update-version :
	sed -i \
	  -e 's/\((rev \)v[0-9a-z.-]*\()\)/\1$(VERSION)\2/' \
	  -e 's/\((gr_text \)v[0-9a-z.-]*\( (\)/\1$(VERSION)\2/' \
	  kicad/drink-me*/drink-me.kicad_pcb
	sed -i \
	  -e 's/\(Rev "\)v[0-9a-z.-]*\("\)/\1$(VERSION)\2/' \
	  kicad/drink-me*/drink-me.sch


vector/drink-me.plate.dxf : openscad/drink-me.plate.scad openscad/drink-me.scad
	openscad -o $@ $<

vector/drink-me.pcb.%.dxf : openscad/drink-me.pcb.%.scad openscad/drink-me.scad
	openscad -o $@ $<

show-pcb-edge-cuts : vector vector/drink-me.pcb.edge-cuts.dxf
	dxf2kicad $^

show-pcb-margin : vector vector/drink-me.pcb.margin.dxf
	dxf2kicad $^

export-pcb-polygons : \
	vector/drink-me.pcb.edge-cuts.dxf \
	vector/drink-me.pcb.margin.dxf


stl/drink-me.$(VERSION).%.stl : openscad/drink-me.%.scad openscad/drink-me.scad
	mkdir -p stl /tmp/drink-me/stl
	openscad -o /tmp/drink-me/$@ $<
	meshlabserver -i /tmp/drink-me/$@ -o $@


define PCB

gerber/drink-me.$(VERSION)-$(1).gerber.zip : kicad/drink-me-$(1)/drink-me.kicad_pcb kicad/kiplot.config.yaml
	mkdir -p gerber
	$(VENV)/bin/kiplot -v \
	  -b $$< \
	  -c kicad/kiplot.config.yaml \
	  -d kicad/drink-me-$(1)/
	zip -j $$@ kicad/drink-me-$(1)/gerber/*

# Digi-Key uses the part of the filename up to the first period as the BOM name.
bom/drink-me-$(VERSION_FLAT)-$(1).bom-digikey.csv : kicad/drink-me-$(1)/drink-me.sch
	mkdir -p bom
	$(VENV)/bin/python python/generate_bom_digikey.py -v \
	  $$^ > $$@

vector/drink-me-$(1).pcb.traces.svg : kicad/drink-me-$(1)/drink-me.kicad_pcb
	kicad2svg $$< $$@


GERBER += $(GERBER) \
	gerber/drink-me.$(VERSION)-$(1).gerber.zip

BOM += $(BOM) \
	bom/drink-me-$(VERSION_FLAT)-$(1).bom-digikey.csv

TRACES_SVG += $(TRACES_SVG) \
	vector/drink-me-$(1).pcb.traces.svg

endef


$(eval $(call PCB,usb-c))
$(eval $(call PCB,usb-mini))
$(eval $(call PCB,usb-micro))


gerber : $(GERBER)

bom : $(BOM)

export-pcb-traces : $(TRACES_SVG)

