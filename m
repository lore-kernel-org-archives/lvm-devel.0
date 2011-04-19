From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 19 Apr 2011 14:55:24 +0200
Subject: [PATCH 1/5] change API to use unsigned for #copies
In-Reply-To: <cover.1303215346.git.zkabelac@redhat.com>
References: <cover.1303215346.git.zkabelac@redhat.com>
Message-ID: <d793383cfe28160fe9f34d4dbd5475aaa666260c.1303215346.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/metadata-exported.h |    2 +-
 lib/metadata/metadata.c          |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 80de552a..dac155a 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -428,7 +428,7 @@ struct physical_volume *pv_create(const struct cmd_context *cmd,
 				  uint32_t existing_extent_count,
 				  uint32_t existing_extent_size,
 				  uint64_t label_sector,
-				  int pvmetadatacopies,
+				  unsigned pvmetadatacopies,
 				  uint64_t pvmetadatasize,
 				  unsigned metadataignore);
 int pv_resize(struct physical_volume *pv, struct volume_group *vg,
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 47a2d98..756ce41 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1582,7 +1582,7 @@ struct physical_volume *pv_create(const struct cmd_context *cmd,
 				  uint32_t existing_extent_count,
 				  uint32_t existing_extent_size,
 				  uint64_t label_sector,
-				  int pvmetadatacopies,
+				  unsigned pvmetadatacopies,
 				  uint64_t pvmetadatasize,
 				  unsigned metadataignore)
 {
-- 
1.7.4.4


