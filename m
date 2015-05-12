From: okozina <okozina@fedoraproject.org>
Date: Tue, 12 May 2015 15:22:12 +0000 (UTC)
Subject: master - libdaemon: shutdown on idle also in non-systemd environment
Message-ID: <20150512152212.4724B6024B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cdb7ce6f17e01821268c38ec10fed65f0400cc55
Commit:        cdb7ce6f17e01821268c38ec10fed65f0400cc55
Parent:        100daa7fd882ee4ba8626930283340ed05219470
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue May 12 09:37:19 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue May 12 17:16:24 2015 +0200

libdaemon: shutdown on idle also in non-systemd environment

---
 WHATS_NEW                        |    1 +
 libdaemon/server/daemon-server.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d724a1b..e1674e2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.120 -
 ===============================
+  Daemons (libdaemon) support exit on idle also in non-systemd environment.
   Provide make dist and make rpm targets
   Configure lvm.conf for use_lvmetad and use_lvmpolld.
   Add lvpoll for cmdline communication with lvmpolld.
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 1869956..5b1aff1 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -82,12 +82,12 @@ static void _exit_handler(int sig __attribute__((unused)))
 
 static int _is_idle(daemon_state s)
 {
-	return _systemd_activation && s.idle && s.idle->is_idle && !s.threads->next;
+	return s.idle && s.idle->is_idle && !s.threads->next;
 }
 
 static struct timeval *_get_timeout(daemon_state s)
 {
-	return (_systemd_activation && s.idle) ? s.idle->ptimeout : NULL;
+	return s.idle ? s.idle->ptimeout : NULL;
 }
 
 static void _reset_timeout(daemon_state s)


