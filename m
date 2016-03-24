From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 24 Mar 2016 13:07:26 +0000 (UTC)
Subject: master - revert: 6129d2e64d14047169048775dc7081135c0fcc50
Message-ID: <20160324130726.26CDB60D25@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=109b7e2095a7bc5603bf79db0224b8399463af7c
Commit:        109b7e2095a7bc5603bf79db0224b8399463af7c
Parent:        37b548c6b5106315943454df8c5392c9bd604368
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Mar 24 14:04:43 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 24 14:06:12 2016 +0100

revert: 6129d2e64d14047169048775dc7081135c0fcc50

Unfortunately, commit 6129d2e64d14047169048775dc7081135c0fcc50 may
cause performance issue. There's going to be a better fix...
---
 WHATS_NEW               |    1 -
 lib/activate/activate.c |    6 ------
 2 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 652b24f..32528a2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,5 @@
 Version 2.02.148 - 
 ==================================
-  Fix missing /dev sync in lvm2 command before dmeventd monitor/unmonitor.
   Replace hard-coded module and target names with macros.
   Add pv_major and pv_minor report fields.
   Detect and warn about mismatch between devices used and assumed for an LV.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 7dce0da..2eb24d4 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1746,12 +1746,6 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 		if (test_mode())
 			continue;
 
-		/*
-		 * Sync all queued device names/symlinks so dmeventd
-		 * has consistent view during possible device scan.
-		 */
-		fs_unlock();
-
 		/* FIXME specify events */
 		if (!monitor_fn(seg, 0)) {
 			log_error("%s: %s segment monitoring function failed.",


