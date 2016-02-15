From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Feb 2016 12:08:44 +0000 (UTC)
Subject: master - metadata: _vg_read: check if PV_EXT_USED flag is set correctly for non-orphan PVs and do a repair if needed
Message-ID: <20160215120844.A7F5660A9E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=531ced90dcaa6d7b18189cb9169456b74c6a2d65
Commit:        531ced90dcaa6d7b18189cb9169456b74c6a2d65
Parent:        f75e42c06cd925d414c1069d6c51e0b50e1934a8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Mar 19 07:53:22 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 15 12:44:46 2016 +0100

metadata: _vg_read: check if PV_EXT_USED flag is set correctly for non-orphan PVs and do a repair if needed

The same check as we already do for orphan PVs, just the other way
round now: if the PV is surely part of some VG and any PV the VG
contains does not have the PV_EXT_USED flag set, repair it.

For example - /dev/sda here is in VG vg and it's incorrectly not
marked as used by PV_EXT_USED flag:

pvs --binary -o pv_ext_vsn,pv_in_use
  WARNING: Volume Group vg is not consistent.
  WARNING: Repairing Physical Volume /dev/sda that is in Volume Group vg but not marked as used.
  PV         VG     Fmt  Attr PSize   PFree   ExtVsn PInUse
  /dev/sda   vg     lvm2 a--  124.00m 124.00m      2      1
---
 lib/metadata/metadata.c |   57 ++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 56 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 172edc1..a08cfc3 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3569,6 +3569,52 @@ static int _check_reappeared_pv(struct volume_group *correct_vg,
 	return rv;
 }
 
+static int _check_or_repair_pv_ext(struct cmd_context *cmd,
+				   struct physical_volume *pv,
+				   int repair, int *inconsistent_pvs)
+{
+	struct lvmcache_info *info;
+	uint32_t ext_version, ext_flags;
+
+	/* Missing PV - nothing to do. */
+	if (!pv->dev)
+		return 1;
+
+	if (!(info = lvmcache_info_from_pvid(pv->dev->pvid, 0))) {
+		log_error("Failed to find cached info for PV %s.", pv_dev_name(pv));
+		return 0;
+	}
+
+	ext_version = lvmcache_ext_version(info);
+	if (ext_version < 2) {
+		*inconsistent_pvs = 0;
+		return 1;
+	}
+
+	ext_flags = lvmcache_ext_flags(info);
+	if (!(ext_flags & PV_EXT_USED)) {
+		if (!repair) {
+			*inconsistent_pvs = 1;
+			return 1;
+		}
+
+		log_warn("WARNING: Repairing Physical Volume %s that is "
+			 "in Volume Group %s but not marked as used.",
+			  pv_dev_name(pv), pv->vg->name);
+
+		/* pv write will set correct ext_flags */
+		if (!pv_write(cmd, pv, 1)) {
+			*inconsistent_pvs = 1;
+			log_error("Failed to repair physical volume \"%s\".",
+				  pv_dev_name(pv));
+			return 0;
+		}
+	}
+
+	*inconsistent_pvs = 0;
+	return 1;
+}
+
 static int _repair_inconsistent_vg(struct volume_group *vg)
 {
 	unsigned saved_handles_missing_pvs = vg->cmd->handles_missing_pvs;
@@ -3872,6 +3918,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 					inconsistent_pvs = 1;
 					break;
 				}
+
 				if (lvmcache_mda_count(info)) {
 					if (!lvmcache_fid_add_mdas_pv(info, fid)) {
 						release_vg(correct_vg);
@@ -4149,7 +4196,15 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		return NULL;
 	}
 
-	*consistent = 1;
+	/* We have the VG now finally, check if PV ext info is in sync with VG metadata. */
+	dm_list_iterate_items(pvl, &correct_vg->pvs) {
+		if (!_check_or_repair_pv_ext(cmd, pvl->pv, *consistent, &inconsistent_pvs)) {
+			release_vg(correct_vg);
+			return_NULL;
+		}
+	}
+
+	*consistent = !inconsistent_pvs;
 	return correct_vg;
 }
 


