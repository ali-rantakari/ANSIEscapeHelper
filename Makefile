# ANSIEscapeHelper makefile
# 
# Created by Ali Rantakari on 4 May, 2009
# 

SHELL=/bin/bash

CURRDATE=$(shell date +"%Y-%m-%d")
APP_VERSION=$(shell /bin/bash -c "cat ANSIEscapeHelper.h | grep '^//  Version .*' | cut -d ' ' -f 4")
VERSION_ON_SERVER=$(shell curl -Ss http://hasseg.org/ansiEscapeHelper/?versioncheck=y)
TEMP_DEPLOYMENT_DIR=deployment/$(APP_VERSION)
TEMP_DEPLOYMENT_ZIPFILE=$(TEMP_DEPLOYMENT_DIR)/ansiEscapeHelper-v$(APP_VERSION).zip
VERSIONCHANGELOGFILELOC="$(TEMP_DEPLOYMENT_DIR)/changelog.html"
GENERALCHANGELOGFILELOC="changelog.html"
SCP_TARGET=$(shell cat ./deploymentScpTarget)
DEPLOYMENT_INCLUDES_DIR="./deployment-files"
DOCS_DIR=./headerdoc





testversionnumber:
	@echo
	@echo Version is: $(APP_VERSION)
	@echo


#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
# generate documentation
#-------------------------------------------------------------------------
docs:
	@echo
	@echo ---- Generating HTML docs from header file:
	@echo ======================================
	/Developer/usr/bin/headerdoc2html -o $(DOCS_DIR) ./ANSIEscapeHelper.h



#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
# make release package (prepare for deployment)
#-------------------------------------------------------------------------
package: docs
	@echo
	@echo ---- Preparing for deployment:
	@echo ======================================
	
# create zip archive
	mkdir -p "$(TEMP_DEPLOYMENT_DIR)"
	echo "-D -j $(TEMP_DEPLOYMENT_ZIPFILE) ANSIEscapeHelper.h ANSIEscapeHelper.m" | xargs zip
	cd $(DEPLOYMENT_INCLUDES_DIR) && echo "-g -R ../$(TEMP_DEPLOYMENT_ZIPFILE) *" | xargs zip
	echo "-g -r $(TEMP_DEPLOYMENT_ZIPFILE) $(DOCS_DIR)" | xargs zip
	
# if changelog doesn't already exist in the deployment dir
# for this version, get 'general' changelog file from root if
# one exists, and if not, create an empty changelog file
	@( if [ ! -e $(VERSIONCHANGELOGFILELOC) ];then\
		if [ -e $(GENERALCHANGELOGFILELOC) ];then\
			cp $(GENERALCHANGELOGFILELOC) $(VERSIONCHANGELOGFILELOC);\
			echo "Copied existing changelog.html from project root into deployment dir - opening it for editing";\
		else\
			echo -e "<ul>\n	<li></li>\n</ul>\n" > $(VERSIONCHANGELOGFILELOC);\
			echo "Created new empty changelog.html into deployment dir - opening it for editing";\
		fi; \
	else\
		echo "changelog.html exists for $(APP_VERSION) - opening it for editing";\
	fi )
	@open -a Smultron $(VERSIONCHANGELOGFILELOC)




#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
# deploy to server
#-------------------------------------------------------------------------
deploy: package
	@echo
	@echo ---- Deploying to server:
	@echo ======================================
	
	@echo "Checking latest version number vs. current version number..."
	@( if [ "$(VERSION_ON_SERVER)" != "$(APP_VERSION)" ];then\
		echo "Latest version on server is $(VERSION_ON_SERVER). Uploading $(APP_VERSION).";\
	else\
		echo "NOTE: Current version exists on server: ($(APP_VERSION)).";\
	fi;\
	echo "Press enter to continue uploading to server or Ctrl-C to cancel.";\
	read INPUTSTR;\
	scp -r $(TEMP_DEPLOYMENT_DIR) $(DOCS_DIR) $(SCP_TARGET); )




#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
# deploy headerdocs to server
#-------------------------------------------------------------------------
deploy-docs: docs
	@echo
	@echo ---- Deploying headerdoc HTML files to server:
	@echo ======================================
	
	@( echo "Press enter to continue uploading to server or Ctrl-C to cancel.";\
	read INPUTSTR;\
	scp -r $(DOCS_DIR) $(SCP_TARGET); )



#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
clean:
	@echo
	@echo ---- Cleaning up:
	@echo ======================================
	-rm -Rf deployment/*
	-rm -Rf $(DOCS_DIR)/*



