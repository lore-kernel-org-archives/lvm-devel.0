From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 26 Sep 2012 17:56:17 +0000 (UTC)
Subject: master - libdaemonclient: Use log_sys_error in place of perror.
Message-ID: <20120926175617.498D3A33AB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4ece923a4b8a38fd794ac1cc83d887747db6edda
Commit:        4ece923a4b8a38fd794ac1cc83d887747db6edda
Parent:        7a2a1a7456be3adbfe5a3d034e122ea5e7cae6a0
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Sep 26 13:11:13 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Sep 26 17:26:23 2012 +0200

libdaemonclient: Use log_sys_error in place of perror.

---
 libdaemon/client/daemon-client.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdaemon/client/daemon-client.c b/libdaemon/client/daemon-client.c
index 39b082f..2de970a 100644
--- a/libdaemon/client/daemon-client.c
+++ b/libdaemon/client/daemon-client.c
@@ -60,7 +60,7 @@ error:
 	h.error = errno;
 	if (h.socket_fd >= 0)
 		if (close(h.socket_fd))
-			perror("close");
+			log_sys_error("close", "daemon_open");
 	if (r.cft)
 		daemon_reply_destroy(r);
 	h.socket_fd = -1;


