From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 21 Oct 2019 09:32:59 -0400
Subject: master - lv_manip: add lv_uniq_rename_update
Message-ID: <201910211332.x9LDWx8X019549@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2266a1863f048899dc6f54c4d62ae05b33605349
Commit:        2266a1863f048899dc6f54c4d62ae05b33605349
Parent:        5714c8c9cc12d9442ad9ee85fb73a8ae49d6b548
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 21 09:16:45 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 21 12:14:15 2019 +0200

lv_manip: add lv_uniq_rename_update

Add function to rename LV to either passed name or if
the name is already in use, generate new lvol% name.
---
 lib/metadata/lv_manip.c          |   24 ++++++++++++++++++++++++
 lib/metadata/metadata-exported.h |    2 ++
 2 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 815ea99..ae103d3 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4626,6 +4626,30 @@ int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 }
 
 /*
+ * Rename LV to new name, if name is occupies, lvol% is generated.
+ * VG must be locked by caller.
+ */
+int lv_uniq_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
+			  const char *new_name, int update_mda)
+{
+	char uniq_name[NAME_LEN];
+
+	/* If the name is in use, generate new lvol%d */
+	if (lv_name_is_used_in_vg(lv->vg, new_name, NULL)) {
+		if (!generate_lv_name(lv->vg, "lvol%d", uniq_name, sizeof(uniq_name))) {
+			log_error("Failed to generate unique name for unused logical volume.");
+			return 0;
+		}
+		new_name = uniq_name;
+	}
+
+	if (!lv_rename_update(cmd, lv, new_name, 0))
+		return_0;
+
+	return 1;
+}
+
+/*
  * Core of LV renaming routine.
  * VG must be locked by caller.
  */
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index f340093..c61c85c 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -845,6 +845,8 @@ int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
 	      const char *new_name);
 int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 		     const char *new_name, int update_mda);
+int lv_uniq_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
+			  const char *new_name, int update_mda);
 
 /* Updates and reloads metadata for given lv */
 int lv_update_and_reload(struct logical_volume *lv);


