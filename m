From: David Teigland <teigland@fedoraproject.org>
Date: Mon,  9 Nov 2015 16:00:32 +0000 (UTC)
Subject: master - lvmlockd: shut up warnings
Message-ID: <20151109160032.6BB9F61041@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e207ededd607fe30cf1f10d5c4415ed30b2d030c
Commit:        e207ededd607fe30cf1f10d5c4415ed30b2d030c
Parent:        36ee36734382b2aa845a435e27fa1fb834be1152
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 9 09:59:51 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Nov 9 10:00:04 2015 -0600

lvmlockd: shut up warnings

---
 daemons/lvmlockd/lvmlockd-core.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 487b6ec..9b06e7d 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -3594,8 +3594,6 @@ static int client_send_result(struct client *cl, struct action *act)
 
 		if (gl_use_sanlock && !gl_lsname_sanlock[0])
 			strcat(result_flags, "NO_GL_LS,");
-		else if (gl_use_dlm && !gl_lsname_dlm[0])
-			strcat(result_flags, "NO_GL_LS,");
 		else
 			strcat(result_flags, "NO_GL_LS,");
 	}


