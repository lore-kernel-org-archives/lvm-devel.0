From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 14 Apr 2014 11:06:01 +0000 (UTC)
Subject: master - polldaemon: ret invalid cmd for negative interval
Message-ID: <20140414110601.4AA8B609E2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=45f45c9932840c4bc2d55a1d016269b3167e0450
Commit:        45f45c9932840c4bc2d55a1d016269b3167e0450
Parent:        a8d63994ea1d7faea83c8a8d79bf36cb8b746ffa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 10 10:08:09 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 14 12:47:14 2014 +0200

polldaemon: ret invalid cmd for negative interval

Negative intervals are not supported.
---
 WHATS_NEW          |    1 +
 tools/polldaemon.c |    4 +++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 99b8311..100b1cb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Return invalid command when specifying negative polling interval.
 
 Version 2.02.106 - 10th April 2014
 ==================================
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 7eeea2c..be8a5a3 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -247,8 +247,10 @@ int poll_daemon(struct cmd_context *cmd, const char *name, const char *uuid,
 	parms.aborting = arg_is_set(cmd, abort_ARG);
 	parms.background = background;
 	interval_sign = arg_sign_value(cmd, interval_ARG, SIGN_NONE);
-	if (interval_sign == SIGN_MINUS)
+	if (interval_sign == SIGN_MINUS) {
 		log_error("Argument to --interval cannot be negative");
+		return EINVALID_CMD_LINE;
+	}
 	parms.interval = arg_uint_value(cmd, interval_ARG,
 					find_config_tree_int(cmd, activation_polling_interval_CFG, NULL));
 	parms.wait_before_testing = (interval_sign == SIGN_PLUS);


