From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 20 Mar 2019 09:39:58 -0400
Subject: master - lv_manip: insert remove layer skips pools
Message-ID: <201903201339.x2KDdwwg012522@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0db22c5f81986d9573e0a704397a6de779fb832e
Commit:        0db22c5f81986d9573e0a704397a6de779fb832e
Parent:        ac31bfd6fd57a4ee281ef0c17448aae2b22eb300
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 24 14:14:31 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 20 14:38:05 2019 +0100

lv_manip: insert remove layer skips pools

Fixing renaming of subLVs when removing and inserting layers - this
got visible when using stacked VDO pools.
---
 lib/metadata/lv_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 6360241..a2f7d74 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6954,7 +6954,7 @@ int remove_layer_from_lv(struct logical_volume *lv,
 			if (strstr(layer_lv->name, _suffixes[r]) == 0) {
 				lv_names.old = layer_lv->name;
 				lv_names.new = parent_lv->name;
-				if (!for_each_sub_lv(parent_lv, _rename_cb, (void *) &lv_names))
+				if (!for_each_sub_lv(parent_lv, _rename_skip_pools_externals_cb, (void *) &lv_names))
 					return_0;
 				break;
 			}
@@ -7072,7 +7072,7 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 		if (strcmp(layer_suffix, _suffixes[i]) == 0) {
 			lv_names.old = lv_where->name;
 			lv_names.new = layer_lv->name;
-			if (!for_each_sub_lv(layer_lv, _rename_cb, (void *) &lv_names))
+			if (!for_each_sub_lv(layer_lv, _rename_skip_pools_externals_cb, (void *) &lv_names))
 				return_NULL;
 			break;
 		}


