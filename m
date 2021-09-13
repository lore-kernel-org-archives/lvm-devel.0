From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Sep 2021 10:36:21 +0000 (GMT)
Subject: main - gcc: remove unused vg setting
Message-ID: <20210913103621.A580E3858002@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=064979dc3238171cc4029ebfcbf63ad71cc7d9cd
Commit:        064979dc3238171cc4029ebfcbf63ad71cc7d9cd
Parent:        00ec716b4db371f0e28880e95539b10208f19d37
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 10 23:34:58 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 13 12:34:41 2021 +0200

gcc: remove unused vg setting

---
 tools/lvconvert.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index d73e16e3a..33ab0637d 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -6294,7 +6294,6 @@ int lvconvert_to_cache_with_cachevol_cmd(struct cmd_context *cmd, int argc, char
 
 static int _lvconvert_integrity_remove(struct cmd_context *cmd, struct logical_volume *lv)
 {
-	struct volume_group *vg = lv->vg;
 	int ret = 0;
 
 	if (!lv_is_integrity(lv) && !lv_is_raid(lv)) {


