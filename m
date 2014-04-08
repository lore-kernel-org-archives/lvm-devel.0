From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Apr 2014 09:02:40 +0000 (UTC)
Subject: master - exec_cmd: skip fork when argv[0] is null
Message-ID: <20140408090240.AAE6360040@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=89615af349056e3a34788a8b6c0842100389d2b8
Commit:        89615af349056e3a34788a8b6c0842100389d2b8
Parent:        6190ded5f1e7862758ff4a18f8a4030331e655d4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 4 21:15:17 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 8 11:00:13 2014 +0200

exec_cmd: skip fork when argv[0] is null

Skip whole fork code path if the arg would be null.
---
 lib/misc/lvm-exec.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/lib/misc/lvm-exec.c b/lib/misc/lvm-exec.c
index e862bad..273e7f9 100644
--- a/lib/misc/lvm-exec.c
+++ b/lib/misc/lvm-exec.c
@@ -53,6 +53,11 @@ int exec_cmd(struct cmd_context *cmd, const char *const argv[],
 	int status;
 	char buf[PATH_MAX * 2];
 
+	if (!argv[0]) {
+		log_error(INTERNAL_ERROR "Missing command.");
+		return 0;
+	}
+
 	if (rstatus)
 		*rstatus = -1;
 
@@ -74,8 +79,7 @@ int exec_cmd(struct cmd_context *cmd, const char *const argv[],
 		/* FIXME Fix effect of reset_locking on cache then include this */
 		/* destroy_toolcontext(cmd); */
 		/* FIXME Use execve directly */
-		if (argv[0])
-			execvp(argv[0], (char **) argv);
+		execvp(argv[0], (char **) argv);
 		log_sys_error("execvp", argv[0]);
 		_exit(errno);
 	}


