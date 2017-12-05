From: David Teigland <teigland@sourceware.org>
Date: Tue, 5 Dec 2017 14:49:18 -0500
Subject: master - lvmlockd: fix log print
Message-ID: <201712051949.vB5JnIKA003004@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b9e419850086473d4309c5211852b0237020421d
Commit:        b9e419850086473d4309c5211852b0237020421d
Parent:        5d5807b238f12cbe1e3ba7bbb31e2db2f08ed173
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Dec 5 13:48:30 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Dec 5 13:48:30 2017 -0600

lvmlockd: fix log print

from previous commit
---
 lib/locking/lvmlockd.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 5870d05..d8bb818 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -1920,11 +1920,11 @@ int lockd_vg(struct cmd_context *cmd, const char *vg_name, const char *def_mode,
 			ret = 1;
 			goto out;
 		} else if (!strcmp(mode, "sh")) {
-			log_warn("VG %s lock skipped: held by other host.", vg_name, result);
+			log_warn("VG %s lock skipped: held by other host.", vg_name);
 			ret = 1;
 			goto out;
 		} else {
-			log_error("VG %s lock failed: held by other host.", vg_name, result);
+			log_error("VG %s lock failed: held by other host.", vg_name);
 			ret = 0;
 			goto out;
 		}


