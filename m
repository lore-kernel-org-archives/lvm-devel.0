From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 14 Jan 2015 13:54:54 +0000 (UTC)
Subject: master - cleanup: missed for build without devmapper
Message-ID: <20150114135454.BBBE060C44@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1e050a77ff333fd1849eb8068b6d22cb9411fc06
Commit:        1e050a77ff333fd1849eb8068b6d22cb9411fc06
Parent:        0869631d7d197fec3ea909c243a5e1f2901bea5c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 14 13:03:52 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 14 14:50:08 2015 +0100

cleanup: missed for build without devmapper

configure --disable-devmapper build fixes.
---
 lib/activate/activate.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 94ad9e2..ed41058 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -238,6 +238,22 @@ int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, int use_layer,
 {
 	return 0;
 }
+int lv_info_with_seg_status(struct cmd_context *cmd, const struct logical_volume *lv,
+			    const struct lv_segment *lv_seg, int use_layer,
+			    struct lv_with_info_and_seg_status *status,
+			    int with_open_count, int with_read_ahead)
+{
+	return 0;
+}
+int lv_status(struct cmd_context *cmd, const struct lv_segment *lv_seg,
+	      struct lv_seg_status *lv_seg_status)
+{
+	return 0;
+}
+int lv_cache_status(const struct logical_volume *cache_lv,
+		    struct lv_status_cache **status)
+{
+}
 int lv_check_not_in_use(const struct logical_volume *lv)
 {
         return 0;


