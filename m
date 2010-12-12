From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 12 Dec 2010 20:36:39 -0000
Subject: LVM2/test Makefile.in test-utils.sh api/Makefi ...
Message-ID: <20101212203639.12471.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-12-12 20:36:38

Modified files:
	test           : Makefile.in test-utils.sh 
	test/api       : Makefile.in 
Added files:
	test/api       : vgtest.sh 
Removed files:
	test           : lvm2app.sh 

Log message:
	First go at a somewhat more comprehensive mechanism to run "unit" tests for the
	lvm2app API. Further factoring of the support code needed. RHBZ 654445

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lvm2app.sh.diff?cvsroot=lvm2&r1=1.2&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/vgtest.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/Makefile.in.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/test/Makefile.in	2010/10/14 14:36:26	1.44
+++ LVM2/test/Makefile.in	2010/12/12 20:36:38	1.45
@@ -28,39 +28,35 @@
 T ?= .
 S ?= @ # never match anything by default
 VERBOSE ?= 0
-RUN = $(shell find -regextype posix-egrep -name t-\*.sh -and -regex ".*($(T)).*" -and -not -regex ".*($(S)).*" | sort)
+RUN = $(shell find $(srcdir) -regextype posix-egrep \( -name t-\*.sh -or -path */api/\*.sh \) -and -regex "$(srcdir)/.*($(T)).*" -and -not -regex "$(srcdir)/.*($(S)).*" | sort)
+RUN_BASE = $(shell echo $(RUN) | sed -e s,$(srcdir)/,,g)
 
 # Shell quote;
 SHELL_PATH_SQ = $(subst ','\'',$(SHELL_PATH))
 
-SCRIPTS := $(wildcard $(srcdir)/t-*.sh) \
- $(srcdir)/test-utils.sh \
- $(srcdir)/lvm-utils.sh
+SUPPORT := $(srcdir)/test-utils.sh \
+           $(srcdir)/lvm-utils.sh
 
 ifeq ("@UDEV_SYNC@", "yes")
 dm_udev_synchronisation = 1
 endif
 
-ifeq ("@APPLIB@", "yes")
-SCRIPTS += $(srcdir)/lvm2app.sh
-all: api/vgtest
-api/vgtest:
-	$(MAKE) -C api vgtest
-endif
-
 all check: init.sh
+	make -C api
 	@echo Testing with locking_type 1
-	VERBOSE=$(VERBOSE) ./bin/harness $(RUN)
+	VERBOSE=$(VERBOSE) ./bin/harness $(RUN_BASE)
 	@echo Testing with locking_type 3
-	VERBOSE=$(VERBOSE) LVM_TEST_LOCKING=3 ./bin/harness $(RUN)
+	VERBOSE=$(VERBOSE) LVM_TEST_LOCKING=3 ./bin/harness $(RUN_BASE)
 
 check_cluster: init.sh
+	make -C api
 	@echo Testing with locking_type 3
-	VERBOSE=$(VERBOSE) LVM_TEST_LOCKING=3 ./bin/harness $(RUN)
+	VERBOSE=$(VERBOSE) LVM_TEST_LOCKING=3 ./bin/harness $(RUN_BASE)
 
 check_local: init.sh
+	make -C api
 	@echo Testing with locking_type 1
-	VERBOSE=$(VERBOSE) LVM_TEST_LOCKING=1 ./bin/harness $(RUN)
+	VERBOSE=$(VERBOSE) LVM_TEST_LOCKING=1 ./bin/harness $(RUN_BASE)
 
 bin/not: $(srcdir)/not.c .bin-dir-stamp
 	$(CC) -o bin/not $<
@@ -73,7 +69,7 @@
 	cp $< bin/check
 	chmod +x bin/check
 
-init.sh: $(srcdir)/Makefile.in .bin-dir-stamp bin/not bin/check bin/harness $(SCRIPTS)
+init.sh: $(srcdir)/Makefile.in .bin-dir-stamp bin/not bin/check bin/harness $(RUN) $(SUPPORT) $(UNIT)
 	rm -f $@-t $@
 	echo 'top_srcdir=$(top_srcdir)' >> $@-t
 	echo 'abs_top_builddir=$(abs_top_builddir)' >> $@-t
@@ -81,6 +77,7 @@
 	echo 'PATH=$$abs_top_builddir/test/bin:$$PATH' >> $@-t
 	LDLPATH="\$$abs_top_builddir/libdm"; \
 	LDLPATH="$$LDLPATH:\$$abs_top_builddir/tools"; \
+	LDLPATH="$$LDLPATH:\$$abs_top_builddir/liblvm"; \
 	LDLPATH="$$LDLPATH:\$$abs_top_builddir/daemons/dmeventd"; \
 	LDLPATH="$$LDLPATH:\$$abs_top_builddir/daemons/dmeventd/plugins/lvm2"; \
 	LDLPATH="$$LDLPATH:\$$abs_top_builddir/daemons/dmeventd/plugins/mirror"; \
@@ -93,7 +90,11 @@
 	echo 'export DM_UDEV_SYNCHRONISATION=$(dm_udev_synchronisation)' >> $@-t
 	chmod a-w $@-t
 	mv $@-t $@
-	@if test "$(srcdir)" != . ; then echo "Copying tests to builddir."; cp $(SCRIPTS) . ; fi
+	@if test "$(srcdir)" != . ; then \
+	    echo "Copying tests to builddir."; \
+	    cp $(SUPPORT) .; \
+	    for f in $(RUN); do cp $$f `echo $$f | sed -e s,$(srcdir)/,,g`; done; \
+	fi
 
 Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
 	cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@
@@ -121,7 +122,7 @@
 
 clean:
 	rm -rf init.sh lvm-wrapper bin .bin-dir-stamp
-	if test "$(srcdir)" != . ; then rm -f $(subst $(srcdir)/, ,$(SCRIPTS)) lvm2app.sh ; fi
+	if test "$(srcdir)" != . ; then rm -f $(subst $(srcdir)/, ,$(RUN)) lvm2app.sh ; fi
 
 distclean: clean
 	rm -f Makefile
--- LVM2/test/test-utils.sh	2010/12/09 11:19:21	1.56
+++ LVM2/test/test-utils.sh	2010/12/12 20:36:38	1.57
@@ -433,6 +433,18 @@
 	lv4=LV4
 }
 
+apitest() {
+	t=$1
+        shift
+	test -x $abs_top_builddir/test/api/$t.t || exit 200
+	$abs_top_builddir/test/api/$t.t "$@"
+}
+
+api() {
+	test -x $abs_top_builddir/test/api/wrapper || exit 200
+	$abs_top_builddir/test/api/wrapper "$@"
+}
+
 LANG=C
 LC_ALL=C
 TZ=UTC
/cvs/lvm2/LVM2/test/api/vgtest.sh,v  -->  standard output
revision 1.1
--- LVM2/test/api/vgtest.sh
+++ -	2010-12-12 20:36:39.260508000 +0000
@@ -0,0 +1,18 @@
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+#
+# tests lvm2app library
+#
+
+. ./test-utils.sh
+aux prepare_devs 2
+pvcreate $dev1 $dev2
+apitest vgtest $vg1 $dev1 $dev2
--- LVM2/test/api/Makefile.in	2010/04/14 16:13:34	1.14
+++ LVM2/test/api/Makefile.in	2010/12/12 20:36:38	1.15
@@ -22,8 +22,11 @@
 TARGETS = vgtest
 test_SOURCES = test.c
 vgtest_SOURCES = vgtest.c
+wrapper_SOURCES = test.c
 INCLUDES += -I../../include
 
+UNIT = vgtest.t
+
 LVMLIBS = @LVM2APP_LIB@ -ldevmapper
 DEPLIBS = $(top_builddir)/liblvm/liblvm2app.so $(top_builddir)/libdm/libdevmapper.so
 
@@ -40,10 +43,22 @@
 
 test_OBJECTS = $(test_SOURCES:.c=.o)
 vgtest_OBJECTS = $(vgtest_SOURCES:.c=.o)
+wrapper_OBJECTS = $(wrapper_SOURCES:.c=.o)
 OBJECTS = $(test_OBJECTS) $(vgtest_OBJECTS)
 
+all: $(UNIT) test
+
 test: $(test_OBJECTS) $(DEPLIBS)
 	$(CC) -o test $(test_OBJECTS) $(CFLAGS) $(LDFLAGS) $(LVMLIBS) $(LIBS) $(READLINE_LIBS)
 
-vgtest: $(vgtest_OBJECTS) $(DEPLIBS)
-	$(CC) -o vgtest $(vgtest_OBJECTS) $(CFLAGS) $(LDFLAGS) $(LVMLIBS) $(LIBS)
+%.o: $(srcdir)/%.c
+	$(CC) -o $@ $(CFLAGS) $(LDFLAGS) $(LVMLIBS) $(LIBS) $(READLINE_LIBS)
+
+%.t: %.o $(DEPLIBS)
+	$(CC) -o $@ $(<) $(CFLAGS) $(LDFLAGS) $(LVMLIBS) $(LIBS)
+
+wrapper: $(wrapper_OBJECTS) $(DEPLIBS)
+	$(CC) -o wrapper $(wrapper_OBJECTS) $(CFLAGS) $(LDFLAGS) $(LVMLIBS) $(LIBS) -lreadline
+
+Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
+	cd $(top_builddir) && $(SHELL) ./config.status test/api/Makefile


