From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 20 Jan 2015 15:25:35 +0000 (UTC)
Subject: master - report: proper lv_attr_dup emulation
Message-ID: <20150120152535.DCEC36062C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=87e80b6aac630f0c26d128006c975841a76ca890
Commit:        87e80b6aac630f0c26d128006c975841a76ca890
Parent:        158e9988768be344c0c97acdf52d1c020ab8c83e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 20 16:24:45 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 20 16:24:45 2015 +0100

report: proper lv_attr_dup emulation

We need to create a mempool for proper emulation of lv_attr_dup
for lvm2api.
---
 lib/metadata/lv.c |   15 ++++++++++++---
 1 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 540eedb..eb67d20 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -827,14 +827,23 @@ out:
 /* backward compatible internal API for lvm2api, TODO improve it */
 char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
+	char *ret = NULL;
 	struct lv_with_info_and_seg_status status = {
-		.seg_status.type = SEG_STATUS_NONE
+		.seg_status.type = SEG_STATUS_NONE,
+		.lv = lv
 	};
 
+	if (!(status.seg_status.mem = dm_pool_create("reporter_pool", 1024)))
+		return_0;
+
 	if (!lv_info_with_seg_status(lv->vg->cmd, lv, first_seg(lv), 1, &status, 1, 1))
-		return_NULL;
+		goto_bad;
+
+	ret = lv_attr_dup_with_info_and_seg_status(mem, &status);
+bad:
+	dm_pool_destroy(status.seg_status.mem);
 
-	return lv_attr_dup_with_info_and_seg_status(mem, &status);
+	return ret;
 }
 
 int lv_set_creation(struct logical_volume *lv,


