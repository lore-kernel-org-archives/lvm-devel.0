From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Aug 2012 12:42:21 +0000 (UTC)
Subject: master - cmirrord: check for result of chdir
Message-ID: <20120823124221.7D583A0D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6d0abc6b484f1441c6a0a65fd3c82bc09e9d2104
Commit:        6d0abc6b484f1441c6a0a65fd3c82bc09e9d2104
Parent:        b1640df5e6375926df0cc0e8dab217b21b23ce57
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 20 00:10:40 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 23 14:37:20 2012 +0200

cmirrord: check for result of chdir

Error exit if chdir fails.
---
 daemons/cmirrord/clogd.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/daemons/cmirrord/clogd.c b/daemons/cmirrord/clogd.c
index 32b01a6..adf7a92 100644
--- a/daemons/cmirrord/clogd.c
+++ b/daemons/cmirrord/clogd.c
@@ -185,7 +185,11 @@ static void daemonize(void)
 	}
 
 	setsid();
-	chdir("/");
+	if (chdir("/")) {
+		LOG_ERROR("Failed to chdir /: %s", strerror(errno));
+		exit(EXIT_FAILURE);
+	}
+
 	umask(0);
 
 	if (close(0) || close(1) || close(2)) {


