From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 23 Apr 2014 14:20:32 -0500
Subject: [PATCH] vgsplit: Make vgsplit work on mirrors with leg and log on same PV
Message-ID: <1398280832.16593.1.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Given a named mirror LV, vgsplit will look for the PVs that compose it
and move them to a new VG.  It does this by first looking at the log
and then the legs.  If the log is on the same device as one of the mirror
images, a problem occurs.  This is because the PV is moved to the new VG
as the log is processed and thus cannot be found in the current VG when
the image is processed.  The solution is to check and see if the PV we are
looking for has already been moved to the new VG.  If so, it is not an
error.


Index: lvm2/lib/metadata/metadata.c
===================================================================
--- lvm2.orig/lib/metadata/metadata.c
+++ lvm2/lib/metadata/metadata.c
@@ -368,6 +368,14 @@ int move_pv(struct volume_group *vg_from
 
 	/* FIXME: handle tags */
 	if (!(pvl = find_pv_in_vg(vg_from, pv_name))) {
+		if (pvl = find_pv_in_vg(vg_to, pv_name))
+			/*
+			 * PV has already been moved.  This can happen if an
+			 * LV is being moved that has multiple sub-LVs on the
+			 * same PV.
+			 */
+			return 1;
+
 		log_error("Physical volume %s not in volume group %s",
 			  pv_name, vg_from->name);
 		return 0;
Index: lvm2/tools/vgsplit.c
===================================================================
--- lvm2.orig/tools/vgsplit.c
+++ lvm2/tools/vgsplit.c
@@ -67,6 +67,7 @@ static int _move_lvs(struct volume_group
 			continue;
 
 		if ((lv->status & MIRRORED))
+			/* further checks by _move_mirrors() */
 			continue;
 
 		if (lv_is_thin_pool(lv) ||



