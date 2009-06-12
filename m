From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 12 Jun 2009 08:34:15 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20090612083415.22207.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-06-12 08:34:15

Modified files:
	.              : WHATS_NEW 

Log message:
	Fix WHATS_NEW - Allow metadata correction even when PVs are missing.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1146&r2=1.1147

--- LVM2/WHATS_NEW	2009/06/12 08:30:19	1.1146
+++ LVM2/WHATS_NEW	2009/06/12 08:34:15	1.1147
@@ -1,6 +1,7 @@
 Version 2.02.48 - 
 ===============================
   Re-instate partial activation support in clustered mode. (2.02.40)
+  Allow metadata correction even when PVs are missing.
   Use 'lvm lvresize' instead of 'lvresize' in fsadm.
   Do not use '-n' realine option in fsadm for busybox compatiblity.
   Update vgrename, vgsplit, and vgcreate to use vg_lock_newname.


