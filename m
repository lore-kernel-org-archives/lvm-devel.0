From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 15 Oct 2012 10:46:40 +0000 (UTC)
Subject: master - lvmetad: Only print scanning messages when scanning 1 device.
Message-ID: <20121015104640.814192274@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=08ba1b447205913a1979143d9bf3b6afbdc5c742
Commit:        08ba1b447205913a1979143d9bf3b6afbdc5c742
Parent:        78dafcba994be668c540ecacd828f61d4a26ed85
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Oct 15 12:44:19 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Oct 15 12:45:50 2012 +0200

lvmetad: Only print scanning messages when scanning 1 device.

---
 lib/cache/lvmetad.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index f7d250e..6a374ac 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -871,6 +871,7 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler)
 	daemon_reply reply;
 	int r = 1;
 	char *future_token;
+	int was_silent;
 
 	if (!(iter = dev_iter_create(cmd->lvmetad_filter, 1))) {
 		log_error("dev_iter creation failed");
@@ -890,6 +891,9 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler)
 		r = 0;
 	daemon_reply_destroy(reply);
 
+	was_silent = silent_mode();
+	init_silent(1);
+
 	while ((dev = dev_iter_get(iter))) {
 		if (!lvmetad_pvscan_single(cmd, dev, handler))
 			r = 0;
@@ -898,6 +902,8 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler)
 			break;
 	}
 
+	init_silent(was_silent);
+
 	dev_iter_destroy(iter);
 
 	_lvmetad_token = future_token;


