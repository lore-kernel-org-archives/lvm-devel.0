From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 28 Nov 2010 18:37:34 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20101128183734.4011.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-11-28 18:37:34

Modified files:
	tools          : lvconvert.c 

Log message:
	Fix "it's" typo to be "its" in lvconvert error message.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.149&r2=1.150

--- LVM2/tools/lvconvert.c	2010/11/25 17:15:47	1.149
+++ LVM2/tools/lvconvert.c	2010/11/28 18:37:33	1.150
@@ -1572,7 +1572,7 @@
 			return ECMD_FAILED;
 		}
 		if (!lvconvert_merge(cmd, lv, lp)) {
-			log_error("Unable to merge LV \"%s\" into it's origin.", lv->name);
+			log_error("Unable to merge LV \"%s\" into its origin.", lv->name);
 			return ECMD_FAILED;
 		}
 	} else if (lp->snapshot) {


