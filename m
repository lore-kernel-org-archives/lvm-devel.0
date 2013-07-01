From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  1 Jul 2013 21:13:23 +0000 (UTC)
Subject: master - cleanup: simplify code around flock
Message-ID: <20130701211323.86BAC610D3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2ab7699ec65e3e01ec87ecd27e03b462b3ad69f3
Commit:        2ab7699ec65e3e01ec87ecd27e03b462b3ad69f3
Parent:        2fb116e71eabfc33dfa72717f9c3c40bb6966983
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jun 29 23:10:33 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 1 23:06:41 2013 +0200

cleanup: simplify code around flock

---
 lib/misc/lvm-file.c |   37 ++++++++++---------------------------
 1 files changed, 10 insertions(+), 27 deletions(-)

diff --git a/lib/misc/lvm-file.c b/lib/misc/lvm-file.c
index b8e49cb..f0e2841 100644
--- a/lib/misc/lvm-file.c
+++ b/lib/misc/lvm-file.c
@@ -31,24 +31,18 @@
 int create_temp_name(const char *dir, char *buffer, size_t len, int *fd,
 		     unsigned *seed)
 {
+	const struct flock lock = { .l_type = F_WRLCK };
 	int i, num;
 	pid_t pid;
 	char hostname[255];
 	char *p;
-	struct flock lock = {
-		.l_type = F_WRLCK,
-		.l_whence = 0,
-		.l_start = 0,
-		.l_len = 0
-	};
 
 	num = rand_r(seed);
 	pid = getpid();
 	if (gethostname(hostname, sizeof(hostname)) < 0) {
 		log_sys_error("gethostname", "");
 		strcpy(hostname, "nohostname");
-	}
-	else {
+	} else {
 		/* Replace any '/' with '?' found in the hostname. */
 		p = hostname;
 		while ((p = strchr(p, '/')))
@@ -161,9 +155,8 @@ int is_empty_dir(const char *dir)
 		if (strcmp(dirent->d_name, ".") && strcmp(dirent->d_name, ".."))
 			break;
 
-	if (closedir(d)) {
+	if (closedir(d))
 		log_sys_error("closedir", dir);
-	}
 
 	return dirent ? 0 : 1;
 }
@@ -212,15 +205,10 @@ void sync_dir(const char *file)
  */
 int fcntl_lock_file(const char *file, short lock_type, int warn_if_read_only)
 {
+	const struct flock lock = { .l_type = lock_type };
 	int lockfd;
 	char *dir;
 	char *c;
-	struct flock lock = {
-		.l_type = lock_type,
-		.l_whence = 0,
-		.l_start = 0,
-		.l_len = 0
-	};
 
 	if (!(dir = dm_strdup(file))) {
 		log_error("fcntl_lock_file failed in strdup.");
@@ -253,7 +241,7 @@ int fcntl_lock_file(const char *file, short lock_type, int warn_if_read_only)
 	if (fcntl(lockfd, F_SETLKW, &lock)) {
 		log_sys_error("fcntl", file);
 		if (close(lockfd))
-                        log_sys_error("close", file);
+			log_sys_error("close", file);
 		return -1;
 	}
 
@@ -262,31 +250,26 @@ int fcntl_lock_file(const char *file, short lock_type, int warn_if_read_only)
 
 void fcntl_unlock_file(int lockfd)
 {
-	struct flock lock = {
-		.l_type = F_UNLCK,
-		.l_whence = 0,
-		.l_start = 0,
-		.l_len = 0
-	};
+	const struct flock lock = { .l_type = F_UNLCK };
 
 	log_very_verbose("Unlocking fd %d", lockfd);
 
 	if (fcntl(lockfd, F_SETLK, &lock) == -1)
-		log_error("fcntl unlock failed on fd %d: %s", lockfd,
-			  strerror(errno));
+		log_sys_error("fcntl", "");
 
 	if (close(lockfd))
-		log_error("lock file close failed on fd %d: %s", lockfd,
-			  strerror(errno));
+		log_sys_error("close","");
 }
 
 int lvm_fclose(FILE *fp, const char *filename)
 {
 	if (!dm_fclose(fp))
 		return 0;
+
 	if (errno == 0)
 		log_error("%s: write error", filename);
 	else
 		log_sys_error("write error", filename);
+
 	return EOF;
 }


