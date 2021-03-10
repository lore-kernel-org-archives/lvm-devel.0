From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 23:19:28 +0000 (GMT)
Subject: main - lvconvert: fix error path on writecache removal
Message-ID: <20210310231928.3EE793857C62@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7a99dac9ad44f0097fb64c48f7fe14a10aea07b7
Commit:        7a99dac9ad44f0097fb64c48f7fe14a10aea07b7
Parent:        127c2fc6e287f0f7edb9c0a061aaaba31bf47e45
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 10 14:07:40 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 10 23:32:12 2021 +0100

lvconvert: fix error path on writecache removal

After setting ret=0 there was missing 'goto out_release'.
Simplify with setting ret to 0 at front and to 1
at succesful end.
---
 tools/lvconvert.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 4e27008fa..4c159b01e 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5751,7 +5751,7 @@ static int _lvconvert_detach_writecache_when_clean(struct cmd_context *cmd,
 	struct logical_volume *lv_fast;
 	uint32_t lockd_state, error_flags;
 	uint64_t dirty;
-	int ret;
+	int ret = 0;
 
 	idl = dm_list_item(dm_list_first(&lr->poll_idls), struct convert_poll_id_list);
 	id = idl->id;
@@ -5780,13 +5780,11 @@ static int _lvconvert_detach_writecache_when_clean(struct cmd_context *cmd,
 
 	if (!vg) {
 		log_error("Detaching writecache interrupted - reading VG failed.");
-		ret = 0;
 		goto out_lockd;
 	}
 
 	if (error_flags) {
 		log_error("Detaching writecache interrupted - reading VG error %x.", error_flags);
-		ret = 0;
 		goto out_release;
 	}
 
@@ -5797,13 +5795,11 @@ static int _lvconvert_detach_writecache_when_clean(struct cmd_context *cmd,
 
 	if (!lv) {
 		log_error("Detaching writecache interrupted - LV not found.");
-		ret = 0;
 		goto out_release;
 	}
 
 	if (!lv_is_active(lv)) {
 		log_error("Detaching writecache interrupted - LV not active.");
-		ret = 0;
 		goto out_release;
 	}
 
@@ -5840,7 +5836,6 @@ static int _lvconvert_detach_writecache_when_clean(struct cmd_context *cmd,
 
 	if (!lv_detach_writecache_cachevol(lv, 1)) {
 		log_error("Detaching writecache cachevol failed.");
-		ret = 0;
 		goto out_release;
 	}
 
@@ -5851,7 +5846,7 @@ static int _lvconvert_detach_writecache_when_clean(struct cmd_context *cmd,
 	if (lr->remove_cache) {
 		if (lvremove_single(cmd, lv_fast, NULL) != ECMD_PROCESSED) {
 			log_error("Removing the writecache cachevol failed.");
-			ret = 0;
+			goto out_release;
 		}
 	}
 


