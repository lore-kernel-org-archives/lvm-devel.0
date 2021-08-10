From: Wu Guanghao <wuguanghao3@huawei.com>
Date: Tue, 10 Aug 2021 09:26:49 +0800
Subject: [PATCH]pvscan: Increase orphans global lock to prevent lvmetad from being modified when pvscan --cache is executed
Message-ID: <fca2aa5b-2d64-edc4-4810-b4cabbef6cf8@huawei.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Appeared by accident during the test,the metadata of the disk is inconsistent with the data saved by lvmetad.

start pvscan --cache x:x (read metadata from disk, no vg info)
								pvcreate /dev/sdb
								vgcreate vg /dev/sdb
								(write vg information to metadata, and update lvmetad)

finish pvscan --cache x:x (No vg information in metadata,overwrite lvmetad)

# vgs
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

+       if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_READ, NULL)) {
+               log_error("Can't get lock for orphan PVs.");
+               return ECMD_FAILED;
+       }
+
        /*
         * This a special case where use_lvmetad=1 in lvm.conf but pvscan
         * cannot use lvmetad for some reason.  In this case pvscan should
@@ -780,6 +785,7 @@ out:

        if (!sync_local_dev_names(cmd))
                stack;
+       unlock_vg(cmd, NULL, VG_ORPHANS);
        unlock_vg(cmd, NULL, VG_GLOBAL);
        return ret;
 }
--
2.23.0


