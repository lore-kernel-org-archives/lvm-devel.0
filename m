From: David Teigland <teigland@sourceware.org>
Date: Fri, 20 Aug 2021 14:42:50 +0000 (GMT)
Subject: stable-2.02 - pvscan: use orphans lock to fix parallel pvscan and vgcreate
Message-ID: <20210820144250.EF5F5385DC15@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=90597a4b6e4fc471a8f14cf5ca30f54387a80f3d
Commit:        90597a4b6e4fc471a8f14cf5ca30f54387a80f3d
Parent:        1afa67f4b9bdeb1e0da1cda17695d0aa58f7c3e3
Author:        Wu Guanghao <wuguanghao3@huawei.com>
AuthorDate:    Thu Aug 19 09:30:08 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 20 09:42:37 2021 -0500

pvscan: use orphans lock to fix parallel pvscan and vgcreate

start pvscan --cache /dev/sdb
  (read metadata from disk, no vg info)

		pvcreate /dev/sdb
		vgcreate vg /dev/sdb
		(write vg information to metadata, and update lvmetad)

finish pvscan --cache /dev/sdb
  (No vg information in metadata from disk, overwrite lvmetad)

vgs
couldn't find vg

Signed-off-by: Wu Guanghao <wuguanghao3@huawei.com>
---
 tools/pvscan.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 2e7a864de..51b5daa9a 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -491,6 +491,11 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_READ, NULL)) {
+		log_error("Can't get lock for orphan PVs.");
+		return ECMD_FAILED;
+	}
+
 	/*
 	 * This a special case where use_lvmetad=1 in lvm.conf but pvscan
 	 * cannot use lvmetad for some reason.  In this case pvscan should
@@ -780,6 +785,7 @@ out:
 
 	if (!sync_local_dev_names(cmd))
 		stack;
+	unlock_vg(cmd, NULL, VG_ORPHANS);
 	unlock_vg(cmd, NULL, VG_GLOBAL);
 	return ret;
 }


