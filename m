From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 25 Jun 2019 11:45:07 -0400
Subject: stable-2.02 - cov: check for socket_path being set
Message-ID: <201906251545.x5PFj761012874@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5cf1c61152bfd5f1eef7f49509a877090f4cc26f
Commit:        5cf1c61152bfd5f1eef7f49509a877090f4cc26f
Parent:        2cd6cd34394cb25d312c73b979f4e536d431c10b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 25 15:11:05 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 25 17:33:25 2019 +0200

cov: check for socket_path being set

As we check for existince on entering path
let's ensure it's there also on exit path.
---
 libdaemon/server/daemon-server.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 79b54d0..bc58f7b 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -693,7 +693,7 @@ void daemon_start(daemon_state s)
 out:
 	/* If activated by systemd, do not unlink the socket - systemd takes care of that! */
 	if (!_systemd_activation && s.socket_fd >= 0)
-		if (unlink(s.socket_path))
+		if (s.socket_path && unlink(s.socket_path))
 			perror("unlink error");
 
 	if (s.socket_fd >= 0)


