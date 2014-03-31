From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 31 Mar 2014 10:06:42 +0000 (UTC)
Subject: master - vg_validate: check size of lv_name + vg_name
Message-ID: <20140331100642.A7CFB60AC5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=84beba5d7f13c235e14938b3ecfbcb16f938364a
Commit:        84beba5d7f13c235e14938b3ecfbcb16f938364a
Parent:        6570d36ad5dff3f2d9e4822cd8e2c0860d8a720a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 31 11:51:50 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 31 12:05:32 2014 +0200

vg_validate: check size of lv_name + vg_name

Since the whole dm device name may not exceed 127 characters,
validate no LV names is bigger then this limit.
---
 WHATS_NEW               |    1 +
 lib/metadata/metadata.c |   11 +++++++++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 34d567f..0a95f3d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Extend internal validation of lv names size is less then 128 chars.
   Fail in resume for lvrename will result in failing command.
   Validate length of new LV name in lvrename to not exceed 127 characters.
   Add explict error message when using lvdisplay -c -m.
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 279043b..798f3ab 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2336,6 +2336,8 @@ int vg_validate(struct volume_group *vg)
 	unsigned pv_count = 0;
 	unsigned num_snapshots = 0;
 	unsigned spare_count = 0;
+	size_t vg_name_len = strlen(vg->name);
+	size_t dev_name_len;
 	struct validate_hash vhash = { NULL };
 
 	if (vg->alloc == ALLOC_CLING_BY_TAGS) {
@@ -2417,6 +2419,15 @@ int vg_validate(struct volume_group *vg)
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv_count++;
 
+		dev_name_len = strlen(lvl->lv->name) + vg_name_len + 3;
+		if (dev_name_len >= NAME_LEN) {
+			log_error(INTERNAL_ERROR "LV name \"%s/%s\" length %"
+				  PRIsize_t " is not supported.",
+				  vg->name, lvl->lv->name, dev_name_len);
+			r = 0;
+		}
+
+
 		if (lv_is_cow(lvl->lv))
 			num_snapshots++;
 


