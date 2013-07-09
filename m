From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  9 Jul 2013 02:08:17 +0000 (UTC)
Subject: master - tools: remove metadata-exported.h
Message-ID: <20130709020817.D300C60E3D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f56a1819e90900487d6d58485dd658944922f251
Commit:        f56a1819e90900487d6d58485dd658944922f251
Parent:        9d5bdc91ca51737be82c463e05e5818a833a1fea
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jul 9 03:07:55 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jul 9 03:07:55 2013 +0100

tools: remove metadata-exported.h

metadata-exported.h is included by tools.h
---
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.h          |    1 -
 tools/pvcreate.c                 |    1 -
 tools/pvresize.c                 |    1 -
 tools/vgck.c                     |    1 -
 5 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index ef192d3..a8e1a29 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -572,6 +572,7 @@ int pv_analyze(struct cmd_context *cmd, const char *pv_name,
 /* FIXME: move internal to library */
 uint32_t pv_list_extents_free(const struct dm_list *pvh);
 
+int vg_validate(struct volume_group *vg);
 struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name);
 int vg_remove_mdas(struct volume_group *vg);
 int vg_remove_check(struct volume_group *vg);
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index d313198..c2a20cb 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -337,7 +337,6 @@ struct format_handler {
 unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignment);
 unsigned long set_pe_align_offset(struct physical_volume *pv,
 				  unsigned long data_alignment_offset);
-int vg_validate(struct volume_group *vg);
 
 int pv_write_orphan(struct cmd_context *cmd, struct physical_volume *pv);
 
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index cbd1a59..958e353 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -14,7 +14,6 @@
  */
 
 #include "tools.h"
-#include "metadata-exported.h"
 
 /*
  * Intial sanity checking of recovery-related command-line arguments.
diff --git a/tools/pvresize.c b/tools/pvresize.c
index 8004700..faf3134 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -15,7 +15,6 @@
  */
 
 #include "tools.h"
-#include "metadata-exported.h"
 
 struct pvresize_params {
 	uint64_t new_size;
diff --git a/tools/vgck.c b/tools/vgck.c
index e9c26a6..eb0ecaf 100644
--- a/tools/vgck.c
+++ b/tools/vgck.c
@@ -14,7 +14,6 @@
  */
 
 #include "tools.h"
-#include "metadata-exported.h"
 
 static int vgck_single(struct cmd_context *cmd __attribute__((unused)),
 		       const char *vg_name,


