From: Milan Broz <mbroz@redhat.com>
Date: Thu, 17 Sep 2009 17:26:16 +0200
Subject: [PATCH 3/3] Warn if pvmove --abort detect lost temporary device.
Message-ID: <4AB25518.9070801@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Warn if pvmove --abort detect lost temporary device.

pvmove --abort never remove device not referenced in metadata.
But if something bad happened, it is possible that temporary device
is present in kernel and can interfere with subsequent pvmove
(at least there is name collision).

Warn user, that system is in inconsistent state. I would prefer
not forcibly remove device here (and I found no easy and clean way
how to do it without lvm layer violation:-)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 tools/polldaemon.c |   35 +++++++++++++++++++++++++++++++++++
 1 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 6b7cd5b..94288bc 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -176,6 +176,38 @@ static int _wait_for_single_mirror(struct cmd_context *cmd, const char *name, co
 	return 1;
 }
 
+static void _check_orphaned_pmvove_devices(struct cmd_context *cmd,
+					   struct volume_group *vg)
+{
+	char *name, dname[NAME_LEN];
+	struct lvinfo info;
+	struct logical_volume orphaned_lv = {
+		.vg = vg,
+		.status = VISIBLE_LV,
+		.major = -1,
+		.minor = -1,
+	};
+
+	/*
+	 * Allocate new pvmove name, also check that there is no such LV in vg
+	 */
+	if (!generate_lv_name(vg, "pvmove%d", dname, sizeof(dname)))
+		return;
+
+	/*
+	 * Check if such device does not exists
+	 */
+	orphaned_lv.name = dname;
+	if (lv_info(vg->cmd, &orphaned_lv, &info, 0, 0) && info.exists) {
+		if (!(name = build_dm_name(vg->vgmem, vg->name, dname, NULL)))
+			return;
+		log_warn("WARNING: There is still existing temporary pvmove device %s "
+			 "which do not belongs to volume group %s.", name, vg->name);
+		log_warn("WARNING: To manually remove it, consider using dmsetup remove "
+			 "%s.", name);
+	}
+}
+
 static int _poll_vg(struct cmd_context *cmd, const char *vgname,
 		    struct volume_group *vg, void *handle)
 {
@@ -198,6 +230,9 @@ static int _poll_vg(struct cmd_context *cmd, const char *vgname,
 			parms->outstanding_count++;
 	}
 
+	if (parms->aborting)
+		_check_orphaned_pmvove_devices(cmd, vg);
+
 	return ECMD_PROCESSED;
 
 }



