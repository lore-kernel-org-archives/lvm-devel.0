From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 10 Sep 2008 10:14:59 -0000
Subject: LVM2/lib/locking locking.c
Message-ID: <20080910101459.12221.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-09-10 10:14:59

Modified files:
	lib/locking    : locking.c 

Log message:
	Do not scan for lvm1 entries in /proc if not running 2.4 kernel.
	(LVM1 is only present in 2.4 kernel.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50

--- LVM2/lib/locking/locking.c	2008/05/09 18:45:15	1.49
+++ LVM2/lib/locking/locking.c	2008/09/10 10:14:59	1.50
@@ -292,6 +292,10 @@
 	if (is_orphan_vg(vgname))
 		return 1;
 
+	/* LVM1 is only present in 2.4 kernels. */
+	if (strncmp(cmd->kernel_vsn, "2.4.", 4))
+		return 1;
+
 	if (dm_snprintf(path, sizeof(path), "%s/lvm/VGs/%s", cmd->proc_dir,
 			 vgname) < 0) {
 		log_error("LVM1 proc VG pathname too long for %s", vgname);


