From: Patrick Caulfield <pcaulfie@redhat.com>
Date: Mon, 23 Oct 2006 11:11:44 +0100
Subject: [PATCH] get exclusive lock on an LV before removing it.
Message-ID: <453C9560.8040701@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch is for BZ#209370 and prevents removing of an LV that is activated exclusively on another node.

patrick


Index: tools/lvremove.c
===================================================================
RCS file: /cvs/lvm2/LVM2/tools/lvremove.c,v
retrieving revision 1.48
diff -u -p -r1.48 lvremove.c
--- tools/lvremove.c	9 May 2006 21:23:51 -0000	1.48
+++ tools/lvremove.c	23 Oct 2006 10:10:48 -0000
@@ -75,6 +75,16 @@ static int lvremove_single(struct cmd_co
 	if (!archive(vg))
 		return ECMD_FAILED;

+	/* If the VG is clustered then make sure no-one else is using the LV
+	   we are about to remove */
+	if (vg->status & CLUSTERED) {
+		if (!activate_lv_excl(cmd, lv)) {
+			log_error("Can't get exclusive access to volume \"%s\"",
+				  lv->name);
+			return ECMD_FAILED;
+		}
+	}
+
 	/* FIXME Snapshot commit out of sequence if it fails after here? */
 	if (!deactivate_lv(cmd, lv)) {
 		log_error("Unable to deactivate logical volume \"%s\"",


-- 

patrick


