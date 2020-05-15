SHELL := /bin/bash

VERSION := v0.1
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
	stl/drink-me.$(VERSION).rest.stl

gerber : gerber/drink-me.$(VERSION).gerber.zip


install-python :
	virtualenv --python python3 --system-site-packages $(VENV)
	$(VENV)/bin/pip install \
	  sexpdata \
	  -e git+https://github.com/johnbeard/kiplot#egg=kiplot \
	  -e git+https://github.com/ianmackinnon/geotk#egg=geotk

uninstall-python :
	rm -rf .venv*


vector/drink-me.pcb.%.dxf : openscad/drink-me.pcb.%.scad openscad/drink-me.scad
	openscad -o $@ $<

vector/drink-me.pcb.traces.svg : kicad/drink-me/drink-me.kicad_pcb
	kicad2svg $< $@

show-pcb-edge-cuts : vector vector/drink-me.pcb.edge-cuts.dxf
	dxf2kicad $^

show-pcb-margin : vector vector/drink-me.pcb.margin.dxf
	dxf2kicad $^

export-pcb-traces : vector vector/drink-me.pcb.traces.svg
export-pcb-polygons : \
	vector/drink-me.pcb.edge-cuts.dxf \
	vector/drink-me.pcb.margin.dxf


stl/drink-me.$(VERSION).%.stl : openscad/drink-me.%.scad openscad/drink-me.scad
	mkdir -p stl /tmp/drink-me/stl
	openscad -o /tmp/drink-me/$@ $<
	meshlabserver -i /tmp/drink-me/$@ -o $@

gerber/drink-me.$(VERSION).gerber.zip : kicad/drink-me/drink-me.kicad_pcb kicad/kiplot.config.yaml
	mkdir -p gerber
	.venv/bin/kiplot -v \
	  -b $< \
	  -c kicad/kiplot.config.yaml \
	  -d kicad/drink-me/
	zip -j $@ kicad/drink-me/gerber/*
