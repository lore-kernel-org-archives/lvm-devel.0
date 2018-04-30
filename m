From: David Teigland <teigland@sourceware.org>
Date: Mon, 30 Apr 2018 10:09:30 -0400
Subject: master - toollib: fix wrong dev reference in process_each_label
Message-ID: <201804301409.w3UE9UVa003519@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bdf747944995faf9184d2b4223a583f6aaa1751a
Commit:        bdf747944995faf9184d2b4223a583f6aaa1751a
Parent:        9384b2b5c59e9bca8c2054f76b62155a64c51c38
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 30 09:08:40 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Apr 30 09:08:40 2018 -0500

toollib: fix wrong dev reference in process_each_label

---
 tools/toollib.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 6b71f2d..b9e6bd2 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1569,7 +1569,7 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv,
 			if (!(label = lvmcache_get_dev_label(devl->dev)))
 				continue;
 
-			log_set_report_object_name_and_id(dev_name(dev), NULL);
+			log_set_report_object_name_and_id(dev_name(devl->dev), NULL);
 
 			ret = process_single_label(cmd, label, handle);
 			report_log_ret_code(ret);


