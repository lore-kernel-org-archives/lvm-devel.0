From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 13 Oct 2012 17:22:16 +0000 (UTC)
Subject: master - lvmetad: fix memory leaks in error paths
Message-ID: <20121013172216.9B55B22CC@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4379365cae3a1efa8299e0d6cf248520a136c798
Commit:        4379365cae3a1efa8299e0d6cf248520a136c798
Parent:        5df6ec24bffc2df7028639f06b580eda46d894df
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 13 19:19:50 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Oct 13 19:19:50 2012 +0200

lvmetad: fix memory leaks in error paths

Destroy interator in error path.
Releasy any possible allocated buffer from buffer_append_f
and buffer_append_vf  in error path.
---
 lib/cache/lvmetad.c              |    1 +
 libdaemon/client/daemon-client.c |    7 ++++---
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 81b6f04..1a52787 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -880,6 +880,7 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler)
 	future_token = _lvmetad_token;
 	_lvmetad_token = (char *) "update in progress";
 	if (!_token_update()) {
+		dev_iter_destroy(iter);
 		_lvmetad_token = future_token;
 		return 0;
 	}
diff --git a/libdaemon/client/daemon-client.c b/libdaemon/client/daemon-client.c
index c4422d6..a010cc0 100644
--- a/libdaemon/client/daemon-client.c
+++ b/libdaemon/client/daemon-client.c
@@ -108,10 +108,11 @@ daemon_reply daemon_send_simple_v(daemon_handle h, const char *id, va_list ap)
 	daemon_request rq = { .cft = NULL };
 	daemon_reply repl;
 
-	if (!buffer_append_f(&rq.buffer, "request = %s", id, NULL))
-		return err;
-	if (!buffer_append_vf(&rq.buffer, ap))
+	if (!buffer_append_f(&rq.buffer, "request = %s", id, NULL) ||
+	    !buffer_append_vf(&rq.buffer, ap)) {
+		buffer_destroy(&rq.buffer);
 		return err;
+	}
 
 	repl = daemon_send(h, rq);
 	buffer_destroy(&rq.buffer);


