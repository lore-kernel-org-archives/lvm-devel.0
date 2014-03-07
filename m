From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  7 Mar 2014 12:03:19 +0000 (UTC)
Subject: master - cleanup: remove superfluous slash in default cache dir path
Message-ID: <20140307120319.E471D60CAD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7409009a20d7c24ddb02f8f792fe4bbd6f2b3e97
Commit:        7409009a20d7c24ddb02f8f792fe4bbd6f2b3e97
Parent:        ef1d910dee1157d157402c28680dfe34e06194af
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Mar 7 13:03:09 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Mar 7 13:03:09 2014 +0100

cleanup: remove superfluous slash in default cache dir path

---
 lib/config/config.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 1717343..b6158bc 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1607,7 +1607,7 @@ const char *get_default_devices_cache_dir_CFG(struct cmd_context *cmd, struct pr
 {
 	static char buf[PATH_MAX];
 
-	if (dm_snprintf(buf, sizeof(buf), "%s/%s/", cmd->system_dir, DEFAULT_CACHE_SUBDIR) < 0) {
+	if (dm_snprintf(buf, sizeof(buf), "%s/%s", cmd->system_dir, DEFAULT_CACHE_SUBDIR) < 0) {
 		log_error("Persistent cache directory name too long.");
 		return NULL;
 	}


