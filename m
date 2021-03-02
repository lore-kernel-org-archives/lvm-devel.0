From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  2 Mar 2021 21:58:33 +0000 (GMT)
Subject: main - archive: support interruption
Message-ID: <20210302215833.A8CA43834402@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2a9a3346e74c1327eafb03c44f2579eb6119943f
Commit:        2a9a3346e74c1327eafb03c44f2579eb6119943f
Parent:        eb1160ee4230e6f37707b19eb5b46d2446257500
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 26 01:23:50 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 2 22:54:40 2021 +0100

archive: support interruption

When lvm2 calls archive() or backup() it can be useful to allow handling
break signal so the command can be interrupted at some consistent point.

Signal is accepted during processing these calls - and can be evaluated
later during even lengthy processing loops.

So now user can interrupt lengthy lvremove().
---
 lib/format_text/archiver.c | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index cb8fc07de..932f97da3 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -17,6 +17,7 @@
 #include "lib/format_text/archiver.h"
 #include "lib/format_text/format-text.h"
 #include "lib/misc/lvm-string.h"
+#include "lib/misc/lvm-signal.h"
 #include "lib/cache/lvmcache.h"
 #include "lib/mm/memlock.h"
 #include "lib/commands/toolcontext.h"
@@ -155,7 +156,13 @@ static int _archive(struct volume_group *vg, int compulsory)
 
 int archive(struct volume_group *vg)
 {
-	return _archive(vg, 1);
+	int r;
+
+	sigint_allow();
+	r  = _archive(vg, 1);
+	sigint_restore();
+
+	return r;
 }
 
 int archive_display(struct cmd_context *cmd, const char *vg_name)
@@ -218,6 +225,7 @@ static int _backup(struct volume_group *vg)
 {
 	char name[PATH_MAX];
 	char *desc;
+	int r;
 
 	if (!(desc = _build_desc(vg->cmd->mem, vg->cmd->cmd_line, 0)))
 		return_0;
@@ -229,7 +237,11 @@ static int _backup(struct volume_group *vg)
 		return 0;
 	}
 
-	return backup_to_file(name, desc, vg);
+	sigint_allow();
+	r = backup_to_file(name, desc, vg);
+	sigint_restore();
+
+	return r;
 }
 
 int backup_locally(struct volume_group *vg)


