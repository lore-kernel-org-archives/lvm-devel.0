From: Bryn Reeves <bmr@sourceware.org>
Date: Thu, 30 Mar 2017 05:04:10 -0400
Subject: master - dmfilemapd: use log_sys_error in _filemap_monitor_set_notify
Message-ID: <201703300904.v2U94AmD019937@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=834574cc27851266bd288163cddcab36b4db22cb
Commit:        834574cc27851266bd288163cddcab36b4db22cb
Parent:        bfc880994c80a798f28d51558ee120f70d65dd0f
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Mar 29 20:29:20 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Mar 30 10:01:57 2017 +0100

dmfilemapd: use log_sys_error in _filemap_monitor_set_notify

Since _filemap_monitor_set_notify() is only called after daemon
start up it should not use the _early_log() macros. Instead, use
log_sys_error to log errors from the two syscalls in the function.
---
 daemons/dmfilemapd/dmfilemapd.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
index 3e691e8..7939c48 100644
--- a/daemons/dmfilemapd/dmfilemapd.c
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -409,13 +409,13 @@ static int _filemap_monitor_set_notify(struct filemap_monitor *fm)
 	 * and does not fork or exec.
 	 */
 	if ((inotify_fd = inotify_init1(IN_NONBLOCK)) < 0) {
-		_early_log("Failed to initialise inotify.");
+		log_sys_error("inotify_init1", "IN_NONBLOCK");
 		return 0;
 	}
 
 	if ((watch_fd = inotify_add_watch(inotify_fd, fm->path,
 					  IN_MODIFY | IN_DELETE_SELF)) < 0) {
-		_early_log("Failed to add inotify watch.");
+		log_sys_error("inotify_add_watch", fm->path);
 		return 0;
 	}
 	fm->inotify_fd = inotify_fd;


