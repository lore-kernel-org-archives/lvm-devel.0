From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 11 Jan 2008 20:17:20 -0000
Subject: LVM2/tools vgsplit.c
Message-ID: <20080111201720.3135.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-01-11 20:17:19

Modified files:
	tools          : vgsplit.c 

Log message:
	Refactor vgsplit for accepting existing vg as destination

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42

--- LVM2/tools/vgsplit.c	2007/11/15 21:59:11	1.41
+++ LVM2/tools/vgsplit.c	2008/01/11 20:17:18	1.42
@@ -239,6 +239,14 @@
 				       CORRECT_INCONSISTENT | FAIL_INCONSISTENT)))
 		 return ECMD_FAILED;
 
+	if ((active = lvs_in_vg_activated(vg_from))) {
+		/* FIXME Remove this restriction */
+		log_error("Logical volumes in \"%s\" must be inactive",
+			  vg_name_from);
+		unlock_vg(cmd, vg_name_from);
+		return ECMD_FAILED;
+	}
+
 	log_verbose("Checking for new volume group \"%s\"", vg_name_to);
 	if ((vg_to = vg_lock_and_read(cmd, vg_name_to, NULL,
 				      LCK_VG_WRITE | LCK_NONBLOCK,
@@ -249,13 +257,6 @@
 		return ECMD_FAILED;
 	}
 
-	if ((active = lvs_in_vg_activated(vg_from))) {
-		/* FIXME Remove this restriction */
-		log_error("Logical volumes in \"%s\" must be inactive",
-			  vg_name_from);
-		goto error;
-	}
-
 	/* Set metadata format of original VG */
 	/* FIXME: need some common logic */
 	cmd->fmt = vg_from->fid->fmt;


