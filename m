From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 18 Sep 2013 09:28:53 +0000 (UTC)
Subject: master - vgcfgrestore: Remove VG rom lvmetad later, to better deal with errors.
Message-ID: <20130918092853.8CA8460EA7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=054cf25b5f6a34de8886ba6293deee2b24720902
Commit:        054cf25b5f6a34de8886ba6293deee2b24720902
Parent:        a6af611ae127de202be9e172099c6efe9ed41d7e
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Sep 18 11:22:49 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Sep 18 11:24:58 2013 +0200

vgcfgrestore: Remove VG rom lvmetad later, to better deal with errors.

---
 lib/format_text/archiver.c |   14 +++++++++++++-
 tools/vgcfgrestore.c       |    8 --------
 2 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index b6b9fb3..752e93c 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -18,6 +18,7 @@
 #include "format-text.h"
 #include "lvm-string.h"
 #include "lvmcache.h"
+#include "lvmetad.h"
 #include "toolcontext.h"
 #include "locking.h"
 
@@ -347,7 +348,18 @@ int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg)
 		vg->extent_size = tmp;
 	}
 
-	if (!vg_write(vg) || !vg_commit(vg))
+	if (!vg_write(vg))
+		return_0;
+
+	if (lvmetad_active()) {
+		struct volume_group *vg_lvmetad = lvmetad_vg_lookup(cmd, vg->name, NULL);
+		if (vg_lvmetad) {
+			lvmetad_vg_remove(vg_lvmetad);
+			release_vg(vg_lvmetad);
+		}
+	}
+
+	if (!vg_commit(vg))
 		return_0;
 
 	return 1;
diff --git a/tools/vgcfgrestore.c b/tools/vgcfgrestore.c
index f560836..36396c3 100644
--- a/tools/vgcfgrestore.c
+++ b/tools/vgcfgrestore.c
@@ -57,14 +57,6 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	if (lvmetad_active()) {
-		struct volume_group *vg = lvmetad_vg_lookup(cmd, vg_name, NULL);
-		if (vg) {
-			lvmetad_vg_remove(vg);
-			release_vg(vg);
-		}
-	}
-
 	cmd->handles_unknown_segments = 1;
 
 	if (!(arg_count(cmd, file_ARG) ?


