From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:29:12 +0000 (UTC)
Subject: master - cleanup: reoder rstatus init
Message-ID: <20151109092912.AA1D460E3C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=22e19cb354d813e4be9a461c16bf27205c86d71e
Commit:        22e19cb354d813e4be9a461c16bf27205c86d71e
Parent:        b1dab26be0ee7eec11a6e91ab715808ddf016355
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 8 17:18:23 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:22:52 2015 +0100

cleanup: reoder rstatus init

In all error paths always initialize *rstatus.
---
 lib/misc/lvm-exec.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/misc/lvm-exec.c b/lib/misc/lvm-exec.c
index e414524..a3a629b 100644
--- a/lib/misc/lvm-exec.c
+++ b/lib/misc/lvm-exec.c
@@ -53,14 +53,14 @@ int exec_cmd(struct cmd_context *cmd, const char *const argv[],
 	int status;
 	char buf[PATH_MAX * 2];
 
+	if (rstatus)
+		*rstatus = -1;
+
 	if (!argv[0]) {
 		log_error(INTERNAL_ERROR "Missing command.");
 		return 0;
 	}
 
-	if (rstatus)
-		*rstatus = -1;
-
 	if (sync_needed)
 		/* Flush ops and reset dm cookie */
 		if (!sync_local_dev_names(cmd)) {


