From: David Teigland <teigland@sourceware.org>
Date: Mon,  2 Aug 2021 21:00:12 +0000 (GMT)
Subject: main - cov: lvmlockd path copy
Message-ID: <20210802210012.804393853800@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bf6dfc248a1de0250eebe8229cae40d55c247ddd
Commit:        bf6dfc248a1de0250eebe8229cae40d55c247ddd
Parent:        d2a2dc2e41b38f1381746ec3aa946cc52d3d8f43
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Aug 2 15:49:39 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Aug 2 15:49:39 2021 -0500

cov: lvmlockd path copy

---
 daemons/lvmlockd/lvmlockd-dlm.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-dlm.c b/daemons/lvmlockd/lvmlockd-dlm.c
index dc665e0a4..67e7bee03 100644
--- a/daemons/lvmlockd/lvmlockd-dlm.c
+++ b/daemons/lvmlockd/lvmlockd-dlm.c
@@ -790,14 +790,14 @@ int lm_is_running_dlm(void)
 
 int lm_refresh_lv_start_dlm(struct action *act)
 {
-	char path[PATH_MAX];
+	char path[PATH_MAX] = { 0 };
 	char command[DLMC_RUN_COMMAND_LEN];
 	char run_uuid[DLMC_RUN_UUID_LEN];
 	char *p, *vgname, *lvname;
 	int rv;
 
 	/* split /dev/vgname/lvname into vgname and lvname strings */
-	strncpy(path, act->path, strlen(act->path));
+	strncpy(path, act->path, PATH_MAX-1);
 
 	/* skip past dev */
 	p = strchr(path + 1, '/');


