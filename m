From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 29 Apr 2019 07:50:03 -0400
Subject: stable-2.02 - libdaemon: ensure threads are reaped before checking shutdown
Message-ID: <201904291150.x3TBo3NZ010071@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b41b112a4bf5f674acd45f12ff4efe7fa0d1d8be
Commit:        b41b112a4bf5f674acd45f12ff4efe7fa0d1d8be
Parent:        559cf0cd1e226baf63a98c39572264fbf5c3f6b4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 29 13:43:36 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 29 13:49:33 2019 +0200

libdaemon: ensure threads are reaped before checking shutdown

Since we are checking _shutdown_requested - we expect all threads
are finished - that is currently checked only by checking ->next ptr
being NULL - so this can be NULL only when _reap() function clears
out all already finished threads.

I'm finding this design quite problematic in its core - but as a
'trivial hotfix' - lets _reap() linked list before check for signal.

There is likely a large potentical for few races - but the windows is
very very small - since lvmetad has been already purged from upstream,
lets go with this hotfix.
---
 libdaemon/server/daemon-server.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 8534b79..79b54d0 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -655,6 +655,7 @@ void daemon_start(daemon_state s)
 		FD_ZERO(&in);
 		FD_SET(s.socket_fd, &in);
 
+		_reap(s, 0);
 		sigprocmask(SIG_SETMASK, &new_set, NULL);
 		if (_shutdown_requested && !s.threads->next) {
 			sigprocmask(SIG_SETMASK, &old_set, NULL);


