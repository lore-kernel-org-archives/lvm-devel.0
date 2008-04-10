From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Apr 2008 20:02:04 -0000
Subject: LVM2/tools vgsplit.c
Message-ID: <20080410200204.7718.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-04-10 20:02:04

Modified files:
	tools          : vgsplit.c 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64

--- LVM2/tools/vgsplit.c	2008/04/10 19:59:43	1.63
+++ LVM2/tools/vgsplit.c	2008/04/10 20:02:04	1.64
@@ -252,10 +252,8 @@
 			return 0;
 		}
 
-		if (seg_in == seg->area_count && log_in) {
-			if (!_move_one_lv(vg_from, vg_to, lvh))
-				return 0;
-		}
+		if (seg_in == seg->area_count && log_in)
+			_move_one_lv(vg_from, vg_to, lvh);
 	}
 
 	return 1;


