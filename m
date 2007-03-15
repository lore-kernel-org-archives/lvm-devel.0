From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 15 Mar 2007 14:00:32 -0000
Subject: LVM2 ./WHATS_NEW tools/vgremove.c
Message-ID: <20070315140032.20347.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2007-03-15 14:00:31

Modified files:
	.              : WHATS_NEW 
	tools          : vgremove.c 

Log message:
	Fix vgremove to require at least one vg argument.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.586&r2=1.587
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgremove.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38

--- LVM2/WHATS_NEW	2007/03/15 13:38:27	1.586
+++ LVM2/WHATS_NEW	2007/03/15 14:00:29	1.587
@@ -1,5 +1,6 @@
 Version 2.02.24 -
 ====================================
+  Fix vgremove to require at least one vg argument.
   Fix reading of striped LVs in LVM1 format.
   Flag nolocking as clustered so clvmd startup sees clustered LVs. (2.02.10)
   Add a few missing pieces of vgname command line validation.
--- LVM2/tools/vgremove.c	2006/05/09 21:23:51	1.37
+++ LVM2/tools/vgremove.c	2007/03/15 14:00:30	1.38
@@ -87,6 +87,11 @@
 {
 	int ret;
 
+	if (!argc) {
+		log_error("Please enter one or more volume group paths");
+		return EINVALID_CMD_LINE;
+	}
+
 	if (!lock_vol(cmd, ORPHAN, LCK_VG_WRITE)) {
 		log_error("Can't get lock for orphan PVs");
 		return ECMD_FAILED;


