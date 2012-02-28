From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Feb 2012 18:20:19 -0000
Subject: LVM2/lib/cache lvmcache.c
Message-ID: <20120228182019.20085.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-02-28 18:20:18

Modified files:
	lib/cache      : lvmcache.c 

Log message:
	If lvmetad fails, don't set _has_scanned

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.130&r2=1.131

--- LVM2/lib/cache/lvmcache.c	2012/02/28 11:08:04	1.130
+++ LVM2/lib/cache/lvmcache.c	2012/02/28 18:20:17	1.131
@@ -116,10 +116,15 @@
 
 void lvmcache_seed_infos_from_lvmetad(struct cmd_context *cmd)
 {
-	if (lvmetad_active() && !_has_scanned) {
-		lvmetad_pv_list_to_lvmcache(cmd);
-		_has_scanned = 1;
+	if (!lvmetad_active() || _has_scanned)
+		return;
+
+	if (!lvmetad_pv_list_to_lvmcache(cmd)) {
+		stack;
+		return;
 	}
+
+	_has_scanned = 1;
 };
 
 


