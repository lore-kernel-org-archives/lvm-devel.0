From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 11 Sep 2009 15:52:24 -0000
Subject: LVM2 ./WHATS_NEW_DM ./make.tmpl.in tools/Makef ...
Message-ID: <20090911155224.8624.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-09-11 15:52:23

Modified files:
	.              : WHATS_NEW_DM make.tmpl.in 
	tools          : Makefile.in 

Log message:
	Fix Makefile to take into account dmsetup's reconfiguration.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.295&r2=1.296
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.70&r2=1.71
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.98&r2=1.99

--- LVM2/WHATS_NEW_DM	2009/09/03 21:51:26	1.295
+++ LVM2/WHATS_NEW_DM	2009/09/11 15:52:22	1.296
@@ -1,5 +1,6 @@
 Version 1.02.37 -
 =================================
+  Fix Makefile to take into account dmsetup's reconfiguration.
   Restore umask when device node creation fails.
   Fix mirror table CTR code to handle 'block_on_error' and 'cluster' features
 
--- LVM2/make.tmpl.in	2009/09/01 18:11:14	1.70
+++ LVM2/make.tmpl.in	2009/09/11 15:52:22	1.71
@@ -239,14 +239,14 @@
 
 clean: $(SUBDIRS.clean)
 	$(RM) $(OBJECTS) $(TARGETS) $(CLEAN_TARGETS) $(SOURCES:%.c=%.d) \
-	      $(SOURCES:%.c=%.pot) $(SOURCES:%.c=%.gcno) \
+	      $(SOURCES2:%.c=%.d) $(SOURCES:%.c=%.pot) $(SOURCES:%.c=%.gcno) \
 	      $(SOURCES:%.c=%.gcda) $(LDDEPS)
 
 distclean: $(SUBDIRS.distclean)
 	$(RM) -rf $(DISTCLEAN_DIRS)
 	$(RM) $(DISTCLEAN_TARGETS) \
 	      $(OBJECTS) $(TARGETS) $(CLEAN_TARGETS) $(SOURCES:%.c=%.d) \
-	      $(SOURCES:%.c=%.pot) $(SOURCES:%.c=%.gcno) \
+	      $(SOURCES2:%.c=%.d) $(SOURCES:%.c=%.pot) $(SOURCES:%.c=%.gcno) \
 	      $(SOURCES:%.c=%.gcda) $(LDDEPS) \
 	      config.cache config.log config.status \
 	      Makefile make.tmpl core \
@@ -262,6 +262,9 @@
     ifdef SOURCES
        -include $(SOURCES:.c=.d)
     endif
+    ifdef SOURCES2
+       -include $(SOURCES2:.c=.d)
+    endif
   endif
 endif
 
--- LVM2/tools/Makefile.in	2009/05/21 11:11:29	1.98
+++ LVM2/tools/Makefile.in	2009/09/11 15:52:23	1.99
@@ -62,6 +62,9 @@
 	vgscan.c \
 	vgsplit.c
 
+SOURCES2 =\
+	dmsetup.c
+
 TARGETS =\
 	.commands \
 	lvm


