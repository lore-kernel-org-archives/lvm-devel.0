From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 21 Oct 2019 09:33:12 -0400
Subject: master - cache: drop _cpool suffix from unused cache-pool
Message-ID: <201910211333.x9LDXCt3019593@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=23f660cf98fd966525672309ee821348edebd014
Commit:        23f660cf98fd966525672309ee821348edebd014
Parent:        a5f8e7a96cd26afd14a8ddc6ab1a64a32dcf6fc6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 21 09:22:32 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 21 12:14:15 2019 +0200

cache: drop _cpool suffix from unused cache-pool

Drop _cpool prefix if present and cache-pool is going to be unused.
---
 tools/lvconvert.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 8b5bf51..9159f57 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1913,6 +1913,8 @@ static int _lvconvert_split_and_keep_cachepool(struct cmd_context *cmd,
 				   struct logical_volume *lv,
 				   struct logical_volume *lv_fast)
 {
+	char name[NAME_LEN];
+
 	if (!archive(lv->vg))
 		return_0;
 
@@ -1926,6 +1928,14 @@ static int _lvconvert_split_and_keep_cachepool(struct cmd_context *cmd,
 	if (!lv_cache_remove(lv))
 		return_0;
 
+	/* Cut off suffix _cpool */
+	if (!drop_lvname_suffix(name, lv_fast->name, "cpool")) {
+		/* likely older instance of metadata */
+		log_debug("LV %s has no suffix for cachepool (skipping rename).",
+			  display_lvname(lv_fast));
+	} else if (!lv_uniq_rename_update(cmd, lv_fast, name, 0))
+		return_0;
+
 	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
 		return_0;
 


