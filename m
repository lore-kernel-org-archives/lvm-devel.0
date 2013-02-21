From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Thu, 21 Feb 2013 17:39:01 +0000 (UTC)
Subject: master - RAID: Make 'lvchange --refresh' restore transiently failed RAID PVs
Message-ID: <20130221173901.3A21DA1045@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bbc6378b73246d7ef00c16274fea38118531ae95
Commit:        bbc6378b73246d7ef00c16274fea38118531ae95
Parent:        3ab46449f4dbcc45fe878149838a8439f5ac8b34
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Thu Feb 21 11:31:36 2013 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Thu Feb 21 11:31:36 2013 -0600

RAID:  Make 'lvchange --refresh' restore transiently failed RAID PVs

A new function (dm_tree_node_force_identical_table_reload) was added to
avoid the suppression of identical table reloads.  This allows RAID LVs
to reload the on-disk superblock information that contains which devices
have failed and the bitmaps.  If the failed device has returned, this has
the effect of restoring the device and initiating recovery.  Without this
patch, the user had to completely deactivate their RAID LV and re-activate
it in order to restore the failed device.  Now they simply need to
suspend and resume (which is done by 'lvchange --refresh').

The identical table suppression is only avoided if the LV is not PARTAIL
(i.e. all of it's devices can be seen and read by LVM) and the kernel
status of the array contains failed devices.  In other words, the function
will only be called in the case where we may have success in restoring
a failed device in the array.
---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 613ec3d..2f8fbd4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Allow identical table reload for RAID to restore transiently failed PVs.
   vgimport '--force' now allows users to import VGs with missing PVs.
   Fix PV alignment to incorporate alignment offset if the PV has zero MDAs.
   Allow remove/replace of RAID sub-LVs that are composed of error targets.


