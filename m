From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  5 Feb 2013 15:55:01 +0000 (UTC)
Subject: master - cleanup: old style gcc
Message-ID: <20130205155501.0B1E1230F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e566faaae605cfbb35a97b46e211c68d3c7bcfd5
Commit:        e566faaae605cfbb35a97b46e211c68d3c7bcfd5
Parent:        d97605beafab98572e7e797139548dffde91274c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 5 16:48:48 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 5 16:54:12 2013 +0100

cleanup: old style gcc

---
 lib/cache/lvmetad.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index e7f00ac..886f163 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -46,7 +46,7 @@ void lvmetad_init(struct cmd_context *cmd)
 	_lvmetad_cmd = cmd;
 }
 
-static void _lvmetad_connect()
+static void _lvmetad_connect(void)
 {
 	if (!_lvmetad_use || !_lvmetad_socket || _lvmetad_connected)
 		return;
@@ -156,8 +156,10 @@ retry:
 
 static int _token_update(void)
 {
+	daemon_reply repl;
+
 	log_debug_lvmetad("Sending updated token to lvmetad: %s", _lvmetad_token ? : "<NONE>");
-	daemon_reply repl = _lvmetad_send("token_update", NULL);
+	repl = _lvmetad_send("token_update", NULL);
 
 	if (repl.error || strcmp(daemon_reply_str(repl, "response", ""), "OK")) {
 		daemon_reply_destroy(repl);


