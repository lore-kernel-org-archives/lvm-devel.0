From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:28:05 +0000 (UTC)
Subject: master - dmeventd: open fifo in one function
Message-ID: <20151109092805.759EB60B93@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2c8d6f5c90d5be62b48ba2881f2a6631091dc5af
Commit:        2c8d6f5c90d5be62b48ba2881f2a6631091dc5af
Parent:        e1b111b02accb4145b82b8b47ce57ed93b1a7184
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 7 21:12:15 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:18:53 2015 +0100

dmeventd: open fifo in one function

Put calls related to fifo opening into a single function.

Fix  Time-Of-Check-Time-Of-Use and use fstat()
and fchmod() on already opened fd instead of
checking first path and then risking to open something
different.
---
 daemons/dmeventd/dmeventd.c |   85 ++++++++++++++++++++-----------------------
 1 files changed, 40 insertions(+), 45 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 42c724b..6c04c1b 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1355,78 +1355,73 @@ static int _get_timeout(struct message_data *message_data)
 	return (msg->data && msg->size) ? 0 : -ENOMEM;
 }
 
-/* Open fifos used for client communication. */
-static int _open_fifos(struct dm_event_fifos *fifos)
+static int _open_fifo(const char *path)
 {
 	struct stat st;
+	int fd = -1;
 
-	/* Create client fifo. */
-	(void) dm_prepare_selinux_context(fifos->client_path, S_IFIFO);
-	if ((mkfifo(fifos->client_path, 0600) == -1) && errno != EEXIST) {
-		log_sys_error("client mkfifo", fifos->client_path);
-		(void) dm_prepare_selinux_context(NULL, 0);
-		goto fail;
-	}
-
-	/* Create server fifo. */
-	(void) dm_prepare_selinux_context(fifos->server_path, S_IFIFO);
-	if ((mkfifo(fifos->server_path, 0600) == -1) && errno != EEXIST) {
-		log_sys_error("server mkfifo", fifos->server_path);
+	/* Create fifo. */
+	(void) dm_prepare_selinux_context(path, S_IFIFO);
+	if ((mkfifo(path, 0600) == -1) && errno != EEXIST) {
+		log_sys_error("mkfifo", path);
 		(void) dm_prepare_selinux_context(NULL, 0);
 		goto fail;
 	}
 
 	(void) dm_prepare_selinux_context(NULL, 0);
 
-	/* Warn about wrong permissions if applicable */
-	if ((!stat(fifos->client_path, &st)) && (st.st_mode & 0777) != 0600)
-		log_warn("WARNING: Fixing wrong permissions on %s: %s.\n",
-			 fifos->client_path, strerror(errno));
-
-	if ((!stat(fifos->server_path, &st)) && (st.st_mode & 0777) != 0600)
-		log_warn("WARNING: Fixing wrong permissions on %s: %s.\n",
-			 fifos->server_path, strerror(errno));
-
-	/* If they were already there, make sure permissions are ok. */
-	if (chmod(fifos->client_path, 0600)) {
-		log_sys_error("chmod", fifos->client_path);
+	/* Need to open read+write or we will block or fail */
+	if ((fd = open(path, O_RDWR)) < 0) {
+		log_sys_error("open", path);
 		goto fail;
 	}
 
-	if (chmod(fifos->server_path, 0600)) {
-		log_sys_error("chmod", fifos->server_path);
+	/* Warn about wrong permissions if applicable */
+	if (fstat(fd, &st)) {
+		log_sys_error("fstat", path);
 		goto fail;
 	}
 
-	/* Need to open read+write or we will block or fail */
-	if ((fifos->server = open(fifos->server_path, O_RDWR)) < 0) {
-		log_sys_error("server open", fifos->server_path);
-		goto fail;
+	if ((st.st_mode & 0777) != 0600) {
+		log_warn("WARNING: Fixing wrong permissions on %s: %s.",
+			 path, strerror(errno));
+
+		if (fchmod(fd, 0600)) {
+			log_sys_error("fchmod", path);
+			goto fail;
+		}
 	}
 
-	if (fcntl(fifos->server, F_SETFD, FD_CLOEXEC) < 0) {
-		log_sys_error("fcntl(FD_CLOEXEC)", fifos->server_path);
+	if (fcntl(fd, F_SETFD, FD_CLOEXEC)) {
+		log_sys_error("fcntl(FD_CLOEXEC)", path);
 		goto fail;
 	}
 
-	/* Need to open read+write for select() to work. */
-	if ((fifos->client = open(fifos->client_path, O_RDWR)) < 0) {
-		log_sys_error("client open", fifos->client_path);
+	return fd;
+
+fail:
+	if ((fd >= 0) && close(fd))
+		log_sys_error("close", path);
+
+	return -1;
+}
+
+/* Open fifos used for client communication. */
+static int _open_fifos(struct dm_event_fifos *fifos)
+{
+	/* Create client fifo. */
+	if ((fifos->client = _open_fifo(fifos->client_path)) < 0)
 		goto fail;
-	}
 
-	if (fcntl(fifos->client, F_SETFD, FD_CLOEXEC) < 0) {
-		log_sys_error("fcntl(FD_CLOEXEC)", fifos->client_path);
+	/* Create server fifo. */
+	if ((fifos->server = _open_fifo(fifos->server_path)) < 0)
 		goto fail;
-	}
 
 	return 1;
-fail:
-	if (fifos->server >= 0 && close(fifos->server))
-		log_sys_error("server close", fifos->server_path);
 
+fail:
 	if (fifos->client >= 0 && close(fifos->client))
-		log_sys_error("client close", fifos->client_path);
+		log_sys_error("close", fifos->client_path);
 
 	return 0;
 }


