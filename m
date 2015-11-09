From: David Teigland <teigland@fedoraproject.org>
Date: Mon,  9 Nov 2015 17:38:05 +0000 (UTC)
Subject: master - lvmlockd: fix the NO_GL_LS condition
Message-ID: <20151109173805.8BCBC603EA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6762eec88c0b9ee85ab77423b41bb0e8b9b0d67d
Commit:        6762eec88c0b9ee85ab77423b41bb0e8b9b0d67d
Parent:        45e749493c55ec349abfe9670cb46c6a70528ae4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 9 11:33:16 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Nov 9 11:33:16 2015 -0600

lvmlockd: fix the NO_GL_LS condition

indicating when no global lockspace exists.
---
 daemons/lvmlockd/lvmlockd-core.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index b4be116..c39f802 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -3594,10 +3594,15 @@ static int client_send_result(struct client *cl, struct action *act)
 			strcat(result_flags, "NO_LOCKSPACES,");
 		pthread_mutex_unlock(&lockspaces_mutex);
 
-		if (gl_use_sanlock && !gl_lsname_sanlock[0])
-			strcat(result_flags, "NO_GL_LS,");
-		else
+		if (gl_use_sanlock) {
+			if (!gl_lsname_sanlock[0])
+				strcat(result_flags, "NO_GL_LS,");
+		} else if (gl_use_dlm) {
+			if (!gl_lsname_dlm[0])
+				strcat(result_flags, "NO_GL_LS,");
+		} else {
 			strcat(result_flags, "NO_GL_LS,");
+		}
 	}
 
 	if (act->flags & LD_AF_DUP_GL_LS)


