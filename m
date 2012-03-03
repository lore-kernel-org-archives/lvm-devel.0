From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Mar 2012 17:12:22 -0000
Subject: LVM2/tools pvscan.c
Message-ID: <20120303171222.24098.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-03-03 17:12:22

Modified files:
	tools          : pvscan.c 

Log message:
	Obtain VG list from lvmetad before relying on get_vgs, otherwise PVs in VGs
	don't appear.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvscan.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59

--- LVM2/tools/pvscan.c	2012/03/03 17:03:20	1.58
+++ LVM2/tools/pvscan.c	2012/03/03 17:12:21	1.59
@@ -165,6 +165,10 @@
 	persistent_filter_wipe(cmd->filter);
 	lvmcache_destroy(cmd, 1);
 
+	/* populate lvmcache */
+	if (!lvmetad_vg_list_to_lvmcache(cmd))
+		stack;
+
 	log_verbose("Walking through all physical volumes");
 	if (!(pvslist = get_pvs(cmd))) {
 		unlock_vg(cmd, VG_GLOBAL);
@@ -177,8 +181,8 @@
 		pv = pvl->pv;
 
 		if ((arg_count(cmd, exported_ARG)
-		     && !(pv_status(pv) & EXPORTED_VG))
-		    || (arg_count(cmd, novolumegroup_ARG) && (!is_orphan(pv)))) {
+		     && !(pv_status(pv) & EXPORTED_VG)) ||
+		    (arg_count(cmd, novolumegroup_ARG) && (!is_orphan(pv)))) {
 			dm_list_del(&pvl->list);
 			continue;
 		}


