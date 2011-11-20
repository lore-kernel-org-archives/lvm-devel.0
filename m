From: agk@sourceware.org <agk@sourceware.org>
Date: 20 Nov 2011 20:52:10 -0000
Subject: LVM2 WHATS_NEW make.tmpl.in
Message-ID: <20111120205210.24055.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-11-20 20:52:09

Modified files:
	.              : WHATS_NEW make.tmpl.in 

Log message:
	Don't ignore configure --mandir and --infodir.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2192&r2=1.2193
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.123&r2=1.124

--- LVM2/WHATS_NEW	2011/11/18 19:42:03	1.2192
+++ LVM2/WHATS_NEW	2011/11/20 20:52:09	1.2193
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Don't ignore configure --mandir and --infodir.
   Drop pool memory allocated within lv_has_target_type().
   Reduce stack allocation of some PATH_MAX sized char buffers.
   Unlock memory before writing metadata.
@@ -8,7 +9,7 @@
   Skip non-virtual snapshots for availability change for lvchange with vg name.
   Adjusted mirror region size only for mirrors and raids.
   Reorder prompt conditions for removal of active volumes.
-  Avoid 'mda inconsistency' by properly registering UNLABELLED_PV flag (2.02.86).
+  Avoid 'mda inconsistency' by properly registering UNLABELLED_PV flag (2.02.86)
   Fix --enable-static_link unless using --enable-dmeventd / --enable-udev_sync.
   Move gentoo MAKEDEV to /sbin in lvm2create_initrd.
   Add filter to avoid scan of device if it is part of active multipath.
--- LVM2/make.tmpl.in	2011/11/14 21:30:35	1.123
+++ LVM2/make.tmpl.in	2011/11/20 20:52:09	1.124
@@ -58,9 +58,9 @@
 usrlibdir = $(DESTDIR)@usrlibdir@
 sbindir = $(DESTDIR)@sbindir@
 usrsbindir = $(DESTDIR)@usrsbindir@
-datarootdir = $(DESTDIR)@datarootdir@
-infodir = $(datarootdir)/info
-mandir = $(datarootdir)/man
+datarootdir = @datarootdir@
+infodir = $(DESTDIR)@infodir@
+mandir = $(DESTDIR)@mandir@
 localedir = $(DESTDIR)@LOCALEDIR@
 staticdir = $(DESTDIR)@STATICDIR@
 udevdir = $(DESTDIR)@udevdir@


