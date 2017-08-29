From: David Teigland <teigland@sourceware.org>
Date: Tue, 29 Aug 2017 16:19:23 -0400
Subject: master - lvmlockd: fix check for no running lock manager
Message-ID: <201708292019.v7TKJNd7006775@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=09c792c20667aa8d7fb2799e484d913a5eb8a147
Commit:        09c792c20667aa8d7fb2799e484d913a5eb8a147
Parent:        f847fcd31a41f61dd81b30ac91f3e2720088b8f2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Aug 29 15:18:12 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Aug 29 15:18:12 2017 -0500

lvmlockd: fix check for no running lock manager

In some cases it was reporting there was no running
lock manager when there is.
---
 daemons/lvmlockd/lvmlockd-core.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index f9d07c1..a921140 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -3676,7 +3676,17 @@ static int client_send_result(struct client *cl, struct action *act)
 			if (!gl_lsname_dlm[0])
 				strcat(result_flags, "NO_GL_LS,");
 		} else {
-			strcat(result_flags, "NO_GL_LS,NO_LM");
+			int found_lm = 0;
+
+			if (lm_support_dlm() && lm_is_running_dlm())
+				found_lm++;
+			if (lm_support_sanlock() && lm_is_running_sanlock())
+				found_lm++;
+
+			if (!found_lm)
+				strcat(result_flags, "NO_GL_LS,NO_LM");
+			else
+				strcat(result_flags, "NO_GL_LS");
 		}
 	}
 


