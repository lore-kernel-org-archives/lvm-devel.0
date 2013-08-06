From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  6 Aug 2013 14:23:16 +0000 (UTC)
Subject: master - clmvd: fix decriptor leak on restart
Message-ID: <20130806142316.B946260CFA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7b1315411f1de73801fd38f264ca507ae3807e53
Commit:        7b1315411f1de73801fd38f264ca507ae3807e53
Parent:        16c1dacb6e98c8b49462a7ca9f98687c0affe498
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 6 16:07:50 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 6 16:20:36 2013 +0200

clmvd: fix decriptor leak on restart

Do not leave descriptor used for dup2() openned.
---
 WHATS_NEW             |    1 +
 daemons/clvmd/clvmd.c |    4 ++++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5284145..446a853 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.100 -
 ================================
+  Fix clvmd descriptor leak on restart.
   Add pipe_open/close() to replace less secure popen() glibc call.
   Fix metadata area offset/size overflow if it's >= 4g and while using lvmetad.
   Inherit and apply any profile attached to a VG if creating new thin pool.
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index f05776f..eaa75ca 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -1085,6 +1085,10 @@ static void be_daemon(int timeout)
 		log_error("Error setting terminal FDs to /dev/null: %m");
 		exit(5);
 	}
+	if ((devnull > STDERR_FILENO) && close(devnull)) {
+		log_sys_error("close", "/dev/null");
+		exit(7);
+	}
 	if (chdir("/")) {
 		log_error("Error setting current directory to /: %m");
 		exit(6);


