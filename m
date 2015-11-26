From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 26 Nov 2015 20:53:13 +0000 (UTC)
Subject: master - debug: show LV name where dlid creation failed
Message-ID: <20151126205313.B57CB60553@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4afe43e1a326d50296b6ad4a7ed836d4b0ae6b26
Commit:        4afe43e1a326d50296b6ad4a7ed836d4b0ae6b26
Parent:        922fccc6560706f5026d59e383b694f9d7f85945
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 26 21:52:05 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 26 21:52:05 2015 +0100

debug: show LV name where dlid creation failed

---
 lib/misc/lvm-string.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index 5d63858..605e8d5 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -16,6 +16,7 @@
 #include "lib.h"
 #include "lvm-string.h"
 #include "metadata-exported.h"
+#include "display.h"
 
 #include <ctype.h>
 #include <stdarg.h>
@@ -211,6 +212,7 @@ char *build_dm_uuid(struct dm_pool *mem, const struct logical_volume *lv,
 		    const char *layer)
 {
 	const char *lvid = lv->lvid.s;
+	char *dlid;
 
 	if (!layer) {
 		/*
@@ -235,5 +237,9 @@ char *build_dm_uuid(struct dm_pool *mem, const struct logical_volume *lv,
 			NULL;
 	}
 
-	return dm_build_dm_uuid(mem, UUID_PREFIX, lvid, layer);
+	if (!(dlid = dm_build_dm_uuid(mem, UUID_PREFIX, lvid, layer)))
+		log_error("Failed to build LVM dlid for %s.",
+			  display_lvname(lv));
+
+	return dlid;
 }


