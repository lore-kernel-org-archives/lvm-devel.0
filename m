From: David Teigland <teigland@sourceware.org>
Date: Wed, 29 Jan 2020 11:39:18 -0500
Subject: master - lvmlockd: use ret value in query function
Message-ID: <34122.120012911391300121@us-mta-189.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8810c11bc924e8871f97aa25c61e73b3b3f1fa87
Commit:        8810c11bc924e8871f97aa25c61e73b3b3f1fa87
Parent:        7404216241827d903dcb3ff441bae0c8819309d2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jan 29 10:37:28 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jan 29 10:37:28 2020 -0600

lvmlockd: use ret value in query function

---
 lib/locking/lvmlockd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index f396478..cbe2121 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -2114,7 +2114,7 @@ static int _query_lock_lv(struct cmd_context *cmd, struct volume_group *vg,
 	if (result == -ENOENT)
 		return 1;
 
-	return 1;
+	return ret;
 }
 
 /*



