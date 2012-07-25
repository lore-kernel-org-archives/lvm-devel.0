From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 25 Jul 2012 12:06:39 +0000 (UTC)
Subject: master - locking: clarify read-only locking error message
Message-ID: <20120725120639.B93F821AC@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a05ac836412f1a9ebc6bc90fe611ff6808d6d844
Commit:        a05ac836412f1a9ebc6bc90fe611ff6808d6d844
Parent:        1b607890203911a0f92e8f5d5f55e60b52d746ad
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 25 14:06:02 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jul 25 14:06:02 2012 +0200

locking: clarify read-only locking error message

---
 lib/locking/no_locking.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/locking/no_locking.c b/lib/locking/no_locking.c
index cc57275..76d8f1f 100644
--- a/lib/locking/no_locking.c
+++ b/lib/locking/no_locking.c
@@ -74,7 +74,8 @@ static int _readonly_lock_resource(struct cmd_context *cmd,
 	    (flags & LCK_SCOPE_MASK) == LCK_VG &&
 	    !(flags & LCK_CACHE) &&
 	    strcmp(resource, VG_GLOBAL)) {
-		log_error("Write locks are prohibited with read-only locking.");
+		log_error("Read-only locking configured via global/locking_type setting. "
+			  "Write locks are prohibited.");
 		return 0;
 	}
 


