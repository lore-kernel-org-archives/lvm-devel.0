From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Feb 2018 10:46:28 -0500
Subject: master - debug: capture internal error for too long resource name
Message-ID: <201802191546.w1JFkSPG026204@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e7f1329cae118ccbfded213eee4895d99d79120b
Commit:        e7f1329cae118ccbfded213eee4895d99d79120b
Parent:        c3bb2b29d441f27d7e1d88f71d934ba8c955b26d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 19 15:30:55 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 19 16:45:10 2018 +0100

debug: capture internal error for too long resource name

Should never happen, so just put in internal error instead of silently
passing some shortened resource name.
---
 lib/locking/locking.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index d61aa35..1e1be56 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -264,7 +264,7 @@ static int _lock_vol(struct cmd_context *cmd, const char *resource,
 	}
 
 	if ((is_orphan_vg(resource) || is_global_vg(resource)) && (flags & LCK_CACHE)) {
-		log_error(INTERNAL_ERROR "P_%s referenced", resource);
+		log_error(INTERNAL_ERROR "P_%s referenced.", resource);
 		goto out;
 	}
 
@@ -358,8 +358,10 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const str
 		return 0;
 	}
 
-	strncpy(resource, vol, sizeof(resource) - 1);
-	resource[sizeof(resource) - 1] = '\0';
+	if (!dm_strncpy(resource, vol, sizeof(resource))) {
+		log_error(INTERNAL_ERROR "Resource name %s is too long.", vol);
+		return 0;
+	}
 
 	if (!_lock_vol(cmd, resource, flags, lv_op, lv))
 		return_0;


