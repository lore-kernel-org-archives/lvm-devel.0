From: David Teigland <teigland@sourceware.org>
Date: Tue, 5 Dec 2017 12:56:19 -0500
Subject: master - lvmlockd: improve error message for VG lock conflict
Message-ID: <201712051756.vB5HuJNG020570@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5d5807b238f12cbe1e3ba7bbb31e2db2f08ed173
Commit:        5d5807b238f12cbe1e3ba7bbb31e2db2f08ed173
Parent:        46d6f7a6393d1d99411d7896285f6f1556de8547
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Nov 29 15:54:44 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Dec 5 11:53:03 2017 -0600

lvmlockd: improve error message for VG lock conflict

When there is significant VG lock contention which retries
have not been able to mask, print a better error message.
---
 lib/locking/lvmlockd.c |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 325549a..5870d05 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -1913,6 +1913,23 @@ int lockd_vg(struct cmd_context *cmd, const char *vg_name, const char *def_mode,
 	}
 
 	/*
+	 * The lock is held by another host, and retries have been unsuccessful.
+	 */
+	if (result == -EAGAIN) {
+		if (!strcmp(mode, "un")) {
+			ret = 1;
+			goto out;
+		} else if (!strcmp(mode, "sh")) {
+			log_warn("VG %s lock skipped: held by other host.", vg_name, result);
+			ret = 1;
+			goto out;
+		} else {
+			log_error("VG %s lock failed: held by other host.", vg_name, result);
+			ret = 0;
+			goto out;
+		}
+	}
+	/*
 	 * No lockspace for the VG was found.  It may be a local
 	 * VG that lvmlockd doesn't keep track of, or it may be
 	 * a lockd VG that lvmlockd doesn't yet know about (it hasn't


