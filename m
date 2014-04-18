From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Apr 2014 14:55:37 +0000 (UTC)
Subject: master - cleanup: dmeventd improve _get_status
Message-ID: <20140418145537.D67DB60E56@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dc21bbfabd92a982712b4dafb7c3d7ede99f815f
Commit:        dc21bbfabd92a982712b4dafb7c3d7ede99f815f
Parent:        0503af846607121e8f8019e6d0b2a98c204c2b72
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 18 14:26:36 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 18 16:51:54 2014 +0200

cleanup: dmeventd improve _get_status

Use directly dm_asprintf() to allocate buffer with message,
and properly detect failing on replacement of snprintf()
which also returns -1 on error.
---
 daemons/dmeventd/dmeventd.c |   26 ++++++++++----------------
 1 files changed, 10 insertions(+), 16 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 8dac207..e13afd2 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -503,26 +503,20 @@ static int _get_status(struct message_data *message_data)
 
 static int _get_parameters(struct message_data *message_data) {
 	struct dm_event_daemon_message *msg = message_data->msg;
-	char buf[128];
-	int r = -1;
+	int size;
 
 	dm_free(msg->data);
+	if ((size = dm_asprintf(&msg->data, "%s pid=%d daemon=%s exec_method=%s",
+				message_data->id, getpid(),
+				_foreground ? "no" : "yes",
+				_systemd_activation ? "systemd" : "direct")) < 0) {
+		stack;
+		return -ENOMEM;
+	}
 
-	if (!(dm_snprintf(buf, sizeof(buf), "%s pid=%d daemon=%s exec_method=%s",
-			  message_data->id,
-			  getpid(),
-			  _foreground ? "no" : "yes",
-			  _systemd_activation ? "systemd" : "direct")))
-		goto_out;
+	msg->size = (uint32_t) size;
 
-	msg->size = strlen(buf) + 1;
-	if (!(msg->data = dm_malloc(msg->size)))
-		goto_out;
-	if (!dm_strncpy(msg->data, buf, msg->size))
-		goto_out;
-	r = 0;
-out:
-	return r;
+	return 0;
 }
 
 /* Cleanup at exit. */


