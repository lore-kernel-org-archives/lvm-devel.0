From: Bryn Reeves <bmr@sourceware.org>
Date: Wed, 29 Mar 2017 11:04:42 -0400
Subject: master - dmfilemapd: log closedir errors with log_sys_error()
Message-ID: <201703291504.v2TF4g9F027406@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d71071a1afe50214f15fa3dd8de0cc207d409147
Commit:        d71071a1afe50214f15fa3dd8de0cc207d409147
Parent:        5dfd35f2f8ec14398a5d5586b8000e16065bf96f
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Mar 29 16:04:15 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Mar 29 16:04:15 2017 +0100

dmfilemapd: log closedir errors with log_sys_error()

---
 daemons/dmfilemapd/dmfilemapd.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
index 2cd875b..391003e 100644
--- a/daemons/dmfilemapd/dmfilemapd.c
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -179,13 +179,16 @@ static int _is_open_in_pid(pid_t pid, const char *path)
 		}
 		link_buf[len] = '\0';
 		if (!strcmp(deleted_path, link_buf)) {
-			closedir(pid_d);
+			if (closedir(pid_d))
+				log_sys_error("closedir", path_buf);
 			return 1;
 		}
 	}
 
 bad:
-	closedir(pid_d);
+	if (closedir(pid_d))
+		log_sys_error("closedir", path_buf);
+
 	return 0;
 }
 
@@ -225,11 +228,15 @@ static int _is_open(const char *path)
 		if (!pid)
 			continue;
 		if (_is_open_in_pid(pid, path)) {
-			closedir(proc_d);
+			if (closedir(pid_d))
+				log_sys_error("closedir", DEFAULT_PROC_DIR);
 			return 1;
 		}
 	}
-	closedir(proc_d);
+
+	if (closedir(pid_d))
+		log_sys_error("closedir", DEFAULT_PROC_DIR);
+
 	return 0;
 }
 


