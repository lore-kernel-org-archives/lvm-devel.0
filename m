From: David Teigland <teigland@sourceware.org>
Date: Fri,  2 Oct 2020 14:25:13 +0000 (GMT)
Subject: master - lvconvert: move log message to fix segfault
Message-ID: <20201002142513.162B7388EC0E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=91f869e43c8f3161d8bcc54477dfab4024a73a58
Commit:        91f869e43c8f3161d8bcc54477dfab4024a73a58
Parent:        0143c7aebe2389ceada6ca0a314a3ff0fd9cdfef
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Oct 2 09:23:25 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Oct 2 09:23:25 2020 -0500

lvconvert: move log message to fix segfault

log message was printing lv name from released vg
---
 tools/lvconvert.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index a4ec48ede..7d5a541d0 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5774,14 +5774,15 @@ static int _lvconvert_detach_writecache_when_clean(struct cmd_context *cmd,
 	backup(vg);
 
 out_release:
+	if (ret)
+		log_print_unless_silent("Logical volume %s write cache has been detached.", display_lvname(lv));
+
 	unlock_and_release_vg(cmd, vg, vg->name);
 
 out_lockd:
 	if (!lockd_vg(cmd, id->vg_name, "un", 0, &lockd_state))
 		stack;
 
-	if (ret)
-		log_print_unless_silent("Logical volume %s write cache has been detached.", display_lvname(lv));
 	return ret;
 }
 


