From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 6 Apr 2010 09:54:13 -0000
Subject: LVM2 Makefile.in make.tmpl.in
Message-ID: <20100406095413.8894.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-04-06 09:54:11

Modified files:
	.              : Makefile.in make.tmpl.in 

Log message:
	Distcleanup config files only in toplevel directory.
	Do not execute 'rm -r' with empty $(DISTCLEAN_DIRS).
	lvm-version.h is already cleaned with subtarget distcleaning.
	Always distcleanup lcov_reports*.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.86&r2=1.87

--- LVM2/Makefile.in	2010/04/06 09:50:07	1.48
+++ LVM2/Makefile.in	2010/04/06 09:54:11	1.49
@@ -37,8 +37,9 @@
   SUBDIRS = doc include man scripts \
     lib tools daemons libdm \
     udev po liblvm test/api test
-  DISTCLEAN_DIRS += lcov_reports*
 endif
+DISTCLEAN_DIRS += lcov_reports*
+DISTCLEAN_TARGETS += config.cache config.log config.status make.tmpl
 
 include make.tmpl
 
--- LVM2/make.tmpl.in	2010/03/29 14:18:00	1.86
+++ LVM2/make.tmpl.in	2010/04/06 09:54:11	1.87
@@ -306,11 +306,8 @@
 	$(SOURCES2:%.c=%.o) $(SOURCES2:%.c=%.d) $(SOURCES2:%.c=%.gcno) $(SOURCES2:%.c=%.gcda)
 
 distclean: clean $(SUBDIRS.distclean)
-	$(RM) -r $(DISTCLEAN_DIRS)
-	$(RM) $(DISTCLEAN_TARGETS)  \
-	      config.cache config.log config.status \
-	      Makefile make.tmpl core \
-	      lvm-version.h
+	test -z "$(DISTCLEAN_DIRS)" || $(RM) -r $(DISTCLEAN_DIRS)
+	$(RM) $(DISTCLEAN_TARGETS) Makefile core
 
 .export.sym: .exported_symbols
 	set -e; (echo "Base {"; echo "	global:"; \


