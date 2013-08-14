From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 14 Aug 2013 12:16:58 +0000 (UTC)
Subject: master - autoactivation: refresh existing VG before autoactivation
Message-ID: <20130814121658.0955A60DEF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=82d83a01ce2cac77fec2e9b763061fbfb5f01ce8
Commit:        82d83a01ce2cac77fec2e9b763061fbfb5f01ce8
Parent:        fcbb34bdccb21f0ed4c8fe990fdc68126f1cbf4f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Aug 14 14:04:58 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Aug 14 14:04:58 2013 +0200

autoactivation: refresh existing VG before autoactivation

When autoactivating a VG, there could be an existing VG with exactly
the same PV UUIDs. The PVs could be reappeared after previous
loss/disconnect (for example disconnecting and reconnecting iscsi).

Since there's no "autodeactivation" yet, the mappings for the LVs
from the VG were left in the system even if the device was disconnected.
These mappings also hold the major:minor of the underlying device.
So if the device reappears, it is assigned a different major:minor
pair (...and kernel name). We need to cope with this during
autoactivation so any existing mappings are corrected for any changes.
The VG refresh does that (the vgchange --refresh functionality) -
call this before VG autoactivation.

(If the VG does not exist yet, the VG refresh is NOP)
---
 WHATS_NEW      |    1 +
 tools/pvscan.c |   20 +++++++++++++-------
 2 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c7fda19..903b28d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.101 - 
 ===================================
+  Refresh existing VG before autoactivation (event retrigger/device reappeared).
   Fix vgck to notice on-disk corruption even if lvmetad is used.
   Move mpath device filter before partitioned filter (which opens devices).
   Split partitioned filter out of lvm_type filter.
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 96bbf6b..3f16b05 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -98,6 +98,7 @@ static int _auto_activation_handler(struct cmd_context *cmd,
 	struct volume_group *vg;
 	int consistent = 0;
 	struct id vgid_raw;
+	int r = 0;
 
 	/* TODO: add support for partial and clustered VGs */
 	if (partial)
@@ -106,24 +107,29 @@ static int _auto_activation_handler(struct cmd_context *cmd,
 	if (!id_read_format(&vgid_raw, vgid))
 		return_0;
 
-	/* NB. This is safe because we know lvmetad is running and we won't hit
-	 * disk. */
+	/* NB. This is safe because we know lvmetad is running and we won't hit disk. */
 	if (!(vg = vg_read_internal(cmd, NULL, (const char *) &vgid_raw, 0, &consistent)))
 	    return 1;
 
 	if (vg_is_clustered(vg)) {
-		release_vg(vg);
-		return 1;
+		r = 1; goto out;
+	}
+
+	if (!vg_refresh_visible(vg->cmd, vg)) {
+		log_error("%s: refresh before autoactivation failed.", vg->name);
+		goto out;
 	}
 
 	if (!vgchange_activate(vg->cmd, vg, activate)) {
 		log_error("%s: autoactivation failed.", vg->name);
-		release_vg(vg);
-		return 0;
+		goto out;
 	}
 
+	r = 1;
+
+out:
 	release_vg(vg);
-	return 1;
+	return r;
 }
 
 static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)


