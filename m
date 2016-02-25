From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 25 Feb 2016 15:15:52 +0000 (UTC)
Subject: master - metadata: add fixme about code used only by liblvm
Message-ID: <20160225151552.6A5F661057@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c201ee09bdfdfccecd5975ee26537cf790b25e25
Commit:        c201ee09bdfdfccecd5975ee26537cf790b25e25
Parent:        04d34da706a596b7c1d7c5376fb42aa99374fc51
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 16 15:33:40 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 25 09:14:10 2016 -0600

metadata: add fixme about code used only by liblvm

---
 lib/metadata/metadata.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 20caab9..5a51782 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -749,6 +749,24 @@ bad:
 }
 
 /*
+ * FIXME: commands shifting to common code in toollib have left a large
+ * amount of code only used by liblvm.  Either remove this by shifting
+ * liblvm to use toollib, or isolate all this code into a liblvm-specific
+ * source file.  All the following and more are only used by liblvm:
+ *
+ * . vg_extend()
+ * . vg_extend_single_pv()
+ * . pvcreate_vol()
+ * . _pvcreate_check()
+ * . _pvcreate_write()
+ * . pvremove_many()
+ * . pvremove_single()
+ * . find_pv_by_name()
+ * . get_pvs()
+ * . the vg->pvs_to_write list and pv_to_write struct
+ */
+
+/*
  * Extend a VG by a single PV / device path
  *
  * Parameters:


