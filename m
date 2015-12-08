From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  8 Dec 2015 01:58:33 +0000 (UTC)
Subject: master - dmeventd: Don't trust fifo with wrong attrs.
Message-ID: <20151208015833.2FF7F60974@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dcd946e95a80da1b6b2d2285d9a5f41e87cb153d
Commit:        dcd946e95a80da1b6b2d2285d9a5f41e87cb153d
Parent:        94dab390ef68de3a56b67bce771b48445aa13d09
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Dec 8 01:48:17 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Dec 8 01:48:17 2015 +0000

dmeventd: Don't trust fifo with wrong attrs.

If an existing fifo has the wrong attributes it cannot be trusted
so we must unlink it and recreate it correctly.
(Replaces 2c8d6f5c90d5be62b48ba2881f2a6631091dc5af: if the other end of
the fifo already got opened while its mode was insecure, delaying the
chmod isn't going to make any difference!)
---
 daemons/dmeventd/dmeventd.c |   34 +++++++++++++++++++++++++---------
 1 files changed, 25 insertions(+), 9 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index b7fff9a..c093d91 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -408,7 +408,7 @@ static struct thread_status *_alloc_thread_status(const struct message_data *dat
 	if (!(thread->device.uuid = dm_strdup(data->device_uuid)))
 		goto_out;
 
-        /* Until real name resolved, use UUID */
+	/* Until real name resolved, use UUID */
 	if (!(thread->device.name = dm_strdup(data->device_uuid)))
 		goto_out;
 
@@ -1359,6 +1359,26 @@ static int _open_fifo(const char *path)
 {
 	struct stat st;
 	int fd = -1;
+ 
+ 	/*
+	 * FIXME Explicitly verify the code's requirement that path is secure:
+	 * - All parent directories owned by root without group/other write access unless sticky.
+	 */
+
+	/* If path exists, only use it if it is root-owned fifo mode 0600 */
+	if ((lstat(path, &st) < 0)) {
+		if (errno != ENOENT) {
+			log_sys_error("stat", path);
+			return -1;
+		}
+	} else if (!S_ISFIFO(st.st_mode) || st.st_uid ||
+		   (st.st_mode & (S_IEXEC | S_IRWXG | S_IRWXO))) {
+		log_warn("WARNING: %s has wrong attributes: Replacing.", path);
+		if (unlink(path)) {
+			log_sys_error("unlink", path);
+			return -1;
+		}
+	}
 
 	/* Create fifo. */
 	(void) dm_prepare_selinux_context(path, S_IFIFO);
@@ -1382,14 +1402,10 @@ static int _open_fifo(const char *path)
 		goto fail;
 	}
 
-	if ((st.st_mode & 0777) != 0600) {
-		log_warn("WARNING: Fixing wrong permissions on %s: %s.",
-			 path, strerror(errno));
-
-		if (fchmod(fd, 0600)) {
-			log_sys_error("fchmod", path);
-			goto fail;
-		}
+	if (!S_ISFIFO(st.st_mode) || st.st_uid ||
+	    (st.st_mode & (S_IEXEC | S_IRWXG | S_IRWXO))) {
+		log_error("%s: fifo has incorrect attributes", path);
+		goto fail;
 	}
 
 	if (fcntl(fd, F_SETFD, FD_CLOEXEC)) {


