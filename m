From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Apr 2011 16:27:11 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20110429162711.4887.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-04-29 16:27:10

Modified files:
	.              : WHATS_NEW 

Log message:
	wake buildbot

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1977&r2=1.1978

--- LVM2/WHATS_NEW	2011/04/29 16:12:21	1.1977
+++ LVM2/WHATS_NEW	2011/04/29 16:27:09	1.1978
@@ -346,7 +346,7 @@
   Fix const warning in dev_manager_info() and _dev_manager_lv_rmnodes().
   Fix const warning in archive_file structure from archive.c.
   Clean generated files .exported_symbols_generated, example.conf for distclean.
-  Handle failure of all mirrored log devices and all but one mirror leg. 
+  Handle failure of all mirrored log devices and all but one mirror leg.
   Disallow 'mirrored' log type for cluster mirrors.
   Do not use VPATH in include/Makefile.
   Fix exported_symbols generation to use standard compiler arguments.

