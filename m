From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 30 Apr 2019 07:30:55 -0400
Subject: stable-2.02 - lv_manip: insert remove layer skips pools
Message-ID: <201904301130.x3UBUtNr020477@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f3be66c002b6dd5b6d1eabc395e10e97d49a1e99
Commit:        f3be66c002b6dd5b6d1eabc395e10e97d49a1e99
Parent:        2047d405af85d0f7e0d494510f439a1e644f3285
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 24 14:14:31 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 30 12:08:36 2019 +0200

lv_manip: insert remove layer skips pools

Fixing renaming of subLVs when removing and inserting layers - this
got visible when using stacked VDO pools.
---
 lib/metadata/lv_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 68ad3c3..f960fad 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6781,7 +6781,7 @@ int remove_layer_from_lv(struct logical_volume *lv,
 			if (strstr(layer_lv->name, _suffixes[r]) == 0) {
 				lv_names.old = layer_lv->name;
 				lv_names.new = parent_lv->name;
-				if (!for_each_sub_lv(parent_lv, _rename_cb, (void *) &lv_names))
+				if (!for_each_sub_lv(parent_lv, _rename_skip_pools_externals_cb, (void *) &lv_names))
 					return_0;
 				break;
 			}
@@ -6905,7 +6905,7 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 		if (strcmp(layer_suffix, _suffixes[i]) == 0) {
 			lv_names.old = lv_where->name;
 			lv_names.new = layer_lv->name;
-			if (!for_each_sub_lv(layer_lv, _rename_cb, (void *) &lv_names))
+			if (!for_each_sub_lv(layer_lv, _rename_skip_pools_externals_cb, (void *) &lv_names))
 				return_NULL;
 			break;
 		}


