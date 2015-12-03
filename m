From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Dec 2015 17:22:29 +0000 (UTC)
Subject: master - vgextend: reinstantiate archiving
Message-ID: <20151203172229.1BD3E60612@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d2524315e6e9ed6796555d8cafbaf56470260b11
Commit:        d2524315e6e9ed6796555d8cafbaf56470260b11
Parent:        e7978c5ab68b1dabfa886fa437646edfcf270b82
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 3 18:15:02 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 3 18:17:45 2015 +0100

vgextend: reinstantiate archiving

Since commit f5d06efbab4c7c77298b18b95c23111575a8db1a we lost archiving.
Restore it now with process_each_vg.
---
 WHATS_NEW        |    1 +
 tools/vgextend.c |    6 ++++++
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 49d1dd6..4b33708 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.137 -
 =====================================
+  Restore archiving before changing metadata in vgextend (2.02.117).
   Dropped internal usage of log_suppress(2).
   Cleaned logging code for buffer size usage.
   Added internal id_read_format_try() function to check and read valid UUID.
diff --git a/tools/vgextend.c b/tools/vgextend.c
index a747113..761df75 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -52,6 +52,9 @@ static int _vgextend_restoremissing(struct cmd_context *cmd __attribute__((unuse
 	int fixed = 0;
 	int i;
 
+	if (!archive(vg))
+		return_0;
+
 	for (i = 0; i < vp->pv_count; i++)
 		if (_restore_pv(vg, vp->pv_names[i]))
 			fixed++;
@@ -88,6 +91,9 @@ static int _vgextend_single(struct cmd_context *cmd, const char *vg_name,
 		return ECMD_FAILED;
 	}
 
+	if (!archive(vg))
+		return_ECMD_FAILED;
+
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
 		log_error("Can't get lock for orphan PVs");
 		return ECMD_FAILED;


