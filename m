From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:20:27 +0000 (UTC)
Subject: master - metadata: add vg_strip_outdated_historical_lvs fn and call it during VG read
Message-ID: <20160303132027.3D29E60308@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=74272e163de8c62208d6de41d15631cf3ecf0b2c
Commit:        74272e163de8c62208d6de41d15631cf3ecf0b2c
Parent:        53b064b9aed3bd2237638cab778b3bffd018ce08
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:27:21 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 13:50:59 2016 +0100

metadata: add vg_strip_outdated_historical_lvs fn and call it during VG read

The vg_strip_outdated_historical_lvs iterates over the list of historical LVs
we have and it shoots down the ones which are outdated.

Configuration hook to set the timeout will be in subsequent patch.
---
 lib/metadata/metadata-exported.h |    2 +
 lib/metadata/metadata.c          |   39 +++++++++++++++++++++++++++++++++++++-
 2 files changed, 40 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index d81166d..dc95995 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1298,4 +1298,6 @@ int is_lockd_type(const char *lock_type);
 
 int is_system_id_allowed(struct cmd_context *cmd, const char *system_id);
 
+int vg_strip_outdated_historical_lvs(struct volume_group *vg);
+
 #endif
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index c37c7ba..417629b 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3930,6 +3930,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	int inconsistent_pvs = 0;
 	int inconsistent_mdas = 0;
 	int inconsistent_mda_count = 0;
+	int strip_historical_lvs = *consistent;
 	unsigned use_precommitted = precommitted;
 	struct dm_list *pvids;
 	struct pv_list *pvl;
@@ -3965,6 +3966,10 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 				lvmetad_vg_clear_outdated_pvs(correct_vg);
                         }
 		}
+
+		if (correct_vg && strip_historical_lvs && !vg_strip_outdated_historical_lvs(correct_vg))
+			return_NULL;
+
 		return correct_vg;
 	}
 
@@ -4405,6 +4410,10 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	}
 
 	*consistent = !inconsistent_pvs;
+
+	if (*consistent && correct_vg && strip_historical_lvs && !vg_strip_outdated_historical_lvs(correct_vg))
+		return_NULL;
+
 	return correct_vg;
 }
 
@@ -4451,7 +4460,6 @@ struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vgnam
 			goto out;
 		}
 	}
-
 out:
 	if (!*consistent && (warn_flags & WARN_INCONSISTENT)) {
 		if (is_orphan_vg(vgname))
@@ -6002,3 +6010,32 @@ int is_lockd_type(const char *lock_type)
 	return 0;
 }
 
+int vg_strip_outdated_historical_lvs(struct volume_group *vg) {
+	struct glv_list *glvl, *tglvl;
+	time_t current_time = time(NULL);
+	uint64_t threshold = 0;
+
+	if (!threshold)
+		return 1;
+
+	dm_list_iterate_items_safe(glvl, tglvl, &vg->historical_lvs) {
+		/*
+		 * Removal time in the future? Not likely,
+		 * but skip this item in any case.
+		*/
+		if ((current_time) < glvl->glv->historical->timestamp_removed)
+			continue;
+
+		if ((current_time - glvl->glv->historical->timestamp_removed) > threshold) {
+			if (!historical_glv_remove(glvl->glv)) {
+				log_error("Failed to destroy record about historical LV %s/%s.",
+					  vg->name, glvl->glv->historical->name);
+				return 0;
+			}
+			log_verbose("Outdated record for historical logical volume \"%s\" "
+				    "automatically destroyed.", glvl->glv->historical->name);
+		}
+	}
+
+	return 1;
+}


