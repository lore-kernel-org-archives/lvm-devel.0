From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Mar 2012 09:39:04 -0000
Subject: LVM2 Makefile.in WHATS_NEW
Message-ID: <20120323093904.4137.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-23 09:39:03

Modified files:
	.              : Makefile.in WHATS_NEW 

Log message:
	Update lcov target

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.71&r2=1.72
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2361&r2=1.2362

--- LVM2/Makefile.in	2012/03/12 15:05:55	1.71
+++ LVM2/Makefile.in	2012/03/23 09:39:03	1.72
@@ -123,11 +123,10 @@
 
 # maybe use subdirs processing to create tracefiles...
 $(LCOV_TRACES):
-	$(LCOV) -b $(basename $@) \
-		-d $(basename $@) -c -o - | $(SED) \
+	$(LCOV) -b $(basename $@) -d $(basename $@) \
+		--ignore-errors source -c -o - | $(SED) \
 		-e "s/\(dmeventd_lvm.[ch]\)/plugins\/lvm2\/\1/" \
-		-e "s/\(dmeventd_mirror.c\)/plugins\/mirror\/\1/" \
-		-e "s/\(dmeventd_snapshot.c\)/plugins\/snapshot\/\1/" \
+		-e "s/dmeventd_\(mirror\|snapshot\|thin\|raid\)\.c/plugins\/\1\/dmeventd_\1\.c/" \
 		>$@
 
 ifneq ("$(GENHTML)", "")
--- LVM2/WHATS_NEW	2012/03/20 17:42:19	1.2361
+++ LVM2/WHATS_NEW	2012/03/23 09:39:03	1.2362
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Update lcov Makefile target to support all dmeventd plugins.
   Fix initializiation of thin monitoring (2.02.92).
   Support improperly formated device numbers in /proc/devices (2.02.91).
   Fix fsadm propagation of -e option.


