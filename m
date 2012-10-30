From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue, 30 Oct 2012 19:40:32 +0000 (UTC)
Subject: master - lvmetad: Init lazily, to avoid socket access on config overrides.
Message-ID: <20121030194033.0FDB0A0DE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=983f0b46f2de85b8de0e2d7f8afbdf53f132a87a
Commit:        983f0b46f2de85b8de0e2d7f8afbdf53f132a87a
Parent:        7c59199d4932d7edcd2919d6d45ec4baac590e2e
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Oct 29 21:39:46 2012 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Oct 30 09:15:47 2012 +0100

lvmetad: Init lazily, to avoid socket access on config overrides.

---
 lib/cache/lvmetad.c |   28 ++++++++++++++++++++++------
 1 files changed, 22 insertions(+), 6 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 6a374ac..72e07fd 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -33,7 +33,8 @@ static struct cmd_context *_lvmetad_cmd = NULL;
 
 void lvmetad_disconnect(void)
 {
-	daemon_close(_lvmetad);
+	if (_lvmetad_connected)
+		daemon_close(_lvmetad);
 	_lvmetad_connected = 0;
 	_lvmetad_cmd = NULL;
 }
@@ -41,19 +42,25 @@ void lvmetad_disconnect(void)
 void lvmetad_init(struct cmd_context *cmd)
 {
 	if (!_lvmetad_use && !access(LVMETAD_PIDFILE, F_OK))
-		log_warn("WARNING: lvmetad is running but disabled. Restart lvmetad before enabling it!");
+		log_warn("WARNING: lvmetad is running but disabled."
+			 " Restart lvmetad before enabling it!");
+	_lvmetad_cmd = cmd;
+}
+
+static void _lvmetad_connect()
+{
 	if (_lvmetad_use && _lvmetad_socket && !_lvmetad_connected) {
 		assert(_lvmetad_socket);
 		_lvmetad = lvmetad_open(_lvmetad_socket);
-		if (_lvmetad.socket_fd >= 0 && !_lvmetad.error) {
+		if (_lvmetad.socket_fd >= 0 && !_lvmetad.error)
 			_lvmetad_connected = 1;
-			_lvmetad_cmd = cmd;
-		}
 	}
 }
 
 void lvmetad_warning(void)
 {
+	if (!_lvmetad_connected)
+		_lvmetad_connect();
 	if (_lvmetad_use && (_lvmetad.socket_fd < 0 || _lvmetad.error))
 		log_warn("WARNING: Failed to connect to lvmetad: %s. Falling back to internal scanning.",
 			 strerror(_lvmetad.error));
@@ -61,7 +68,11 @@ void lvmetad_warning(void)
 
 int lvmetad_active(void)
 {
-	return _lvmetad_use && _lvmetad_connected;
+	if (!_lvmetad_use)
+		return 0;
+	if (!_lvmetad_connected)
+		_lvmetad_connect();
+	return _lvmetad_connected;
 }
 
 void lvmetad_set_active(int active)
@@ -873,6 +884,11 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler)
 	char *future_token;
 	int was_silent;
 
+	if (!lvmetad_active()) {
+		log_error("Cannot proceed since lvmetad is not active.");
+		return 0;
+	}
+
 	if (!(iter = dev_iter_create(cmd->lvmetad_filter, 1))) {
 		log_error("dev_iter creation failed");
 		return 0;


