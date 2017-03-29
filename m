From: Bryn Reeves <bmr@sourceware.org>
Date: Wed, 29 Mar 2017 11:49:24 -0400
Subject: master - dmfilemapd: do not closdir(pid_d) unless it is open
Message-ID: <201703291549.v2TFnOr7000495@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=481a522dd76baaa36b9e903dcd23d66be0b6754a
Commit:        481a522dd76baaa36b9e903dcd23d66be0b6754a
Parent:        d71071a1afe50214f15fa3dd8de0cc207d409147
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Mar 29 16:48:32 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Mar 29 16:48:32 2017 +0100

dmfilemapd: do not closdir(pid_d) unless it is open

---
 daemons/dmfilemapd/dmfilemapd.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
index 391003e..dec74ec 100644
--- a/daemons/dmfilemapd/dmfilemapd.c
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -151,7 +151,7 @@ static int _is_open_in_pid(pid_t pid, const char *path)
 	if (dm_snprintf(path_buf, sizeof(path_buf),
 			DEFAULT_PROC_DIR "%d/fd", pid) < 0) {
 		log_error("Could not format pid path.");
-		goto bad;
+		return 0;
 	}
 
 	/*
@@ -160,12 +160,13 @@ static int _is_open_in_pid(pid_t pid, const char *path)
 	if (dm_snprintf(deleted_path, sizeof(deleted_path), "%s %s",
 			path, PROC_FD_DELETED_STR) < 0) {
 		log_error("Could not format check path.");
+		return 0;
 	}
 
 	pid_d = opendir(path_buf);
 	if (!pid_d) {
 		log_error("Could not open proc path: %s.", path_buf);
-		goto bad;
+		return 0;
 	}
 
 	while ((pid_dp = readdir(pid_d)) != NULL) {


