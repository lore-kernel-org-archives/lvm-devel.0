From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 15 Apr 2010 15:09:36 -0000
Subject: LVM2 WHATS_NEW make.tmpl.in
Message-ID: <20100415150936.13928.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-04-15 15:09:35

Modified files:
	.              : WHATS_NEW make.tmpl.in 

Log message:
	Fix double DESTDIR usage for infodir and mandir.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1526&r2=1.1527
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.90&r2=1.91

--- LVM2/WHATS_NEW	2010/04/15 15:06:26	1.1526
+++ LVM2/WHATS_NEW	2010/04/15 15:09:35	1.1527
@@ -1,6 +1,7 @@
 Version 2.02.64 -
 =================================
   Added awk script relpath.awk to calculate relative paths.
+  Fix double DESTDIR usage for infodir and mandir.
 
 Version 2.02.63 - 14th April 2010
 =================================
--- LVM2/make.tmpl.in	2010/04/09 21:42:48	1.90
+++ LVM2/make.tmpl.in	2010/04/15 15:09:35	1.91
@@ -57,8 +57,8 @@
 sbindir = $(DESTDIR)@sbindir@
 usrsbindir = $(DESTDIR)@usrsbindir@
 datarootdir = $(DESTDIR)@datarootdir@
-infodir = $(DESTDIR)@infodir@
-mandir = $(DESTDIR)@mandir@
+infodir = $(datarootdir)/info
+mandir = $(datarootdir)/man
 localedir = $(DESTDIR)@LOCALEDIR@
 staticdir = $(DESTDIR)@STATICDIR@
 udevdir = $(DESTDIR)@udevdir@


