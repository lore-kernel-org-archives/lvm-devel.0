From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Apr 2008 19:16:37 -0000
Subject: LVM2/lib/display display.c
Message-ID: <20080410191637.5360.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-04-10 19:16:35

Modified files:
	lib/display    : display.c 

Log message:
	fix 3rd copy

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.89&r2=1.90

--- LVM2/lib/display/display.c	2008/04/10 17:19:02	1.89
+++ LVM2/lib/display/display.c	2008/04/10 19:16:35	1.90
@@ -670,7 +670,7 @@
 		active_pvs = vg->pv_count;
 
 	list_iterate_items(lvl, &vg->lvs)
-		if (lv_is_visible(lvl->lv) || (lvl->lv->status & SNAPSHOT))
+		if (lv_is_visible(lvl->lv) && !(lvl->lv->status & SNAPSHOT))
 			lv_count++;
 
 	switch (vg->status & (LVM_READ | LVM_WRITE)) {


