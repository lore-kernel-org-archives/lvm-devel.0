From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 5 Jan 2011 00:16:41 -0000
Subject: LVM2/test Makefile.in t-000-basic.sh t-activat ...
Message-ID: <20110105001641.3640.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-01-05 00:16:21

Modified files:
	test           : Makefile.in t-000-basic.sh 
	                 t-activate-missing.sh t-activate-partial.sh 
	                 t-covercmd.sh t-dmeventd-restart.sh t-fsadm.sh 
	                 t-inconsistent-metadata.sh t-listings.sh 
	                 t-lock-blocking.sh t-lvchange-mirror.sh 
	                 t-lvconvert-mirror-basic.sh 
	                 t-lvconvert-mirror.sh 
	                 t-lvconvert-repair-dmeventd.sh 
	                 t-lvconvert-repair-policy.sh 
	                 t-lvconvert-repair-replace.sh 
	                 t-lvconvert-repair-transient.sh 
	                 t-lvconvert-repair.sh t-lvconvert-twostep.sh 
	                 t-lvcreate-mirror.sh t-lvcreate-operation.sh 
	                 t-lvcreate-pvtags.sh t-lvcreate-small-snap.sh 
	                 t-lvcreate-usage.sh 
	                 t-lvextend-percent-extents.sh 
	                 t-lvextend-snapshot-dmeventd.sh 
	                 t-lvextend-snapshot-policy.sh t-lvm-init.sh 
	                 t-lvmcache-exercise.sh t-lvresize-mirror.sh 
	                 t-lvresize-usage.sh t-mdata-strings.sh 
	                 t-metadata-balance.sh t-metadata.sh 
	                 t-mirror-names.sh 
	                 t-mirror-vgreduce-removemissing.sh 
	                 t-nomda-missing.sh t-pool-labels.sh 
	                 t-pv-range-overflow.sh t-pvchange-usage.sh 
	                 t-pvcreate-metadata0.sh 
	                 t-pvcreate-operation-md.sh 
	                 t-pvcreate-operation.sh t-pvcreate-usage.sh 
	                 t-pvmove-basic.sh t-pvremove-usage.sh 
	                 t-read-ahead.sh 
	                 t-snapshot-autoumount-dmeventd.sh 
	                 t-snapshot-merge.sh t-snapshots-of-mirrors.sh 
	                 t-tags.sh t-test-partition.sh 
	                 t-topology-support.sh t-unknown-segment.sh 
	                 t-unlost-pv.sh t-vgcfgbackup-usage.sh 
	                 t-vgchange-maxlv.sh t-vgchange-usage.sh 
	                 t-vgcreate-usage.sh 
	                 t-vgextend-restoremissing.sh 
	                 t-vgextend-usage.sh t-vgmerge-operation.sh 
	                 t-vgmerge-usage.sh t-vgreduce-usage.sh 
	                 t-vgrename-usage.sh t-vgsplit-operation.sh 
	                 t-vgsplit-stacked.sh t-vgsplit-usage.sh 
	test/api       : percent.sh vgtest.sh 
Added files:
	test/lib       : aux.sh check.sh get.sh harness.c lvm-wrapper.sh 
	                 not.c test.sh utils.sh 
Removed files:
	test           : check.sh harness.c not.c 

Log message:
	Substantial rework of the functional test support code. Some new features:
	
	- somewhat neater, more consistent and more readable output
	- possible to set any lvm.conf value: aux lvmconf "section/key = value"
	- LVM_TEST_NODEBUG to suppress the (lengthy) "## DEBUG" output
	- back-substitution on test output ($TESTDIR/$PREFIX -> @TESTDIR@/@PREFIX@)
	- support code moved from test/ to test/lib/ --> less clutter

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-000-basic.sh.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-activate-missing.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-activate-partial.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-covercmd.sh.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-dmeventd-restart.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-fsadm.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-inconsistent-metadata.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-listings.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lock-blocking.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvchange-mirror.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror-basic.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror.sh.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair-dmeventd.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair-policy.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair-replace.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair-transient.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair.sh.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-twostep.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-mirror.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-pvtags.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-small-snap.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvextend-percent-extents.sh.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvextend-snapshot-dmeventd.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvextend-snapshot-policy.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvm-init.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvmcache-exercise.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvresize-mirror.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvresize-usage.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mdata-strings.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-metadata-balance.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-metadata.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-names.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-vgreduce-removemissing.sh.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-nomda-missing.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pool-labels.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pv-range-overflow.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvchange-usage.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-metadata0.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation-md.sh.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvmove-basic.sh.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvremove-usage.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-read-ahead.sh.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-snapshot-autoumount-dmeventd.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-snapshot-merge.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-snapshots-of-mirrors.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-tags.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-test-partition.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-topology-support.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-unknown-segment.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-unlost-pv.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgcfgbackup-usage.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgchange-maxlv.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgchange-usage.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgcreate-usage.sh.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgextend-restoremissing.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgextend-usage.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgmerge-operation.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgmerge-usage.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgreduce-usage.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgrename-usage.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-operation.sh.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-stacked.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-usage.sh.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/check.sh.diff?cvsroot=lvm2&r1=1.6&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/harness.c.diff?cvsroot=lvm2&r1=1.14&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/not.c.diff?cvsroot=lvm2&r1=1.5&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/percent.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/vgtest.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/check.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/get.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/harness.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/lvm-wrapper.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/not.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/test.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/utils.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1

--- LVM2/test/Makefile.in	2010/12/14 23:23:45	1.49
+++ LVM2/test/Makefile.in	2011/01/05 00:16:18	1.50
@@ -34,94 +34,73 @@
 # Shell quote;
 SHELL_PATH_SQ = $(subst ','\'',$(SHELL_PATH))
 
-SUPPORT := $(srcdir)/test-utils.sh \
-           $(srcdir)/lvm-utils.sh
-
 ifeq ("@UDEV_SYNC@", "yes")
 dm_udev_synchronisation = 1
 endif
 
-all check: init.sh
+all check: .tests-stamp
 	make -C api tests
 	@echo Testing with locking_type 1
-	VERBOSE=$(VERBOSE) ./bin/harness $(RUN_BASE)
+	VERBOSE=$(VERBOSE) ./lib/harness $(RUN_BASE)
 	@echo Testing with locking_type 3
-	VERBOSE=$(VERBOSE) LVM_TEST_LOCKING=3 ./bin/harness $(RUN_BASE)
+	VERBOSE=$(VERBOSE) LVM_TEST_LOCKING=3 ./lib/harness $(RUN_BASE)
 
-check_cluster: init.sh
+check_cluster: .tests-stamp
 	make -C api tests
 	@echo Testing with locking_type 3
-	VERBOSE=$(VERBOSE) LVM_TEST_LOCKING=3 ./bin/harness $(RUN_BASE)
+	VERBOSE=$(VERBOSE) LVM_TEST_LOCKING=3 ./lib/harness $(RUN_BASE)
 
-check_local: init.sh
+check_local: .tests-stamp
 	make -C api tests
 	@echo Testing with locking_type 1
-	VERBOSE=$(VERBOSE) LVM_TEST_LOCKING=1 ./bin/harness $(RUN_BASE)
+	VERBOSE=$(VERBOSE) LVM_TEST_LOCKING=1 ./lib/harness $(RUN_BASE)
 
-bin/not: $(srcdir)/not.c .bin-dir-stamp
-	$(CC) -o bin/not $<
-	ln -sf not bin/should
+lib/should: lib/not
+	ln -sf not lib/should
 
-bin/harness: $(srcdir)/harness.c .bin-dir-stamp
-	$(CC) -o bin/harness $<
+lib/%: $(srcdir)/lib/%.c .lib-dir-stamp
+	$(CC) -o $@ $<
 
-bin/check: $(srcdir)/check.sh .bin-dir-stamp
-	cp $< bin/check
-	chmod +x bin/check
+lib/%: $(srcdir)/lib/%.sh .lib-dir-stamp
+	cp $< $@
+	chmod +x $@
 
-init.sh: $(srcdir)/Makefile.in .bin-dir-stamp bin/not bin/check bin/harness $(RUN) $(SUPPORT) $(UNIT)
-	rm -f $@-t $@
+lib/paths: $(srcdir)/Makefile.in .lib-dir-stamp
+	rm -f $@-t
 	echo 'top_srcdir=$(top_srcdir)' >> $@-t
 	echo 'abs_top_builddir=$(abs_top_builddir)' >> $@-t
 	echo 'abs_top_srcdir=$(abs_top_builddir)' >> $@-t
-	echo 'PATH=$$abs_top_builddir/test/bin:$$PATH' >> $@-t
-	LDLPATH="\$$abs_top_builddir/libdm"; \
-	LDLPATH="$$LDLPATH:\$$abs_top_builddir/tools"; \
-	LDLPATH="$$LDLPATH:\$$abs_top_builddir/liblvm"; \
-	LDLPATH="$$LDLPATH:\$$abs_top_builddir/daemons/dmeventd"; \
-	LDLPATH="$$LDLPATH:\$$abs_top_builddir/daemons/dmeventd/plugins/lvm2"; \
-	LDLPATH="$$LDLPATH:\$$abs_top_builddir/daemons/dmeventd/plugins/mirror"; \
-	LDLPATH="$$LDLPATH:\$$abs_top_builddir/daemons/dmeventd/plugins/snapshot"; \
-	echo "export LD_LIBRARY_PATH=\"$$LDLPATH\"" >> $@-t
-	echo 'top_srcdir=$(top_srcdir)' >> $@-t
 	echo 'abs_srcdir=$(abs_srcdir)' >> $@-t
 	echo 'abs_builddir=$(abs_builddir)' >> $@-t
-	echo 'export PATH' >> $@-t
 	echo 'export DM_UDEV_SYNCHRONISATION=$(dm_udev_synchronisation)' >> $@-t
-	chmod a-w $@-t
 	mv $@-t $@
+
+LIB = lib/not lib/should lib/harness \
+      lib/check lib/aux lib/test lib/utils lib/get lib/lvm-wrapper \
+      lib/paths
+
+.tests-stamp: $(RUN) $(LIB)
 	@if test "$(srcdir)" != . ; then \
 	    echo "Copying tests to builddir."; \
-	    cp $(SUPPORT) .; \
 	    for f in $(RUN); do cp $$f `echo $$f | sed -e s,^$(srcdir)/,,`; done; \
 	fi
+	touch .tests-stamp
 
 Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
 	cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@
 
-.bin-dir-stamp: lvm-wrapper
-	rm -rf bin
-	mkdir bin
+.lib-dir-stamp:
+	mkdir -p lib
 	for i in lvm $$(cat ../tools/.commands); do \
-	  ln -s ../lvm-wrapper bin/$$i; \
+	  ln -fs lvm-wrapper lib/$$i; \
 	done
-	ln -s "$(abs_top_builddir)/tools/dmsetup" bin/dmsetup
-	ln -s "$(abs_top_builddir)/daemons/clvmd/clvmd" bin/clvmd
-	ln -s "$(abs_top_builddir)/daemons/dmeventd/dmeventd" bin/dmeventd
+	ln -s "$(abs_top_builddir)/tools/dmsetup" lib/dmsetup
+	ln -s "$(abs_top_builddir)/daemons/clvmd/clvmd" lib/clvmd
+	ln -s "$(abs_top_builddir)/daemons/dmeventd/dmeventd" lib/dmeventd
 	touch $@
 
-lvm-wrapper: Makefile
-	rm -f $@-t $@
-	echo '#!/bin/sh'                                          >  $@-t
-	echo 'cmd=$$(echo ./$$0|sed "s,.*/,,")'                   >> $@-t
-	echo 'test "$$cmd" = lvm &&'                              >> $@-t
-	echo 'exec "$(abs_top_builddir)/tools/lvm" "$$@"'         >> $@-t
-	echo 'exec "$(abs_top_builddir)/tools/lvm" "$$cmd" "$$@"' >> $@-t
-	chmod a-w,a+x $@-t
-	mv $@-t $@
-
 clean:
-	rm -rf init.sh lvm-wrapper bin .bin-dir-stamp
+	rm -rf bin .lib-dir-stamp .test-stamp
 	if test "$(srcdir)" != . ; then rm -f $(subst $(srcdir)/, ,$(RUN)) lvm2app.sh ; fi
 
 distclean: clean
--- LVM2/test/t-000-basic.sh	2010/08/02 13:18:02	1.10
+++ LVM2/test/t-000-basic.sh	2011/01/05 00:16:20	1.11
@@ -8,7 +8,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
 lvm version
 
--- LVM2/test/t-activate-missing.sh	2010/07/28 12:20:41	1.3
+++ LVM2/test/t-activate-missing.sh	2011/01/05 00:16:20	1.4
@@ -17,9 +17,9 @@
 #   instead lvconvert --repair them?)
 # - linear LVs with bits missing are not activated
 
-. ./test-utils.sh
+. lib/test
 
-prepare_vg 4
+aux prepare_vg 4
 
 lvcreate -l1 -n linear1 $vg $dev1
 lvcreate -l1 -n linear2 $vg $dev2
@@ -32,7 +32,7 @@
 lvcreate -l1 -m1 -n mirror123 $vg $dev1 $dev2 $dev3
 
 vgchange -a n $vg
-disable_dev $dev1
+aux disable_dev $dev1
 not vgchange -a y $vg
 not vgck $vg
 
@@ -45,8 +45,8 @@
 check inactive $vg mirror123
 
 vgchange -a n $vg
-enable_dev $dev1
-disable_dev $dev2
+aux enable_dev $dev1
+aux disable_dev $dev2
 not vgchange -a y $vg
 not vgck $vg
 
@@ -59,8 +59,8 @@
 check inactive $vg mirror123
 
 vgchange -a n $vg
-enable_dev $dev2
-disable_dev $dev3
+aux enable_dev $dev2
+aux disable_dev $dev3
 not vgchange -a y $vg
 not vgck $vg
 
@@ -73,8 +73,8 @@
 check active $vg mirror12
 
 vgchange -a n $vg
-enable_dev $dev3
-disable_dev $dev4
+aux enable_dev $dev3
+aux disable_dev $dev4
 vgchange -a y $vg
 not vgck $vg
 
--- LVM2/test/t-activate-partial.sh	2010/07/28 12:20:41	1.4
+++ LVM2/test/t-activate-partial.sh	2011/01/05 00:16:20	1.5
@@ -8,13 +8,13 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_vg 3
 
 lvcreate -m 1 -l 1 -n mirror $vg
 lvchange -a n $vg/mirror
-disable_dev $dev1
+aux disable_dev $dev1
 
 not vgreduce --removemissing $vg
 not lvchange -v -a y $vg/mirror
--- LVM2/test/t-covercmd.sh	2010/08/12 04:09:00	1.9
+++ LVM2/test/t-covercmd.sh	2011/01/05 00:16:20	1.10
@@ -12,7 +12,7 @@
 # tests basic functionality of read-ahead and ra regressions
 #
 
-. ./test-utils.sh
+. lib/test
 
 TEST_UUID="aaaaaa-aaaa-aaaa-aaaa-aaaa-aaaa-aaaaaa"
 
@@ -31,7 +31,7 @@
 pvcreate --metadatacopies 0 $dev3
 pvcreate $dev4
 pvcreate --norestorefile -u $TEST_UUID --metadatacopies 0 $dev5
-vgcreate -c n $vg $devs
+vgcreate -c n $vg $(cat DEVICES)
 lvcreate -n $lv -l 5 -i5 -I256 $vg
 
 # test *scan and *display tools
--- LVM2/test/t-dmeventd-restart.sh	2010/10/27 09:16:31	1.1
+++ LVM2/test/t-dmeventd-restart.sh	2011/01/05 00:16:20	1.2
@@ -9,10 +9,10 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
-prepare_vg 5
-prepare_dmeventd
+aux prepare_vg 5
+aux prepare_dmeventd
 
 which mkfs.ext2 || exit 200
 
@@ -22,7 +22,7 @@
 lvchange --monitor y $vg/3way
 
 dmeventd -R -f &
-LOCAL_DMEVENTD="$!"
+echo "$!" > LOCAL_DMEVENTD
 
 sleep 1 # wait a bit, so we talk to the new dmeventd later
 
--- LVM2/test/t-fsadm.sh	2010/10/13 09:44:52	1.4
+++ LVM2/test/t-fsadm.sh	2011/01/05 00:16:20	1.5
@@ -12,7 +12,7 @@
 test_description='Exercise fsadm filesystem resize'
 exit 200
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_vg 1 100
 
--- LVM2/test/t-inconsistent-metadata.sh	2010/07/07 14:43:57	1.4
+++ LVM2/test/t-inconsistent-metadata.sh	2011/01/05 00:16:20	1.5
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_vg 3
 
@@ -17,14 +17,14 @@
 lvcreate -l 1 -n resized $vg
 lvchange -a n $vg/mirror
 
-backup_dev $devs
+aux backup_dev $(cat DEVICES)
 
 init() {
-	restore_dev $devs
+	aux restore_dev $(cat DEVICES)
 	lvs -o lv_name,lv_size --units k $vg | tee lvs.out
 	grep resized lvs.out | not grep 8192
 	lvresize -L 8192K $vg/resized
-	restore_dev $dev1
+	aux restore_dev $dev1
 }
 
 check() {
@@ -66,10 +66,10 @@
 
 echo Check auto-repair of failed vgextend - metadata written to original pv but not new pv
 vgremove -f $vg
-pvremove -ff $devs
-pvcreate $devs
-backup_dev $dev2
+pvremove -ff $(cat DEVICES)
+pvcreate $(cat DEVICES)
+aux backup_dev $dev2
 vgcreate $vg $dev1
 vgextend $vg $dev2
-restore_dev $dev2
-should compare_two_fields_ vgs $vg vg_mda_count pvs $dev2 vg_mda_count
+aux restore_dev $dev2
+should check compare_fields vgs $vg vg_mda_count pvs $dev2 vg_mda_count
--- LVM2/test/t-listings.sh	2009/04/21 12:59:18	1.2
+++ LVM2/test/t-listings.sh	2011/01/05 00:16:20	1.3
@@ -12,7 +12,7 @@
 # tests functionality of lvs, pvs, vgs, *display tools
 #
 
-. ./test-utils.sh
+. lib/test
 
 get_lvs_()
 {
@@ -38,16 +38,16 @@
 pvs --noheadings -o  seg_all,pv_all,lv_all,vg_all | tee out
 test $(wc -l <out) -eq 5
 
-vgcreate -c n $vg $devs
+vgcreate -c n $vg $(cat DEVICES)
 
 #COMM pvs and vgs report mda_count, mda_free (bz202886, bz247444)
-pvs -o +pv_mda_count,pv_mda_free $devs
+pvs -o +pv_mda_count,pv_mda_free $(cat DEVICES)
 for I in $dev2 $dev3 $dev5; do
-	aux check_pv_field_ $I pv_mda_count 0
-	aux check_pv_field_ $I pv_mda_free 0
+	check pv_field $I pv_mda_count 0
+	check pv_field $I pv_mda_free 0
 done
 vgs -o +vg_mda_count,vg_mda_free $vg
-aux check_vg_field_ $vg vg_mda_count 2
+check vg_field $vg vg_mda_count 2
 
 #COMM pvs doesn't display --metadatacopies 0 PVs as orphans (bz409061)
 pvdisplay $dev2|grep "VG Name.*$vg"
@@ -77,7 +77,7 @@
 # would complain if not
 
 #COMM pvdisplay --maps feature (bz149814)
-pvdisplay $devs >out
-pvdisplay --maps $devs >out2
+pvdisplay $(cat DEVICES) >out
+pvdisplay --maps $(cat DEVICES) >out2
 not diff out out2
 
--- LVM2/test/t-lock-blocking.sh	2010/08/02 13:23:01	1.2
+++ LVM2/test/t-lock-blocking.sh	2011/01/05 00:16:20	1.3
@@ -11,7 +11,7 @@
 
 test_description='test some blocking / non-blocking multi-vg operations'
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_devs 3
 test -n "$LOCAL_CLVMD" && exit 200
--- LVM2/test/t-lvchange-mirror.sh	2010/04/12 19:16:24	1.1
+++ LVM2/test/t-lvchange-mirror.sh	2011/01/05 00:16:20	1.2
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 aux prepare_vg 3
 
 # force resync 2-way active mirror
--- LVM2/test/t-lvconvert-mirror-basic.sh	2010/07/28 12:20:41	1.4
+++ LVM2/test/t-lvconvert-mirror-basic.sh	2011/01/05 00:16:20	1.5
@@ -8,7 +8,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
 log_name_to_count()
 {
@@ -83,7 +83,7 @@
 		max_log_count=$start_log_count
 	fi
 
-	prepare_vg 5
+	aux prepare_vg 5
 
 	if [ $start_count -gt 0 ]; then
 		# Are there extra devices for the log or do we overlap
--- LVM2/test/t-lvconvert-mirror.sh	2010/11/30 11:35:32	1.8
+++ LVM2/test/t-lvconvert-mirror.sh	2011/01/05 00:16:20	1.9
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
 # convert from linear to 2-way mirror
 aux prepare_vg 5
--- LVM2/test/t-lvconvert-repair-dmeventd.sh	2010/10/26 12:53:07	1.3
+++ LVM2/test/t-lvconvert-repair-dmeventd.sh	2011/01/05 00:16:20	1.4
@@ -9,18 +9,18 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
-prepare_vg 5
-prepare_dmeventd
+aux prepare_vg 5
+aux prepare_dmeventd
 
 which mkfs.ext2 || exit 200
 
 lvcreate -m 3 --ig -L 1 -n 4way $vg
 lvchange --monitor y $vg/4way
-disable_dev $dev2 $dev4
+aux disable_dev $dev2 $dev4
 mkfs.ext2 $DM_DEV_DIR/$vg/4way
 sleep 10 # FIXME: need a "poll" utility, akin to "check"
-enable_dev $dev2 $dev4
+aux enable_dev $dev2 $dev4
 check mirror $vg 4way
 check mirror_legs $vg 4way 2
--- LVM2/test/t-lvconvert-repair-policy.sh	2010/05/24 15:32:21	1.5
+++ LVM2/test/t-lvconvert-repair-policy.sh	2011/01/05 00:16:20	1.6
@@ -9,16 +9,16 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
-prepare_vg 4
+aux prepare_vg 4
 
 # Clean-up and create a 2-way mirror, where the the
 # leg devices are always on $dev[12] and the log
 # is always on $dev3.  ($dev4 behaves as a spare)
 cleanup() {
 	vgreduce --removemissing $vg
-	for d in "$@"; do enable_dev $d; done
+	for d in "$@"; do aux enable_dev $d; done
 	for d in "$@"; do vgextend $vg $d; done
 	lvremove -ff $vg/mirror
 	lvcreate -m 1 --ig -l 2 -n mirror $vg $dev1 $dev2 $dev3:0
@@ -36,7 +36,7 @@
 lvchange --partial -a y $vg/mirror
 repair 'activation { mirror_image_fault_policy = "remove" }'
 check linear $vg mirror
-aux cleanup $dev1
+cleanup $dev1
 
 # Fail a leg of a mirror.
 # Expected result: Mirror (leg replaced)
@@ -44,7 +44,7 @@
 repair 'activation { mirror_image_fault_policy = "replace" }'
 check mirror $vg mirror
 lvs | grep mirror_mlog
-aux cleanup $dev1
+cleanup $dev1
 
 # Fail a leg of a mirror (use old name for policy specification)
 # Expected result: Mirror (leg replaced)
@@ -52,7 +52,7 @@
 repair 'activation { mirror_device_fault_policy = "replace" }'
 check mirror $vg mirror
 lvs | grep mirror_mlog
-aux cleanup $dev1
+cleanup $dev1
 
 # Fail a leg of a mirror w/ no available spare
 # Expected result: 2-way with corelog
@@ -60,7 +60,7 @@
 repair 'activation { mirror_image_fault_policy = "replace" }'
 check mirror $vg mirror
 lvs | not grep mirror_mlog
-aux cleanup $dev2 $dev4
+cleanup $dev2 $dev4
 
 # Fail the log device of a mirror w/ no available spare
 # Expected result: mirror w/ corelog
@@ -68,7 +68,7 @@
 repair 'activation { mirror_image_fault_policy = "replace" }' $vg/mirror
 check mirror $vg mirror
 lvs | not grep mirror_mlog
-aux cleanup $dev3 $dev4
+cleanup $dev3 $dev4
 
 # Fail the log device with a remove policy
 # Expected result: mirror w/ corelog
--- LVM2/test/t-lvconvert-repair-replace.sh	2010/04/14 13:51:58	1.1
+++ LVM2/test/t-lvconvert-repair-replace.sh	2011/01/05 00:16:20	1.2
@@ -9,43 +9,43 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
-prepare_vg 6
+aux prepare_vg 6
 
 # multiple failures, full replace
 lvcreate --mirrorlog disk -m 2 --ig -L 1 -n 3way $vg $dev1 $dev2 $dev3 $dev4:0-1
-disable_dev $dev1 $dev2
+aux disable_dev $dev1 $dev2
 echo y | lvconvert --repair $vg/3way 2>&1 | tee 3way.out
 lvs -a -o +devices | not grep unknown
 not grep "WARNING: Failed" 3way.out
 vgreduce --removemissing $vg
 check mirror $vg 3way
-enable_dev $dev1 $dev2
+aux enable_dev $dev1 $dev2
 
 vgremove -ff $vg; vgcreate -c n $vg $dev1 $dev2 $dev3 $dev4 $dev5
 
 # multiple failures, partial replace
 lvcreate --mirrorlog disk -m 2 --ig -L 1 -n 3way $vg $dev1 $dev2 $dev3 $dev4
-disable_dev $dev1 $dev2
+aux disable_dev $dev1 $dev2
 echo y | lvconvert --repair $vg/3way 2>&1 | tee 3way.out
 grep "WARNING: Failed" 3way.out
 lvs -a -o +devices | not grep unknown
 vgreduce --removemissing $vg
 check mirror $vg 3way
-enable_dev $dev1 $dev2
+aux enable_dev $dev1 $dev2
 lvchange -a n $vg/3way
 
 vgremove -ff $vg; vgcreate -c n $vg $dev1 $dev2 $dev3
 
 lvcreate --mirrorlog disk -m 1 --ig -L 1 -n 2way $vg $dev1 $dev2 $dev3
-disable_dev $dev1
+aux disable_dev $dev1
 echo y | lvconvert --repair $vg/2way 2>&1 | tee 2way.out
 grep "WARNING: Failed" 2way.out
 lvs -a -o +devices | not grep unknown
 vgreduce --removemissing $vg
 check mirror $vg 2way
-enable_dev $dev1 $dev2
+aux enable_dev $dev1 $dev2
 lvchange -a n $vg/2way
 
 vgremove -ff $vg; vgcreate -c n $vg $dev1 $dev2 $dev3 $dev4
--- LVM2/test/t-lvconvert-repair-transient.sh	2010/05/24 16:33:21	1.2
+++ LVM2/test/t-lvconvert-repair-transient.sh	2011/01/05 00:16:20	1.3
@@ -9,18 +9,18 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
-
-prepare_vg 5
+. lib/test
 
 exit 200 # this breaks upstream .33 and RHEL6 kernel :(
 
+aux prepare_vg 5
+
 # fail multiple devices
 
 lvcreate -m 3 --ig -L 1 -n 4way $vg
-disable_dev $dev2 $dev4
+aux disable_dev $dev2 $dev4
 mkfs.ext3 $DM_DEV_DIR/$vg/4way
-enable_dev $dev2 $dev4
+aux enable_dev $dev2 $dev4
 echo n | lvconvert --repair $vg/4way 2>&1 | tee 4way.out
 lvs -a -o +devices | not grep unknown
 vgreduce --removemissing $vg
--- LVM2/test/t-lvconvert-repair.sh	2010/05/24 15:32:21	1.8
+++ LVM2/test/t-lvconvert-repair.sh	2011/01/05 00:16:20	1.9
@@ -9,54 +9,54 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
 
 # fail multiple devices
 
 aux prepare_vg 5
 lvcreate -m 3 --ig -L 1 -n 4way $vg $dev1 $dev2 $dev3 $dev4 $dev5:0
-disable_dev $dev2 $dev4
+aux disable_dev $dev2 $dev4
 echo n | lvconvert --repair $vg/4way 2>&1 | tee 4way.out
 lvs -a -o +devices | not grep unknown
 vgreduce --removemissing $vg
-enable_dev $dev2 $dev4
+aux enable_dev $dev2 $dev4
 check mirror $vg 4way $dev5
 
 aux prepare_vg 5
 lvcreate -m 2 --ig -L 1 -n 3way $vg
-disable_dev $dev1 $dev2
+aux disable_dev $dev1 $dev2
 echo n | lvconvert --repair $vg/3way
 check linear $vg 3way
 lvs -a -o +devices | not grep unknown
 lvs -a -o +devices | not grep mlog
 dmsetup ls | grep $PREFIX | not grep mlog
 vgreduce --removemissing $vg
-enable_dev $dev1 $dev2
+aux enable_dev $dev1 $dev2
 check linear $vg 3way
 
 # fail just log and get it removed
 
 aux prepare_vg 5
 lvcreate -m 2 --ig -L 1 -n 3way $vg $dev1 $dev2 $dev3 $dev4:0
-disable_dev $dev4
+aux disable_dev $dev4
 echo n | lvconvert --repair $vg/3way
 check mirror $vg 3way core
 lvs -a -o +devices | not grep unknown
 lvs -a -o +devices | not grep mlog
 dmsetup ls | grep $PREFIX | not grep mlog
 vgreduce --removemissing $vg
-enable_dev $dev4
+aux enable_dev $dev4
 
 aux prepare_vg 5
 lvcreate -m 1 --ig -L 1 -n 2way $vg $dev1 $dev2 $dev3:0
-disable_dev $dev3
+aux disable_dev $dev3
 echo n | lvconvert --repair $vg/2way
 check mirror $vg 2way core
 lvs -a -o +devices | not grep unknown
 lvs -a -o +devices | not grep mlog
 vgreduce --removemissing $vg
-enable_dev $dev3
+aux enable_dev $dev3
 
 # fail single devices
 
@@ -66,24 +66,24 @@
 lvcreate -m 1 --ig -L 1 -n mirror $vg
 lvchange -a n $vg/mirror
 vgextend $vg $dev4
-disable_dev $dev1
+aux disable_dev $dev1
 lvchange --partial -a y $vg/mirror
 
 not vgreduce -v --removemissing $vg
 lvconvert -y --repair $vg/mirror
 vgreduce --removemissing $vg
 
-enable_dev $dev1
+aux enable_dev $dev1
 vgextend $vg $dev1
-disable_dev $dev2
+aux disable_dev $dev2
 lvconvert -y --repair $vg/mirror
 vgreduce --removemissing $vg
 
-enable_dev $dev2
+aux enable_dev $dev2
 vgextend $vg $dev2
-disable_dev $dev3
+aux disable_dev $dev3
 lvconvert -y --repair $vg/mirror
 vgreduce --removemissing $vg
-enable_dev $dev3
+aux enable_dev $dev3
 vgextend $vg $dev3
 lvremove -ff $vg
--- LVM2/test/t-lvconvert-twostep.sh	2010/11/25 17:15:46	1.1
+++ LVM2/test/t-lvconvert-twostep.sh	2011/01/05 00:16:20	1.2
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_vg 4
 lvcreate -m 1 --mirrorlog disk --ig -L 1 -n mirror $vg
--- LVM2/test/t-lvcreate-mirror.sh	2010/05/12 10:08:36	1.2
+++ LVM2/test/t-lvcreate-mirror.sh	2011/01/05 00:16:20	1.3
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 aux prepare_vg 5 80
 
 # 2-way mirror with corelog, 2 PVs
--- LVM2/test/t-lvcreate-operation.sh	2010/04/07 14:46:26	1.5
+++ LVM2/test/t-lvcreate-operation.sh	2011/01/05 00:16:20	1.6
@@ -11,7 +11,7 @@
 
 # 'Exercise some lvcreate diagnostics'
 
-. ./test-utils.sh
+. lib/test
 
 cleanup_lvs() {
 	lvremove -ff $vg
@@ -21,9 +21,9 @@
 	fi
 }
 
-prepare_pvs 2
+aux prepare_pvs 2
 aux pvcreate --metadatacopies 0 $dev1
-aux vgcreate -c n $vg $devs
+aux vgcreate -c n $vg $(cat DEVICES)
 
 # ---
 # Create snapshots of LVs on --metadatacopies 0 PV (bz450651)
--- LVM2/test/t-lvcreate-pvtags.sh	2010/04/07 14:46:26	1.7
+++ LVM2/test/t-lvcreate-pvtags.sh	2011/01/05 00:16:20	1.8
@@ -8,14 +8,14 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_pvs 3
 # not required, just testing
 aux pvcreate --metadatacopies 0 $dev1
 
-vgcreate -c n $vg $devs
-pvchange --addtag fast $devs
+vgcreate -c n $vg $(cat DEVICES)
+pvchange --addtag fast $(cat DEVICES)
 
 # 3 stripes with 3 PVs (selected by tag, @fast) is fine
 lvcreate -l3 -i3 $vg @fast
--- LVM2/test/t-lvcreate-small-snap.sh	2010/10/13 13:52:54	1.1
+++ LVM2/test/t-lvcreate-small-snap.sh	2011/01/05 00:16:20	1.2
@@ -9,11 +9,11 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_pvs 3
 
-vgcreate -c n -s 1k $vg $devs
+vgcreate -c n -s 1k $vg $(cat DEVICES)
 
 lvcreate -n one -l 10 $vg
 lvcreate -s -l 8 -n snapA $vg/one
--- LVM2/test/t-lvcreate-usage.sh	2010/04/13 06:25:08	1.18
+++ LVM2/test/t-lvcreate-usage.sh	2011/01/05 00:16:20	1.19
@@ -11,11 +11,11 @@
 
 # 'Exercise some lvcreate diagnostics'
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_pvs 4
 aux pvcreate --metadatacopies 0 $dev1
-vgcreate -cn $vg $devs
+vgcreate -cn $vg $(cat DEVICES)
 
 # "lvcreate rejects repeated invocation (run 2 times) (bz178216)" 
 lvcreate -n $lv -l 4 $vg 
@@ -42,7 +42,7 @@
 lvcreate -L 64m -n $lv -i2 $vg > out
 grep "^  Using default stripesize" out 
 lvdisplay $vg 
-check_lv_field_ $vg/$lv stripesize "64.00k"
+check lv_field $vg/$lv stripesize "64.00k"
 lvremove -ff $vg
 
 # 'lvcreate rejects an invalid number of stripes' 
@@ -89,16 +89,16 @@
 # lvcreate rejects invalid chunksize, accepts between 4K and 512K
 # validate origin_size
 vgremove -ff $vg
-vgcreate -cn $vg $devs
+vgcreate -cn $vg $(cat DEVICES)
 lvcreate -L 32m -n $lv1 $vg
 not lvcreate -L 8m -n $lv2 -s --chunksize 3k $vg/$lv1
 not lvcreate -L 8m -n $lv2 -s --chunksize 1024k $vg/$lv1
 lvcreate -L 8m -n $lv2 -s --chunksize 4k $vg/$lv1
-check_lv_field_ $vg/$lv2 chunk_size 4.00k
-check_lv_field_ $vg/$lv2 origin_size 32.00m
+check lv_field $vg/$lv2 chunk_size 4.00k
+check lv_field $vg/$lv2 origin_size 32.00m
 lvcreate -L 8m -n $lv3 -s --chunksize 512k $vg/$lv1
-check_lv_field_ $vg/$lv3 chunk_size 512.00k
-check_lv_field_ $vg/$lv3 origin_size 32.00m
+check lv_field $vg/$lv3 chunk_size 512.00k
+check lv_field $vg/$lv3 origin_size 32.00m
 lvremove -ff $vg
 vgchange -l 0 $vg
 
@@ -111,10 +111,10 @@
 not lvcreate -L 32m -n $lv -R 11k $vg
 not lvcreate -L 32m -n $lv -R 1k $vg
 lvcreate -L 32m -n $lv --regionsize 128m  -m 1 $vg
-check_lv_field_ $vg/$lv regionsize "32.00m"
+check lv_field $vg/$lv regionsize "32.00m"
 lvremove -ff $vg
 lvcreate -L 32m -n $lv --regionsize 4m -m 1 $vg
-check_lv_field_ $vg/$lv regionsize "4.00m"
+check lv_field $vg/$lv regionsize "4.00m"
 lvremove -ff $vg
 
 # snapshot with virtual origin works
@@ -127,15 +127,15 @@
 
 # readahead default (auto), none, #, auto
 lvcreate -L 32m -n $lv $vg
-check_lv_field_ $vg/$lv lv_read_ahead "auto"
+check lv_field $vg/$lv lv_read_ahead "auto"
 lvremove -ff $vg
 lvcreate -L 32m -n $lv --readahead none $vg
-check_lv_field_ $vg/$lv lv_read_ahead "0"
+check lv_field $vg/$lv lv_read_ahead "0"
 lvremove -ff $vg
 lvcreate -L 32m -n $lv --readahead 8k $vg
-check_lv_field_ $vg/$lv lv_read_ahead "8.00k"
+check lv_field $vg/$lv lv_read_ahead "8.00k"
 lvremove -ff $vg
 lvcreate -L 32m -n $lv --readahead auto $vg
-check_lv_field_ $vg/$lv lv_read_ahead "auto"
+check lv_field $vg/$lv lv_read_ahead "auto"
 lvremove -ff $vg
 
--- LVM2/test/t-lvextend-percent-extents.sh	2010/02/17 15:41:28	1.9
+++ LVM2/test/t-lvextend-percent-extents.sh	2011/01/05 00:16:20	1.10
@@ -11,7 +11,7 @@
 
 # 'Check extents percentage arguments'
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_vg 2 128
 
@@ -28,7 +28,7 @@
 # 'lvextend accepts no size or extents but one PV - bz154691'
 lvextend $vg/$lv $dev1 >out
 grep "^  Logical volume $lv successfully resized\$" out
-check_pv_field_ $dev1 pv_free "0"
+check pv_field $dev1 pv_free "0"
 
 lvremove -f $vg/$lv 
 
@@ -45,8 +45,8 @@
 # 'lvextend accepts no size but extents 100%PVS and two PVs - bz154691'
 lvextend -l +100%PVS $vg/$lv $dev1 $dev2 >out
 grep "^  Logical volume $lv successfully resized\$" out 
-check_pv_field_ $dev1 pv_free "0" 
-check_pv_field_ $dev2 pv_free "0"
+check pv_field $dev1 pv_free "0" 
+check pv_field $dev2 pv_free "0"
 
 # Exercise the range overlap code.  Allocate every 2 extents.
 #
@@ -72,13 +72,13 @@
 create_pvs=`for i in $(seq 0 4 20); do echo -n "\$dev1:$i-$(($i + 1)) "; done` 
 lvremove -f $vg/$lv
 lvcreate -l 12 -n $lv $vg $create_pvs
-check_lv_field_ $vg/$lv lv_size "48.00m"
+check lv_field $vg/$lv lv_size "48.00m"
 
 # 'lvextend with partially allocated PVs and extents 100%PVS with PE ranges' 
 extend_pvs=`for i in $(seq 0 6 18); do echo -n "\$dev1:$i-$(($i + 2)) "; done` 
 lvextend -l +100%PVS $vg/$lv $extend_pvs >out
 grep "^  Logical volume $lv successfully resized\$" out 
-check_lv_field_ $vg/$lv lv_size "72.00m"
+check lv_field $vg/$lv lv_size "72.00m"
 
 # Simple seg_count validation; initially create the LV with half the # of
 # extents (should be 1 lv segment), extend it (should go to 2 segments),
@@ -90,12 +90,12 @@
 lvcreate -l $pe1 -n $lv $vg
 pesize=$(lvs -ovg_extent_size --units b --nosuffix --noheadings $vg/$lv)
 segsize=$(( $pe1 * $pesize / 1024 / 1024 ))m
-check_lv_field_ $vg/$lv seg_count 1
-check_lv_field_ $vg/$lv seg_start 0
-check_lv_field_ $vg/$lv seg_start_pe 0
-#check_lv_field_ $vg/$lv seg_size $segsize
+check lv_field $vg/$lv seg_count 1
+check lv_field $vg/$lv seg_start 0
+check lv_field $vg/$lv seg_start_pe 0
+#check lv_field $vg/$lv seg_size $segsize
 lvextend -l +$(( $pe_count * 1 )) $vg/$lv
-check_lv_field_ $vg/$lv seg_count 2
+check lv_field $vg/$lv seg_count 2
 lvreduce -f -l -$(( $pe_count * 1 )) $vg/$lv
-check_lv_field_ $vg/$lv seg_count 1
+check lv_field $vg/$lv seg_count 1
 
--- LVM2/test/t-lvextend-snapshot-dmeventd.sh	2010/10/15 16:28:15	1.1
+++ LVM2/test/t-lvextend-snapshot-dmeventd.sh	2011/01/05 00:16:20	1.2
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
 extend() {
 	lvextend --use-policies --config "activation { snapshot_extend_threshold = $1 }" $vg/snap
--- LVM2/test/t-lvextend-snapshot-policy.sh	2010/10/15 16:28:15	1.1
+++ LVM2/test/t-lvextend-snapshot-policy.sh	2011/01/05 00:16:20	1.2
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
 extend() {
 	lvextend --use-policies --config "activation { snapshot_extend_threshold = $1 }" $vg/snap
--- LVM2/test/t-lvm-init.sh	2009/07/08 18:14:47	1.1
+++ LVM2/test/t-lvm-init.sh	2011/01/05 00:16:20	1.2
@@ -12,7 +12,7 @@
 # tests lvm initialization, and especially negative tests of error paths
 #
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_devs 5
 
--- LVM2/test/t-lvmcache-exercise.sh	2008/09/29 16:02:49	1.2
+++ LVM2/test/t-lvmcache-exercise.sh	2011/01/05 00:16:20	1.3
@@ -8,16 +8,16 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_pvs 5
 
 vgcreate $vg1 $dev1
 vgcreate $vg2 $dev3
 
-disable_dev $dev1
+aux disable_dev $dev1
 pvscan
 vgcreate $vg1 $dev2
-enable_dev $dev1
+aux enable_dev $dev1
 pvs
 pvs
--- LVM2/test/t-lvresize-mirror.sh	2010/04/12 19:16:24	1.1
+++ LVM2/test/t-lvresize-mirror.sh	2011/01/05 00:16:20	1.2
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 aux prepare_vg 5 80
 
 # extend 2-way mirror
--- LVM2/test/t-lvresize-usage.sh	2008/09/29 16:02:49	1.3
+++ LVM2/test/t-lvresize-usage.sh	2011/01/05 00:16:20	1.4
@@ -8,7 +8,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_vg 2
 
--- LVM2/test/t-mdata-strings.sh	2009/04/03 14:23:17	1.5
+++ LVM2/test/t-mdata-strings.sh	2011/01/05 00:16:20	1.6
@@ -11,7 +11,7 @@
 
 # 'Test for proper escaping of strings in metadata (bz431474)'
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_devs 1
 
--- LVM2/test/t-metadata-balance.sh	2010/07/07 19:14:58	1.4
+++ LVM2/test/t-metadata-balance.sh	2011/01/05 00:16:20	1.5
@@ -8,7 +8,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_devs 6
 
@@ -21,22 +21,22 @@
 		vgcreate -c n "$vg" $dev1 $dev2 $dev3
 	fi
 	pvchange --metadataignore y $dev1
-	check_pv_field_ $dev1 pv_mda_count $mdacp
-	check_pv_field_ $dev1 pv_mda_used_count 0
-	check_pv_field_ $dev2 pv_mda_count $mdacp
-	check_pv_field_ $dev2 pv_mda_used_count $mdacp
+	check pv_field $dev1 pv_mda_count $mdacp
+	check pv_field $dev1 pv_mda_used_count 0
+	check pv_field $dev2 pv_mda_count $mdacp
+	check pv_field $dev2 pv_mda_used_count $mdacp
 	if [ $pv_in_vg = 1 ]; then
-		check_vg_field_ $vg vg_mda_count $(($mdacp * 2))
-		check_vg_field_ $vg vg_mda_used_count $mdacp
-		check_vg_field_ $vg vg_mda_copies unmanaged
+		check vg_field $vg vg_mda_count $(($mdacp * 2))
+		check vg_field $vg vg_mda_used_count $mdacp
+		check vg_field $vg vg_mda_copies unmanaged
 	fi
 	pvchange --metadataignore n $dev1
-	check_pv_field_ $dev1 pv_mda_count $mdacp
-	check_pv_field_ $dev1 pv_mda_used_count $mdacp
+	check pv_field $dev1 pv_mda_count $mdacp
+	check pv_field $dev1 pv_mda_used_count $mdacp
 	if [ $pv_in_vg = 1 ]; then
-		check_vg_field_ $vg vg_mda_count $(($mdacp * 2))
-		check_vg_field_ $vg vg_mda_used_count $(($mdacp * 2))
-		check_vg_field_ $vg vg_mda_copies unmanaged
+		check vg_field $vg vg_mda_count $(($mdacp * 2))
+		check vg_field $vg vg_mda_used_count $(($mdacp * 2))
+		check vg_field $vg vg_mda_copies unmanaged
 		vgremove -f $vg
 	fi
 done
@@ -44,7 +44,7 @@
 
 # Check if a PV has unignored (used) mdas, and if so, ignore
 pvignore_ () {
-	pv_mda_used_count=$(get_pv_field "$1" pv_mda_used_count)
+	pv_mda_used_count=$(get pv_field "$1" pv_mda_used_count)
 	if [ $pv_mda_used_count -ne 0 ]; then
 	    pvchange --metadataignore y $1
 	fi
@@ -52,8 +52,8 @@
 
 # Check if a PV has ignored mdas, and if so, unignore (make used)
 pvunignore_ () {
-	pv_mda_count=$(get_pv_field "$1" pv_mda_count)
-	pv_mda_used_count=$(get_pv_field "$1" pv_mda_used_count)
+	pv_mda_count=$(get pv_field "$1" pv_mda_count)
+	pv_mda_used_count=$(get pv_field "$1" pv_mda_used_count)
 	if [ $pv_mda_count -gt $pv_mda_used_count ]; then
 	    pvchange --metadataignore n $1
 	fi
@@ -62,51 +62,51 @@
 echo Test of vgmetadatacopies with vgcreate and vgchange
 for mdacp in 1 2; do
 	pvcreate --metadatacopies $mdacp $dev1 $dev2 $dev4 $dev5
-	check_pv_field_ $dev1 pv_mda_used_count $mdacp
-	check_pv_field_ $dev2 pv_mda_used_count $mdacp
-	check_pv_field_ $dev4 pv_mda_used_count $mdacp
-	check_pv_field_ $dev5 pv_mda_used_count $mdacp
+	check pv_field $dev1 pv_mda_used_count $mdacp
+	check pv_field $dev2 pv_mda_used_count $mdacp
+	check pv_field $dev4 pv_mda_used_count $mdacp
+	check pv_field $dev5 pv_mda_used_count $mdacp
 	pvcreate --metadatacopies 0 $dev3
 	vgcreate -c n "$vg" $dev1 $dev2 $dev3
-	check_vg_field_ $vg vg_mda_copies unmanaged
+	check vg_field $vg vg_mda_copies unmanaged
 	echo ensure both --vgmetadatacopies and --metadatacopies accepted
 	vgchange --metadatacopies $(($mdacp * 1)) $vg
 	echo --vgmetadatacopies is persistent on disk
 	echo --vgmetadatacopies affects underlying pv mda ignore
-	check_vg_field_ $vg vg_mda_copies $(($mdacp * 1))
-	check_vg_field_ $vg vg_mda_used_count $(($mdacp * 1))
+	check vg_field $vg vg_mda_copies $(($mdacp * 1))
+	check vg_field $vg vg_mda_used_count $(($mdacp * 1))
 	vgchange --vgmetadatacopies $(($mdacp * 2)) $vg
-	check_vg_field_ $vg vg_mda_copies $(($mdacp * 2))
-	check_vg_field_ $vg vg_mda_used_count $(($mdacp * 2))
+	check vg_field $vg vg_mda_copies $(($mdacp * 2))
+	check vg_field $vg vg_mda_used_count $(($mdacp * 2))
 	echo allow setting metadatacopies larger than number of PVs
 	vgchange --vgmetadatacopies $(($mdacp * 5)) $vg
-	check_vg_field_ $vg vg_mda_copies $(($mdacp * 5))
-	check_vg_field_ $vg vg_mda_used_count $(($mdacp * 2))
+	check vg_field $vg vg_mda_copies $(($mdacp * 5))
+	check vg_field $vg vg_mda_used_count $(($mdacp * 2))
 	echo setting to 0 disables automatic balancing
 	vgchange --vgmetadatacopies unmanaged $vg
-	check_vg_field_ $vg vg_mda_copies unmanaged
+	check vg_field $vg vg_mda_copies unmanaged
 	vgremove -f $vg
 	echo vgcreate succeeds even when creating a VG w/all ignored mdas
 	pvchange --metadataignore y $dev1 $dev2
-	check_pv_field_ $dev1 pv_mda_count $mdacp
-	check_pv_field_ $dev2 pv_mda_used_count 0
+	check pv_field $dev1 pv_mda_count $mdacp
+	check pv_field $dev2 pv_mda_used_count 0
 	vgcreate -c n "$vg" $dev1 $dev2
-	check_vg_field_ $vg vg_mda_copies unmanaged
+	check vg_field $vg vg_mda_copies unmanaged
 	vgremove -f $vg
 	echo vgcreate succeeds with a specific number of metadata copies
 	vgcreate -c n --vgmetadatacopies $(($mdacp * 2)) "$vg" $dev1 $dev2
-	check_vg_field_ $vg vg_mda_copies $(($mdacp * 2))
+	check vg_field $vg vg_mda_copies $(($mdacp * 2))
 	vgremove -f $vg
 	vgcreate -c n --vgmetadatacopies $(($mdacp * 1)) "$vg" $dev1 $dev2
-	check_vg_field_ $vg vg_mda_copies $(($mdacp * 1))
+	check vg_field $vg vg_mda_copies $(($mdacp * 1))
 	vgremove -f $vg
 	echo vgcreate succeeds with a larger value than total metadatacopies
 	vgcreate -c n --vgmetadatacopies $(($mdacp * 5)) "$vg" $dev1 $dev2
-	check_vg_field_ $vg vg_mda_copies $(($mdacp * 5))
+	check vg_field $vg vg_mda_copies $(($mdacp * 5))
 	vgremove -f $vg
 	echo vgcreate succeeds with --vgmetadatacopies unmanaged
 	vgcreate -c n --vgmetadatacopies unmanaged "$vg" $dev1 $dev2
-	check_vg_field_ $vg vg_mda_copies unmanaged
+	check vg_field $vg vg_mda_copies unmanaged
 	vgremove -f $vg
 	pvunignore_ $dev1
 	pvunignore_ $dev2
@@ -114,24 +114,24 @@
 	pvunignore_ $dev5
 	echo vgcreate succeds with small value of --metadatacopies, ignores mdas
 	vgcreate -c n --vgmetadatacopies 1 "$vg" $dev1 $dev2 $dev4 $dev5
-	check_vg_field_ $vg vg_mda_copies 1
-	check_vg_field_ $vg vg_mda_count $(($mdacp * 4))
-	check_vg_field_ $vg vg_mda_used_count 1
+	check vg_field $vg vg_mda_copies 1
+	check vg_field $vg vg_mda_count $(($mdacp * 4))
+	check vg_field $vg vg_mda_used_count 1
 	echo Setting a larger value should trigger non-ignore of mdas
 	vgchange --metadatacopies 3 $vg
-	check_vg_field_ $vg vg_mda_copies 3
-	check_vg_field_ $vg vg_mda_used_count 3
+	check vg_field $vg vg_mda_copies 3
+	check vg_field $vg vg_mda_used_count 3
 	echo Setting all should trigger unignore of all mdas
 	vgchange --vgmetadatacopies all $vg
-	check_vg_field_ $vg vg_mda_count $(($mdacp * 4))
-	check_vg_field_ $vg vg_mda_copies unmanaged
-	check_vg_field_ $vg vg_mda_used_count $(($mdacp * 4))
+	check vg_field $vg vg_mda_count $(($mdacp * 4))
+	check vg_field $vg vg_mda_copies unmanaged
+	check vg_field $vg vg_mda_used_count $(($mdacp * 4))
 	echo --vgmetadatacopies 0 should be unmanaged for vgchange and vgcreate
 	vgchange --vgmetadatacopies 0 $vg
-	check_vg_field_ $vg vg_mda_copies unmanaged
+	check vg_field $vg vg_mda_copies unmanaged
 	vgremove -f $vg
 	vgcreate -c n --vgmetadatacopies 0 "$vg" $dev1 $dev2 $dev4 $dev5
-	check_vg_field_ $vg vg_mda_copies unmanaged
+	check vg_field $vg vg_mda_copies unmanaged
 	vgremove -f $vg
 done
 
@@ -141,43 +141,43 @@
 	pvcreate --metadatacopies 0 $dev3
 	echo Set a large value of vgmetadatacopies
 	vgcreate -c n --vgmetadatacopies $(($mdacp * 5)) "$vg" $dev1 $dev2 $dev3
-	check_vg_field_ $vg vg_mda_copies $(($mdacp * 5))
+	check vg_field $vg vg_mda_copies $(($mdacp * 5))
 	echo Ignore mdas on devices to be used for vgextend
 	echo Large value of vgetadatacopies should automatically un-ignore mdas
 	pvchange --metadataignore y $dev4 $dev5
-	check_pv_field_ $dev4 pv_mda_used_count 0
+	check pv_field $dev4 pv_mda_used_count 0
 	vgextend $vg $dev4 $dev5
-	check_pv_field_ $dev4 pv_mda_used_count $mdacp
-	check_pv_field_ $dev5 pv_mda_used_count $mdacp
+	check pv_field $dev4 pv_mda_used_count $mdacp
+	check pv_field $dev5 pv_mda_used_count $mdacp
 	vgremove -f $vg
 	echo Set a small value of vgmetadatacopies
 	vgcreate -c n --vgmetadatacopies $(($mdacp * 1)) "$vg" $dev1 $dev2 $dev3
-	check_vg_field_ $vg vg_mda_copies $(($mdacp * 1))
+	check vg_field $vg vg_mda_copies $(($mdacp * 1))
 	echo Ignore mdas on devices to be used for vgextend
 	echo Small value of vgetadatacopies should leave mdas as ignored
 	pvchange --metadataignore y $dev4 $dev5
-	check_pv_field_ $dev4 pv_mda_used_count 0
+	check pv_field $dev4 pv_mda_used_count 0
 	vgextend $vg $dev4 $dev5
-	check_pv_field_ $dev4 pv_mda_used_count 0
-	check_pv_field_ $dev5 pv_mda_used_count 0
+	check pv_field $dev4 pv_mda_used_count 0
+	check pv_field $dev5 pv_mda_used_count 0
 	echo vgreduce of ignored pv w/mda should not trigger any change to ignore bits
 	vgreduce $vg $dev4
-	check_pv_field_ $dev4 pv_mda_used_count 0
-	check_pv_field_ $dev5 pv_mda_used_count 0
+	check pv_field $dev4 pv_mda_used_count 0
+	check pv_field $dev5 pv_mda_used_count 0
 	echo vgreduce of un-ignored pv w/mda should trigger un-ignore on an mda
 	vgreduce $vg $dev1 $dev2 $dev3
-	check_pv_field_ $dev5 pv_mda_used_count $mdacp
-	check_vg_field_ $vg vg_mda_copies $(($mdacp * 1))
+	check pv_field $dev5 pv_mda_used_count $mdacp
+	check vg_field $vg vg_mda_copies $(($mdacp * 1))
 	pvunignore_ $dev1
 	pvunignore_ $dev2
 	echo setting vgmetadatacopies to unmanaged should allow vgextend to add w/out balancing
 	vgchange --vgmetadatacopies unmanaged $vg
 	vgextend $vg $dev1 $dev2
-	check_vg_field_ $vg vg_mda_copies unmanaged
-	check_vg_field_ $vg vg_mda_count $(($mdacp * 3))
-	check_vg_field_ $vg vg_mda_used_count $((mdacp * 3))
-	check_pv_field_ $dev1 pv_mda_used_count $mdacp
-	check_pv_field_ $dev2 pv_mda_used_count $mdacp
+	check vg_field $vg vg_mda_copies unmanaged
+	check vg_field $vg vg_mda_count $(($mdacp * 3))
+	check vg_field $vg vg_mda_used_count $((mdacp * 3))
+	check pv_field $dev1 pv_mda_used_count $mdacp
+	check pv_field $dev2 pv_mda_used_count $mdacp
 	vgremove -f $vg
 done
 
@@ -187,16 +187,16 @@
 	vgcreate -c n --vgmetadatacopies 2 $vg1 $dev1 $dev2 $dev3
 	vgcreate -c n --vgmetadatacopies $(($mdacp * 1)) $vg2 $dev4 $dev5
 	echo vgsplit/vgmerge preserves value of metadata copies
-	check_vg_field_ $vg1 vg_mda_copies 2
-	check_vg_field_ $vg2 vg_mda_copies $(($mdacp * 1))
+	check vg_field $vg1 vg_mda_copies 2
+	check vg_field $vg2 vg_mda_copies $(($mdacp * 1))
 	vgsplit $vg1 $vg2 $dev1
-	check_vg_field_ $vg2 vg_mda_copies $(($mdacp * 1))
+	check vg_field $vg2 vg_mda_copies $(($mdacp * 1))
 	vgmerge $vg1 $vg2
-	check_vg_field_ $vg1 vg_mda_copies 2
-	check_vg_field_ $vg1 vg_mda_count $(($mdacp * 5))
+	check vg_field $vg1 vg_mda_copies 2
+	check vg_field $vg1 vg_mda_count $(($mdacp * 5))
 	echo vgsplit into new vg sets proper value of vgmetadatacopies
 	vgsplit --vgmetadatacopies $(($mdacp * 2)) $vg1 $vg2 $dev1 $dev2
-	check_vg_field_ $vg2 vg_mda_copies $(($mdacp * 2))
+	check vg_field $vg2 vg_mda_copies $(($mdacp * 2))
 	echo vgchange fails if given both vgmetadatacopies and metadatacopies
 	not vgchange --vgmetadatacopies 5 --metadatacopies 7 $vg2
 	vgremove -f $vg1
@@ -207,26 +207,26 @@
 for mdacp in 1 2; do
 	pvcreate --metadatacopies $mdacp $dev1 $dev2 $dev3 $dev4 $dev5
 	vgcreate -c n --vgmetadatacopies $(($mdacp * 1)) $vg1 $dev1 $dev2
-	check_vg_field_ $vg1 vg_mda_copies $(($mdacp * 1))
-	check_vg_field_ $vg1 vg_mda_used_count $(($mdacp * 1))
+	check vg_field $vg1 vg_mda_copies $(($mdacp * 1))
+	check vg_field $vg1 vg_mda_used_count $(($mdacp * 1))
 	pvignore_ $dev3
 	echo Ensure vgextend of PVs with ignored MDAs does not add to vg_mda_used_count
 	vgextend $vg1 $dev3
-	check_vg_field_ $vg1 vg_mda_used_count $(($mdacp * 1))
+	check vg_field $vg1 vg_mda_used_count $(($mdacp * 1))
 	echo Using pvchange to unignore should update vg_mda_used_count
 	pvchange -f --metadataignore n $dev3
-	check_pv_field_ $dev3 pv_mda_used_count $mdacp
-	check_vg_field_ $vg1 vg_mda_used_count $(($mdacp * 2))
+	check pv_field $dev3 pv_mda_used_count $mdacp
+	check vg_field $vg1 vg_mda_used_count $(($mdacp * 2))
 	echo Set unmanaged on the vg should keep ignore bits the same during vgextend
 	vgchange --vgmetadatacopies unmanaged $vg1
-	check_vg_field_ $vg1 vg_mda_used_count $(($mdacp * 2))
+	check vg_field $vg1 vg_mda_used_count $(($mdacp * 2))
 	pvunignore_ $dev4
 	vgextend $vg1 $dev4
-	check_pv_field_ $dev4 pv_mda_used_count $mdacp
-	check_vg_field_ $vg1 vg_mda_used_count $(($mdacp * 3))
+	check pv_field $dev4 pv_mda_used_count $mdacp
+	check vg_field $vg1 vg_mda_used_count $(($mdacp * 3))
 	echo Using pvchange to ignore should update vg_mda_used_count
 	pvchange -f --metadataignore y $dev4
-	check_pv_field_ $dev4 pv_mda_used_count 0
-	check_vg_field_ $vg1 vg_mda_used_count $(($mdacp * 2))
+	check pv_field $dev4 pv_mda_used_count 0
+	check vg_field $vg1 vg_mda_used_count $(($mdacp * 2))
 	vgremove -f $vg1
 done
--- LVM2/test/t-metadata.sh	2010/10/26 12:52:25	1.6
+++ LVM2/test/t-metadata.sh	2011/01/05 00:16:20	1.7
@@ -8,7 +8,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_devs 5
 
@@ -18,7 +18,7 @@
 pvcreate $dev4
 pvcreate --metadatacopies 0 $dev5
 
-vgcreate -c n "$vg" $devs
+vgcreate -c n "$vg" $(cat DEVICES)
 lvcreate -n $lv -l 1 -i5 -I256 $vg
 
 pvchange -x n $dev1
@@ -30,9 +30,9 @@
 
 # check that PVs without metadata don't cause too many full device rescans (bz452606)
 for mdacp in 1 0; do
-	pvcreate --metadatacopies $mdacp $devs
+	pvcreate --metadatacopies $mdacp $(cat DEVICES)
 	pvcreate $dev1
-	vgcreate -c n $vg $devs
+	vgcreate -c n $vg $(cat DEVICES)
 	lvcreate -n $lv1 -l 2 -i5 -I256 $vg
 	lvcreate -n $lv2 -m2 -l 2  $vg
 	#lvchange -an $vg
@@ -55,9 +55,9 @@
 
 # verify pe_start of all M1 PVs
 pv_align="128.00k"
-check_pv_field_ $dev1 pe_start $pv_align
-check_pv_field_ $dev2 pe_start $pv_align
-check_pv_field_ $dev3 pe_start $pv_align
+check pv_field $dev1 pe_start $pv_align
+check pv_field $dev2 pe_start $pv_align
+check pv_field $dev3 pe_start $pv_align
 
 pvs --units k -o name,pe_start,vg_mda_size,vg_name
 
@@ -65,9 +65,9 @@
 vgconvert -M2 $vg
 
 # verify pe_start of all M2 PVs
-check_pv_field_ $dev1 pe_start $pv_align
-check_pv_field_ $dev2 pe_start $pv_align
-check_pv_field_ $dev3 pe_start $pv_align
+check pv_field $dev1 pe_start $pv_align
+check pv_field $dev2 pe_start $pv_align
+check pv_field $dev3 pe_start $pv_align
 
 pvs --units k -o name,pe_start,vg_mda_size,vg_name
 
@@ -77,4 +77,4 @@
 vgcfgrestore -f $TESTDIR/bak-$vg $vg
 
 # verify pe_start of $dev3
-check_pv_field_ $dev3 pe_start $pv_align
+check pv_field $dev3 pe_start $pv_align
--- LVM2/test/t-mirror-names.sh	2010/10/20 15:35:00	1.7
+++ LVM2/test/t-mirror-names.sh	2011/01/05 00:16:20	1.8
@@ -12,7 +12,7 @@
 
 test_description="check namings of mirrored LV"
 
-. ./test-utils.sh
+. lib/test
 
 # ---------------------------------------------------------------------
 # Utilities
--- LVM2/test/t-mirror-vgreduce-removemissing.sh	2010/04/07 16:00:19	1.9
+++ LVM2/test/t-mirror-vgreduce-removemissing.sh	2011/01/05 00:16:20	1.10
@@ -11,7 +11,7 @@
 
 test_description="ensure that 'vgreduce --removemissing' works on mirrored LV"
 
-. ./test-utils.sh
+. lib/test
 
 lv_is_on_ ()
 {
@@ -86,7 +86,7 @@
 # ---------------------------------------------------------------------
 # Initialize PVs and VGs
 
-prepare_vg 5
+aux prepare_vg 5
 
 # ---------------------------------------------------------------------
 # Common environment setup/cleanup for each sub testcases
@@ -113,7 +113,7 @@
 
 recover_vg_()
 {
-	enable_dev $* 
+	aux enable_dev $* 
 	pvcreate -ff $* 
 	vgextend $vg $* 
 	check_and_cleanup_lvs_
@@ -130,9 +130,9 @@
 prepare_lvs_
 lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
 lvchange -an $vg/$lv1
-aux mimages_are_on_ $lv1 $dev1 $dev2
+mimages_are_on_ $lv1 $dev1 $dev2
 mirrorlog_is_on_ $lv1 $dev3
-disable_dev $dev2
+aux disable_dev $dev2
 vgreduce --removemissing --force $vg
 lv_is_linear_ $lv1
 lv_is_on_ $lv1 $dev1
@@ -151,9 +151,9 @@
 
 	lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev3 $dev4:0
 	lvchange -an $vg/$lv1
-	aux mimages_are_on_ $lv1 $dev1 $dev2 $dev3
+	mimages_are_on_ $lv1 $dev1 $dev2 $dev3
 	mirrorlog_is_on_ $lv1 $dev4
-	eval disable_dev \$dev$index
+	eval aux disable_dev \$dev$index
 	vgreduce --removemissing --force $vg
 	lvs -a -o+devices $vg
 	mimages_are_on_ $lv1 $(rest_pvs_ $index 3)
@@ -181,10 +181,10 @@
 	mimages_are_on_ $lv1 $dev1 $dev2 $dev3
 	mirrorlog_is_on_ $lv1 $dev4
 	rest_pvs_ $index 3
-	disable_dev $(rest_pvs_ $index 3)
+	aux disable_dev $(rest_pvs_ $index 3)
 	vgreduce --force --removemissing $vg
 	lvs -a -o+devices $vg
-	aux lv_is_linear_ $lv1
+	lv_is_linear_ $lv1
 	eval lv_is_on_ $lv1 \$dev$n
 }
 
@@ -209,7 +209,7 @@
 	lvconvert -m+1 $vg/$lv1 $dev4 
 	mimages_are_on_ $lv1 $dev1 $dev2 $dev3 $dev4 
 	mirrorlog_is_on_ $lv1 $dev5 
-	eval disable_dev \$dev$n 
+	eval aux disable_dev \$dev$n 
 	vgreduce --removemissing --force $vg 
 	lvs -a -o+devices $vg 
 	mimages_are_on_ $lv1 $(rest_pvs_ $index 4) 
@@ -237,7 +237,7 @@
 	lvconvert -m+1 $vg/$lv1 $dev4 
 	mimages_are_on_ $lv1 $dev1 $dev2 $dev3 $dev4 
 	mirrorlog_is_on_ $lv1 $dev5 
-	disable_dev $(rest_pvs_ $index 4) 
+	aux disable_dev $(rest_pvs_ $index 4) 
 	vgreduce --removemissing --force $vg 
 	lvs -a -o+devices $vg 
 	eval local dev=\$dev$n
@@ -266,7 +266,7 @@
 	lvconvert -m+2 $vg/$lv1 $dev3 $dev4 
 	mimages_are_on_ $lv1 $dev1 $dev2 $dev3 $dev4 
 	mirrorlog_is_on_ $lv1 $dev5 
-	eval disable_dev \$dev$n 
+	eval aux disable_dev \$dev$n 
 	vgreduce --removemissing --force $vg 
 	lvs -a -o+devices $vg 
 	mimages_are_on_ $lv1 $(rest_pvs_ $index 4) 
@@ -294,7 +294,7 @@
 	lvconvert -m+2 $vg/$lv1 $dev3 $dev4 
 	mimages_are_on_ $lv1 $dev1 $dev2 $dev3 $dev4 
 	mirrorlog_is_on_ $lv1 $dev5 
-	disable_dev $(rest_pvs_ $index 4) 
+	aux disable_dev $(rest_pvs_ $index 4) 
 	vgreduce --removemissing --force $vg 
 	lvs -a -o+devices $vg 
 	eval local dev=\$dev$n
@@ -318,7 +318,7 @@
 lvchange -an $vg/$lv1 
 mimages_are_on_ $lv1 $dev1 $dev2 
 mirrorlog_is_on_ $lv1 $dev5 
-disable_dev $dev5 
+aux disable_dev $dev5 
 vgreduce --removemissing --force $vg 
 mimages_are_on_ $lv1 $dev1 $dev2 
 not mirrorlog_is_on_ $lv1 $dev5
@@ -331,7 +331,7 @@
 lvconvert -m+1 $vg/$lv1 $dev3 
 mimages_are_on_ $lv1 $dev1 $dev2 $dev3 
 mirrorlog_is_on_ $lv1 $dev5 
-disable_dev $dev5 
+aux disable_dev $dev5 
 vgreduce --removemissing --force $vg 
 mimages_are_on_ $lv1 $dev1 $dev2 $dev3 
 not mirrorlog_is_on_ $lv1 $dev5
@@ -346,7 +346,7 @@
 lvchange -an $vg/$lv1 
 mimages_are_on_ $lv1 $dev1 $dev2 
 mirrorlog_is_on_ $lv1 $dev5 
-disable_dev $dev1 $dev2 
+aux disable_dev $dev1 $dev2 
 vgreduce --removemissing --force $vg 
 not lvs $vg/$lv1
 recover_vg_ $dev1 $dev2
@@ -358,7 +358,7 @@
 lvconvert -m+1 $vg/$lv1 $dev3 
 mimages_are_on_ $lv1 $dev1 $dev2 $dev3 
 mirrorlog_is_on_ $lv1 $dev5 
-disable_dev $dev1 $dev2 $dev3 
+aux disable_dev $dev1 $dev2 $dev3 
 vgreduce --removemissing --force $vg 
 not lvs $vg/$lv1
 recover_vg_ $dev1 $dev2 $dev3
@@ -376,7 +376,7 @@
 mimages_are_on_ $lv2 $dev3 $dev4 
 mirrorlog_is_on_ $lv1 $dev5 
 mirrorlog_is_on_ $lv2 $dev5 
-disable_dev $dev2 
+aux disable_dev $dev2 
 vgreduce --removemissing --force $vg 
 mimages_are_on_ $lv2 $dev3 $dev4 
 mirrorlog_is_on_ $lv2 $dev5 
@@ -394,8 +394,8 @@
 mimages_are_on_ $lv2 $dev3 $dev4 
 mirrorlog_is_on_ $lv1 $dev5 
 mirrorlog_is_on_ $lv2 $dev5 
-disable_dev $dev2 
-disable_dev $dev4 
+aux disable_dev $dev2 
+aux disable_dev $dev4 
 vgreduce --removemissing --force $vg 
 lv_is_linear_ $lv1 
 lv_is_on_ $lv1 $dev1 
--- LVM2/test/t-nomda-missing.sh	2010/07/28 12:20:41	1.3
+++ LVM2/test/t-nomda-missing.sh	2011/01/05 00:16:20	1.4
@@ -10,9 +10,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
-prepare_devs 4
+aux prepare_devs 4
 pvcreate $dev1 $dev2
 pvcreate --metadatacopies 0 $dev3 $dev4
 vgcreate -c n $vg $dev1 $dev2 $dev3 $dev4
@@ -28,7 +28,7 @@
 lvcreate -l1 -m1 -n mirror123 $vg $dev1 $dev2 $dev3
 
 vgchange -a n $vg
-disable_dev $dev1
+aux disable_dev $dev1
 not vgchange -a y $vg
 not vgck $vg
 
@@ -41,8 +41,8 @@
 check inactive $vg mirror123
 
 vgchange -a n $vg
-enable_dev $dev1
-disable_dev $dev2
+aux enable_dev $dev1
+aux disable_dev $dev2
 not vgchange -a y $vg
 not vgck $vg
 
@@ -55,8 +55,8 @@
 check inactive $vg mirror123
 
 vgchange -a n $vg
-enable_dev $dev2
-disable_dev $dev3
+aux enable_dev $dev2
+aux disable_dev $dev3
 not vgchange -a y $vg
 not vgck $vg
 
@@ -69,8 +69,8 @@
 check active $vg mirror12
 
 vgchange -a n $vg
-enable_dev $dev3
-disable_dev $dev4
+aux enable_dev $dev3
+aux disable_dev $dev4
 vgchange -a y $vg
 not vgck $vg
 
--- LVM2/test/t-pool-labels.sh	2008/11/10 13:44:01	1.3
+++ LVM2/test/t-pool-labels.sh	2011/01/05 00:16:20	1.4
@@ -8,7 +8,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
 # create the old GFS pool labeled linear devices
 create_pool_label_()
@@ -32,7 +32,7 @@
 
 # check that vgdisplay and pvcreate -ff works with the pool device
 vgdisplay --config 'global { locking_type = 0 }'
-disable_dev "$dev2"
+aux disable_dev "$dev2"
 # FIXME! since pool1 cannot be opened, vgdisplay gives error... should we say
 # "not" there instead, checking that it indeed does fail?
 vgdisplay --config 'global { locking_type = 0 }' || true
--- LVM2/test/t-pv-range-overflow.sh	2008/10/06 16:47:07	1.4
+++ LVM2/test/t-pv-range-overflow.sh	2011/01/05 00:16:20	1.5
@@ -11,7 +11,7 @@
 
 # 'Ensure that pvmove diagnoses PE-range values 2^32 and larger.'
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_vg 2
 
--- LVM2/test/t-pvchange-usage.sh	2010/08/02 13:20:50	1.5
+++ LVM2/test/t-pvchange-usage.sh	2011/01/05 00:16:20	1.6
@@ -11,7 +11,7 @@
 
 # 'Test pvchange option values'
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_devs 4
 
@@ -24,15 +24,15 @@
 
 # "pvchange adds/dels tag to pvs with metadatacopies = $mda " 
 	pvchange $dev1 --addtag test$mda 
-	check_pv_field_ $dev1 pv_tags test$mda 
+	check pv_field $dev1 pv_tags test$mda 
 	pvchange $dev1 --deltag test$mda 
-	check_pv_field_ $dev1 pv_tags ""
+	check pv_field $dev1 pv_tags ""
 
 # "vgchange disable/enable allocation for pvs with metadatacopies = $mda (bz452982)"
 	pvchange $dev1 -x n 
-	check_pv_field_ $dev1 pv_attr  --  
+	check pv_field $dev1 pv_attr  --  
 	pvchange $dev1 -x y 
-	check_pv_field_ $dev1 pv_attr  a- 
+	check pv_field $dev1 pv_attr  a- 
 
 # 'remove pv'
 	vgremove $vg1 
@@ -45,13 +45,13 @@
 vgcreate $vg1 $dev1 $dev2 
 pvchange -u $dev1 
 pvchange -u $dev2 
-vg_validate_pvlv_counts_ $vg1 2 0 0
+check pvlv_counts $vg1 2 0 0
 pvchange -u --all
-vg_validate_pvlv_counts_ $vg1 2 0 0
+check pvlv_counts $vg1 2 0 0
 
 # "pvchange rejects uuid change under an active lv" 
 lvcreate -l 16 -i 2 -n $lv --alloc anywhere $vg1 
-vg_validate_pvlv_counts_ $vg1 2 1 0 
+check pvlv_counts $vg1 2 1 0 
 not pvchange -u $dev1
 lvchange -an "$vg1"/"$lv" 
 pvchange -u $dev1
--- LVM2/test/t-pvcreate-metadata0.sh	2008/10/06 16:47:07	1.2
+++ LVM2/test/t-pvcreate-metadata0.sh	2011/01/05 00:16:20	1.3
@@ -15,7 +15,7 @@
 #
 # 'Test pvcreate without metadata on all pvs'
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_devs 2 128
 
--- LVM2/test/t-pvcreate-operation-md.sh	2010/08/21 15:43:45	1.10
+++ LVM2/test/t-pvcreate-operation-md.sh	2011/01/05 00:16:20	1.11
@@ -18,9 +18,9 @@
 test -f /proc/mdstat && grep -q raid0 /proc/mdstat || \
 modprobe raid0 || exit 200
 
-. ./test-utils.sh
+. lib/test
 
-prepare_lvmconf '[ "a|/dev/md.*|", "a/dev\/mapper\/.*$/", "r/.*/" ]'
+prepare_lvmconf 'devices/filter = [ "a|/dev/md.*|", "a/dev\/mapper\/.*$/", "r/.*/" ]'
 aux prepare_devs 2
 
 # Have MD use a non-standard name to avoid colliding with an existing MD device
@@ -60,14 +60,14 @@
 pvcreate --metadatasize 128k \
     --config 'devices {md_chunk_alignment=0 data_alignment_detection=0 data_alignment_offset_detection=0}' \
     $mddev
-check_pv_field_ $mddev pe_start $pv_align
+check pv_field $mddev pe_start $pv_align
 
 # Test md_chunk_alignment independent of topology-aware detection
 pv_align="1.00m"
 pvcreate --metadatasize 128k \
     --config 'devices {data_alignment_detection=0 data_alignment_offset_detection=0}' \
     $mddev
-check_pv_field_ $mddev pe_start $pv_align
+check pv_field $mddev pe_start $pv_align
 
 # Get linux minor version
 linux_minor=$(echo `uname -r` | cut -d'.' -f3 | cut -d'-' -f1)
@@ -79,7 +79,7 @@
     # optimal_io_size=131072, minimum_io_size=65536
     pvcreate --metadatasize 128k \
 	--config 'devices { md_chunk_alignment=0 }' $mddev
-    check_pv_field_ $mddev pe_start $pv_align
+    check pv_field $mddev pe_start $pv_align
 fi
 
 # partition MD array directly, depends on blkext in Linux >= 2.6.28
@@ -113,7 +113,7 @@
         # default alignment is 1M, add alignment_offset
 	pv_align=$((1048576+$alignment_offset))B
 	pvcreate --metadatasize 128k $mddev_p
-	check_pv_field_ $mddev_p pe_start $pv_align "--units b"
+	check pv_field $mddev_p pe_start $pv_align "--units b"
 	pvremove $mddev_p
     fi
 fi
@@ -133,11 +133,11 @@
     pv_align="2.00m"
     pvcreate --metadatasize 128k \
 	--config 'devices { md_chunk_alignment=0 }' $mddev
-    check_pv_field_ $mddev pe_start $pv_align
+    check pv_field $mddev pe_start $pv_align
 
     # now verify pe_start alignment override using --dataalignment
     pv_align="192.00k"
     pvcreate --dataalignment 64k --metadatasize 128k \
 	--config 'devices { md_chunk_alignment=0 }' $mddev
-    check_pv_field_ $mddev pe_start $pv_align
+    check pv_field $mddev pe_start $pv_align
 fi
--- LVM2/test/t-pvcreate-operation.sh	2010/08/12 04:09:00	1.19
+++ LVM2/test/t-pvcreate-operation.sh	2011/01/05 00:16:20	1.20
@@ -8,7 +8,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_devs 4
 
--- LVM2/test/t-pvcreate-usage.sh	2010/08/12 04:11:50	1.16
+++ LVM2/test/t-pvcreate-usage.sh	2011/01/05 00:16:20	1.17
@@ -12,7 +12,7 @@
 test_description='Test pvcreate option values'
 PAGESIZE=$(getconf PAGESIZE)
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_devs 4
 
@@ -25,7 +25,7 @@
 # x. metadatasize 0, defaults to 255
 # FIXME: unable to check default value, not in reporting cmds
 # should default to 255 according to code
-#   check_pv_field_ pv_mda_size 255 
+#   check pv_field pv_mda_size 255 
 #COMM 'pvcreate accepts metadatasize 0'
 pvcreate --metadatasize 0 $dev1
 pvremove $dev1
@@ -34,7 +34,7 @@
 pvcreate --metadatasize 512k $dev1
 pvcreate --metadatasize 96k $dev2
 vgcreate $vg $dev1 $dev2
-compare_two_fields_ vgs $vg vg_mda_size pvs $dev2 pv_mda_size
+check compare_fields vgs $vg vg_mda_size pvs $dev2 pv_mda_size
 vgremove -ff $vg
 
 # x. metadatasize too large
@@ -51,9 +51,9 @@
 pvcreate --$j 0 $dev1
 pvcreate --$j 1 $dev2
 pvcreate --$j 2 $dev3
-check_pv_field_ $dev1 pv_mda_count 0
-check_pv_field_ $dev2 pv_mda_count 1
-check_pv_field_ $dev3 pv_mda_count 2
+check pv_field $dev1 pv_mda_count 0
+check pv_field $dev2 pv_mda_count 1
+check pv_field $dev3 pv_mda_count 2
 pvremove $dev1 
 pvremove $dev2 
 pvremove $dev3
@@ -89,21 +89,21 @@
 #COMM 'pvcreate always rounded up to page size for start of device'
 #pvcreate --metadatacopies 0 --dataalignment 1 $dev1
 # amuse shell experts
-#check_pv_field_ $dev1 pe_start $(($(getconf PAGESIZE)/1024))".00k"
+#check pv_field $dev1 pe_start $(($(getconf PAGESIZE)/1024))".00k"
 
 #COMM 'pvcreate sets data offset directly'
 pvcreate --dataalignment 512k $dev1
-check_pv_field_ $dev1 pe_start 512.00k
+check pv_field $dev1 pe_start 512.00k
 
 #COMM 'vgcreate/vgremove do not modify data offset of existing PV'
 vgcreate $vg $dev1  --config 'devices { data_alignment = 1024 }'
-check_pv_field_ $dev1 pe_start 512.00k
+check pv_field $dev1 pe_start 512.00k
 vgremove $vg --config 'devices { data_alignment = 1024 }'
-check_pv_field_ $dev1 pe_start 512.00k
+check pv_field $dev1 pe_start 512.00k
 
 #COMM 'pvcreate sets data offset next to mda area'
 pvcreate --metadatasize 100k --dataalignment 100k $dev1
-check_pv_field_ $dev1 pe_start 200.00k
+check pv_field $dev1 pe_start 200.00k
 
 # metadata area start is aligned according to pagesize
 # pagesize should be 64k or 4k ...
@@ -114,21 +114,21 @@
 fi
 
 pvcreate --metadatasize 128k --dataalignment 3.5k $dev1
-check_pv_field_ $dev1 pe_start $pv_align
+check pv_field $dev1 pe_start $pv_align
 
 pvcreate --metadatasize 128k --metadatacopies 2 --dataalignment 3.5k $dev1
-check_pv_field_ $dev1 pe_start $pv_align
+check pv_field $dev1 pe_start $pv_align
 
 # data area is aligned to 1M by default,
 # data area start is shifted by the specified alignment_offset
 pv_align="1052160B" # 1048576 + (7*512)
 pvcreate --metadatasize 128k --dataalignmentoffset 7s $dev1
-check_pv_field_ $dev1 pe_start $pv_align "--units b"
+check pv_field $dev1 pe_start $pv_align "--units b"
 
 # 2nd metadata area is created without problems when
 # data area start is shifted by the specified alignment_offset
 pvcreate --metadatasize 128k --metadatacopies 2 --dataalignmentoffset 7s $dev1
-check_pv_field_ $dev1 pv_mda_count 2
+check pv_field $dev1 pv_mda_count 2
 # FIXME: compare start of 2nd mda with and without --dataalignmentoffset
 
 #COMM 'pv with LVM1 compatible data alignment can be convereted'
@@ -137,7 +137,7 @@
 vgcreate -s 1m $vg $dev1
 vgconvert -M1 $vg
 vgconvert -M2 $vg
-check_pv_field_ $dev1 pe_start 256.00k
+check pv_field $dev1 pe_start 256.00k
 vgremove $vg
 
 #COMM 'pv with LVM1 incompatible data alignment cannot be convereted'
@@ -155,8 +155,8 @@
 vgcfgbackup -f "$(pwd)/backup.$$" $vg
 sed 's/pe_start = [0-9]*/pe_start = 0/' "$(pwd)/backup.$$" > "$(pwd)/backup.$$1"
 vgcfgrestore -f "$(pwd)/backup.$$1" $vg
-check_pv_field_ $dev1 pe_start 0
-check_pv_field_ $dev2 pe_start 0
+check pv_field $dev1 pe_start 0
+check pv_field $dev2 pe_start 0
 vgremove $vg
 
 echo test pvcreate --metadataignore
@@ -165,25 +165,25 @@
 for ignore in y n; do
 	echo pvcreate --metadataignore has proper mda_count and mda_used_count
 	pvcreate --metadatacopies $mdacp --metadataignore $ignore $dev1 $dev2
-	check_pv_field_ $dev1 pv_mda_count $mdacp
-	check_pv_field_ $dev2 pv_mda_count $mdacp
+	check pv_field $dev1 pv_mda_count $mdacp
+	check pv_field $dev2 pv_mda_count $mdacp
 	if [ $ignore = y ]; then
-		check_pv_field_ $dev1 pv_mda_used_count 0
-		check_pv_field_ $dev2 pv_mda_used_count 0
+		check pv_field $dev1 pv_mda_used_count 0
+		check pv_field $dev2 pv_mda_used_count 0
 	else
-		check_pv_field_ $dev1 pv_mda_used_count $mdacp
-		check_pv_field_ $dev2 pv_mda_used_count $mdacp
+		check pv_field $dev1 pv_mda_used_count $mdacp
+		check pv_field $dev2 pv_mda_used_count $mdacp
 	fi
 	echo vgcreate has proper vg_mda_count and vg_mda_used_count
 	if [ $pv_in_vg = 1 ]; then
 		vgcreate -c n "$vg" $dev1 $dev2
-		check_vg_field_ $vg vg_mda_count $(($mdacp * 2))
+		check vg_field $vg vg_mda_count $(($mdacp * 2))
 		if [ $ignore = y ]; then
-			check_vg_field_ $vg vg_mda_used_count 1
+			check vg_field $vg vg_mda_used_count 1
 		else
-			check_vg_field_ $vg vg_mda_used_count $(($mdacp * 2))
+			check vg_field $vg vg_mda_used_count $(($mdacp * 2))
 		fi
-		check_vg_field_ $vg vg_mda_copies unmanaged
+		check vg_field $vg vg_mda_copies unmanaged
 		vgremove $vg
 	fi
 done
--- LVM2/test/t-pvmove-basic.sh	2010/08/02 13:18:02	1.11
+++ LVM2/test/t-pvmove-basic.sh	2011/01/05 00:16:20	1.12
@@ -12,7 +12,7 @@
 
 test_description="ensure that pvmove works with basic options"
 
-. ./test-utils.sh
+. lib/test
 
 # ---------------------------------------------------------------------
 # Utilities
@@ -361,9 +361,9 @@
 
 #COMM "pvmove out of --metadatacopies 0 PV (bz252150)"
 vgremove -ff $vg
-pvcreate $devs
+pvcreate $(cat DEVICES)
 pvcreate --metadatacopies 0 $dev1 $dev2
-vgcreate -c n $vg $devs
+vgcreate -c n $vg $(cat DEVICES)
 lvcreate -l4 -n $lv1 $vg $dev1
 pvmove $dev1
 
--- LVM2/test/t-pvremove-usage.sh	2010/02/17 15:41:28	1.6
+++ LVM2/test/t-pvremove-usage.sh	2011/01/05 00:16:20	1.7
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_devs 3
 pvcreate $dev1
--- LVM2/test/t-read-ahead.sh	2010/04/07 14:46:26	1.12
+++ LVM2/test/t-read-ahead.sh	2011/01/05 00:16:20	1.13
@@ -15,7 +15,7 @@
 
 test_description='Test read-ahead functionality'
 
-. ./test-utils.sh
+. lib/test
 
 
 get_lvs_() {
@@ -53,10 +53,10 @@
 # Check default, active/inactive values for read_ahead / kernel_read_ahead
 lvcreate -n $lv -l 50%FREE $vg
 lvchange -an $vg/$lv
-check_lv_field_ $vg/$lv lv_read_ahead auto
-check_lv_field_ $vg/$lv lv_kernel_read_ahead -1
+check lv_field $vg/$lv lv_read_ahead auto
+check lv_field $vg/$lv lv_kernel_read_ahead -1
 lvchange -r 512 $vg/$lv
 lvchange -ay $vg/$lv
-check_lv_field_ $vg/$lv lv_read_ahead 256.00k
-check_lv_field_ $vg/$lv lv_kernel_read_ahead 256.00k
+check lv_field $vg/$lv lv_read_ahead 256.00k
+check lv_field $vg/$lv lv_kernel_read_ahead 256.00k
 lvremove -ff $vg
--- LVM2/test/t-snapshot-autoumount-dmeventd.sh	2010/10/29 16:43:52	1.1
+++ LVM2/test/t-snapshot-autoumount-dmeventd.sh	2011/01/05 00:16:20	1.2
@@ -10,15 +10,13 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 # no automatic extensions please
-LVM_TEST_CONFIG_SNAPSHOT_AUTOEXTEND="
-    snapshot_autoextend_percent = 0
-    snapshot_autoextend_threshold = 100"
 
-. ./test-utils.sh
+. lib/test
 
 which mkfs.ext2 || exit 200
 
-prepare_lvmconf
+aux lvmconf "activation/snapshot_autoextend_percent = 0" \
+            "activation/snapshot_autoextend_threshold = 100"
 
 aux prepare_vg 2
 aux prepare_dmeventd
--- LVM2/test/t-snapshot-merge.sh	2010/08/03 20:22:31	1.7
+++ LVM2/test/t-snapshot-merge.sh	2011/01/05 00:16:20	1.8
@@ -12,7 +12,7 @@
 
 which mkfs.ext3 || exit 200
 
-. ./test-utils.sh
+. lib/test
 
 lvdev_()
 {
--- LVM2/test/t-snapshots-of-mirrors.sh	2010/07/28 12:20:41	1.5
+++ LVM2/test/t-snapshots-of-mirrors.sh	2011/01/05 00:16:20	1.6
@@ -8,9 +8,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
-prepare_vg 4
+aux prepare_vg 4
 
 # Create snapshot of a mirror origin
 lvcreate -m 1 -L 10M -n lv $vg
--- LVM2/test/t-tags.sh	2010/02/16 17:49:18	1.1
+++ LVM2/test/t-tags.sh	2011/01/05 00:16:20	1.2
@@ -8,15 +8,15 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_pvs 5
 
 # vgcreate with --addtag
 vgcreate -c n --addtag firstvg $vg1 $dev1 $dev2
 vgcreate -c n --addtag secondvg $vg2 $dev3 $dev4
-check_vg_field_ $vg1 tags firstvg
-check_vg_field_ $vg2 tags secondvg
+check vg_field $vg1 tags firstvg
+check vg_field $vg2 tags secondvg
 vgremove -ff $vg1
 vgremove -ff $vg2
 
@@ -31,10 +31,10 @@
 vgchange --addtag secondvgtag1 $vg2
 vgchange --addtag secondvgtag2 $vg2
 vgchange --addtag secondvgtag3 $vg2
-check_vg_field_ @firstvgtag2 tags "firstvgtag1,firstvgtag2,firstvgtag3"
-check_vg_field_ @secondvgtag1 tags "secondvgtag1,secondvgtag2,secondvgtag3"
+check vg_field @firstvgtag2 tags "firstvgtag1,firstvgtag2,firstvgtag3"
+check vg_field @secondvgtag1 tags "secondvgtag1,secondvgtag2,secondvgtag3"
 vgchange --deltag firstvgtag2 $vg1
-check_vg_field_ @firstvgtag1 tags "firstvgtag1,firstvgtag3"
+check vg_field @firstvgtag1 tags "firstvgtag1,firstvgtag3"
 # deleting a tag multiple times is not an error
 vgchange --deltag firstvgtag2 $vg1
 vgchange --deltag firstvgtag1 $vg2
@@ -45,10 +45,10 @@
 vgcreate -c n $vg1 $dev1 $dev2
 lvcreate --addtag firstlvtag1 -l 4 -n $lv1 $vg1
 lvcreate --addtag secondlvtag1 -l 4 -n $lv2 $vg1
-check_lv_field_ @firstlvtag1 tags "firstlvtag1"
-not check_lv_field_ @secondlvtag1 tags "firstlvtag1"
-check_lv_field_ $vg1/$lv2 tags "secondlvtag1"
-not check_lv_field_ $vg1/$lv1 tags "secondlvtag1"
+check lv_field @firstlvtag1 tags "firstlvtag1"
+not check lv_field @secondlvtag1 tags "firstlvtag1"
+check lv_field $vg1/$lv2 tags "secondlvtag1"
+not check lv_field $vg1/$lv1 tags "secondlvtag1"
 vgremove -ff $vg1
 
 # lvchange with --addtag and --deltag
@@ -63,12 +63,12 @@
 lvchange --addtag secondlvtag1 $vg1/$lv2
 lvchange --addtag secondlvtag2 $vg1/$lv2
 lvchange --addtag secondlvtag3 $vg1/$lv2
-check_lv_field_ $vg1/$lv1 tags "firstlvtag1,firstlvtag2,firstlvtag3"
-not $(check_lv_field_ $vg1/$lv1 tags "secondlvtag1")
-check_lv_field_ $vg1/$lv2 tags "secondlvtag1,secondlvtag2,secondlvtag3"
-not $(check_lv_field_ $vg1/$lv1 tags "secondlvtag1")
+check lv_field $vg1/$lv1 tags "firstlvtag1,firstlvtag2,firstlvtag3"
+not $(check lv_field $vg1/$lv1 tags "secondlvtag1")
+check lv_field $vg1/$lv2 tags "secondlvtag1,secondlvtag2,secondlvtag3"
+not $(check lv_field $vg1/$lv1 tags "secondlvtag1")
 # deleting a tag multiple times is not an error
 lvchange --deltag firstlvtag2 $vg1/$lv1
 lvchange --deltag firstlvtag2 $vg1/$lv1
-check_lv_field_ $vg1/$lv1 tags "firstlvtag1,firstlvtag3"
-check_lv_field_ $vg1/$lv2 tags "secondlvtag1,secondlvtag2,secondlvtag3"
+check lv_field $vg1/$lv1 tags "firstlvtag1,firstlvtag3"
+check lv_field $vg1/$lv2 tags "secondlvtag1,secondlvtag2,secondlvtag3"
--- LVM2/test/t-test-partition.sh	2010/10/20 15:14:13	1.1
+++ LVM2/test/t-test-partition.sh	2011/01/05 00:16:20	1.2
@@ -18,7 +18,7 @@
 
 LVM_TEST_CONFIG_DEVICES="types = [\"device-mapper\", 142]"
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_pvs 1 30
 
--- LVM2/test/t-topology-support.sh	2010/08/12 04:11:50	1.5
+++ LVM2/test/t-topology-support.sh	2011/01/05 00:16:20	1.6
@@ -15,7 +15,7 @@
 
 test $linux_minor -ge 31 || exit 200
 
-. ./test-utils.sh
+. lib/test
 
 check_logical_block_size()
 {
@@ -64,41 +64,41 @@
 # Create "desktop-class" 4K drive
 # (logical_block_size=512, physical_block_size=4096, alignment_offset=0):
 LOGICAL_BLOCK_SIZE=512
-prepare_scsi_debug_dev $DEV_SIZE \
+aux prepare_scsi_debug_dev $DEV_SIZE \
     sector_size=$LOGICAL_BLOCK_SIZE physblk_exp=3
 check_logical_block_size $SCSI_DEBUG_DEV $LOGICAL_BLOCK_SIZE
 
 aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
-vgcreate -c n $vg $devs
+vgcreate -c n $vg $(cat DEVICES)
 test_snapshot_mount
 vgremove $vg
 
-cleanup_scsi_debug_dev
+aux cleanup_scsi_debug_dev
 
 # ---------------------------------------------
 # Create "desktop-class" 4K drive w/ 63-sector DOS partition compensation
 # (logical_block_size=512, physical_block_size=4096, alignment_offset=3584):
 LOGICAL_BLOCK_SIZE=512
-prepare_scsi_debug_dev $DEV_SIZE \
+aux prepare_scsi_debug_dev $DEV_SIZE \
     sector_size=$LOGICAL_BLOCK_SIZE physblk_exp=3 lowest_aligned=7
 check_logical_block_size $SCSI_DEBUG_DEV $LOGICAL_BLOCK_SIZE
 
 aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
-vgcreate -c n $vg $devs
+vgcreate -c n $vg $(cat DEVICES)
 test_snapshot_mount
 vgremove $vg
 
-cleanup_scsi_debug_dev
+aux cleanup_scsi_debug_dev
 
 # ---------------------------------------------
 # Create "enterprise-class" 4K drive
 # (logical_block_size=4096, physical_block_size=4096, alignment_offset=0):
 LOGICAL_BLOCK_SIZE=4096
-prepare_scsi_debug_dev $DEV_SIZE \
+aux prepare_scsi_debug_dev $DEV_SIZE \
     sector_size=$LOGICAL_BLOCK_SIZE
 check_logical_block_size $SCSI_DEBUG_DEV $LOGICAL_BLOCK_SIZE
 
 aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
-vgcreate -c n $vg $devs
+vgcreate -c n $vg $(cat DEVICES)
 test_snapshot_mount
 vgremove $vg
--- LVM2/test/t-unknown-segment.sh	2009/10/16 17:41:52	1.1
+++ LVM2/test/t-unknown-segment.sh	2011/01/05 00:16:20	1.2
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_vg 4
 
--- LVM2/test/t-unlost-pv.sh	2009/06/10 20:17:33	1.3
+++ LVM2/test/t-unlost-pv.sh	2011/01/05 00:16:20	1.4
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_vg 3
 
@@ -24,15 +24,15 @@
 }
 
 # try orphaning a missing PV (bz45867)
-disable_dev $dev1
+aux disable_dev $dev1
 vgreduce --removemissing --force $vg
-enable_dev $dev1
+aux enable_dev $dev1
 check
 
 # try to just change metadata; we expect the new version (with MISSING_PV set
 # on the reappeared volume) to be written out to the previously missing PV
 vgextend $vg $dev1
-disable_dev $dev1
+aux disable_dev $dev1
 lvremove $vg/mirror
-enable_dev $dev1
+aux enable_dev $dev1
 check
--- LVM2/test/t-vgcfgbackup-usage.sh	2010/10/04 18:59:02	1.6
+++ LVM2/test/t-vgcfgbackup-usage.sh	2011/01/05 00:16:20	1.7
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_pvs 4
 
@@ -28,7 +28,7 @@
 # and vgcfgrestore able to restore them when device reappears
 pv1_uuid=$(pvs --noheadings -o pv_uuid $dev1)
 pv2_uuid=$(pvs --noheadings -o pv_uuid $dev2)
-vgcreate $vg $devs
+vgcreate $vg $(cat DEVICES)
 lvcreate -l1 -n $lv1 $vg $dev1
 lvcreate -l1 -n $lv2 $vg $dev2
 lvcreate -l1 -n $lv3 $vg $dev3
@@ -46,8 +46,8 @@
 # FIXME: clvmd seems to have problem with metadata format change here
 # fix it and remove this vgscan
 vgscan
-pvcreate -M1 $devs
-vgcreate -M1 -c n $vg $devs
+pvcreate -M1 $(cat DEVICES)
+vgcreate -M1 -c n $vg $(cat DEVICES)
 lvcreate -l1 -n $lv1 $vg $dev1
 pvremove -ff -y $dev2
 not lvcreate -l1 -n $lv1 $vg $dev3
--- LVM2/test/t-vgchange-maxlv.sh	2010/10/20 15:32:15	1.1
+++ LVM2/test/t-vgchange-maxlv.sh	2011/01/05 00:16:20	1.2
@@ -9,9 +9,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
-prepare_dmeventd
+aux prepare_dmeventd
 aux prepare_pvs 3
 
 vgcreate -c n -l 2 $vg $dev1 $dev2 $dev3
--- LVM2/test/t-vgchange-usage.sh	2010/02/16 17:48:46	1.2
+++ LVM2/test/t-vgchange-usage.sh	2011/01/05 00:16:20	1.3
@@ -11,34 +11,34 @@
 
 test_description='Exercise some vgchange diagnostics'
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_pvs 3
 pvcreate --metadatacopies 0 $dev1
-vgcreate $vg $devs
+vgcreate $vg $(cat DEVICES)
 
 vgdisplay $vg
 
 # vgchange -p MaxPhysicalVolumes (bz202232)
-aux check_vg_field_ $vg max_pv 0
+aux check vg_field $vg max_pv 0
 vgchange -p 128 $vg
-aux check_vg_field_ $vg max_pv 128
+aux check vg_field $vg max_pv 128
 
-pv_count=$(get_vg_field $vg pv_count)
+pv_count=$(get vg_field $vg pv_count)
 not vgchange -p 2 $vg 2>err
 grep "MaxPhysicalVolumes is less than the current number $pv_count of PVs for" err
-aux check_vg_field_ $vg max_pv 128
+aux check vg_field $vg max_pv 128
 
 # vgchange -l MaxLogicalVolumes
-aux check_vg_field_ $vg max_lv 0
+aux check vg_field $vg max_lv 0
 vgchange -l 128 $vg
-aux check_vg_field_ $vg max_lv 128
+aux check vg_field $vg max_lv 128
 
 lvcreate -l4 -n$lv1 $vg
 lvcreate -l4 -n$lv2 $vg
 
-lv_count=$(get_vg_field $vg lv_count)
+lv_count=$(get vg_field $vg lv_count)
 not vgchange -l 1 $vg 2>err
 grep "MaxLogicalVolume is less than the current number $lv_count of LVs for"  err
-aux check_vg_field_ $vg max_lv 128
+aux check vg_field $vg max_lv 128
 
--- LVM2/test/t-vgcreate-usage.sh	2010/08/12 04:11:50	1.17
+++ LVM2/test/t-vgcreate-usage.sh	2011/01/05 00:16:20	1.18
@@ -11,7 +11,7 @@
 
 test_description='Exercise some vgcreate diagnostics'
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_devs 3
 pvcreate $dev1 $dev2
@@ -21,7 +21,7 @@
 
 #COMM 'vgcreate accepts 8.00m physicalextentsize for VG'
 vgcreate -c n $vg --physicalextentsize 8.00m $dev1 $dev2
-check_vg_field_ $vg vg_extent_size 8.00m
+check vg_field  $vg vg_extent_size 8.00m
 vgremove $vg
 # try vgck and to remove it again - should fail (but not segfault)
 not vgremove $vg
@@ -29,12 +29,12 @@
 
 #COMM 'vgcreate accepts smaller (128) maxlogicalvolumes for VG'
 vgcreate -c n $vg --maxlogicalvolumes 128 $dev1 $dev2 
-check_vg_field_ $vg max_lv 128 
+check vg_field $vg max_lv 128 
 vgremove $vg
 
 #COMM 'vgcreate accepts smaller (128) maxphysicalvolumes for VG'
 vgcreate -c n $vg --maxphysicalvolumes 128 $dev1 $dev2
-check_vg_field_ $vg max_pv 128
+check vg_field $vg max_pv 128
 vgremove $vg
 
 #COMM 'vgcreate rejects a zero physical extent size'
@@ -75,7 +75,7 @@
 # Test default (4MB) vg_extent_size as well as limits of extent_size
 not vgcreate -c n --physicalextentsize 0k $vg $dev1 $dev2
 vgcreate -c n --physicalextentsize 1k $vg $dev1 $dev2
-check_vg_field_ $vg vg_extent_size 1.00k
+check vg_field $vg vg_extent_size 1.00k
 vgremove -ff $vg
 not vgcreate -c n --physicalextentsize 3K $vg $dev1 $dev2
 not vgcreate -c n --physicalextentsize 1024t $vg $dev1 $dev2
@@ -84,10 +84,10 @@
 
 # Test default max_lv, max_pv, extent_size, alloc_policy, clustered
 vgcreate -c n $vg $dev1 $dev2
-check_vg_field_ $vg vg_extent_size 4.00m
-check_vg_field_ $vg max_lv 0
-check_vg_field_ $vg max_pv 0
-check_vg_field_ $vg vg_attr "wz--n-"
+check vg_field $vg vg_extent_size 4.00m
+check vg_field $vg max_lv 0
+check vg_field $vg max_pv 0
+check vg_field $vg vg_attr "wz--n-"
 vgremove -ff $vg
 
 # Implicit pvcreate tests, test pvcreate options on vgcreate
@@ -111,22 +111,22 @@
 for i in 1 2
 do
     vgcreate -c n --pvmetadatacopies $i $vg $dev1
-    check_pv_field_ $dev1 pv_mda_count $i
+    check pv_field $dev1 pv_mda_count $i
     vgremove -f $vg
     pvremove -f $dev1
 done
 not vgcreate -c n --pvmetadatacopies 0 $vg $dev1
 pvcreate --metadatacopies 1 $dev2
 vgcreate -c n --pvmetadatacopies 0 $vg $dev1 $dev2
-check_pv_field_ $dev1 pv_mda_count 0
-check_pv_field_ $dev2 pv_mda_count 1
+check pv_field $dev1 pv_mda_count 0
+check pv_field $dev2 pv_mda_count 1
 vgremove -f $vg
 pvremove -f $dev1
 
 # metadatasize, dataalignment, dataalignmentoffset
 #COMM 'pvcreate sets data offset next to mda area'
 vgcreate -c n --metadatasize 100k --dataalignment 100k $vg $dev1
-check_pv_field_ $dev1 pe_start 200.00k
+check pv_field $dev1 pe_start 200.00k
 vgremove -f $vg
 pvremove -f $dev1
 
@@ -134,7 +134,7 @@
 # data area start is shifted by the specified alignment_offset
 pv_align="1052160B" # 1048576 + (7*512)
 vgcreate -c n --metadatasize 128k --dataalignmentoffset 7s $vg $dev1
-check_pv_field_ $dev1 pe_start $pv_align "--units b"
+check pv_field $dev1 pe_start $pv_align "--units b"
 vgremove -f $vg
 pvremove -f $dev1
 
@@ -142,7 +142,7 @@
 for i in 1 2
 do
     vgcreate -c n -M $i $vg $dev1
-    check_vg_field_ $vg vg_fmt lvm$i
+    check vg_field $vg vg_fmt lvm$i
     vgremove -f $vg
     pvremove -f $dev1
 done
@@ -156,8 +156,8 @@
 # all PVs exist in the VG after created
 pvcreate $dev1
 vgcreate -c n $vg1 $dev1 $dev2 $dev3
-check_pv_field_ $dev1 vg_name $vg1
-check_pv_field_ $dev2 vg_name $vg1
-check_pv_field_ $dev3 vg_name $vg1
+check pv_field $dev1 vg_name $vg1
+check pv_field $dev2 vg_name $vg1
+check pv_field $dev3 vg_name $vg1
 vgremove -f $vg1
 pvremove -f $dev1 $dev2 $dev3
--- LVM2/test/t-vgextend-restoremissing.sh	2010/10/13 10:36:26	1.1
+++ LVM2/test/t-vgextend-restoremissing.sh	2011/01/05 00:16:20	1.2
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
 
 aux prepare_vg 3
@@ -19,9 +19,9 @@
 
 # try to just change metadata; we expect the new version (with MISSING_PV set
 # on the reappeared volume) to be written out to the previously missing PV
-disable_dev $dev1
+aux disable_dev $dev1
 lvremove $vg/mirror
-enable_dev $dev1
+aux enable_dev $dev1
 not vgck $vg 2>&1 | tee log
 grep "missing 1 physical volume" log
 not lvcreate -m 1 -l 1 -n mirror $vg # write operations fail
--- LVM2/test/t-vgextend-usage.sh	2010/08/12 04:11:50	1.5
+++ LVM2/test/t-vgextend-usage.sh	2011/01/05 00:16:20	1.6
@@ -12,7 +12,7 @@
 # Exercise various vgextend commands
 #
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_devs 5
 
@@ -55,7 +55,7 @@
 for i in 0 1 2
 do
     vgextend --pvmetadatacopies $i $vg $dev1
-    check_pv_field_ $dev1 pv_mda_count $i
+    check pv_field $dev1 pv_mda_count $i
     vgreduce $vg $dev1
     pvremove -f $dev1
 done
@@ -63,7 +63,7 @@
 # metadatasize, dataalignment, dataalignmentoffset
 #COMM 'pvcreate sets data offset next to mda area'
 vgextend --metadatasize 100k --dataalignment 100k $vg $dev1
-check_pv_field_ $dev1 pe_start 200.00k
+check pv_field $dev1 pe_start 200.00k
 vgreduce $vg $dev1
 pvremove -f $dev1
 
@@ -71,7 +71,7 @@
 # data area start is shifted by the specified alignment_offset
 pv_align="1052160B" # 1048576 + (7*512)
 vgextend --metadatasize 128k --dataalignmentoffset 7s $vg $dev1
-check_pv_field_ $dev1 pe_start $pv_align "--units b"
+check pv_field $dev1 pe_start $pv_align "--units b"
 vgremove -f $vg
 pvremove -f $dev1
 
@@ -94,9 +94,9 @@
 pvcreate $dev1
 vgcreate $vg1 $dev2
 vgextend $vg1 $dev1 $dev3
-check_pv_field_ $dev1 vg_name $vg1
-check_pv_field_ $dev2 vg_name $vg1
-check_pv_field_ $dev3 vg_name $vg1
+check pv_field $dev1 vg_name $vg1
+check pv_field $dev2 vg_name $vg1
+check pv_field $dev3 vg_name $vg1
 vgremove -f $vg1
 pvremove -f $dev1 $dev2 $dev3
 
@@ -106,23 +106,23 @@
 	echo vgextend --metadataignore has proper mda_count and mda_used_count
 	vgcreate $vg $dev3
 	vgextend --metadataignore $ignore --pvmetadatacopies $mdacp $vg $dev1 $dev2
-	check_pv_field_ $dev1 pv_mda_count $mdacp
-	check_pv_field_ $dev2 pv_mda_count $mdacp
+	check pv_field $dev1 pv_mda_count $mdacp
+	check pv_field $dev2 pv_mda_count $mdacp
 	if [ $ignore = y ]; then
-		check_pv_field_ $dev1 pv_mda_used_count 0
-		check_pv_field_ $dev2 pv_mda_used_count 0
+		check pv_field $dev1 pv_mda_used_count 0
+		check pv_field $dev2 pv_mda_used_count 0
 	else
-		check_pv_field_ $dev1 pv_mda_used_count $mdacp
-		check_pv_field_ $dev2 pv_mda_used_count $mdacp
+		check pv_field $dev1 pv_mda_used_count $mdacp
+		check pv_field $dev2 pv_mda_used_count $mdacp
 	fi
 	echo vg has proper vg_mda_count and vg_mda_used_count
-	check_vg_field_ $vg vg_mda_count $(($mdacp * 2 + 1))
+	check vg_field $vg vg_mda_count $(($mdacp * 2 + 1))
 	if [ $ignore = y ]; then
-		check_vg_field_ $vg vg_mda_used_count 1
+		check vg_field $vg vg_mda_used_count 1
 	else
-		check_vg_field_ $vg vg_mda_used_count $(($mdacp * 2 + 1))
+		check vg_field $vg vg_mda_used_count $(($mdacp * 2 + 1))
 	fi
-	check_vg_field_ $vg vg_mda_copies unmanaged
+	check vg_field $vg vg_mda_copies unmanaged
 	vgremove $vg
 	pvremove -ff $dev1 $dev2 $dev3
 done
--- LVM2/test/t-vgmerge-operation.sh	2009/12/28 18:33:04	1.6
+++ LVM2/test/t-vgmerge-operation.sh	2011/01/05 00:16:20	1.7
@@ -11,7 +11,7 @@
 
 test_description='Test vgmerge operation'
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_pvs 4 64
 
@@ -20,10 +20,10 @@
 vgcreate -c n $vg2 $dev3 $dev4 
 lvcreate -l 4 -n $lv1 $vg1 $dev1 
 vgchange -an $vg1 
-vg_validate_pvlv_counts_ $vg1 2 1 0 
-vg_validate_pvlv_counts_ $vg2 2 0 0 
+check pvlv_counts $vg1 2 1 0 
+check pvlv_counts $vg2 2 0 0 
 vgmerge $vg2 $vg1 
-vg_validate_pvlv_counts_ $vg2 4 1 0 
+check pvlv_counts $vg2 4 1 0 
 vgremove -f $vg2
 
 # 'vgmerge succeeds with single linear LV in source and destination VG'
@@ -33,10 +33,10 @@
 lvcreate -l 4 -n $lv2 $vg2 
 vgchange -an $vg1 
 vgchange -an $vg2 
-vg_validate_pvlv_counts_ $vg1 2 1 0 
-vg_validate_pvlv_counts_ $vg2 2 1 0 
+check pvlv_counts $vg1 2 1 0 
+check pvlv_counts $vg2 2 1 0 
 vgmerge $vg2 $vg1 
-vg_validate_pvlv_counts_ $vg2 4 2 0 
+check pvlv_counts $vg2 4 2 0 
 vgremove -f $vg2
 
 # 'vgmerge succeeds with linear LV + snapshots in source VG'
@@ -45,10 +45,10 @@
 lvcreate -l 16 -n $lv1 $vg1 
 lvcreate -l 4 -s -n $lv2 $vg1/$lv1 
 vgchange -an $vg1 
-vg_validate_pvlv_counts_ $vg1 2 2 1 
-vg_validate_pvlv_counts_ $vg2 2 0 0 
+check pvlv_counts $vg1 2 2 1 
+check pvlv_counts $vg2 2 0 0 
 vgmerge $vg2 $vg1 
-vg_validate_pvlv_counts_ $vg2 4 2 1 
+check pvlv_counts $vg2 4 2 1 
 lvremove -f $vg2/$lv2 
 vgremove -f $vg2
 
@@ -57,10 +57,10 @@
 vgcreate -c n $vg2 $dev4 
 lvcreate -l 4 -n $lv1 -m1 $vg1 
 vgchange -an $vg1 
-vg_validate_pvlv_counts_ $vg1 3 1 0 
-vg_validate_pvlv_counts_ $vg2 1 0 0 
+check pvlv_counts $vg1 3 1 0 
+check pvlv_counts $vg2 1 0 0 
 vgmerge $vg2 $vg1 
-vg_validate_pvlv_counts_ $vg2 4 1 0 
+check pvlv_counts $vg2 4 1 0 
 lvremove -f $vg2/$lv1 
 vgremove -f $vg2
 
@@ -70,12 +70,12 @@
 lvcreate -l 4 -n $lv1 $vg1
 lvcreate -l 4 -n $lv1 $vg2
 vgchange -an $vg1
-aux vg_validate_pvlv_counts_ $vg1 2 1 0
-aux vg_validate_pvlv_counts_ $vg2 2 1 0
+check pvlv_counts $vg1 2 1 0
+check pvlv_counts $vg2 2 1 0
 not vgmerge $vg2 $vg1 2>err
 grep "Duplicate logical volume name \"$lv1\" in \"$vg2\" and \"$vg1" err
-aux vg_validate_pvlv_counts_ $vg1 2 1 0
-aux vg_validate_pvlv_counts_ $vg2 2 1 0
+check pvlv_counts $vg1 2 1 0
+check pvlv_counts $vg2 2 1 0
 vgremove -f $vg1
 vgremove -f $vg2
 
--- LVM2/test/t-vgmerge-usage.sh	2009/12/28 18:33:04	1.7
+++ LVM2/test/t-vgmerge-usage.sh	2011/01/05 00:16:20	1.8
@@ -11,7 +11,7 @@
 
 # 'Test vgmerge command options for validity'
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_pvs 4
 
--- LVM2/test/t-vgreduce-usage.sh	2009/12/28 18:33:04	1.6
+++ LVM2/test/t-vgreduce-usage.sh	2011/01/05 00:16:20	1.7
@@ -9,7 +9,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_devs 4
 
@@ -21,7 +21,7 @@
     # (lvm$mdatype) vgreduce removes only the specified pv from vg (bz427382)" '
     vgcreate -c n -M$mdatype $vg1 $dev1 $dev2
     vgreduce $vg1 $dev1
-    check_pv_field_ $dev2 vg_name $vg1
+    check pv_field $dev2 vg_name $vg1
     vgremove -f $vg1
 
     # (lvm$mdatype) vgreduce rejects removing the last pv (--all)
@@ -58,15 +58,15 @@
 aux disable_dev $dev1
 # (lvm$mdatype) vgreduce --removemissing --force repares to linear
 vgreduce --removemissing --force $vg1
-check_lv_field_ $vg1/$lv1 segtype linear
-vg_validate_pvlv_counts_ $vg1 2 3 0
+check lv_field $vg1/$lv1 segtype linear
+check pvlv_counts $vg1 2 3 0
 # cleanup
 aux enable_dev $dev1
 vgremove -ff $vg1
 
 #COMM "vgreduce rejects --removemissing --mirrorsonly --force when nonmirror lv lost too"
 # (lvm$mdatype) setup: create mirror + linear lvs
-vgcreate -c n -M$mdatype $vg1 $devs
+vgcreate -c n -M$mdatype $vg1 $(cat DEVICES)
 lvcreate -n $lv2 -l 4 $vg1
 lvcreate -m1 -n $lv1 -l 4 $vg1 $dev1 $dev2 $dev3
 lvcreate -n $lv3 -l 4 $vg1 $dev3
--- LVM2/test/t-vgrename-usage.sh	2009/09/02 18:31:11	1.5
+++ LVM2/test/t-vgrename-usage.sh	2011/01/05 00:16:20	1.6
@@ -8,7 +8,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_devs 4
 pvcreate $dev1 $dev2
@@ -19,17 +19,17 @@
 # ensure name ordering does not matter
 vgcreate $vg1 $dev1 $dev2
 vgrename $vg1 $vg2
-check_vg_field_ $vg2 vg_name $vg2
+check vg_field $vg2 vg_name $vg2
 vgrename $vg2 $vg1
-check_vg_field_ $vg1 vg_name $vg1
+check vg_field $vg1 vg_name $vg1
 vgremove $vg1
 
 # vgrename by uuid (bz231187)
 vgcreate $vg1 $dev1 $dev3
 UUID=$(vgs --noheading -o vg_uuid $vg1)
-check_vg_field_ $vg1 vg_uuid $UUID
+check vg_field $vg1 vg_uuid $UUID
 vgrename $UUID $vg2
-check_vg_field_ $vg2 vg_name $vg2
+check vg_field $vg2 vg_name $vg2
 vgremove $vg2
 
 # vgrename fails - new vg already exists
--- LVM2/test/t-vgsplit-operation.sh	2010/08/12 04:11:50	1.26
+++ LVM2/test/t-vgsplit-operation.sh	2011/01/05 00:16:20	1.27
@@ -11,13 +11,13 @@
 
 # Test vgsplit operation, including different LV types
 
-. ./test-utils.sh
+. lib/test
 
 COMM() {  
 	LAST_TEST="$@"
 }
 
-prepare_pvs 5 258
+aux prepare_pvs 5 258
 # FIXME: paramaterize lvm1 vs lvm2 metadata; most of these tests should run
 # fine with lvm1 metadata as well; for now, just add disks 5 and 6 as lvm1
 # metadata
@@ -44,11 +44,11 @@
 		else
 		  vgsplit -n $lv1 $vg1 $vg2
 		fi 
-		vg_validate_pvlv_counts_ $vg1 1 0 0 
+		check pvlv_counts $vg1 1 0 0 
 		if [ $i = existing ]; then
-		   aux vg_validate_pvlv_counts_ $vg2 3 1 0
+		   check pvlv_counts $vg2 3 1 0
 		else
-		   aux vg_validate_pvlv_counts_ $vg2 1 1 0
+		   check pvlv_counts $vg2 1 1 0
 		fi 
 		lvremove -f $vg2/$lv1 
 		vgremove -f $vg2 
@@ -67,9 +67,9 @@
 		  vgsplit -n $lv1 $vg1 $vg2
 		fi 
 		if [ $i = existing ]; then
-		  aux vg_validate_pvlv_counts_ $vg2 4 1 0
+		  check pvlv_counts $vg2 4 1 0
 		else
-		  aux vg_validate_pvlv_counts_ $vg2 2 1 0
+		  check pvlv_counts $vg2 2 1 0
 		fi 
 		lvremove -f $vg2/$lv1 
 		vgremove -f $vg2
@@ -87,9 +87,9 @@
 		  vgsplit -n $lv1 $vg1 $vg2
 		fi 
 		if [ $i = existing ]; then
-		  aux vg_validate_pvlv_counts_ $vg2 4 1 0
+		  check pvlv_counts $vg2 4 1 0
 		else
-		  aux vg_validate_pvlv_counts_ $vg2 3 1 0
+		  check pvlv_counts $vg2 3 1 0
 		fi 
 		lvremove -f $vg2/$lv1 
 		vgremove -f $vg2
@@ -108,9 +108,9 @@
 		  vgsplit -n $lv1 $vg1 $vg2
 		fi 
 		if [ $i = existing ]; then
-		  aux vg_validate_pvlv_counts_ $vg2 4 2 1
+		  check pvlv_counts $vg2 4 2 1
 		else
-		  aux vg_validate_pvlv_counts_ $vg2 2 2 1
+		  check pvlv_counts $vg2 2 2 1
 		fi 
 		lvremove -f $vg2/$lv2 
 		lvremove -f $vg2/$lv1 
@@ -132,11 +132,11 @@
 		  vgsplit -n $lv3 $vg1 $vg2
 		fi 
 		if [ $i = existing ]; then
-		  aux vg_validate_pvlv_counts_ $vg2 2 1 0
-		  aux vg_validate_pvlv_counts_ $vg1 2 2 1
+		  check pvlv_counts $vg2 2 1 0
+		  check pvlv_counts $vg1 2 2 1
 		else
-		  aux vg_validate_pvlv_counts_ $vg2 1 1 0
-		  aux vg_validate_pvlv_counts_ $vg1 2 2 1
+		  check pvlv_counts $vg2 1 1 0
+		  check pvlv_counts $vg1 2 2 1
 		fi 
 		lvremove -f $vg1/$lv2 
 		lvremove -f $vg1/$lv1 
@@ -162,14 +162,14 @@
 		  vgsplit -n $lv2 $vg1 $vg2
 		fi 
 		if [ $i = existing ]; then
-		  aux vg_validate_pvlv_counts_ $vg1 3 1 0
-		  aux vg_validate_pvlv_counts_ $vg2 2 1 0
+		  check pvlv_counts $vg1 3 1 0
+		  check pvlv_counts $vg2 2 1 0
 		else
 		vgs
 		lvs 
 		pvs
-		  aux vg_validate_pvlv_counts_ $vg1 3 1 0
-		  aux vg_validate_pvlv_counts_ $vg2 1 1 0
+		  check pvlv_counts $vg1 3 1 0
+		  check pvlv_counts $vg2 1 1 0
 		fi 
 		lvremove -f $vg1/$lv1 
 		lvremove -f $vg2/$lv2 
@@ -197,7 +197,7 @@
 lvcreate -l 16 -n $lv1 $vg1 $dev1 $dev2 
 lvcreate -l 4 -n $lv2 -s $vg1/$lv1 $dev3
 lvcreate -l 4 -n $lv3 -s $vg1/$lv1 $dev4
-vg_validate_pvlv_counts_ $vg1 4 3 2 
+check pvlv_counts $vg1 4 3 2 
 vgchange -an $vg1 
 not vgsplit -n $lv1 $vg1 $vg2;
 lvremove -f $vg1/$lv2 
@@ -210,7 +210,7 @@
 lvcreate -l 16 -n $lv1 $vg1 $dev1 $dev2 
 lvcreate -l 4 -n $lv2 -s $vg1/$lv1 $dev3
 lvcreate -l 4 -n $lv3 -s $vg1/$lv1 $dev4
-vg_validate_pvlv_counts_ $vg1 4 3 2 
+check pvlv_counts $vg1 4 3 2 
 vgchange -an $vg1 
 not vgsplit -n $lv2 $vg1 $vg2
 lvremove -f $vg1/$lv2 
@@ -221,7 +221,7 @@
 COMM "vgsplit fails splitting one mirror LV, only one PV specified" 
 vgcreate -c n $vg1 $dev1 $dev2 $dev3 $dev4 
 lvcreate -l 16 -n $lv1 -m1 $vg1 $dev1 $dev2 $dev3 
-vg_validate_pvlv_counts_ $vg1 4 1 0 
+check pvlv_counts $vg1 4 1 0 
 vgchange -an $vg1 
 not vgsplit $vg1 $vg2 $dev2 
 vgremove -ff $vg1
@@ -230,7 +230,7 @@
 vgcreate -c n $vg1 $dev1 $dev2 $dev3 $dev4 
 lvcreate -l 16 -n $lv1 -m1 $vg1 $dev1 $dev2 $dev3 
 lvcreate -l 16 -n $lv2 -i 2 $vg1 $dev3 $dev4 
-vg_validate_pvlv_counts_ $vg1 4 2 0 
+check pvlv_counts $vg1 4 2 0 
 vgchange -an $vg1 
 not vgsplit -n $lv2 $vg1 $vg2 2>err
 vgremove -ff $vg1
@@ -243,9 +243,9 @@
 lvcreate -l 16 -n $lv1 -m1 $vg1 $dev1 $dev2 $dev3 
 lvcreate -l 16 -n $lv2 $vg1 $dev4 
 lvchange -an $vg1/$lv2 
-vg_validate_pvlv_counts_ $vg1 4 2 0 
+check pvlv_counts $vg1 4 2 0 
 not vgsplit -n $lv1 $vg1 $vg2;
-vg_validate_pvlv_counts_ $vg1 4 2 0 
+check pvlv_counts $vg1 4 2 0 
 vgremove -ff $vg1
 
 COMM "vgsplit succeeds, active mirror not involved in split" 
@@ -253,10 +253,10 @@
 lvcreate -l 16 -n $lv1 -m1 $vg1 $dev1 $dev2 $dev3 
 lvcreate -l 16 -n $lv2 $vg1 $dev4 
 lvchange -an $vg1/$lv2 
-vg_validate_pvlv_counts_ $vg1 4 2 0 
+check pvlv_counts $vg1 4 2 0 
 vgsplit -n $lv2 $vg1 $vg2 
-vg_validate_pvlv_counts_ $vg1 3 1 0 
-vg_validate_pvlv_counts_ $vg2 1 1 0 
+check pvlv_counts $vg1 3 1 0 
+check pvlv_counts $vg2 1 1 0 
 vgremove -ff $vg1 
 vgremove -ff $vg2
 
@@ -266,9 +266,9 @@
 lvcreate -l 4 -i 2 -s -n $lv2 $vg1/$lv1 
 lvcreate -l 64 -i 2 -n $lv3 $vg1 $dev3 $dev4 
 lvchange -an $vg1/$lv3 
-vg_validate_pvlv_counts_ $vg1 4 3 1 
+check pvlv_counts $vg1 4 3 1 
 not vgsplit -n $lv2 $vg1 $vg2;
-vg_validate_pvlv_counts_ $vg1 4 3 1 
+check pvlv_counts $vg1 4 3 1 
 lvremove -f $vg1/$lv2 
 vgremove -ff $vg1
 
@@ -279,10 +279,10 @@
 vgextend $vg1 $dev4 
 lvcreate -l 64 -n $lv3 $vg1 $dev4 
 lvchange -an $vg1/$lv3 
-vg_validate_pvlv_counts_ $vg1 4 3 1 
+check pvlv_counts $vg1 4 3 1 
 vgsplit -n $lv3 $vg1 $vg2 
-vg_validate_pvlv_counts_ $vg1 3 2 1 
-vg_validate_pvlv_counts_ $vg2 1 1 0 
+check pvlv_counts $vg1 3 2 1 
+check pvlv_counts $vg2 1 1 0 
 vgchange -an $vg1 
 lvremove -f $vg1/$lv2 
 vgremove -ff $vg1 
--- LVM2/test/t-vgsplit-stacked.sh	2010/07/28 12:20:41	1.4
+++ LVM2/test/t-vgsplit-stacked.sh	2011/01/05 00:16:20	1.5
@@ -8,12 +8,13 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-. ./test-utils.sh
+. lib/test
 
-prepare_lvmconf '[ "a/dev\/mirror/", "a/dev\/mapper\/.*$/", "a/dev\/LVMTEST/", "r/.*/" ]'
+aux lvmconf 'devices/filter = [ "a/dev\/mirror/", "a/dev\/mapper\/.*$/", "a/dev\/LVMTEST/", "r/.*/" ]'
+cat $TESTDIR/etc/lvm.conf
 aux prepare_devs 3
 
-pvcreate $devs
+pvcreate $(cat DEVICES)
 vgcreate $vg1 $dev1 $dev2
 lvcreate -n $lv1 -l 100%FREE $vg1
 
--- LVM2/test/t-vgsplit-usage.sh	2009/09/02 19:38:53	1.14
+++ LVM2/test/t-vgsplit-usage.sh	2011/01/05 00:16:20	1.15
@@ -11,29 +11,29 @@
 
 # Test vgsplit command options for validity
 
-. ./test-utils.sh
+. lib/test
 
 aux prepare_devs 5
 
 for mdatype in 1 2
 do
 
-pvcreate -M$mdatype $devs
+pvcreate -M$mdatype $(cat DEVICES)
 
 # ensure name order does not matter
 # NOTE: if we're using lvm1, we must use -M on vgsplit
-vgcreate -M$mdatype $vg1 $devs
+vgcreate -M$mdatype $vg1 $(cat DEVICES)
 vgsplit -M$mdatype $vg1 $vg2 $dev1
 vgremove $vg1
 vgremove $vg2
-vgcreate -M$mdatype $vg2 $devs
+vgcreate -M$mdatype $vg2 $(cat DEVICES)
 vgsplit -M$mdatype $vg2 $vg1 $dev1
 vgremove $vg1
 vgremove $vg2
 
 # vgsplit accepts new vg as destination of split
 # lvm1 -- bz244792
-vgcreate -M$mdatype $vg1 $devs
+vgcreate -M$mdatype $vg1 $(cat DEVICES)
 vgsplit $vg1 $vg2 $dev1 1>err
 grep "New volume group \"$vg2\" successfully split from \"$vg1\"" err 
 vgremove $vg1 
@@ -50,14 +50,14 @@
 # vgsplit accepts --maxphysicalvolumes 128 on new VG
 vgcreate -M$mdatype $vg1 $dev1 $dev2 
 vgsplit --maxphysicalvolumes 128 $vg1 $vg2 $dev1 
-check_vg_field_ $vg2 max_pv 128 
+check vg_field $vg2 max_pv 128 
 vgremove $vg1 
 vgremove $vg2
 
 # vgsplit accepts --maxlogicalvolumes 128 on new VG
 vgcreate -M$mdatype $vg1 $dev1 $dev2 
 vgsplit --maxlogicalvolumes 128 $vg1 $vg2 $dev1 
-check_vg_field_ $vg2 max_lv 128 
+check vg_field $vg2 max_lv 128 
 vgremove $vg1 
 vgremove $vg2
 
@@ -129,7 +129,7 @@
 lvcreate -l 4 -n $lv1 $vg1 
 vgchange -an $vg1 
 vgsplit $vg1 $vg2 $dev1 
-compare_vg_field_ $vg1 $vg2 max_lv 
+check compare_vg_field $vg1 $vg2 max_lv 
 vgremove -f $vg2 
 vgremove -f $vg1
 
@@ -138,7 +138,7 @@
 lvcreate -l 4 -n $lv1 $vg1 
 vgchange -an $vg1 
 vgsplit $vg1 $vg2 $dev1 
-compare_vg_field_ $vg1 $vg2 max_pv 
+check compare_vg_field $vg1 $vg2 max_pv 
 vgremove -f $vg2 
 vgremove -f $vg1
 
@@ -147,7 +147,7 @@
 lvcreate -l 4 -n $lv1 $vg1 
 vgchange -an $vg1 
 vgsplit $vg1 $vg2 $dev1 
-compare_vg_field_ $vg1 $vg2 vg_fmt 
+check compare_vg_field $vg1 $vg2 vg_fmt 
 vgremove -f $vg2 
 vgremove -f $vg1
 
@@ -170,9 +170,9 @@
 vgcreate $vg1 $dev5 $dev2  
 lvcreate -l 10 -n $lv1  $vg1 
 lvchange -an $vg1/$lv1 
-vg_validate_pvlv_counts_ $vg1 2 1 0 
+check pvlv_counts $vg1 2 1 0 
 not vgsplit  $vg1 $vg2 $dev5;
-vg_validate_pvlv_counts_ $vg1 2 1 0 
+check pvlv_counts $vg1 2 1 0 
 vgremove -ff $vg1
 
 # vgsplit rejects split because metadata types differ
--- LVM2/test/api/percent.sh	2010/12/21 01:14:34	1.2
+++ LVM2/test/api/percent.sh	2011/01/05 00:16:21	1.3
@@ -11,13 +11,14 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
 
-. ./test-utils.sh
+. lib/test
+
 aux prepare_devs 2
-vgcreate -c n -s 4k $vg $devs
+vgcreate -c n -s 4k $vg $(cat DEVICES)
 lvcreate -n foo $vg -l 5
 lvcreate -s -n snap $vg/foo -l 2 -c 4k
 lvcreate -s -n snap2 $vg/foo -l 6 -c 4k
 dd if=/dev/urandom of=$DM_DEV_DIR/$vg/snap2 count=1 bs=1024
 lvcreate -m 1 -n mirr $vg -l 1 --mirrorlog core
 lvs
-apitest percent $vg
+aux apitest percent $vg
--- LVM2/test/api/vgtest.sh	2010/12/12 20:36:38	1.1
+++ LVM2/test/api/vgtest.sh	2011/01/05 00:16:21	1.2
@@ -12,7 +12,7 @@
 # tests lvm2app library
 #
 
-. ./test-utils.sh
+. lib/test
 aux prepare_devs 2
 pvcreate $dev1 $dev2
-apitest vgtest $vg1 $dev1 $dev2
+aux apitest vgtest $vg1 $dev1 $dev2
/cvs/lvm2/LVM2/test/lib/aux.sh,v  -->  standard output
revision 1.1
--- LVM2/test/lib/aux.sh
+++ -	2011-01-05 00:16:39.654010000 +0000
@@ -0,0 +1,367 @@
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/utils
+
+prepare_clvmd() {
+	if test -z "$LVM_TEST_LOCKING" || test "$LVM_TEST_LOCKING" -ne 3 ; then
+		return 0 # not needed
+	fi
+
+	if pgrep clvmd ; then
+		echo "Cannot use fake cluster locking with real clvmd ($(pgrep clvmd)) running."
+                touch SKIP_THIS_TEST
+		exit 1
+	fi
+
+	# skip if we don't have our own clvmd...
+	(which clvmd | grep $abs_builddir) || exit 200
+
+	# skip if we singlenode is not compiled in
+	(clvmd --help 2>&1 | grep "Available cluster managers" | grep singlenode) || exit 200
+
+	clvmd -Isinglenode -d 1 &
+	LOCAL_CLVMD="$!"
+
+	# check that it is really running now
+	sleep .1
+	ps $LOCAL_CLVMD || exit 200
+}
+
+prepare_dmeventd() {
+	if pgrep dmeventd ; then
+		echo "Cannot test dmeventd with real dmeventd ($(pgrep dmeventd)) running."
+                touch SKIP_THIS_TEST
+		exit 1
+	fi
+
+	# skip if we don't have our own dmeventd...
+	(which dmeventd | grep $abs_builddir) || exit 200
+
+	dmeventd -f &
+	echo "$!" > LOCAL_DMEVENTD
+}
+
+teardown_devs() {
+	test -n "$PREFIX" && {
+		rm -rf $TESTDIR/dev/$PREFIX*
+
+		init_udev_transaction
+		while dmsetup table | grep -q ^$PREFIX; do
+			for s in `dmsetup info -c -o name --noheading | grep ^$PREFIX`; do
+				umount -fl $DM_DEV_DIR/mapper/$s >& /dev/null || true
+				dmsetup remove $s >& /dev/null || true
+			done
+		done
+		finish_udev_transaction
+
+	}
+
+	# NOTE: SCSI_DEBUG_DEV test must come before the LOOP test because
+	# prepare_scsi_debug_dev() also sets LOOP to short-circuit prepare_loop()
+	if test -f SCSI_DEBUG_DEV; then
+		modprobe -r scsi_debug
+	else
+		test -f LOOP && losetup -d $(cat LOOP)
+		test -f LOOPFILE && rm -f $(cat LOOPFILE)
+	fi
+	rm -f DEVICES # devs is set in prepare_devs()
+	rm -f LOOP
+}
+
+teardown() {
+    echo -n "## teardown..."
+
+    test -n "$LOCAL_CLVMD" && {
+	kill "$LOCAL_CLVMD"
+	sleep .1
+	kill -9 "$LOCAL_CLVMD" || true
+    }
+
+    echo -n .
+
+    test -f LOCAL_DMEVENTD && kill -9 "$(cat LOCAL_DMEVENTD)"
+
+    echo -n .
+
+    teardown_devs
+
+    echo -n .
+
+    test -n "$TESTDIR" && {
+	cd $OLDPWD
+	rm -rf $TESTDIR || echo BLA
+    }
+
+    echo "ok"
+}
+
+make_ioerror() {
+	echo 0 10000000 error | dmsetup create ioerror
+	ln -s $DM_DEV_DIR/mapper/ioerror $DM_DEV_DIR/ioerror
+}
+
+prepare_loop() {
+	size=$1
+	test -n "$size" || size=32
+
+        echo -n "## preparing loop device..."
+
+	# skip if prepare_scsi_debug_dev() was used
+	if [ -f "SCSI_DEBUG_DEV" -a -f "LOOP" ]; then
+                echo "(skipped)"
+		return 0
+	fi
+
+	test ! -e LOOP
+	test -n "$DM_DEV_DIR"
+
+	for i in 0 1 2 3 4 5 6 7; do
+		test -e $DM_DEV_DIR/loop$i || mknod $DM_DEV_DIR/loop$i b 7 $i
+	done
+
+        echo -n .
+
+	LOOPFILE="$PWD/test.img"
+	dd if=/dev/zero of="$LOOPFILE" bs=$((1024*1024)) count=0 seek=$(($size-1)) 2> /dev/null
+	if LOOP=`losetup -s -f "$LOOPFILE" 2>/dev/null`; then
+		:
+	elif LOOP=`losetup -f` && losetup $LOOP "$LOOPFILE"; then
+		# no -s support
+		:
+	else
+		# no -f support 
+		# Iterate through $DM_DEV_DIR/loop{,/}{0,1,2,3,4,5,6,7}
+		for slash in '' /; do
+			for i in 0 1 2 3 4 5 6 7; do
+				local dev=$DM_DEV_DIR/loop$slash$i
+				! losetup $dev >/dev/null 2>&1 || continue
+				# got a free
+				losetup "$dev" "$LOOPFILE"
+				LOOP=$dev
+				break
+			done
+			if [ -n "$LOOP" ]; then 
+				break
+			fi
+		done
+	fi
+	test -n "$LOOP" # confirm or fail
+        echo "$LOOP" > LOOP
+        echo "ok ($LOOP)"
+}
+
+# A drop-in replacement for prepare_loop() that uses scsi_debug to create
+# a ramdisk-based SCSI device upon which all LVM devices will be created
+# - scripts must take care not to use a DEV_SIZE that will enduce OOM-killer
+prepare_scsi_debug_dev()
+{
+    local DEV_SIZE="$1"
+    shift
+    local SCSI_DEBUG_PARAMS="$@"
+
+    test -f "SCSI_DEBUG_DEV" && return 0
+    test -z "$LOOP"
+    test -n "$DM_DEV_DIR"
+
+    # Skip test if awk isn't available (required for get_sd_devs_)
+    which awk || exit 200
+
+    # Skip test if scsi_debug module is unavailable or is already in use
+    modprobe --dry-run scsi_debug || exit 200
+    lsmod | grep -q scsi_debug && exit 200
+
+    # Create the scsi_debug device and determine the new scsi device's name
+    # NOTE: it will _never_ make sense to pass num_tgts param;
+    # last param wins.. so num_tgts=1 is imposed
+    modprobe scsi_debug dev_size_mb=$DEV_SIZE $SCSI_DEBUG_PARAMS num_tgts=1 || exit 200
+    sleep 2 # allow for async Linux SCSI device registration
+
+    local DEBUG_DEV=/dev/$(grep -H scsi_debug /sys/block/*/device/model | cut -f4 -d /)
+    [ -b $DEBUG_DEV ] || exit 1 # should not happen
+
+    # Create symlink to scsi_debug device in $DM_DEV_DIR
+    SCSI_DEBUG_DEV="$DM_DEV_DIR/$(basename $DEBUG_DEV)"
+    echo "$SCSI_DEBUG_DEV" > SCSI_DEBUG_DEV
+    echo "$SCSI_DEBUG_DEV" > LOOP
+    # Setting $LOOP provides means for prepare_devs() override
+    ln -snf $DEBUG_DEV $SCSI_DEBUG_DEV
+    return 0
+}
+
+cleanup_scsi_debug_dev()
+{
+    aux teardown_devs
+    rm -f SCSI_DEBUG_DEV
+    rm -f LOOP
+}
+
+prepare_devs() {
+	local n="$1"
+	test -z "$n" && n=3
+	local devsize="$2"
+	test -z "$devsize" && devsize=34
+	local pvname="$3"
+	test -z "$pvname" && pvname="pv"
+
+	prepare_loop $(($n*$devsize))
+        echo -n "## preparing $n devices..."
+
+	if ! loopsz=`blockdev --getsz $LOOP 2>/dev/null`; then
+  		loopsz=`blockdev --getsize $LOOP 2>/dev/null`
+	fi
+
+	local size=$(($loopsz/$n))
+
+	init_udev_transaction
+	for i in `seq 1 $n`; do
+		local name="${PREFIX}$pvname$i"
+		local dev="$DM_DEV_DIR/mapper/$name"
+		devs="$devs $dev"
+		echo 0 $size linear $LOOP $((($i-1)*$size)) > $name.table
+		dmsetup create $name $name.table
+	done
+	finish_udev_transaction
+
+	#for i in `seq 1 $n`; do
+	#	local name="${PREFIX}$pvname$i"
+	#	dmsetup info -c $name
+	#done
+	#for i in `seq 1 $n`; do
+	#	local name="${PREFIX}$pvname$i"
+	#	dmsetup table $name
+	#done
+
+        echo $devs > DEVICES
+        echo "ok"
+}
+
+disable_dev() {
+
+	init_udev_transaction
+	for dev in "$@"; do
+        # first we make the device inaccessible
+		echo 0 10000000 error | dmsetup load $dev
+		dmsetup resume $dev
+        # now let's try to get rid of it if it's unused
+        #dmsetup remove $dev
+	done
+	finish_udev_transaction
+
+}
+
+enable_dev() {
+
+	init_udev_transaction
+	for dev in "$@"; do
+		local name=`echo "$dev" | sed -e 's,.*/,,'`
+		dmsetup create $name $name.table || dmsetup load $name $name.table
+		dmsetup resume $dev
+	done
+	finish_udev_transaction
+}
+
+backup_dev() {
+	for dev in "$@"; do
+		dd if=$dev of=$dev.backup bs=1024
+	done
+}
+
+restore_dev() {
+	for dev in "$@"; do
+		test -e $dev.backup || {
+			echo "Internal error: $dev not backed up, can't restore!"
+			exit 1
+		}
+		dd of=$dev if=$dev.backup bs=1024
+	done
+}
+
+prepare_pvs() {
+	prepare_devs "$@"
+	pvcreate -ff $devs
+}
+
+prepare_vg() {
+	vgremove -ff $vg >& /dev/null || true
+	teardown_devs
+
+	prepare_pvs "$@"
+	vgcreate -c n $vg $devs
+	#pvs -v
+}
+
+lvmconf() {
+    if test -z "$LVM_TEST_LOCKING"; then LVM_TEST_LOCKING=1; fi
+    test -f CONFIG_VALUES || {
+        cat > CONFIG_VALUES <<-EOF
+devices/dir = "$DM_DEV_DIR"
+devices/scan = "$DM_DEV_DIR"
+devices/filter = [ "a/dev\/mirror/", "a/dev\/mapper\/.*pv[0-9_]*$/", "r/.*/" ]
+devices/cache_dir = "$TESTDIR/etc"
+devices/sysfs_scan = 0
+devices/default_data_alignment = 1
+log/syslog = 0
+log/indent = 1
+log/level = 9
+log/file = "$TESTDIR/debug.log"
+log/overwrite = 1
+log/activation = 1
+backup/backup = 0
+backup/archive = 0
+global/abort_on_internal_errors = 1
+global/library_dir = "$TESTDIR/lib"
+global/locking_dir = "$TESTDIR/var/lock/lvm"
+global/locking_type=$LVM_TEST_LOCKING
+global/si_unit_consistency = 1
+global/fallback_to_local_locking = 0
+activation/udev_sync = 1
+activation/udev_rules = 1
+activation/polling_interval = 0
+activation/snapshot_autoextend_percent = 50
+activation/snapshot_autoextend_threshold = 50
+EOF
+    }
+
+    for v in "$@"; do
+        echo "$v" >> CONFIG_VALUES
+    done
+
+    rm -f CONFIG
+    for s in `cat CONFIG_VALUES | cut -f1 -d/ | sort | uniq`; do
+        echo "$s {" >> CONFIG
+        for k in `grep ^$s/ CONFIG_VALUES | cut -f1 -d= | sed -e 's, *$,,' | sort | uniq`; do
+            grep "^$k" CONFIG_VALUES | tail -n 1 | sed -e "s,^$s/,    ," >> CONFIG
+        done
+        echo "}" >> CONFIG
+        echo >> CONFIG
+    done
+    mv -f CONFIG $TESTDIR/etc/lvm.conf
+}
+
+apitest() {
+	t=$1
+        shift
+	test -x $abs_top_builddir/test/api/$t.t || {
+            touch SKIP_THIS_TEST
+            exit 200
+        }
+	$abs_top_builddir/test/api/$t.t "$@"
+}
+
+api() {
+	test -x $abs_top_builddir/test/api/wrapper || exit 200
+	$abs_top_builddir/test/api/wrapper "$@"
+}
+
+test -f DEVICES && devs=$(cat DEVICES)
+test -f LOOP && LOOP=$(cat LOOP)
+
+"$@"
/cvs/lvm2/LVM2/test/lib/check.sh,v  -->  standard output
revision 1.1
--- LVM2/test/lib/check.sh
+++ -	2011-01-05 00:16:39.767535000 +0000
@@ -0,0 +1,281 @@
+#!/bin/bash
+
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# check.sh: assert various things about volumes
+
+# USAGE
+#  check linear VG LV
+#  check lv_on VG LV PV
+
+#  check mirror VG LV [LOGDEV|core]
+#  check mirror_nonredundant VG LV
+#  check mirror_legs VG LV N
+#  check mirror_images_on VG LV DEV [DEV...]
+
+# ...
+
+set -e -o pipefail
+
+trim()
+{
+    trimmed=${1%% }
+    trimmed=${trimmed## }
+
+    echo "$trimmed"
+}
+
+lvl() {
+	lvs -a --noheadings "$@"
+}
+
+lvdevices() {
+	lvl -odevices "$@" | sed 's/([^)]*)//g; s/,/ /g'
+}
+
+mirror_images_redundant()
+{
+  vg=$1
+  lv=$vg/$2
+
+  lvs -a $vg -o+devices
+  for i in `lvdevices $lv`; do
+	  echo "# $i:"
+	  lvdevices $vg/$i | sort | uniq
+  done > check.tmp.all
+
+  (grep -v ^# check.tmp.all || true) | sort | uniq -d > check.tmp
+
+  test "`cat check.tmp | wc -l`" -eq 0 || {
+	  echo "mirror images of $lv expected redundant, but are not:"
+	  cat check.tmp.all
+	  exit 1
+  }
+}
+
+mirror_images_on() {
+	vg=$1
+	lv=$2
+
+	shift 2
+
+	for i in `lvdevices $lv`; do
+		lv_on $vg $lv $1
+		shift
+	done
+}
+
+lv_on()
+{
+	lv="$1/$2"
+	lvdevices $lv | grep -F "$3" || {
+		echo "LV $lv expected on $3 but is not:" >&2
+		lvdevices $lv >&2
+		exit 1
+	}
+	test `lvdevices $lv | grep -vF "$3" | wc -l` -eq 0 || {
+		echo "LV $lv contains unexpected devices:" >&2
+		lvdevices $lv >&2
+		exit 1
+	}
+}
+
+mirror_log_on()
+{
+	vg="$1"
+	lv="$2"
+	where="$3"
+	if test "$where" = "core"; then
+		lvl -omirror_log "$vg/$lv" | not grep mlog
+	else
+		lv_on $vg "${lv}_mlog" "$where"
+	fi
+}
+
+lv_is_contiguous()
+{
+	test `lvl --segments $1 | wc -l` -eq 1 || {
+		echo "LV $1 expected to be contiguous, but is not:"
+		lvl --segments $1
+		exit 1
+	}
+}
+
+lv_is_clung()
+{
+	test `lvdevices $1 | sort | uniq | wc -l` -eq 1 || {
+		echo "LV $1 expected to be clung, but is not:"
+		lvdevices $! | sort | uniq
+		exit 1
+	}
+}
+
+mirror_images_contiguous()
+{
+	for i in `lvdevices $1/$2`; do
+		lv_is_contiguous $1/$i
+	done
+}
+
+mirror_images_clung()
+{
+	for i in `lvdevices $1/$2`; do
+		lv_is_clung $1/$i
+	done
+}
+
+mirror() {
+	mirror_nonredundant "$@"
+	mirror_images_redundant "$1" "$2"
+}
+
+mirror_nonredundant() {
+	lv="$1/$2"
+	lvs -oattr "$lv" | grep -q "^ *m.....$" || {
+		echo "$lv expected a mirror, but is not:"
+		lvs -a $lv
+		exit 1
+	}
+	if test -n "$3"; then mirror_log_on "$1" "$2" "$3"; fi
+}
+
+mirror_legs() {
+	lv="$1/$2"
+	expect="$3"
+	lvdevices "$lv"
+	real=`lvdevices "$lv" | wc -w`
+	test "$expect" = "$real"
+}
+
+mirror_no_temporaries()
+{
+	vg=$1
+	lv=$2
+	lvl -oname $vg | grep $lv | not grep "tmp" || {
+		echo "$lv has temporary mirror images unexpectedly:"
+		lvl $vg | grep $lv
+		exit 1
+	}
+}
+
+linear() {
+	lv="$1/$2"
+	lvl -ostripes "$lv" | grep -q "1" || {
+		echo "$lv expected linear, but is not:"
+		lvl "$lv" -o+devices
+		exit 1
+	}
+}
+
+active() {
+	lv="$1/$2"
+	lvl -oattr "$lv" 2> /dev/null | grep -q "^ *....a.$" || {
+		echo "$lv expected active, but lvs says it's not:"
+		lvl "$lv" -o+devices 2>/dev/null
+		exit 1
+	}
+	dmsetup table | egrep -q "$1-$2: *[^ ]+" || {
+		echo "$lv expected active, lvs thinks it is but there are no mappings!"
+		dmsetup table | grep $1-$2:
+		exit 1
+	}
+}
+
+inactive() {
+	lv="$1/$2"
+	lvl -oattr "$lv" 2> /dev/null | grep -q '^ *....[-isd].$' || {
+		echo "$lv expected inactive, but lvs says it's not:"
+		lvl "$lv" -o+devices 2>/dev/null
+		exit 1
+	}
+	dmsetup table | not egrep -q "$1-$2: *[^ ]+" || {
+		echo "$lv expected inactive, lvs thinks it is but there are mappings!"
+		dmsetup table | grep $1-$2:
+		exit 1
+	}
+}
+
+pv_field()
+{
+    actual=$(trim $(pvs --noheadings $4 -o $2 $1))
+
+    test "$actual" = "$3" || {
+        echo "pv_field: PV=$1, field=$2, actual=$actual, expected=$3"
+        exit 1
+    }
+}
+
+vg_field()
+{
+    actual=$(trim $(vgs --noheadings $4 -o $2 $1))
+    test "$actual" = "$3" || {
+        echo "vg_field: vg=$1, field=$2, actual=$actual, expected=$3"
+        exit 1
+    }
+}
+
+lv_field()
+{
+    actual=$(trim $(lvs --noheadings $4 -o $2 $1))
+    test "$actual" = "$3" || {
+        echo "lv_field: lv=$1, field=$2, actual=$actual, expected=$3"
+        exit 1
+    }
+}
+
+compare_fields()
+{
+    local cmd1=$1;
+    local obj1=$2;
+    local field1=$3;
+    local cmd2=$4;
+    local obj2=$5;
+    local field2=$6;
+    local val1;
+    local val2;
+
+    val1=$($cmd1 --noheadings -o $field1 $obj1)
+    val2=$($cmd2 --noheadings -o $field2 $obj2)
+    test "$val1" = "$val2" || {
+        echo "compare_fields $obj1($field1): $val1 $obj2($field2): $val2"
+        exit 1
+    }
+}
+
+compare_vg_field()
+{
+    local vg1=$1;
+    local vg2=$2;
+    local field=$3;
+
+    val1=$(vgs --noheadings -o $field $vg1)
+    val2=$(vgs --noheadings -o $field $vg2)
+    test "$val1" = "$val2" || {
+        echo "compare_vg_field: $vg1: $val1, $vg2: $val2"
+        exit 1
+    }
+}
+
+pvlv_counts()
+{
+	local local_vg=$1
+	local num_pvs=$2
+	local num_lvs=$3
+	local num_snaps=$4
+
+	lvs -a -o+devices $local_vg
+
+	vg_field $local_vg pv_count $num_pvs
+	vg_field $local_vg lv_count $num_lvs
+	vg_field $local_vg snap_count $num_snaps
+}
+
+"$@"
/cvs/lvm2/LVM2/test/lib/get.sh,v  -->  standard output
revision 1.1
--- LVM2/test/lib/get.sh
+++ -	2011-01-05 00:16:39.910727000 +0000
@@ -0,0 +1,23 @@
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+pv_field() {
+	pvs --noheading -o $2 $1 | sed 's/^ *//'
+}
+
+vg_field() {
+	vgs --noheading -o $2 $1 | sed 's/^ *//'
+}
+
+lv_field() {
+	lvs --noheading -o $2 $1 | sed 's/^ *//'
+}
+
+"$@"
/cvs/lvm2/LVM2/test/lib/harness.c,v  -->  standard output
revision 1.1
--- LVM2/test/lib/harness.c
+++ -	2011-01-05 00:16:40.027256000 +0000
@@ -0,0 +1,284 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include <fcntl.h>
+#include <string.h>
+#include <stdio.h>
+#include <sys/socket.h>
+#include <sys/wait.h>
+#include <unistd.h>
+#include <stdlib.h>
+
+pid_t pid;
+int fds[2];
+
+#define MAX 1024
+
+struct stats {
+	int nfailed;
+	int nskipped;
+	int npassed;
+	int nwarned;
+	int status[MAX];
+};
+
+struct stats s;
+
+char *readbuf = NULL;
+int readbuf_sz = 0, readbuf_used = 0;
+
+int die = 0;
+int verbose = 0;
+int verbose_off = 0;
+
+struct subst {
+        char *key;
+        char *value;
+};
+
+struct subst subst[2];
+
+char *TESTDIR = NULL;
+char *PREFIX = NULL;
+
+#define PASSED 0
+#define SKIPPED 1
+#define FAILED 2
+#define WARNED 3
+
+void handler( int s ) {
+	signal( s, SIG_DFL );
+	kill( pid, s );
+	die = s;
+}
+
+int outline(char *buf, int start, int force) {
+        char *from = buf + start;
+        char *next = strchr(buf + start, '\n');
+
+        if (!next && !force) /* not a complete line yet... */
+                return start;
+
+        if (!next)
+                next = from + strlen(from);
+        else
+                ++next;
+
+        if (!strncmp(from, "@TESTDIR=", 9)) {
+                subst[0].key = "@TESTDIR@";
+                subst[0].value = strndup(from + 9, next - from - 9 - 1);
+        } else if (!strncmp(from, "@PREFIX=", 8)) {
+                subst[1].key = "@PREFIX@";
+                subst[1].value = strndup(from + 8, next - from - 8 - 1);
+        } else {
+                char *line = strndup(from, next - from);
+                char *a = line, *b;
+                do {
+                        b = line + strlen(line);
+                        int idx = -1;
+                        int i;
+                        for ( i = 0; i < 2; ++i ) {
+                                if (subst[i].key) {
+                                        // printf("trying: %s -> %s\n", subst[i].value, subst[i].key);
+                                        char *stop = strstr(a, subst[i].value);
+                                        if (stop && stop < b) {
+                                                idx = i;
+                                                b = stop;
+                                        }
+                                }
+                        }
+                        fwrite(a, 1, b - a, stdout);
+                        a = b;
+
+                        if ( idx >= 0 ) {
+                                fprintf(stdout, "%s", subst[idx].key);
+                                a += strlen(subst[idx].value);
+                        }
+                } while (b < line + strlen(line));
+                free(line);
+        }
+
+        return next - buf + (force ? 0 : 1);
+}
+
+void dump() {
+        int counter = 0;
+
+        while ( counter < readbuf_used )
+                counter = outline( readbuf, counter, 1 );
+}
+
+void clear() {
+	readbuf_used = 0;
+}
+
+void drain() {
+	int sz;
+	char buf[2048];
+        memset(buf, 0, 2048);
+
+	while (1) {
+		sz = read(fds[1], buf, 2047);
+		if (verbose)
+			write(1, buf, sz);
+		if (sz <= 0)
+			return;
+		if (readbuf_used + sz >= readbuf_sz) {
+			readbuf_sz = readbuf_sz ? 2 * readbuf_sz : 4096;
+			readbuf = realloc(readbuf, readbuf_sz);
+		}
+		if (!readbuf)
+			exit(205);
+		memcpy(readbuf + readbuf_used, buf, sz);
+		readbuf_used += sz;
+		readbuf[readbuf_used] = 0;
+	}
+}
+
+void passed(int i, char *f) {
+	if (strstr(readbuf, "TEST WARNING")) {
+		++s.nwarned;
+		s.status[i] = WARNED;
+		printf("warnings\n");
+	} else {
+		++ s.npassed;
+		s.status[i] = PASSED;
+		printf("passed.\n");
+	}
+}
+
+void skipped(int i, char *f) {
+	++ s.nskipped;
+	s.status[i] = SKIPPED;
+	printf("skipped.\n");
+}
+
+void failed(int i, char *f, int st) {
+	++ s.nfailed;
+	s.status[i] = FAILED;
+	if(die == 2) {
+		printf("interrupted.\n");
+		return;
+	}
+	printf("FAILED.\n");
+	printf("-- FAILED %s ------------------------------------\n", f);
+	dump();
+	printf("-- FAILED %s (end) ------------------------------\n", f);
+}
+
+void run(int i, char *f) {
+	pid = fork();
+	if (pid < 0) {
+		perror("Fork failed.");
+		exit(201);
+	} else if (pid == 0) {
+		close(0);
+		dup2(fds[0], 1);
+		dup2(fds[0], 2);
+                close(fds[0]);
+                close(fds[1]);
+		execlp("bash", "bash", f, NULL);
+		perror("execlp");
+		fflush(stderr);
+		_exit(202);
+	} else {
+		char buf[128];
+		snprintf(buf, 128, "%s ...", f);
+		buf[127] = 0;
+		printf("Running %-40s ", buf);
+		fflush(stdout);
+		int st, w;
+		while ((w = waitpid(pid, &st, WNOHANG)) == 0) {
+			drain();
+			usleep(20000);
+		}
+		if (w != pid) {
+			perror("waitpid");
+			exit(206);
+		}
+		drain();
+		if (WIFEXITED(st)) {
+			if (WEXITSTATUS(st) == 0) {
+				passed(i, f);
+			} else if (WEXITSTATUS(st) == 200) {
+				skipped(i, f);
+			} else {
+				failed(i, f, st);
+			}
+		} else {
+			failed(i, f, st);
+		}
+		clear();
+	}
+}
+
+int main(int argc, char **argv) {
+	int i;
+
+	if (argc >= MAX) {
+		fprintf(stderr, "Sorry, my head exploded. Please increase MAX.\n");
+		exit(1);
+	}
+
+	s.nwarned = s.nfailed = s.npassed = s.nskipped = 0;
+
+	char *be_verbose = getenv("VERBOSE");
+	if (be_verbose && atoi(be_verbose))
+		verbose = 1; // XXX
+
+	if (socketpair(PF_UNIX, SOCK_STREAM, 0, fds)) {
+		perror("socketpair");
+		return 201;
+	}
+
+        if ( fcntl( fds[1], F_SETFL, O_NONBLOCK ) == -1 ) {
+		perror("fcntl on socket");
+		return 202;
+	}
+
+	/* set up signal handlers */
+        for (i = 0; i <= 32; ++i) {
+            if (i == SIGCHLD || i == SIGWINCH || i == SIGURG)
+                continue;
+            signal(i, handler);
+        }
+
+	/* run the tests */
+	for (i = 1; i < argc; ++ i) {
+		run(i, argv[i]);
+		if (die)
+			break;
+	}
+
+	printf("\n## %d tests: %d OK, %d warnings, %d failures; %d skipped\n",
+	       s.nwarned + s.npassed + s.nfailed + s.nskipped,
+	       s.npassed, s.nwarned, s.nfailed, s.nskipped);
+
+	/* print out a summary */
+	if (s.nfailed || s.nskipped) {
+		for (i = 1; i < argc; ++ i) {
+			switch (s.status[i]) {
+			case FAILED:
+				printf("FAILED: %s\n", argv[i]);
+				break;
+			case SKIPPED:
+				printf("skipped: %s\n", argv[i]);
+				break;
+			}
+		}
+		printf("\n");
+		return s.nfailed > 0 || die;
+	}
+	return die;
+}
/cvs/lvm2/LVM2/test/lib/lvm-wrapper.sh,v  -->  standard output
revision 1.1
--- LVM2/test/lib/lvm-wrapper.sh
+++ -	2011-01-05 00:16:40.332200000 +0000
@@ -0,0 +1,7 @@
+#!/bin/sh
+
+. lib/paths
+cmd=$(echo ./$0|sed "s,.*/,,")
+
+test "$cmd" = lvm && exec "$abs_top_builddir/tools/lvm" "$@"
+exec "$abs_top_builddir/tools/lvm" "$cmd" "$@"
/cvs/lvm2/LVM2/test/lib/not.c,v  -->  standard output
revision 1.1
--- LVM2/test/lib/not.c
+++ -	2011-01-05 00:16:40.553031000 +0000
@@ -0,0 +1,65 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include <unistd.h>
+#include <stdio.h>
+#include <stdarg.h>
+#include <sys/types.h>
+#include <sys/wait.h>
+
+int finished(const char *cmd, int status) {
+	if (!strcmp(cmd, "not"))
+		return !status;
+	if (!strcmp(cmd, "should")) {
+		if (status)
+			fprintf(stderr, "TEST WARNING: Ignoring command failure.\n");
+		return 0;
+	}
+	return 6;
+}
+
+int main(int args, char **argv) {
+	pid_t pid;
+	int status;
+	int FAILURE = 6;
+
+	if (args < 2) {
+		fprintf(stderr, "Need args\n");
+		return FAILURE;
+	}
+
+	pid = fork();
+	if (pid == -1) {
+		fprintf(stderr, "Could not fork\n");
+		return FAILURE;
+	} else if (pid == 0) { 	/* child */
+		execvp(argv[1], &argv[1]);
+		/* should not be accessible */
+		return FAILURE;
+	} else {		/* parent */
+		waitpid(pid, &status, 0);
+		if (!WIFEXITED(status)) {
+			if (WIFSIGNALED(status))
+				fprintf(stderr,
+					"Process %d died of signal %d.\n",
+					pid, WTERMSIG(status));
+			/* did not exit correctly */
+			return FAILURE;
+		}
+
+		return finished(argv[0], WEXITSTATUS(status));
+	}
+	/* not accessible */
+	return FAILURE;
+}
/cvs/lvm2/LVM2/test/lib/test.sh,v  -->  standard output
revision 1.1
--- LVM2/test/lib/test.sh
+++ -	2011-01-05 00:16:40.981486000 +0000
@@ -0,0 +1,55 @@
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# sanitize the environment
+LANG=C
+LC_ALL=C
+TZ=UTC
+
+unset CDPATH
+
+# grab some common utilities
+. lib/utils
+
+OLDPWD="`pwd`"
+PREFIX="LVMTEST$$"
+
+TESTDIR=$($abs_srcdir/mkdtemp ${LVM_TEST_DIR-$(pwd)} $PREFIX.XXXXXXXXXX) \
+	|| { echo "failed to create temporary directory in ${LVM_TEST_DIR-$(pwd)}"; exit 1; }
+
+export PREFIX
+export TESTDIR
+
+trap 'set +vx; STACKTRACE; set -vx' ERR
+trap 'aux teardown' EXIT # don't forget to clean up
+
+export LVM_SYSTEM_DIR=$TESTDIR/etc
+export DM_DEV_DIR=$TESTDIR/dev
+mkdir $LVM_SYSTEM_DIR $DM_DEV_DIR $DM_DEV_DIR/mapper $TESTDIR/lib
+
+cd $TESTDIR
+
+for i in `find $abs_top_builddir/daemons/dmeventd/plugins/ -name \*.so`; do
+	#echo Setting up symlink from $i to $TESTDIR/lib
+	ln -s $i $TESTDIR/lib
+done
+
+ln -s $abs_top_builddir/test/lib/* $TESTDIR/lib
+
+# re-do the utils now that we have TESTDIR/PREFIX/...
+. lib/utils
+
+set -eE -o pipefail
+aux lvmconf
+aux prepare_clvmd
+echo "@TESTDIR=$TESTDIR"
+echo "@PREFIX=$PREFIX"
+
+set -vx
/cvs/lvm2/LVM2/test/lib/utils.sh,v  -->  standard output
revision 1.1
--- LVM2/test/lib/utils.sh
+++ -	2011-01-05 00:16:41.135555000 +0000
@@ -0,0 +1,80 @@
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+set -e
+
+STACKTRACE() {
+    trap - ERR;
+    i=0;
+
+    while FUNC=${FUNCNAME[$i]}; test "$FUNC" != "main"; do 
+	echo "## $i ${FUNC}() called from ${BASH_SOURCE[$i]}:${BASH_LINENO[$i]}"
+	i=$(($i + 1));
+    done
+
+    # Get backtraces from coredumps
+    if which gdb >& /dev/null; then
+	echo bt full > gdb_commands.txt
+	echo l >> gdb_commands.txt
+	echo quit >> gdb_commands.txt
+	for core in `ls core* 2>/dev/null`; do
+	    bin=$(gdb -batch -c $core 2>&1 | grep "generated by" | \
+		sed -e "s,.*generated by \`\([^ ']*\).*,\1,")
+	    gdb -batch -c $core -x gdb_commands.txt `which $bin`
+	done
+    fi
+
+    test -z "$LVM_TEST_NODEBUG" && test -f debug.log && {
+	sed -e "s,^,## DEBUG: ,;s,$top_srcdir/\?,," < debug.log
+    }
+
+    test -f SKIP_THIS_TEST && exit 200
+}
+
+init_udev_transaction() {
+    if test "$DM_UDEV_SYNCHRONISATION" = 1; then
+	COOKIE=$(dmsetup udevcreatecookie)
+	# Cookie is not generated if udev is not running!
+	if test -n "$COOKIE"; then
+	    export DM_UDEV_COOKIE=$COOKIE
+	fi
+    fi
+}
+
+finish_udev_transaction() {
+    if test "$DM_UDEV_SYNCHRONISATION" = 1 -a -n "$DM_UDEV_COOKIE"; then
+	dmsetup udevreleasecookie
+	unset DM_UDEV_COOKIE
+    fi
+}
+
+. lib/paths || { echo >&2 you must run make first; exit 1; }
+
+PATH=$abs_top_builddir/test/lib:$PATH
+LIBDIRS="libdm tools liblvm daemons/dmeventd daemons/dmeventd/plugins/lvm2 \
+         daemons/dmeventd/plugins/mirror daemons/dmeventd/plugins/snapshot"
+
+for d in $LIBDIRS; do
+    LD_LIBRARY_PATH=$abs_top_builddir/$d:$LD_LIBRARY_PATH
+done
+export LD_LIBRARY_PATH
+
+if test -n "$PREFIX"; then
+    vg=${PREFIX}vg
+    lv=LV
+
+    for i in `seq 1 16`; do
+        name="${PREFIX}pv$i"
+        dev="$DM_DEV_DIR/mapper/$name"
+        eval "dev$i=$dev"
+        eval "lv$i=LV$i"
+        eval "vg$i=${PREFIX}vg$i"
+    done
+fi


