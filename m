From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 15 Oct 2021 21:42:25 +0000 (GMT)
Subject: main - cov: check pointer before dereferencing
Message-ID: <20211015214225.1A0223858401@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=882141eb8c1a9718652cd903e411b6876aff54ef
Commit:        882141eb8c1a9718652cd903e411b6876aff54ef
Parent:        65ba4964df27d2d3f308d2f378e814290ba6d7bb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 15 14:48:48 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 15 23:40:56 2021 +0200

cov: check pointer before dereferencing

Check pv2 is non-null before trying to deref its tags.
---
 lib/metadata/lv_manip.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 1a4e613a7..003748d6f 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2354,7 +2354,7 @@ static int _match_pv_tags(const struct dm_config_node *cling_tag_list_cn,
 	const struct dm_config_value *cv;
 	const char *str;
 	const char *tag_matched;
-	struct dm_list *tags_to_match = mem ? NULL : pv_tags ? : &pv2->tags;
+	struct dm_list *tags_to_match = mem ? NULL : pv_tags ? : ((pv2) ? &pv2->tags : NULL);
 	struct dm_str_list *sl;
 	unsigned first_tag = 1;
 
@@ -2409,7 +2409,7 @@ static int _match_pv_tags(const struct dm_config_node *cling_tag_list_cn,
 				continue;
 			}
 
-			if (!str_list_match_list(&pv1->tags, tags_to_match, &tag_matched))
+			if (tags_to_match && !str_list_match_list(&pv1->tags, tags_to_match, &tag_matched))
 				continue;
 
 			if (!pv_tags) {


