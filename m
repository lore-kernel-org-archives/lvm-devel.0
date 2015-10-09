From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  9 Oct 2015 17:23:06 +0000 (UTC)
Subject: master - Fix segfault when lvmlockd is running but not lvmetad
Message-ID: <20151009172306.168546022C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=21a8ac0cd3a392feaa049ab509c4727eee548d6b
Commit:        21a8ac0cd3a392feaa049ab509c4727eee548d6b
Parent:        1f30ba6178df6c3faac06328f17158f549b9d4f7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Oct 9 12:20:22 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Oct 9 12:20:22 2015 -0500

Fix segfault when lvmlockd is running but not lvmetad

If lvmlockd is running, lvmetad is configured (use_lvmetad=1),
but lvmetad is not running, then commands will seg fault
when trying to send a message to lvmetad.

The difference is lvmetad being "active", not just "used".
---
 lib/cache/lvmetad.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 20d2001..c7f6ecb 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1683,7 +1683,7 @@ void lvmetad_validate_global_cache(struct cmd_context *cmd, int force)
 		return;
 	}
 
-	if (!lvmetad_used())
+	if (!lvmetad_active())
 		return;
 
 	log_debug_lvmetad("Validating global lvmetad cache");


