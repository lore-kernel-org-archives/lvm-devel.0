From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 21 Apr 2016 14:28:25 +0000 (UTC)
Subject: master - lvmetad: check for socket in connect
Message-ID: <20160421142825.7B2846104B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d00b70c789cca1ca73b3d1311db9981d9ca5056b
Commit:        d00b70c789cca1ca73b3d1311db9981d9ca5056b
Parent:        0778d2e9857966e2d7e8f44c7f769fbdebb03a73
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Apr 21 09:27:20 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Apr 21 09:27:20 2016 -0500

lvmetad: check for socket in connect

We can connect if the socket is present, even
though the pidfile may not exist, since systemd
may start the process when the socket is opened.
---
 lib/cache/lvmetad.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index bbf3550..e50234a 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -126,8 +126,8 @@ void lvmetad_disconnect(void)
 
 int lvmetad_connect(struct cmd_context *cmd)
 {
-	if (access(getenv("LVM_LVMETAD_PIDFILE") ? : LVMETAD_PIDFILE, F_OK)) {
-		log_debug_lvmetad("Failed to connect to lvmetad: not running.");
+	if (!lvmetad_socket_present()) {
+		log_debug_lvmetad("Failed to connect to lvmetad: socket not present.");
 		_lvmetad_connected = 0;
 		_lvmetad_use = 0;
 		_lvmetad_cmd = NULL;


