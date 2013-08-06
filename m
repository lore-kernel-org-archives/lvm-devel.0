From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  6 Aug 2013 14:23:08 +0000 (UTC)
Subject: master - cleanup: update exec_cmd comment and error
Message-ID: <20130806142308.44B9C60E80@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b6437a61806bdec29951eb80616db121c4ec4eff
Commit:        b6437a61806bdec29951eb80616db121c4ec4eff
Parent:        61e7dc833cbcc07453d0e919d52d92290d3ab541
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 6 14:26:00 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 6 16:16:57 2013 +0200

cleanup: update exec_cmd comment and error

Use log_sys_error for reporting error of system call.
Fix comment for return value.
---
 lib/misc/lvm-exec.c |    2 +-
 lib/misc/lvm-exec.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/misc/lvm-exec.c b/lib/misc/lvm-exec.c
index 1b69635..2f0f5ca 100644
--- a/lib/misc/lvm-exec.c
+++ b/lib/misc/lvm-exec.c
@@ -64,7 +64,7 @@ int exec_cmd(struct cmd_context *cmd, const char *const argv[],
 	log_verbose("Executing:%s", _verbose_args(argv, buf, sizeof(buf)));
 
 	if ((pid = fork()) == -1) {
-		log_error("fork failed: %s", strerror(errno));
+		log_sys_error("fork", "");
 		return 0;
 	}
 
diff --git a/lib/misc/lvm-exec.h b/lib/misc/lvm-exec.h
index c91ffaf..3ad4af1 100644
--- a/lib/misc/lvm-exec.h
+++ b/lib/misc/lvm-exec.h
@@ -32,7 +32,7 @@ struct cmd_context;
  * Note: You cannot synchronize devices within activation context.
  *
  * \return
- * 0 (success) or -1 (failure).
+ * 1 (success) or 0 (failure).
  */
 int exec_cmd(struct cmd_context *cmd, const char *const argv[],
 	     int *rstatus, int sync_needed);


