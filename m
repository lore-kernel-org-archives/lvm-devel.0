From: David Teigland <teigland@sourceware.org>
Date: Thu,  1 Dec 2022 18:07:22 +0000 (GMT)
Subject: main - lvmlockd: fix missing closedir
Message-ID: <20221201180722.F40533858C52@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=55b29c1c3d4b5c1366ec0a24fb680cfb81fc4961
Commit:        55b29c1c3d4b5c1366ec0a24fb680cfb81fc4961
Parent:        e63b0c7262f50ab43fcde1c50b6d880acab68407
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Dec 1 09:53:57 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Dec 1 09:55:11 2022 -0600

lvmlockd: fix missing closedir

in get_local_nodeid from recent lock purge feature:
  lvmlockd: purge the lock resources left in previous lockspace
---
 daemons/lvmlockd/lvmlockd-dlm.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/daemons/lvmlockd/lvmlockd-dlm.c b/daemons/lvmlockd/lvmlockd-dlm.c
index d262fa281..248081d0e 100644
--- a/daemons/lvmlockd/lvmlockd-dlm.c
+++ b/daemons/lvmlockd/lvmlockd-dlm.c
@@ -260,6 +260,7 @@ static int get_local_nodeid(void)
 					rv = sscanf(line, "%d", &val);
 					if (rv == 1) {
 						fclose(file);
+						closedir(ls_dir);
 						return val;
 					}
 				}
@@ -270,7 +271,7 @@ static int get_local_nodeid(void)
 
 	if (closedir(ls_dir))
 		log_error("get_local_nodeid closedir error");
-    return rv;
+	return rv;
 }
 
 int lm_purge_locks_dlm(struct lockspace *ls)

