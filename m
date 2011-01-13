From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Jan 2011 14:59:00 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20110113145900.14465.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-13 14:58:59

Modified files:
	test           : Makefile.in 

Log message:
	Include default make.tmpl
	
	Use default clean targets for this Makefile
	Use also same build flags for compiling testing tools like harness.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.51&r2=1.52

--- LVM2/test/Makefile.in	2011/01/07 12:26:02	1.51
+++ LVM2/test/Makefile.in	2011/01/13 14:58:59	1.52
@@ -24,6 +24,7 @@
 abs_builddir = @abs_builddir@
 abs_top_builddir = @abs_top_builddir@
 abs_top_srcdir = @abs_top_srcdir@
+include $(top_builddir)/make.tmpl
 
 T ?= .
 S ?= @ # never match anything by default
@@ -59,7 +60,7 @@
 	ln -sf not lib/should
 
 lib/%: $(srcdir)/lib/%.c .lib-dir-stamp
-	$(CC) -o $@ $<
+	$(CC) $(DEFS) $(CFLAGS) -o $@ $<
 
 lib/%: $(srcdir)/lib/%.sh .lib-dir-stamp
 	cp $< $@
@@ -100,13 +101,9 @@
 	touch $@
 
 clean:
-	rm -rf bin .lib-dir-stamp .test-stamp
-	rm -f $(LIB)
-	rm -f lib/dmsetup lib/clvmd lib/dmeventd
 	for i in lvm $$(cat ../tools/.commands); do rm -f lib/$$i; done
 	if test "$(srcdir)" != . ; then rm -f $(subst $(srcdir)/, ,$(RUN)) lvm2app.sh ; fi
 
-distclean: clean
-	rm -f Makefile
+CLEAN_TARGETS += .lib-dir-stamp .test-stamp -f $(LIB) lib/dmsetup lib/clvmd lib/dmeventd
 
 .NOTPARALLEL:


