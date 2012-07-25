From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 25 Jul 2012 12:42:39 +0000 (UTC)
Subject: master - locking: clarify read-only locking error message v2
Message-ID: <20120725124239.858C4237E@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=81e89c0647d856d328ac6ccc8db55472b5746181
Commit:        81e89c0647d856d328ac6ccc8db55472b5746181
Parent:        a05ac836412f1a9ebc6bc90fe611ff6808d6d844
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 25 14:37:22 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jul 25 14:37:22 2012 +0200

locking: clarify read-only locking error message v2

---
 lib/locking/no_locking.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/locking/no_locking.c b/lib/locking/no_locking.c
index 76d8f1f..53a5948 100644
--- a/lib/locking/no_locking.c
+++ b/lib/locking/no_locking.c
@@ -74,7 +74,7 @@ static int _readonly_lock_resource(struct cmd_context *cmd,
 	    (flags & LCK_SCOPE_MASK) == LCK_VG &&
 	    !(flags & LCK_CACHE) &&
 	    strcmp(resource, VG_GLOBAL)) {
-		log_error("Read-only locking configured via global/locking_type setting. "
+		log_error("Read-only locking type set. "
 			  "Write locks are prohibited.");
 		return 0;
 	}


