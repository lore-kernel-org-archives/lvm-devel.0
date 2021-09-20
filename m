From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:30:00 +0000 (GMT)
Subject: main - cov: add error path for daemon_request_extend
Message-ID: <20210920133000.CC6663858C3B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e1840dd9e0b3be55281466e60a9a07cce068db4f
Commit:        e1840dd9e0b3be55281466e60a9a07cce068db4f
Parent:        6427803252354203dfa5d816c6a8dc0ae385051e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 20 01:48:30 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 14:26:09 2021 +0200

cov: add error path for daemon_request_extend

Check for errors in daemon_request_extend().
---
 lib/locking/lvmlockd.c | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 2284d60fe..4f9952d5b 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -186,7 +186,7 @@ static int _lockd_result(daemon_reply reply, int *result, uint32_t *lockd_flags)
 static daemon_reply _lockd_send_with_pvs(const char *req_name,
 				const struct lvmlockd_pvs *lock_pvs, ...)
 {
-	daemon_reply repl;
+	daemon_reply repl = { .error = -1 };
 	daemon_request req;
 	int i;
 	char key[32];
@@ -201,18 +201,23 @@ static daemon_reply _lockd_send_with_pvs(const char *req_name,
 
 	/* Pass PV list */
 	if (lock_pvs && lock_pvs->num) {
-		daemon_request_extend(req, "path_num = " FMTd64,
-				      (int64_t)(lock_pvs)->num, NULL);
-
+		if (!daemon_request_extend(req, "path_num = " FMTd64,
+					   (int64_t)(lock_pvs)->num, NULL)) {
+			log_error("Failed to create pvs request.");
+			goto bad;
+		}
 		for (i = 0; i < lock_pvs->num; i++) {
 			snprintf(key, sizeof(key), "path[%d] = %%s", i);
 			val = lock_pvs->path[i] ? lock_pvs->path[i] : "none";
-			daemon_request_extend(req, key, val, NULL);
+			if (!daemon_request_extend(req, key, val, NULL)) {
+				log_error("Failed to create pvs request.");
+				goto bad;
+			}
 		}
 	}
 
 	repl = daemon_send(_lvmlockd, req);
-
+bad:
 	daemon_request_destroy(req);
 
 	return repl;


