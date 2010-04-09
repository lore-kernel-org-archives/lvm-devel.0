From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 9 Apr 2010 21:44:29 -0000
Subject: LVM2/udev Makefile.in
Message-ID: <20100409214429.13811.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-04-09 21:44:28

Modified files:
	udev           : Makefile.in 

Log message:
	Update install rules for udev.
	
	Fix unwanted modification of $(top_builddir)/make.tmpl.
	
	Using dependency rules to install rules for udev.
	There is minor problem, with concurent usage of builddir
	and srcdir could lead to missuse of 10-dm.rules which
	could be found in VPATH from different builddir.
	However current solution uses intermediate target so
	the generated 10-dm.rules exists only for short period of time
	during make install execution.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/Makefile.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/udev/Makefile.in	2010/04/09 21:34:32	1.7
+++ LVM2/udev/Makefile.in	2010/04/09 21:44:28	1.8
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2009-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -25,24 +25,13 @@
 
 vpath %.rules $(srcdir)
 
-%: %.in
+%.rules: %.rules.in
 	$(SED) -e "s/(DM_DIR)/$(DM_DIR)/" $< >$@
 
-install_lvm2: $(LVM_RULES)
-	@echo "Installing $(LVM_RULES) in $(udevdir)"
-	@for f in $(LVM_RULES); \
-	do \
-	   $(RM) $(udevdir)/$$f; \
-	   $(INSTALL) -c -D $(OWNER) $(GROUP) -m 644 $(srcdir)/$$f $(udevdir)/$$f; \
-	done
-
-install_device-mapper: $(DM_RULES)
-	@echo "Installing $(DM_RULES) in $(udevdir)"
-	@for f in $(DM_RULES); \
-	do \
-	   $(RM) $(udevdir)/$$f; \
-	   if test -f $$f; then file=$$f; else file=$(srcdir)/$$f; fi; \
-	   $(INSTALL) -c -D $(OWNER) $(GROUP) -m 644 $$file $(udevdir)/$$f; \
-	done
+%_install: %.rules
+	$(INSTALL_DATA) -D $< $(udevdir)/$(<F)
+
+install_device-mapper: $(DM_RULES:.rules=_install)
+install_lvm2: $(LVM_RULES:.rules=_install)
 
 install: install_lvm2 install_device-mapper


