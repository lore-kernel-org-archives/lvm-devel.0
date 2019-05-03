From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 3 May 2019 07:18:21 -0400
Subject: master - locking: validate locking mode
Message-ID: <201905031118.x43BILjT028327@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a520b3002c2f31f84324d2f59dd1e156bc45ec65
Commit:        a520b3002c2f31f84324d2f59dd1e156bc45ec65
Parent:        3c70ae1803b06dea68b2e6e1ec2176b3f3fe9707
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 3 13:01:02 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 3 13:17:22 2019 +0200

locking: validate locking mode

Ensure 'ret' is always defined and validate 'mode'.
---
 lib/locking/locking.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index fd2b975..630a3bc 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -361,6 +361,9 @@ static int _lockf_global(struct cmd_context *cmd, const char *mode, int convert)
 	} else if (!strcmp(mode, "un")) {
 		ret = lock_vol(cmd, VG_GLOBAL, LCK_UNLOCK, NULL);
 		cmd->lockf_global_ex = 0;
+	} else {
+		log_error(INTERNAL_ERROR "Unknown locking mode %s.", mode);
+		return 0;
 	}
 
 	return ret;


