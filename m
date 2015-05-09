From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat,  9 May 2015 07:18:25 +0000 (UTC)
Subject: master - cleanup: drop extra test for NULL
Message-ID: <20150509071825.47F2260E3C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3d845e492adab0aba279f24e244d8617faa3279d
Commit:        3d845e492adab0aba279f24e244d8617faa3279d
Parent:        e047f043948758be0405ccc67c4a066e237dcbb1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 8 23:01:32 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 9 09:17:26 2015 +0200

cleanup: drop extra test for NULL

vg cannot be NULL here - it's been already used in the code above.
---
 tools/pvmove_poll.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/tools/pvmove_poll.c b/tools/pvmove_poll.c
index 61ebd23..df896b5 100644
--- a/tools/pvmove_poll.c
+++ b/tools/pvmove_poll.c
@@ -89,8 +89,7 @@ int pvmove_update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 	}
 
 	if (!suspend_lv(cmd, lv_mirr)) {
-		if (vg)
-			vg_revert(vg);
+		vg_revert(vg);
 		log_error("ABORTING: Temporary pvmove mirror reload failed.");
 		if (!revert_lv(cmd, lv_mirr))
 			stack;


