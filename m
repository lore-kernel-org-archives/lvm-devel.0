From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 19 Nov 2009 13:44:37 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20091119134437.27419.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-11-19 13:44:37

Modified files:
	lib/metadata   : metadata.c 

Log message:
	In case we refuse to continue due to missing PVs, print a hint about using
	vgreduce --removemissing to remedy the situation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.296&r2=1.297

--- LVM2/lib/metadata/metadata.c	2009/11/19 12:13:37	1.296
+++ LVM2/lib/metadata/metadata.c	2009/11/19 13:44:37	1.297
@@ -3378,8 +3378,8 @@
 
 	if (!cmd->handles_missing_pvs && vg_missing_pv_count(vg) &&
 	    (lock_flags & LCK_WRITE)) {
-		log_error("Cannot change VG %s while PVs are missing!",
-			  vg->name);
+		log_error("Cannot change VG %s while PVs are missing.", vg->name);
+		log_error("Consider vgreduce --removemissing.");
 		failure |= FAILED_INCONSISTENT; /* FIXME new failure code here? */
 		goto_bad;
 	}


