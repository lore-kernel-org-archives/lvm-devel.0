From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 15 Jan 2013 14:06:09 +0000 (UTC)
Subject: master - dmeventd: close dmeventd FIFO FDs on exec (add FD_CLOEXEC).
Message-ID: <20130115140609.72AD916CC@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6fc596ca90640817fd555942bd5b5d3b7404a177
Commit:        6fc596ca90640817fd555942bd5b5d3b7404a177
Parent:        2b760a7fa7de3b1e3d2db182e5c6fb472b4fe9a1
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jan 15 14:59:54 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jan 15 14:59:54 2013 +0100

dmeventd: close dmeventd FIFO FDs on exec (add FD_CLOEXEC).

---
 WHATS_NEW_DM                |    1 +
 daemons/dmeventd/dmeventd.c |   37 ++++++++++++++++++++++++++++---------
 2 files changed, 29 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index ce342cf..12ba71e 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.78 - 
 ===================================
+  Close open dmeventd FIFO file descriptors on exec (FD_CLOEXEC).
   Fix resource leak in error path of dmeventd's umount of thin volume.
   Automatically deactivate failed preloaded dm tree node.
   Add DM_DISABLE_UDEV environment variable to manage dev nodes by libdm only.
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 13148c3..5f2339f 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1237,7 +1237,8 @@ static int _get_timeout(struct message_data *message_data)
 /* Initialize a fifos structure with path names. */
 static void _init_fifos(struct dm_event_fifos *fifos)
 {
-	memset(fifos, 0, sizeof(*fifos));
+	fifos->client = -1;
+	fifos->server = -1;
 
 	fifos->client_path = DM_EVENT_FIFO_CLIENT;
 	fifos->server_path = DM_EVENT_FIFO_SERVER;
@@ -1254,7 +1255,7 @@ static int _open_fifos(struct dm_event_fifos *fifos)
 		syslog(LOG_ERR, "%s: Failed to create client fifo %s: %m.\n",
 		       __func__, fifos->client_path);
 		(void) dm_prepare_selinux_context(NULL, 0);
-		return 0;
+		goto fail;
 	}
 
 	/* Create server fifo. */
@@ -1263,7 +1264,7 @@ static int _open_fifos(struct dm_event_fifos *fifos)
 		syslog(LOG_ERR, "%s: Failed to create server fifo %s: %m.\n",
 		       __func__, fifos->server_path);
 		(void) dm_prepare_selinux_context(NULL, 0);
-		return 0;
+		goto fail;
 	}
 
 	(void) dm_prepare_selinux_context(NULL, 0);
@@ -1281,31 +1282,49 @@ static int _open_fifos(struct dm_event_fifos *fifos)
 	if (chmod(fifos->client_path, 0600)) {
 		syslog(LOG_ERR, "Unable to set correct file permissions on %s: %m.\n",
 		       fifos->client_path);
-		return 0;
+		goto fail;
 	}
 
 	if (chmod(fifos->server_path, 0600)) {
 		syslog(LOG_ERR, "Unable to set correct file permissions on %s: %m.\n",
 		       fifos->server_path);
-		return 0;
+		goto fail;
 	}
 
 	/* Need to open read+write or we will block or fail */
 	if ((fifos->server = open(fifos->server_path, O_RDWR)) < 0) {
 		syslog(LOG_ERR, "Failed to open fifo server %s: %m.\n",
 		       fifos->server_path);
-		return 0;
+		goto fail;
+	}
+
+	if (fcntl(fifos->server, F_SETFD, FD_CLOEXEC) < 0) {
+		syslog(LOG_ERR, "Failed to set FD_CLOEXEC for fifo server %s: %m.\n",
+		       fifos->server_path);
+		goto fail;
 	}
 
 	/* Need to open read+write for select() to work. */
 	if ((fifos->client = open(fifos->client_path, O_RDWR)) < 0) {
 		syslog(LOG_ERR, "Failed to open fifo client %s: %m", fifos->client_path);
-		if (close(fifos->server))
-			syslog(LOG_ERR, "Failed to close fifo server %s: %m", fifos->server_path);
-		return 0;
+		goto fail;
+	}
+
+	if (fcntl(fifos->client, F_SETFD, FD_CLOEXEC) < 0) {
+		syslog(LOG_ERR, "Failed to set FD_CLOEXEC for fifo client %s: %m.\n",
+		       fifos->client_path);
+		goto fail;
 	}
 
 	return 1;
+fail:
+	if (fifos->server >= 0 && close(fifos->server))
+		syslog(LOG_ERR, "Failed to close fifo server %s: %m", fifos->server_path);
+
+	if (fifos->client >= 0 && close(fifos->client))
+		syslog(LOG_ERR, "Failed to close fifo client %s: %m", fifos->client_path);
+
+	return 0;
 }
 
 /*


