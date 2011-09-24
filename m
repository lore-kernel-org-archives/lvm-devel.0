From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 24 Sep 2011 21:10:19 -0000
Subject: LVM2 ./WHATS_NEW test/Makefile.in
Message-ID: <20110924211019.2590.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-24 21:10:19

Modified files:
	.              : WHATS_NEW 
	test           : Makefile.in 

Log message:
	Improvements
	
	Simplify RUN_BASE
	
	Put .tests-stamp deps only for check target and fix its cleanup.
	Fix abs_top_srcdir.
	vgimportclone needs  srcdir.
	Clean  api subdir.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2136&r2=1.2137
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.59&r2=1.60

--- LVM2/WHATS_NEW	2011/09/24 21:05:03	1.2136
+++ LVM2/WHATS_NEW	2011/09/24 21:10:19	1.2137
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Improve testing Makefile.
   Fix install_ocf make target when srcdir != builddir. (2.02.80)
   Support env vars LVM_CLVMD_BINARY and LVM_BINARY in clvmd.
   Fix restart of clvmd (preserve exlusive locks). (2.02.64)
--- LVM2/test/Makefile.in	2011/09/19 15:54:15	1.59
+++ LVM2/test/Makefile.in	2011/09/24 21:10:19	1.60
@@ -1,4 +1,4 @@
-# Copyright (C) 2007-2010 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007-2011 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -31,7 +31,7 @@
 VERBOSE ?= 0
 ALL = $(shell find $(srcdir) \( -name t-\*.sh -or -path */api/\*.sh \) | sort)
 RUN = $(shell find $(srcdir) -regextype posix-egrep \( -name t-\*.sh -or -path */api/\*.sh \) -and -regex "$(srcdir)/.*($(T)).*" -and -not -regex "$(srcdir)/.*($(S)).*" | sort)
-RUN_BASE = $(shell echo $(RUN) | xargs -n 1 echo | sed -e s,^$(srcdir)/,,)
+RUN_BASE = $(subst $(srcdir)/,,$(RUN))
 
 # Shell quote;
 SHELL_PATH_SQ = $(subst ','\'',$(SHELL_PATH))
@@ -40,7 +40,9 @@
 dm_udev_synchronisation = 1
 endif
 
-all check: .tests-stamp
+all: check
+
+check: .tests-stamp
 	make -C api tests
 	@echo Testing with locking_type 1
 	VERBOSE=$(VERBOSE) ./lib/harness $(RUN_BASE)
@@ -71,7 +73,7 @@
 	rm -f $@-t
 	echo 'top_srcdir=$(top_srcdir)' >> $@-t
 	echo 'abs_top_builddir=$(abs_top_builddir)' >> $@-t
-	echo 'abs_top_srcdir=$(abs_top_builddir)' >> $@-t
+	echo 'abs_top_srcdir=$(abs_top_srcdir)' >> $@-t
 	echo 'abs_srcdir=$(abs_srcdir)' >> $@-t
 	echo 'abs_builddir=$(abs_builddir)' >> $@-t
 	echo 'export DM_UDEV_SYNCHRONISATION=$(dm_udev_synchronisation)' >> $@-t
@@ -81,35 +83,35 @@
       lib/check lib/aux lib/test lib/utils lib/get lib/lvm-wrapper \
       lib/paths
 
+CMDS = lvm $(shell cat $(top_builddir)/tools/.commands)
+
 .tests-stamp: $(ALL) $(LIB)
 	@if test "$(srcdir)" != . ; then \
 	    echo "Copying tests to builddir."; \
 	    for f in $(ALL); do cp $$f `echo $$f | sed -e s,^$(srcdir)/,,`; done; \
 	fi
-	touch .tests-stamp
+	touch $@
 
 Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
 	cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@
 
-.lib-dir-stamp:
+.lib-dir-stamp: $(top_srcdir)/scripts/fsadm.sh
 	mkdir -p lib
-	for i in lvm $$(cat ../tools/.commands); do \
-	  ln -fs lvm-wrapper lib/$$i; \
-	done
+	for i in $(CMDS); do ln -fs lvm-wrapper lib/$$i; done
 	ln -fs "$(abs_top_builddir)/tools/dmsetup" lib/dmsetup
 	ln -fs "$(abs_top_builddir)/daemons/clvmd/clvmd" lib/clvmd
 	ln -fs "$(abs_top_builddir)/daemons/dmeventd/dmeventd" lib/dmeventd
 	ln -fs "$(abs_top_builddir)/daemons/lvmetad/lvmetad" lib/lvmetad
-	ln -fs "$(abs_top_builddir)/scripts/vgimportclone.sh" lib/vgimportclone
-	chmod +x "$(abs_top_builddir)/scripts/fsadm.sh"
-	ln -fs "$(abs_top_builddir)/scripts/fsadm.sh" lib/fsadm
+	ln -fs "$(abs_top_srcdir)/scripts/vgimportclone.sh" lib/vgimportclone
+	cp -f "$(top_srcdir)/scripts/fsadm.sh" lib/fsadm
+	@chmod +x lib/fsadm
 	touch $@
 
 clean:
-	for i in lvm $$(cat ../tools/.commands); do rm -f lib/$$i; done
-	if test "$(srcdir)" != . ; then rm -f $(subst $(srcdir)/, ,$(RUN)) lvm2app.sh ; fi
+	make -C api clean
+	test "$(srcdir)" != . && rm -f $(RUN_BASE) lvm2app.sh
 
-CLEAN_TARGETS += .lib-dir-stamp .test-stamp $(LIB) \
-	lib/dmsetup lib/clvmd lib/dmeventd lib/vgimportclone lib/fsadm
+CLEAN_TARGETS += .lib-dir-stamp .tests-stamp $(LIB) $(addprefix lib/,$(CMDS)) \
+	lib/clvmd lib/dmeventd lib/dmsetup lib/lvmetad lib/fsadm lib/vgimportclone
 
 .NOTPARALLEL:


