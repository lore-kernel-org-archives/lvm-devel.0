From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 4 Feb 2020 11:22:58 -0500
Subject: master - lvmlockctl: ensure result value is always defined
Message-ID: <09134.120020411224800695@us-mta-305.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d01f27f41135189611d2030ec87ff5714eb259af
Commit:        d01f27f41135189611d2030ec87ff5714eb259af
Parent:        bcfe4993e577167440be511da4ec879fac19afdb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 4 15:33:36 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 4 17:22:06 2020 +0100

lvmlockctl: ensure result value is always defined

Ensure passed pointer gets predefined value (instead of random stack
value).
---
 daemons/lvmlockd/lvmlockctl.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/daemons/lvmlockd/lvmlockctl.c b/daemons/lvmlockd/lvmlockctl.c
index 0dfc3e6..40432b5 100644
--- a/daemons/lvmlockd/lvmlockctl.c
+++ b/daemons/lvmlockd/lvmlockctl.c
@@ -326,6 +326,8 @@ static int _lvmlockd_result(daemon_reply reply, int *result)
 {
 	int reply_result;
 
+	*result = NO_LOCKD_RESULT;
+
 	if (reply.error) {
 		log_error("lvmlockd_result reply error %d", reply.error);
 		return 0;
@@ -337,7 +339,7 @@ static int _lvmlockd_result(daemon_reply reply, int *result)
 	}
 
 	reply_result = daemon_reply_int(reply, "op_result", NO_LOCKD_RESULT);
-	if (reply_result == -1000) {
+	if (reply_result == NO_LOCKD_RESULT) {
 		log_error("lvmlockd_result no op_result");
 		return 0;
 	}



