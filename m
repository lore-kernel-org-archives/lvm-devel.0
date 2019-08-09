From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 9 Aug 2019 06:58:36 -0400
Subject: master - cov: check for socket_path being set
Message-ID: <201908091058.x79AwaXv031582@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=728435e7d680c95fd21fe496d707d1c77adf7d85
Commit:        728435e7d680c95fd21fe496d707d1c77adf7d85
Parent:        cc4a92b13c08f500c1dc0c7af95af599b1c15095
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 25 15:11:05 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 9 12:57:07 2019 +0200

cov: check for socket_path being set

As we check for existince on entering path
let's ensure it's there also on exit path.
---
 libdaemon/server/daemon-server.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 9dd0017..2df4e89 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -690,7 +690,7 @@ void daemon_start(daemon_state s)
 out:
 	/* If activated by systemd, do not unlink the socket - systemd takes care of that! */
 	if (!_systemd_activation && s.socket_fd >= 0)
-		if (unlink(s.socket_path))
+		if (s.socket_path && unlink(s.socket_path))
 			perror("unlink error");
 
 	if (s.socket_fd >= 0)


