From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 4 Feb 2020 11:22:53 -0500
Subject: master - lvmlockd: move eval of ENOENT
Message-ID: <95836.120020411224400499@us-mta-379.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bcfe4993e577167440be511da4ec879fac19afdb
Commit:        bcfe4993e577167440be511da4ec879fac19afdb
Parent:        555d6d4e62b5a10a8f52454a93e3cdc65e0d1abd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 30 12:52:19 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 4 17:22:06 2020 +0100

lvmlockd: move eval of ENOENT

To avoid logging 'errors' for no real error state (ENOENT),
move this evaluation upward in the code.
---
 lib/locking/lvmlockd.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index cbe2121..4161210 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -2092,7 +2092,8 @@ static int _query_lock_lv(struct cmd_context *cmd, struct volume_group *vg,
 		log_error("Lock query failed for LV %s/%s", vg->name, lv_name);
 		return 0;
 	} else {
-		ret = (result < 0) ? 0 : 1;
+		/* ENOENT => The lv was not active/locked. */
+		ret = (result < 0 && (result != -ENOENT)) ? 0 : 1;
 	}
 
 	if (!ret)
@@ -2110,10 +2111,6 @@ static int _query_lock_lv(struct cmd_context *cmd, struct volume_group *vg,
 
 	daemon_reply_destroy(reply);
 
-	/* The lv was not active/locked. */
-	if (result == -ENOENT)
-		return 1;
-
 	return ret;
 }
 



