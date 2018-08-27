CURRENT=$(pwd)
NAME := $(APP_NAME)
OS := $(shell uname)
RELEASE_VERSION := $(shell cat VERSION)
REV := $(shell git rev-list --tags --max-count=1 --grep '^[Rr]elease')
PREVIOUS_REV := $(shell git rev-list --tags --max-count=1 --skip=1 --grep '^[Rr]elease')
REV_TAG := $(shell git describe $(PREVIOUS_REV))
PREVIOUS_REV_TAG := $(shell git describe ${REV})



changelog: 
	echo Creating Github Changelog Release: $(RELEASE_VERSION)

	echo Found commits between $(PREVIOUS_REV_TAG) and $(REV_TAG) tags:
	git rev-list $(PREVIOUS_REV)..$(REV) --first-parent --pretty
	
	jx step changelog --version v$(RELEASE_VERSION) --generate-yaml=false --rev=$(REV) --previous-rev=$(PREVIOUS_REV)

tag:
	git add --all
	git commit -m "Release $(RELEASE_VERSION)" --allow-empty # if first release then no verion update is performed
	git tag -fa v$(RELEASE_VERSION) -m "Release version $(RELEASE_VERSION)"
	git push origin v$(RELEASE_VERSION)

