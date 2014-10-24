From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:40:20 +0000 (UTC)
Subject: master - segments: disable init of free segment
Message-ID: <20141024144020.2A6FB60317@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fd1aa7fd5a1ccd7ebcf3446988110ad5c16fddc7
Commit:        fd1aa7fd5a1ccd7ebcf3446988110ad5c16fddc7
Parent:        128131dbc579daf510c4aa7b5cd8f0ca076539a3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 11 09:10:07 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:31 2014 +0200

segments: disable init of free segment

Since it is not needed and would require separate
code for validation disable its initialization.
---
 lib/commands/toolcontext.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index e38aa56..72525f5 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1218,7 +1218,7 @@ static int _init_segtypes(struct cmd_context *cmd)
 		init_striped_segtype,
 		init_zero_segtype,
 		init_error_segtype,
-		init_free_segtype,
+		/* disabled until needed init_free_segtype, */
 #ifdef SNAPSHOT_INTERNAL
 		init_snapshot_segtype,
 #endif


