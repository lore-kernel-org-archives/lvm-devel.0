From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  9 Jul 2015 14:35:27 +0000 (UTC)
Subject: master - libdaemon: config_make_nodes_v needs fixing
Message-ID: <20150709143527.8EC0161482@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=14811250420630d9f2f5f9aa3de7e8893b53e53b
Commit:        14811250420630d9f2f5f9aa3de7e8893b53e53b
Parent:        10d27998b3d2f6100e9e29e83d1d99948c55875f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 9 16:34:02 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jul 9 16:34:08 2015 +0200

libdaemon: config_make_nodes_v needs fixing

Put the change from commit #10d27998b3d2f6100e9e29e83d1d99948c55875f
back so we have working tree again for now. This code needs a bit of
a cleanup to return proper return value to check...
---
 lib/cache/lvmetad.c            |    9 ++-------
 libdaemon/client/config-util.c |    4 ++++
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index d22df75..60f0277 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -148,13 +148,12 @@ static int _lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler
 static daemon_reply _lvmetad_send(const char *id, ...)
 {
 	va_list ap;
-	daemon_reply repl;
+	daemon_reply repl = { 0 };
 	daemon_request req;
 	unsigned num_rescans = 0;
 	unsigned total_usecs_waited = 0;
 	unsigned max_remaining_sleep_times = 1;
 	unsigned wait_usecs;
-	int r;
 
 retry:
 	req = daemon_request_make(id);
@@ -165,12 +164,8 @@ retry:
 	}
 
 	va_start(ap, id);
-	r = daemon_request_extend_v(req, ap);
+	daemon_request_extend_v(req, ap);
 	va_end(ap);
-	if (!r) {
-		repl.error = ENOMEM;
-		return repl;
-	}
 
 	repl = daemon_send(_lvmetad, req);
 
diff --git a/libdaemon/client/config-util.c b/libdaemon/client/config-util.c
index 895815c..023257e 100644
--- a/libdaemon/client/config-util.c
+++ b/libdaemon/client/config-util.c
@@ -208,6 +208,10 @@ struct dm_config_node *make_int_node(struct dm_config_tree *cft,
 	return cn;
 }
 
+/*
+ * FIXME: return 1 even if VA list is empty and return the
+ *        dm_config_node* result as output parameter
+ */
 struct dm_config_node *config_make_nodes_v(struct dm_config_tree *cft,
 					   struct dm_config_node *parent,
 					   struct dm_config_node *pre_sib,


