From: Bryn Reeves <bmr@sourceware.org>
Date: Wed, 29 Mar 2017 11:55:43 -0400
Subject: master - dmfilemapd: pass correct dirp to closedir()
Message-ID: <201703291555.v2TFth1r001303@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b5252a51a5d041a94e712d804a506e94c9a68893
Commit:        b5252a51a5d041a94e712d804a506e94c9a68893
Parent:        481a522dd76baaa36b9e903dcd23d66be0b6754a
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Mar 29 16:54:44 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Mar 29 16:54:44 2017 +0100

dmfilemapd: pass correct dirp to closedir()

---
 daemons/dmfilemapd/dmfilemapd.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
index dec74ec..fae6a10 100644
--- a/daemons/dmfilemapd/dmfilemapd.c
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -229,13 +229,13 @@ static int _is_open(const char *path)
 		if (!pid)
 			continue;
 		if (_is_open_in_pid(pid, path)) {
-			if (closedir(pid_d))
+			if (closedir(proc_d))
 				log_sys_error("closedir", DEFAULT_PROC_DIR);
 			return 1;
 		}
 	}
 
-	if (closedir(pid_d))
+	if (closedir(proc_d))
 		log_sys_error("closedir", DEFAULT_PROC_DIR);
 
 	return 0;


