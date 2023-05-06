From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat,  6 May 2023 20:46:04 +0000 (GMT)
Subject: main - cov: ensure NULL baton is not dereferenced
Message-ID: <20230506204604.0EC393858D35@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=871d9f379f79f1969d71b660164efe18515826c2
Commit:        871d9f379f79f1969d71b660164efe18515826c2
Parent:        662020c221fdb3e23c66947f6c81f99a0950744a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 26 13:37:41 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 6 19:22:05 2023 +0200

cov: ensure NULL baton is not dereferenced

---
 tools/pvmove_poll.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/pvmove_poll.c b/tools/pvmove_poll.c
index 751313cd7..6b3ab4550 100644
--- a/tools/pvmove_poll.c
+++ b/tools/pvmove_poll.c
@@ -20,7 +20,7 @@
 static int _is_pvmove_image_removable(struct logical_volume *mimage_lv,
 				      void *baton)
 {
-	uint32_t mimage_to_remove = *((uint32_t *)baton);
+	uint32_t mimage_to_remove = baton ? *((uint32_t *)baton) : UINT32_MAX;
 	struct lv_segment *mirror_seg;
 
 	if (!(mirror_seg = get_only_segment_using_this_lv(mimage_lv))) {

