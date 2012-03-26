From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 26 Mar 2012 20:33:41 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/locking.c tools/p ...
Message-ID: <20120326203341.16447.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2012-03-26 20:33:40

Modified files:
	.              : WHATS_NEW 
	lib/locking    : locking.c 
	tools          : pvmove.c 

Log message:
	Keep exclusive activation in pvmove if LV is already active.
	
	Pvmove should never try to downgrade exclusive lock
	for LVs.
	
	This allows pvmove to work again for exclusive activated LVs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2369&r2=1.2370
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.103&r2=1.104
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.96&r2=1.97

--- LVM2/WHATS_NEW	2012/03/26 20:32:58	1.2369
+++ LVM2/WHATS_NEW	2012/03/26 20:33:40	1.2370
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Keep exclusive activation in pvmove if LV is already active.
   Disallow pvmove for exclusive LV if some affected LVs are not exclusively activated.
   Remove unused and wrongly set cluster VG flag from clvmd lock query command.
   Fix pvmove for exclusively activated LV pvmove in clustered VG. (2.02.86)
--- LVM2/lib/locking/locking.c	2012/02/08 11:05:04	1.103
+++ LVM2/lib/locking/locking.c	2012/03/26 20:33:40	1.104
@@ -574,7 +574,7 @@
 	struct lv_list *lvl;
 
 	dm_list_iterate_items(lvl, lvs) {
-		if (!exclusive) {
+		if (!exclusive && !lv_is_active_exclusive(lvl->lv)) {
 			if (!activate_lv(cmd, lvl->lv)) {
 				log_error("Failed to activate %s", lvl->lv->name);
 				return 0;
--- LVM2/tools/pvmove.c	2012/03/26 20:32:58	1.96
+++ LVM2/tools/pvmove.c	2012/03/26 20:33:40	1.97
@@ -296,7 +296,7 @@
 {
 	int r = 0;
 
-	if (exclusive)
+	if (exclusive || lv_is_active_exclusive(lv_mirr))
 		r = activate_lv_excl(cmd, lv_mirr);
 	else
 		r = activate_lv(cmd, lv_mirr);


