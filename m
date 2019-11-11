From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 11 Nov 2019 16:46:13 -0500
Subject: master - cov: missing checks of syscalls
Message-ID: <17297.119111116460801271@us-mta-133.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=30a23a194167d270d235afea469352f3d709a466
Commit:        30a23a194167d270d235afea469352f3d709a466
Parent:        8679d45917c321ea76c48c150395db833ba7b812
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 8 15:42:42 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 11 22:44:25 2019 +0100

cov: missing checks of syscalls

Check for sigprocmask errors
---
 libdaemon/server/daemon-server.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 2df4e89..0b1810c 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -653,14 +653,17 @@ void daemon_start(daemon_state s)
 		FD_ZERO(&in);
 		FD_SET(s.socket_fd, &in);
 
-		sigprocmask(SIG_SETMASK, &new_set, NULL);
+		if (sigprocmask(SIG_SETMASK, &new_set, NULL))
+			perror("sigprocmask error");
 		if (_shutdown_requested && !s.threads->next) {
-			sigprocmask(SIG_SETMASK, &old_set, NULL);
+			if (sigprocmask(SIG_SETMASK, &old_set, NULL))
+				perror("sigprocmask error");
 			INFO(&s, "%s shutdown requested", s.name);
 			break;
 		}
 		ret = pselect(s.socket_fd + 1, &in, NULL, NULL, _get_timeout(s), &old_set);
-		sigprocmask(SIG_SETMASK, &old_set, NULL);
+		if (sigprocmask(SIG_SETMASK, &old_set, NULL))
+			perror("sigprocmask error");
 
 		if (ret < 0) {
 			if (errno != EINTR && errno != EAGAIN &&



