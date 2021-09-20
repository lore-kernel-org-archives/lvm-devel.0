From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:29:49 +0000 (GMT)
Subject: main - gcc-fanalyzer: explicit test null not pass
Message-ID: <20210920132949.8C7193858C3B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5126ac7c3aa4f9f47a36c66095246d5b13871e61
Commit:        5126ac7c3aa4f9f47a36c66095246d5b13871e61
Parent:        e15d1e53c181b804b12f059788ed111d42353be9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 18 00:26:24 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 10:51:30 2021 +0200

gcc-fanalyzer: explicit test null not pass

Make analyzer explicitelly aware we can't get NULL here.
---
 lib/metadata/mirror.c | 5 +++++
 tools/vgcfgrestore.c  | 5 ++++-
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 050341a03..e2bf191a1 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -657,6 +657,11 @@ static int _split_mirror_images(struct logical_volume *lv,
 		dm_list_add(&split_images, &lvl->list);
 	}
 
+	if (!new_lv) {
+		log_error(INTERNAL_ERROR "New LV not found.");
+		return 0;
+	}
+
 	new_lv->name = dm_pool_strdup(lv->vg->vgmem, split_name);
 	if (!new_lv->name) {
 		log_error("Unable to rename newly split LV.");
diff --git a/tools/vgcfgrestore.c b/tools/vgcfgrestore.c
index e05c28688..e49313d14 100644
--- a/tools/vgcfgrestore.c
+++ b/tools/vgcfgrestore.c
@@ -104,7 +104,10 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_PROCESSED;
 	}
 
-	if (!_check_all_dm_devices(vg_name, &found)) {
+	if (!vg_name) {
+		log_error(INTERNAL_ERROR "VG name is not set.");
+		return ECMD_FAILED;
+	} else if (!_check_all_dm_devices(vg_name, &found)) {
 		log_warn("WARNING: Failed to check for active volumes in volume group \"%s\".", vg_name);
 	} else if (found) {
 		log_warn("WARNING: Found %u active volume(s) in volume group \"%s\".",


