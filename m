From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 21 Feb 2013 12:34:24 +0000 (UTC)
Subject: master - report: fix pvs -o pv_free reporting for PVs with 0 PEs
Message-ID: <20130221123424.C5712A32BE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=722ca363f03f805cb583156eb42886c72f9c93b8
Commit:        722ca363f03f805cb583156eb42886c72f9c93b8
Parent:        e566faaae605cfbb35a97b46e211c68d3c7bcfd5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Feb 21 13:28:07 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Feb 21 13:28:07 2013 +0100

report: fix pvs -o pv_free reporting for PVs with 0 PEs

[0] raw/~ # lsblk -o NAME,SIZE /dev/sda
NAME  SIZE
sda   128M

[0] raw/~ # pvcreate --dataalignment 128m /dev/sda
  Physical volume "/dev/sda" successfully created

[0] raw/~ # vgcreate vg /dev/sda
  Volume group "vg" successfully created

[0] raw/~ # lvcreate -l1 vg
  Volume group "vg" has insufficient free space (0 extents): 1 required.

Before this patch:
[0] raw/~ # pvs -o pv_name,pv_free
  PV         PFree
  /dev/sda   128.00m

After this patch:
[0] raw/~ # pvs -o pv_name,pv_free
  PV         PFree
  /dev/sda      0
---
 WHATS_NEW         |    1 +
 lib/metadata/pv.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c08f2a5..426f302 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Fix pvs -o pv_free reporting for PVs with zero PE count.
   Fix missing cleanup of flags when the LV is detached from pool.
   Fix check for some forbidden discards conversion of thin pools.
   Add pool_is_active() to check for any pool related active LV.
diff --git a/lib/metadata/pv.c b/lib/metadata/pv.c
index 09b869b..3cd06aa 100644
--- a/lib/metadata/pv.c
+++ b/lib/metadata/pv.c
@@ -106,7 +106,7 @@ uint64_t pv_free(const struct physical_volume *pv)
 {
 	uint64_t freespace;
 
-	if (!pv->pe_count)
+	if (!pv->vg || is_orphan_vg(pv->vg->name))
 		freespace = pv->size;
 	else
 		freespace = (uint64_t)


