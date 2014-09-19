From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 19 Sep 2014 13:57:44 +0000 (UTC)
Subject: master - backup: drops locked memory
Message-ID: <20140919135744.F3AFA60E56@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e3cbdde070b25db30984efa0898f16c2555301d9
Commit:        e3cbdde070b25db30984efa0898f16c2555301d9
Parent:        702b6482154b0d8a9488c304081992f2d569f005
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 19 15:31:41 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 19 15:55:46 2014 +0200

backup: drops locked memory

Since we want to backup metadata, this is the point
we no longer want to hold memory locked.
---
 lib/format_text/archiver.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 2667bdb..a2f40f2 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -19,6 +19,7 @@
 #include "lvm-string.h"
 #include "lvmcache.h"
 #include "lvmetad.h"
+#include "memlock.h"
 #include "toolcontext.h"
 #include "locking.h"
 
@@ -255,6 +256,9 @@ int backup_locally(struct volume_group *vg)
 
 int backup(struct volume_group *vg)
 {
+	/* Unlock memory if possible */
+	memlock_unlock(vg->cmd);
+
 	/* Don't back up orphan VGs. */
 	if (is_orphan_vg(vg->name))
 		return 1;


