From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Apr 2019 05:36:09 -0400
Subject: master - cleanup: missed string specifier
Message-ID: <201904170936.x3H9a9UT006392@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8fbaa6d9a5dd738a566906a23f5bbe901d80a9d2
Commit:        8fbaa6d9a5dd738a566906a23f5bbe901d80a9d2
Parent:        44cfa558437634c15ec6da38507e73b4c86837c1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 17 11:29:35 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 17 11:35:44 2019 +0200

cleanup: missed string specifier

---
 libdaemon/server/daemon-server.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index e4ff8a1..9dd0017 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -656,7 +656,7 @@ void daemon_start(daemon_state s)
 		sigprocmask(SIG_SETMASK, &new_set, NULL);
 		if (_shutdown_requested && !s.threads->next) {
 			sigprocmask(SIG_SETMASK, &old_set, NULL);
-			INFO(&s, "shutdown requested", s.name);
+			INFO(&s, "%s shutdown requested", s.name);
 			break;
 		}
 		ret = pselect(s.socket_fd + 1, &in, NULL, NULL, _get_timeout(s), &old_set);


