From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 23:19:36 +0000 (GMT)
Subject: main - gcc: adding const
Message-ID: <20210310231936.3CD403858001@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a654148b76c71022997c3ea509b52354985b8d7f
Commit:        a654148b76c71022997c3ea509b52354985b8d7f
Parent:        d7bb23dd156cd059500e32a4f3966d3d1be52225
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 10 21:58:57 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 11 00:18:01 2021 +0100

gcc: adding const

---
 lib/metadata/metadata.c | 2 +-
 lib/metadata/metadata.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 71e59207d..ed1c05f75 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1659,7 +1659,7 @@ struct lv_list *find_lv_in_lv_list(const struct dm_list *ll,
 	return NULL;
 }
 
-struct logical_volume *find_lv_in_vg_by_lvid(struct volume_group *vg,
+struct logical_volume *find_lv_in_vg_by_lvid(const struct volume_group *vg,
 					     const union lvid *lvid)
 {
 	struct lv_list *lvl;
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index c6500d488..3ea77ce2e 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -393,7 +393,7 @@ uint32_t vg_bad_status_bits(const struct volume_group *vg, uint64_t status);
 int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 		 struct physical_volume *pv, int new_pv);
 
-struct logical_volume *find_lv_in_vg_by_lvid(struct volume_group *vg,
+struct logical_volume *find_lv_in_vg_by_lvid(const struct volume_group *vg,
 					     const union lvid *lvid);
 
 struct lv_list *find_lv_in_lv_list(const struct dm_list *ll,


