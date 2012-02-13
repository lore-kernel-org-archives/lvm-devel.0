From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 13 Feb 2012 17:31:15 -0000
Subject: LVM2 make.tmpl.in
Message-ID: <20120213173115.12735.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-13 17:31:15

Modified files:
	.              : make.tmpl.in 

Log message:
	Superfluous '/' in systemd_dir path.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.128&r2=1.129

--- LVM2/make.tmpl.in	2012/02/13 13:02:48	1.128
+++ LVM2/make.tmpl.in	2012/02/13 17:31:14	1.129
@@ -66,7 +66,7 @@
 udevdir = $(DESTDIR)@udevdir@
 pkgconfigdir = $(usrlibdir)/pkgconfig
 initdir = $(DESTDIR)@sysconfdir@/rc.d/init.d
-systemd_dir = $(DESTDIR)/@systemdsystemunitdir@
+systemd_dir = $(DESTDIR)@systemdsystemunitdir@
 ocf_scriptdir = $(DESTDIR)@OCFDIR@
 
 USRLIB_RELPATH = $(shell echo $(abspath $(usrlibdir) $(libdir)) | \


