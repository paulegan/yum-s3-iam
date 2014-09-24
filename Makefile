PROJECT_NAME ?= yum-plugin-s3-iam
SPEC ?= $(PROJECT_NAME).spec
SOURCES := ./s3iam.* ./LICENSE ./README.md ./NOTICE ./Makefile

RPMDIR ?= $(CURDIR)/dist
BUILDDIR ?= $(CURDIR)/build
DEFINES = \
	--define '_topdir $(CURDIR)' \
	--define '_rpmtopdir $(CURDIR)' \
	--define '_specdir $(CURDIR)' \
	--define '_rpmdir $(RPMDIR)' \
	--define '_srcrpmdir $(RPMDIR)' \
	--define '_sourcedir $(RPMDIR)' \
	--define '_builddir $(CURDIR)' \
	--define '_buildrootdir $(BUILDDIR)'

RPM_BUILDNAME := $(shell rpm --eval '%{_build_name_fmt}')
RPM ?= $(RPMDIR)/$(shell rpm --specfile $(SPEC) -q --qf '$(RPM_BUILDNAME)\n' $(DEFINES))

SOURCE0_URL ?= $(word 2, $(shell spectool -l -s 0 $(DEFINES) $(SPEC)))
SOURCE0 ?= $(RPMDIR)/$(shell basename $(SOURCE0_URL))

.PHONY: rpm test install clean

rpm: $(RPM)

test: $(RPM)
	@python tests.py

install:
	install -m 0755 -d $(DESTDIR)/etc/yum/pluginconf.d/
	install -m 0644 s3iam.conf $(DESTDIR)/etc/yum/pluginconf.d/
	install -m 0755 -d $(DESTDIR)/usr/lib/yum-plugins/
	install -m 0644 s3iam.py $(DESTDIR)/usr/lib/yum-plugins/

install-rpm: $(RPM)
	sudo yum localinstall $<

clean:
	$(RM) -r $(SOURCE0) $(RPM) $(RPMDIR) $(BUILDDIR)

$(RPM): $(SPEC) $(SOURCE0)
	rpmbuild $(DEFINES) --clean -bb $<

$(SOURCE0): $(RPMDIR)
	tar -c --transform 's,^\.,$(PROJECT_NAME)-master,' -f $@ $(SOURCES)

$(RPMDIR):
	@mkdir $@
