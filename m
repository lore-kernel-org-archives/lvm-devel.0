From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  6 Aug 2013 14:23:18 +0000 (UTC)
Subject: master - clogd: fix descriptor leak when daemonzing
Message-ID: <20130806142318.D71A760CFA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=003f08c1642f060e57c55e950d4690d470451602
Commit:        003f08c1642f060e57c55e950d4690d470451602
Parent:        7b1315411f1de73801fd38f264ca507ae3807e53
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 6 16:08:31 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 6 16:21:51 2013 +0200

clogd: fix descriptor leak when daemonzing

---
 WHATS_NEW                |    1 +
 daemons/cmirrord/clogd.c |    6 ++++++
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 446a853..fd7e39f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.100 -
 ================================
+  Fix clogd descriptor leak when daemonizing.
   Fix clvmd descriptor leak on restart.
   Add pipe_open/close() to replace less secure popen() glibc call.
   Fix metadata area offset/size overflow if it's >= 4g and while using lvmetad.
diff --git a/daemons/cmirrord/clogd.c b/daemons/cmirrord/clogd.c
index adf7a92..86d06bd 100644
--- a/daemons/cmirrord/clogd.c
+++ b/daemons/cmirrord/clogd.c
@@ -202,6 +202,12 @@ static void daemonize(void)
 	    (dup2(devnull, 2) < 0))   /* reopen stderr */
 		exit(EXIT_FAILURE);
 
+	if ((devnull > STDERR_FILENO) && close(devnull)) {
+		LOG_ERROR("Failed to close descriptor %d: %s",
+			  devnull, strerror(errno));
+		exit(EXIT_FAILURE);
+	}
+
 	LOG_OPEN("cmirrord", LOG_PID, LOG_DAEMON);
 
 	(void) dm_prepare_selinux_context(CMIRRORD_PIDFILE, S_IFREG);


