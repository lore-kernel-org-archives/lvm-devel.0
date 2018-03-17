From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 17 Mar 2018 18:35:00 -0400
Subject: master - coverity: drop unused local static var
Message-ID: <201803172235.w2HMZ05A011258@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f4383a70ba0538f290657adfa20fe00967553195
Commit:        f4383a70ba0538f290657adfa20fe00967553195
Parent:        aa75e181bec4e61ac08a5f1029e966d0593c5d45
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 17 14:00:44 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 17 23:33:58 2018 +0100

coverity: drop unused local static var

---
 lib/locking/lvmlockd.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index a4684b4..0521ede 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -20,7 +20,6 @@
 
 static daemon_handle _lvmlockd;
 static const char *_lvmlockd_socket = NULL;
-static struct cmd_context *_lvmlockd_cmd = NULL;
 static int _use_lvmlockd = 0;         /* is 1 if command is configured to use lvmlockd */
 static int _lvmlockd_connected = 0;   /* is 1 if command is connected to lvmlockd */
 static int _lvmlockd_init_failed = 0; /* used to suppress further warnings */
@@ -69,8 +68,6 @@ void lvmlockd_init(struct cmd_context *cmd)
 	} else {
 		_lvmlockd_init_failed = 0;
 	}
-
-	_lvmlockd_cmd = cmd;
 }
 
 void lvmlockd_connect(void)
@@ -103,7 +100,6 @@ void lvmlockd_disconnect(void)
 	if (_lvmlockd_connected)
 		daemon_close(_lvmlockd);
 	_lvmlockd_connected = 0;
-	_lvmlockd_cmd = NULL;
 }
 
 /* Translate the result strings from lvmlockd to bit flags. */


