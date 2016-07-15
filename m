From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 15 Jul 2016 13:49:34 +0000 (UTC)
Subject: master - coverity: close socket before closing app
Message-ID: <20160715134934.E5A7B60E26@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4de7a843ebc5c9ed4c54225a1a062cf40534edaf
Commit:        4de7a843ebc5c9ed4c54225a1a062cf40534edaf
Parent:        d2bb19e883f46a95e9780cea046e6e0a5db006b9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 15 15:42:01 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 15 15:49:01 2016 +0200

coverity: close socket before closing app

Opened socket descriptor goes out-of-sight still opened.
Close it - but since this happens before app exit, it
just fixed valgrind report.
---
 libdaemon/server/daemon-server.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 7911dd6..e4d7ce2 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -660,6 +660,10 @@ out:
 		if (unlink(s.socket_path))
 			perror("unlink error");
 
+	if (s.socket_fd >= 0)
+		if (close(s.socket_fd))
+			perror("scoket close");
+
 	if (s.daemon_fini)
 		if (!s.daemon_fini(&s))
 			failed = 1;


