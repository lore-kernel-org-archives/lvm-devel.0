From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Jan 2009 13:34:08 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20090126133408.27257.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-01-26 13:34:08

Modified files:
	.              : WHATS_NEW 

Log message:
	Add stuff people missed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1025&r2=1.1026

--- LVM2/WHATS_NEW	2009/01/26 13:14:22	1.1025
+++ LVM2/WHATS_NEW	2009/01/26 13:34:07	1.1026
@@ -14,8 +14,10 @@
   Fix incorrect exit status from 'help <command>'.
   Fix vgrename using UUID if there are VGs with identical names.
   Fix segfault when invalid field given in reporting commands.
+  Move is_static from cmd to global is_static().
   Refactor init_lvm() for lvmcmdline and clvmd.
   Add liblvm interactive test infrastructure to build.
+  Add skeleton lvm2.h file in preparation for a shared library interface.
   Use better random seed value in temp file creation.
   Add read_urandom to read /dev/urandom. Use in uuid calculation.
   Use displayable_lvs_in_vg and lv_is_displayable for consistency throughout.


