From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Feb 2023 16:53:17 +0000 (GMT)
Subject: main - metadata-exported.h: correcting definition
Message-ID: <20230210165317.BEAE4385840D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=631762d6db1390487694e6b7ae1de885911458b2
Commit:        631762d6db1390487694e6b7ae1de885911458b2
Parent:        e3534d0f68c698532101eea211ece52b7aee315c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 10 17:48:28 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 10 17:50:27 2023 +0100

metadata-exported.h: correcting definition

Fixing minor mismatch between definition and declaration of
update_thin_pool_params().
---
 lib/metadata/metadata-exported.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index a27345781..ded0389b1 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -896,7 +896,7 @@ int update_thin_pool_params(struct cmd_context *cmd,
 			    uint32_t pool_data_extents,
 			    uint32_t *pool_metadata_extents,
 			    struct logical_volume *metadata_lv,
-			    unsigned *crop_metadata,
+			    thin_crop_metadata_t *crop_metadata,
 			    int *chunk_size_calc_method, uint32_t *chunk_size,
 			    thin_discards_t *discards, thin_zero_t *zero_new_blocks);
 

