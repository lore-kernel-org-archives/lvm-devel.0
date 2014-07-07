From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon,  7 Jul 2014 12:07:58 +0000 (UTC)
Subject: master - metadata: fix regression causing PVs not in VGs to be marked as allocatable
Message-ID: <20140707120758.CA66C60991@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6dc7b783c80c6834aa724df49b5d47b9b5601506
Commit:        6dc7b783c80c6834aa724df49b5d47b9b5601506
Parent:        7021c8f1a483d91a58ce2abc52583e73e2910da7
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jul 7 13:58:42 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jul 7 14:07:21 2014 +0200

metadata: fix regression causing PVs not in VGs to be marked as allocatable

If the PV is not yet in a VG, it's not allocatable.
A regression introduced by commit 0283c439ec2dc195184a12f86a060b271476aae0
(_pv_create) and later commit a7ca10151795b4c4ed6fa4bf7d3d6b1a687430b0
(pv_read).
---
 WHATS_NEW                    |    1 +
 lib/metadata/metadata.c      |    1 -
 test/shell/pvchange-usage.sh |   11 +++++++++++
 3 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5a1e214..ab36cb3 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.108 -
 =================================
+  Fix regression causing PVs not in VGs to be marked as allocatable (2.02.59).
   Fix VG component of lvid in vgsplit/vgmerge and check in vg_validate.
   Add lv_full_name, lv_parent and lv_dm_path fields to reports.
   Change lv_path field to suppress devices that never appear in /dev/vg.
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 50d44ec..2d69714 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1599,7 +1599,6 @@ static struct physical_volume *_alloc_pv(struct dm_pool *mem, struct device *dev
 	}
 
 	pv->dev = dev;
-	pv->status = ALLOCATABLE_PV;
 
 	dm_list_init(&pv->tags);
 	dm_list_init(&pv->segments);
diff --git a/test/shell/pvchange-usage.sh b/test/shell/pvchange-usage.sh
index ac63aec..72ab16b 100644
--- a/test/shell/pvchange-usage.sh
+++ b/test/shell/pvchange-usage.sh
@@ -19,6 +19,17 @@ check_changed_uuid_() {
 
 aux prepare_pvs 4
 
+# check 'allocatable' pv attribute
+pvcreate $dev1
+check pv_field "$dev1" pv_attr ---
+vgcreate $vg1 "$dev1"
+check pv_field "$dev1" pv_attr a--
+pvchange --allocatable n "$dev1"
+check pv_field "$dev1" pv_attr ---
+vgremove -ff $vg1
+not pvchange --allocatable y "$dev1"
+pvremove -ff "$dev1"
+
 for mda in 0 1 2
 do
 # "setup pv with metadatacopies = $mda"


