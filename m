From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  1 Aug 2014 09:40:11 +0000 (UTC)
Subject: master - filters: fix regression caused by commit e80884cd080cad7e10be4588e3493b9000649426
Message-ID: <20140801094011.B67A3612CD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=54685c20fc9dfb155a2e5bc9d8cf5f0aad944305
Commit:        54685c20fc9dfb155a2e5bc9d8cf5f0aad944305
Parent:        c7b9f0ab424136b686cd08ff7416078e7c3728c3
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Aug 1 11:28:18 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Aug 1 11:39:53 2014 +0200

filters: fix regression caused by commit e80884cd080cad7e10be4588e3493b9000649426

Commit e80884cd080cad7e10be4588e3493b9000649426 tried to dump filters
for them to be reevaluated when creating a PV to avoid overwriting
any existing signature that may have been created after last
scan/filtering.

However, we need to call refresh_filters instead of
persistent_filter->dump since dump requires proper rescannig to fill
up the persistent filter again. However, this is true only for pvcreate
but not for vgcreate with PV creation where the scanning happens before
this PV creation and hence the next rescan (if not full scan), does not
fill the persistent filter.

Also, move refresh_filters so that it's called sooner and only for
pvcreate, vgcreate already calls lvmcache_label_scan(cmd, 2) which
then calls refresh_filters itself, so no need to reevaluate this again.

This caused the persistent filter (/etc/lvm/cache/.cache file) to be
wrong and contain only the PV just being processed with
vgcreate <vg_name> <pv_name_to_create>.

This regression caused other block devices to be filtered out in case
the vgcreate with PV creation was used and then the persistent filter
is used by any other LVM command afterwards.
---
 WHATS_NEW               |    1 +
 lib/metadata/metadata.c |    7 -------
 tools/pvcreate.c        |    9 +++++++++
 3 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a1099fe..ff30039 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.109 - 
 =================================
+  Fix incorrect persistent .cache after vgcreate with PV creation. (2.02.108)
   Display actual size changed when resizing LV.
   Allow approximate allocation with +%FREE in lvextend.
   Remove possible spurious "not found" message on PV create before wiping.
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 39fa45f..6f88fd8 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1337,13 +1337,6 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 
 	/* FIXME Check partition type is LVM unless --force is given */
 
-	/*
-	 * Make sure we don't overwrite any existing signature
-	 * that may have been created after last time we did filtering.
-	 */
-	if (cmd->filter->wipe)
-		cmd->filter->wipe(cmd->filter);
-
 	/* Is there a pv here already? */
 	pv = find_pv_by_name(cmd, name, 1, 1);
 
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index 958e353..67ecd41 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -105,6 +105,15 @@ int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
+	/*
+	 * Make sure we don't overwrite any existing signature
+	 * that may have been created after last time we did filtering.
+	 */
+	if (!(refresh_filters(cmd))) {
+		log_error("Failed to refresh filters before pvcreate.");
+		return ECMD_FAILED;
+	}
+
 	for (i = 0; i < argc; i++) {
 		if (sigint_caught())
 			return_ECMD_FAILED;


