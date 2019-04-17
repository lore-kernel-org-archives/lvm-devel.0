From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Apr 2019 05:35:08 -0400
Subject: stable-2.02 - cleanup: missed string specifier
Message-ID: <201904170935.x3H9Z8YC006363@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=228e331e270451e16126659655905a583a03a0d3
Commit:        228e331e270451e16126659655905a583a03a0d3
Parent:        3ead62e24b6b616c4bde093db37dc770a38669ae
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 17 11:29:35 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 17 11:29:35 2019 +0200

cleanup: missed string specifier

---
 libdaemon/server/daemon-server.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index c61683a..8534b79 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -658,7 +658,7 @@ void daemon_start(daemon_state s)
 		sigprocmask(SIG_SETMASK, &new_set, NULL);
 		if (_shutdown_requested && !s.threads->next) {
 			sigprocmask(SIG_SETMASK, &old_set, NULL);
-			INFO(&s, "shutdown requested", s.name);
+			INFO(&s, "%s shutdown requested", s.name);
 			break;
 		}
 		ret = pselect(s.socket_fd + 1, &in, NULL, NULL, _get_timeout(s), &old_set);


