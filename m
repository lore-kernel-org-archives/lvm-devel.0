From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  8 Jan 2014 11:05:38 +0000 (UTC)
Subject: master - thin: accept const struct
Message-ID: <20140108110538.3BDF76119F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=95b1af72803336f8a2e559bae4eadefff9a48a7a
Commit:        95b1af72803336f8a2e559bae4eadefff9a48a7a
Parent:        de3abfa6222c7c35f8262032112fea3b6098fd58
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 8 10:27:17 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 8 11:57:43 2014 +0100

thin: accept const struct

---
 lib/metadata/metadata-exported.h |    2 +-
 lib/metadata/thin_manip.c        |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 6a959d1..8e36891 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -672,7 +672,7 @@ int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 uint64_t extents_from_size(struct cmd_context *cmd, uint64_t size,
 			   uint32_t extent_size);
 
-struct logical_volume *find_pool_lv(struct logical_volume *lv);
+struct logical_volume *find_pool_lv(const struct logical_volume *lv);
 int pool_is_active(const struct logical_volume *pool_lv);
 int pool_can_resize_metadata(const struct logical_volume *pool_lv);
 int update_pool_lv(struct logical_volume *lv, int activate);
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 0223752..e12a8ad 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -392,7 +392,7 @@ struct lv_segment *find_pool_seg(const struct lv_segment *seg)
 	return pool_seg;
 }
 
-struct logical_volume *find_pool_lv(struct logical_volume *lv)
+struct logical_volume *find_pool_lv(const struct logical_volume *lv)
 {
 	struct lv_segment *seg;
 


