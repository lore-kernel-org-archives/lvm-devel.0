From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Oct 2006 15:30:33 -0000
Subject: LVM2/tools lvchange.c
Message-ID: <20061024153033.22985.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-10-24 15:30:33

Modified files:
	tools          : lvchange.c 

Log message:
	fix forcesync local active detection

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71

--- LVM2/tools/lvchange.c	2006/10/23 23:03:55	1.70
+++ LVM2/tools/lvchange.c	2006/10/24 15:30:33	1.71
@@ -205,17 +205,18 @@
 			return ECMD_FAILED;
 		}
 
-		if (info.exists && !arg_count(cmd, yes_ARG)) {
-			if (yes_no_prompt("Do you really want to deactivate "
+		if (info.exists) {
+			if (!arg_count(cmd, yes_ARG) &&
+			    yes_no_prompt("Do you really want to deactivate "
 					  "logical volume %s to resync it? [y/n]: ",
 					  lv->name) == 'n') {
 				log_print("Logical volume \"%s\" not resynced",
 					  lv->name);
 				return ECMD_FAILED;
 			}
-		}
 
-		active = 1;
+			active = 1;
+		}
 	}
 
 	if ((lv->vg->status & CLUSTERED) && !activate_lv_excl(cmd, lv)) {


