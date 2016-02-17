From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 17 Feb 2016 09:32:49 +0000 (UTC)
Subject: master - metadata: add missing _repair_inconsinstent_vg call during PV ext repair
Message-ID: <20160217093249.300AD60B41@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=065526c59084d3d47de476acee2d095199e9412d
Commit:        065526c59084d3d47de476acee2d095199e9412d
Parent:        b077e7374f6bcb4ad5d8d9247553301ce75fa38e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Feb 16 15:50:32 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Feb 17 10:19:55 2016 +0100

metadata: add missing _repair_inconsinstent_vg call during PV ext repair

---
 lib/metadata/metadata.c |   19 +++++++++++++++----
 1 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 3b59e65..ca7f9c7 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3723,6 +3723,8 @@ static int _check_or_repair_pv_ext(struct cmd_context *cmd,
 	struct lvmcache_info *info;
 	uint32_t ext_version, ext_flags;
 	struct pv_list *pvl;
+	unsigned pvs_fixed = 0;
+	int r = 0;
 
 	*inconsistent_pvs = 0;
 
@@ -3733,7 +3735,7 @@ static int _check_or_repair_pv_ext(struct cmd_context *cmd,
 
 		if (!(info = lvmcache_info_from_pvid(pvl->pv->dev->pvid, 0))) {
 			log_error("Failed to find cached info for PV %s.", pv_dev_name(pvl->pv));
-			return 0;
+			goto out;
 		}
 
 		ext_version = lvmcache_ext_version(info);
@@ -3744,7 +3746,10 @@ static int _check_or_repair_pv_ext(struct cmd_context *cmd,
 		if (!(ext_flags & PV_EXT_USED)) {
 			if (!repair) {
 				*inconsistent_pvs = 1;
-				continue;
+				/* we're not repairing now, so no need to
+				 * check further PVs - inconsistent_pvs is already
+				 * set and that will trigger the repair next time */
+				return 1;
 			}
 
 			if (_is_foreign_vg(vg)) {
@@ -3762,13 +3767,19 @@ static int _check_or_repair_pv_ext(struct cmd_context *cmd,
 					*inconsistent_pvs = 1;
 					log_error("Failed to repair physical volume \"%s\".",
 						  pv_dev_name(pvl->pv));
-					return 0;
+					goto out;
 				}
+				pvs_fixed++;
 			}
 		}
 	}
 
-	return 1;
+	r = 1;
+out:
+	if ((pvs_fixed > 0) && !_repair_inconsistent_vg(vg))
+		return_0;
+
+	return r;
 }
 
 /* Caller sets consistent to 1 if it's safe for vg_read_internal to correct


