From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 30 Oct 2014 23:00:53 +0000 (UTC)
Subject: master - cleanup: extents_from_size is 32bit value
Message-ID: <20141030230053.8955E60AA2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=888b21e9bd10d70154fb361359a2342aa56af27a
Commit:        888b21e9bd10d70154fb361359a2342aa56af27a
Parent:        9a6cf3d9f4b43e0d47ac686d8acc5f280d4bfd70
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 30 11:38:49 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 30 23:58:49 2014 +0100

cleanup: extents_from_size is 32bit value

Current lvm2 does support only 32bit extents count.
---
 lib/metadata/metadata-exported.h |    2 +-
 lib/metadata/metadata.c          |    5 +++--
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 890e808..013da16 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -731,7 +731,7 @@ int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 int lv_update_and_reload(struct logical_volume *lv);
 int lv_update_and_reload_origin(struct logical_volume *lv);
 
-uint64_t extents_from_size(struct cmd_context *cmd, uint64_t size,
+uint32_t extents_from_size(struct cmd_context *cmd, uint64_t size,
 			   uint32_t extent_size);
 uint32_t extents_from_percent_size(struct volume_group *vg, const struct dm_list *pvh,
 				   uint32_t extents, int roundup,
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 2038f06..df2d6a3 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1075,7 +1075,8 @@ bad:
 	return NULL;
 }
 
-uint64_t extents_from_size(struct cmd_context *cmd, uint64_t size,
+/* Rounds up by default */
+uint32_t extents_from_size(struct cmd_context *cmd, uint64_t size,
 			   uint32_t extent_size)
 {
 	if (size % extent_size) {
@@ -1094,7 +1095,7 @@ uint64_t extents_from_size(struct cmd_context *cmd, uint64_t size,
 		return 0;
 	}
 
-	return size / extent_size;
+	return (uint32_t) (size / extent_size);
 }
 
 /*


