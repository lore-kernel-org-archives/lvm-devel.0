From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 12 Sep 2013 08:42:19 +0000 (UTC)
Subject: master - clvmd: add missing debug newline
Message-ID: <20130912084219.8976060B3E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7b5f2e7f34e3236382f4ca8351a12de73956117d
Commit:        7b5f2e7f34e3236382f4ca8351a12de73956117d
Parent:        b8ea27ac97ef94837f6ee3fce86fd65dcb294d65
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 12 10:33:51 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 12 10:38:49 2013 +0200

clvmd: add missing debug newline

Just missing new line.
---
 daemons/clvmd/lvm-functions.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 5f1658d..da7d335 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -256,7 +256,7 @@ static int hold_lock(char *resource, int mode, int flags)
 		}
 		if ((lvi->lock_mode == LCK_EXCL) && (mode == LCK_WRITE)) {
 			DEBUGLOG("hold_lock, lock already held LCK_EXCL, "
-				 "ignoring LCK_WRITE request");
+				 "ignoring LCK_WRITE request\n");
 			return 0;
 		}
 	}


