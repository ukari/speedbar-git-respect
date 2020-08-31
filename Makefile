VERSION:=0.1.1
REPO_NAME:=speedbar-git-respect
PACKAGE_NAME:=$(REPO_NAME)-$(VERSION)
PACKAGE_DIR:=/tmp/$(PACKAGE_NAME)

package: $(PACKAGE_DIR)
	tar --exclude="*#" --exclude="*~" --exclude="*.template.el" --exclude="Makefile" --exclude="*.elc" -cvf ../$(PACKAGE_NAME).tar -C $(PACKAGE_DIR)/.. $(PACKAGE_NAME)

$(PACKAGE_DIR):
	mkdir $@
	cp -r ../$(REPO_NAME)/* $@
	sed -re "s/VERSION/$(VERSION)/" $@/$(REPO_NAME)-pkg.template.el > $@/$(REPO_NAME)-pkg.el

clean:
	rm -f ../$(PACKAGE_NAME).tar
	rm -rf $(PACKAGE_DIR)

# end
