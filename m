From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Mar 2010 14:09:27 -0000
Subject: LVM2 ./Makefile.in ./make.tmpl.in daemons/Make ...
Message-ID: <20100329140927.17958.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-29 14:09:26

Modified files:
	.              : Makefile.in make.tmpl.in 
	daemons        : Makefile.in 
	lib            : Makefile.in 

Log message:
	distclean fixes
	
	Move daemons/ and lib/ subtargets to their Makefiles so we don't get
	double cleanup error during execution of distclean target.
	Instead of duplicating clean target inside distclean target,
	just use it as a subtarget and avoid add duplicating code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.83&r2=1.84
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/Makefile.in.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.97&r2=1.98

--- LVM2/Makefile.in	2010/03/29 14:07:56	1.44
+++ LVM2/Makefile.in	2010/03/29 14:09:25	1.45
@@ -34,16 +34,7 @@
 endif
 
 ifeq ($(MAKECMDGOALS),distclean)
-  SUBDIRS += daemons/clvmd \
-	     daemons/cmirrord \
-	     daemons/dmeventd/plugins \
-	     daemons/dmeventd \
-	     lib/format1 \
-	     lib/format_pool \
-	     lib/locking \
-	     lib/mirror \
-	     lib/snapshot \
-	     liblvm \
+  SUBDIRS += liblvm \
 	     udev \
 	     test/api \
 	     test \
--- LVM2/make.tmpl.in	2010/03/04 12:12:34	1.83
+++ LVM2/make.tmpl.in	2010/03/29 14:09:25	1.84
@@ -257,12 +257,9 @@
 	      $(SOURCES2:%.c=%.d) $(SOURCES:%.c=%.pot) $(SOURCES:%.c=%.gcno) \
 	      $(SOURCES:%.c=%.gcda) $(LDDEPS)
 
-distclean: $(SUBDIRS.distclean)
+distclean: clean $(SUBDIRS.distclean)
 	$(RM) -rf $(DISTCLEAN_DIRS)
-	$(RM) $(DISTCLEAN_TARGETS) \
-	      $(OBJECTS) $(TARGETS) $(CLEAN_TARGETS) $(SOURCES:%.c=%.d) \
-	      $(SOURCES2:%.c=%.d) $(SOURCES:%.c=%.pot) $(SOURCES:%.c=%.gcno) \
-	      $(SOURCES:%.c=%.gcda) $(LDDEPS) \
+	$(RM) $(DISTCLEAN_TARGETS)  \
 	      config.cache config.log config.status \
 	      Makefile make.tmpl core \
 	      lvm-version.h
--- LVM2/daemons/Makefile.in	2010/03/04 09:51:37	1.13
+++ LVM2/daemons/Makefile.in	2010/03/29 14:09:25	1.14
@@ -30,6 +30,10 @@
   SUBDIRS += dmeventd
 endif
 
+ifeq ($(MAKECMDGOALS),distclean)
+  SUBDIRS = clvmd cmirrord dmeventd
+endif
+
 include $(top_builddir)/make.tmpl
 
 ifeq ("@BUILD_DMEVENTD@", "yes")
--- LVM2/lib/Makefile.in	2010/03/04 09:51:39	1.97
+++ LVM2/lib/Makefile.in	2010/03/29 14:09:26	1.98
@@ -152,6 +152,15 @@
 
 CLEAN_TARGETS += $(LIB_NAME).cflow
 
+ifeq ($(MAKECMDGOALS),distclean)
+  SUBDIRS =\
+	format1 \
+	format_pool \
+	snapshot \
+	mirror \
+	locking
+endif
+
 include $(top_builddir)/make.tmpl
 
 $(SUBDIRS): $(LIB_STATIC)


