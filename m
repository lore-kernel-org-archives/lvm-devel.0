From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  4 Mar 2015 00:46:42 +0000 (UTC)
Subject: master - format1: Export generate_lvm1_system_id.
Message-ID: <20150304004642.08D80602EB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=340369ab2526bc3cf5c52c2738998e589865f4a2
Commit:        340369ab2526bc3cf5c52c2738998e589865f4a2
Parent:        4e6f3e5162e06de09c38e360cbd1d348939ad7f0
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Mar 4 00:44:15 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Mar 4 00:44:15 2015 +0000

format1: Export generate_lvm1_system_id.

Export _lvm1_system_id as generate_lvm1_system_id and call it in
vg_setup() so it is set before writing the metadata to disk
and not missing from the initial metadata backup file.
---
 lib/format1/disk-rep.h      |    2 ++
 lib/format1/format1.c       |    5 +++++
 lib/format1/import-export.c |    8 ++++----
 3 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/lib/format1/disk-rep.h b/lib/format1/disk-rep.h
index 729601e..9d1c8a5 100644
--- a/lib/format1/disk-rep.h
+++ b/lib/format1/disk-rep.h
@@ -245,4 +245,6 @@ int get_free_vg_number(struct format_instance *fid, struct dev_filter *filter,
 int export_vg_number(struct format_instance *fid, struct dm_list *pvds,
 		     const char *vg_name, struct dev_filter *filter);
 
+int generate_lvm1_system_id(struct cmd_context *cmd, char *s, const char *prefix);
+
 #endif
diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index f7df7c3..19df8aa 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -496,6 +496,11 @@ static int _format1_vg_setup(struct format_instance *fid, struct volume_group *v
 	if (!vg_check_new_extent_size(vg->fid->fmt, vg->extent_size))
 		return_0;
 
+        /* Generate lvm1_system_id if not yet set */
+        if (!*vg->lvm1_system_id &&
+            !generate_lvm1_system_id(vg->cmd, vg->lvm1_system_id, ""))
+		return_0;
+
 	return 1;
 }
 
diff --git a/lib/format1/import-export.c b/lib/format1/import-export.c
index a3c060f..8155b04 100644
--- a/lib/format1/import-export.c
+++ b/lib/format1/import-export.c
@@ -125,7 +125,7 @@ int import_pv(const struct format_type *fmt, struct dm_pool *mem,
 	return 1;
 }
 
-static int _lvm1_system_id(struct cmd_context *cmd, char *s, const char *prefix)
+int generate_lvm1_system_id(struct cmd_context *cmd, char *s, const char *prefix)
 {
 
 	if (dm_snprintf(s, NAME_LEN, "%s%s%lu",
@@ -165,7 +165,7 @@ int export_pv(struct cmd_context *cmd, struct dm_pool *mem __attribute__((unused
 		if (!*vg->lvm1_system_id ||
 		    strncmp(vg->lvm1_system_id, EXPORTED_TAG,
 			    sizeof(EXPORTED_TAG) - 1)) {
-			if (!_lvm1_system_id(cmd, (char *)pvd->system_id, EXPORTED_TAG))
+			if (!generate_lvm1_system_id(cmd, (char *)pvd->system_id, EXPORTED_TAG))
 				return_0;
 		}
 		if (strlen((char *)pvd->vg_name) + sizeof(EXPORTED_TAG) >
@@ -180,13 +180,13 @@ int export_pv(struct cmd_context *cmd, struct dm_pool *mem __attribute__((unused
 	/* Is VG being imported? */
 	if (vg && !vg_is_exported(vg) && *vg->lvm1_system_id &&
 	    !strncmp(vg->lvm1_system_id, EXPORTED_TAG, sizeof(EXPORTED_TAG) - 1)) {
-		if (!_lvm1_system_id(cmd, (char *)pvd->system_id, IMPORTED_TAG))
+		if (!generate_lvm1_system_id(cmd, (char *)pvd->system_id, IMPORTED_TAG))
 			return_0;
 	}
 
 	/* Generate system_id if PV is in VG */
 	if (!pvd->system_id[0])
-		if (!_lvm1_system_id(cmd, (char *)pvd->system_id, ""))
+		if (!generate_lvm1_system_id(cmd, (char *)pvd->system_id, ""))
 			return_0;
 
 	/* Update internal system_id if we changed it */


