From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 16 Mar 2010 18:33:49 -0400
Subject: [PATCH] Avoid scanning all pvs in the system if pvcreating on a device with mdas.
Message-ID: <1268778829-18908-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Other areas of the code check whether there are mdas on an orphan pv before
doing the expensive scan of the system.  This patch adds this check to pvcreate
as well, and so will avoid the unnecessary scan if pvcreate on a device that
is an orphan PV.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 2cab0b6..fff7a61 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1254,11 +1254,14 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 	struct device *dev;
 	uint64_t md_superblock, swap_signature;
 	int wipe_md, wipe_swap;
+	struct dm_list mdas;
+
+	dm_list_init(&mdas);
 
 	/* FIXME Check partition type is LVM unless --force is given */
 
 	/* Is there a pv here already? */
-	pv = pv_read(cmd, name, NULL, NULL, 0, 0);
+	pv = pv_read(cmd, name, &mdas, NULL, 0, 0);
 
 	/*
 	 * If a PV has no MDAs it may appear to be an orphan until the
@@ -1266,7 +1269,7 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 	 * this means checking every VG by scanning every PV on the
 	 * system.
 	 */
-	if (pv && is_orphan(pv)) {
+	if (pv && is_orphan(pv) && !dm_list_size(&mdas)) {
 		if (!scan_vgs_for_pvs(cmd))
 			return_0;
 		pv = pv_read(cmd, name, NULL, NULL, 0, 0);
-- 
1.6.0.6


