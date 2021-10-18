From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 18 Oct 2021 17:19:29 +0000 (GMT)
Subject: main - cleanup: use const char buffer
Message-ID: <20211018171929.53E48385840D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a172a02a9a980d084d5729cc8483bdddad0100f2
Commit:        a172a02a9a980d084d5729cc8483bdddad0100f2
Parent:        9cf4eac250ef7abd5e0961da2371294da07ab4de
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 16 10:09:02 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 18 19:17:27 2021 +0200

cleanup: use const char buffer

---
 lib/locking/lvmlockd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 4f9952d5b..b598df3d6 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -503,7 +503,7 @@ static int _create_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg,
 		.read_ahead = DM_READ_AHEAD_NONE,
 		.stripes = 1,
 		.vg_name = vg->name,
-		.lv_name = dm_pool_strdup(cmd->mem, lock_lv_name),
+		.lv_name = lock_lv_name,
 		.zero = 1,
 	};
 


