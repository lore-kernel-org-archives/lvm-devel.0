From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Jun 2018 16:03:16 -0400
Subject: master - vgchange: start polling with activation
Message-ID: <201806142003.w5EK3GcD004069@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a35098b1102eb7f387e90bd16da4cf3ed833ca57
Commit:        a35098b1102eb7f387e90bd16da4cf3ed833ca57
Parent:        218c57410c32bfa7bf7044cc6d94fd9253d6b547
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 14 21:05:41 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 14 22:02:01 2018 +0200

vgchange: start polling with activation

Shuffle code for better readability as set of conditions was
hard to follow.

Make it obvious the refresh & activate path is handling
monitoring and polling on its own.

So the only --monitor and --poll option needs explicit care.
Option --monitor without option --poll will now as a result
of this patch NOT start polling.

So command: vgchange --monitor n    is no longer a polling starter.
---
 tools/vgchange.c |   23 +++++++++--------------
 1 files changed, 9 insertions(+), 14 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index c513470..c444c30 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -662,26 +662,21 @@ static int _vgchange_single(struct cmd_context *cmd, const char *vg_name,
 		activate = (activation_change_t) arg_uint_value(cmd, activate_ARG, 0);
 		if (!vgchange_activate(cmd, vg, activate))
 			return_ECMD_FAILED;
-	}
-
-	if (arg_is_set(cmd, refresh_ARG)) {
+	} else if (arg_is_set(cmd, refresh_ARG)) {
 		/* refreshes the visible LVs (which starts polling) */
 		if (!_vgchange_refresh(cmd, vg))
 			return_ECMD_FAILED;
-	}
-
-	if (!arg_is_set(cmd, activate_ARG) &&
-	    !arg_is_set(cmd, refresh_ARG) &&
-	    arg_is_set(cmd, monitor_ARG)) {
+	} else {
 		/* -ay* will have already done monitoring changes */
-		if (!_vgchange_monitoring(cmd, vg))
+		if (arg_is_set(cmd, monitor_ARG) &&
+		    !_vgchange_monitoring(cmd, vg))
 			return_ECMD_FAILED;
-	}
 
-	if (!arg_is_set(cmd, refresh_ARG) &&
-	    arg_is_set(cmd, poll_ARG) &&
-	    !vgchange_background_polling(cmd, vg))
-		return_ECMD_FAILED;
+		/* When explicitelly specified --poll */
+		if (arg_is_set(cmd, poll_ARG) &&
+		    !vgchange_background_polling(cmd, vg))
+			return_ECMD_FAILED;
+	}
 
 	return ret;
 }


