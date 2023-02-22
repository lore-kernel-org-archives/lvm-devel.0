From: David Teigland <teigland@sourceware.org>
Date: Wed, 22 Feb 2023 22:24:36 +0000 (GMT)
Subject: main - vgimport: invalidate hints
Message-ID: <20230222222436.2BA493858412@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=25cb6a042fab1af7ea4f4a164771a810e1acdef5
Commit:        25cb6a042fab1af7ea4f4a164771a810e1acdef5
Parent:        0f6da9926d0e7be66e759c27f42baf0c414c1ff8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 22 16:19:48 2023 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 22 16:19:48 2023 -0600

vgimport: invalidate hints

There may be some unconventional methods of sharing disks with vgimport
where hints could cause confusion.  Hints should be disabled when
sharing disks, or pvscan --cache used to regenerate hints as needed,
but invalidating hints from vgimport might help reduce confusion.
---
 tools/vgimport.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/tools/vgimport.c b/tools/vgimport.c
index 84b76bd8d..d94b11314 100644
--- a/tools/vgimport.c
+++ b/tools/vgimport.c
@@ -14,6 +14,7 @@
  */
 
 #include "tools.h"
+#include "lib/label/hints.h"
 
 static int _vgimport_single(struct cmd_context *cmd,
 			    const char *vg_name,
@@ -48,6 +49,13 @@ static int _vgimport_single(struct cmd_context *cmd,
 
 	log_print_unless_silent("Volume group \"%s\" successfully imported", vg->name);
 
+	/*
+	 * This is not necessary for any normal, known cases, but it could be
+	 * associated with some unconventional method of sharing disks.  Hints
+	 * should be disabled when sharing disks, but this might help.
+	 */
+	invalidate_hints(cmd);
+
 	return ECMD_PROCESSED;
 
 bad:

