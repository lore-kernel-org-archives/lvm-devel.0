From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 15 Aug 2013 10:24:56 +0000 (UTC)
Subject: master - fix: some issues reported by coverity
Message-ID: <20130815102456.51338612CA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0563bd0037610397c5838d0172fd1c913c62c187
Commit:        0563bd0037610397c5838d0172fd1c913c62c187
Parent:        8cbbe851a80e8d99dc886ce9b44834137731d8ce
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Aug 15 12:23:49 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Aug 15 12:23:49 2013 +0200

fix: some issues reported by coverity

  - null_fd resource leak on error path in _reopen_fd_null fn
  - dead code in verify_message in clvmd code
  - dead code in _init_filter_components in toolcontext code
  - null dereference in dm_prepare_selinux_context on error path if
    setfscreatecon fails while resetting SELinux context
---
 daemons/clvmd/clvmd.c      |    5 -----
 lib/commands/toolcontext.c |    4 ----
 lib/misc/lvm-exec.c        |    9 ++++++---
 libdm/libdm-common.c       |    2 +-
 4 files changed, 7 insertions(+), 13 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index eaa75ca..a52b39d 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -1133,11 +1133,6 @@ static int verify_message(char *buf, int len)
 		return -1;
 	}
 
-	if (h->clientid < 0) {
-		log_error("verify_message bad clientid %x", h->clientid);
-		return -1;
-	}
-
 	if (h->arglen > max_cluster_message) {
 		log_error("verify_message bad arglen %x max %d", h->arglen, max_cluster_message);
 		return -1;
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 65371b1..702a2d8 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -879,10 +879,6 @@ static struct dev_filter *_init_filter_components(struct cmd_context *cmd)
 			nr_filt++;
 	}
 
-	/* Only build a composite filter if we really need it. */
-	if (nr_filt == 1)
-		return filters[0];
-
 	if (!(composite = composite_filter_create(nr_filt, filters)))
 		goto_bad;
 
diff --git a/lib/misc/lvm-exec.c b/lib/misc/lvm-exec.c
index 4cecfa3..01704ad 100644
--- a/lib/misc/lvm-exec.c
+++ b/lib/misc/lvm-exec.c
@@ -111,6 +111,7 @@ int exec_cmd(struct cmd_context *cmd, const char *const argv[],
 static int _reopen_fd_to_null(int fd)
 {
 	int null_fd;
+	int r = 0;
 
 	if ((null_fd = open("/dev/null", O_RDWR)) == -1) {
 		log_sys_error("open", "/dev/null");
@@ -119,20 +120,22 @@ static int _reopen_fd_to_null(int fd)
 
 	if (close(fd)) {
 		log_sys_error("close", "");
-		return 0;
+		goto out;
 	}
 
 	if (dup2(null_fd, fd) == -1) {
 		log_sys_error("dup2", "");
-		return 0;
+		goto out;
 	}
 
+	r = 1;
+out:
 	if (close(null_fd)) {
 		log_sys_error("dup2", "");
 		return 0;
 	}
 
-	return 1;
+	return r;
 }
 
 FILE *pipe_open(struct cmd_context *cmd, const char *const argv[],
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 2e068dc..4f398f1 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -880,7 +880,7 @@ int dm_prepare_selinux_context(const char *path, mode_t mode)
 		log_debug_activation("Resetting SELinux context to default value.");
 
 	if (setfscreatecon(scontext) < 0) {
-		log_sys_error("setfscreatecon", path);
+		log_sys_error("setfscreatecon", path ? : "SELinux context reset");
 		freecon(scontext);
 		return 0;
 	}


