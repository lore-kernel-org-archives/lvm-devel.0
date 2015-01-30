From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 30 Jan 2015 12:32:12 +0000 (UTC)
Subject: master - WHATS_NEW
Message-ID: <20150130123212.26ED360DF2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c99cb207153b5c103889a1ac67f799f6af4687d2
Commit:        c99cb207153b5c103889a1ac67f799f6af4687d2
Parent:        28ba0450e93db30ee4dd815cbe85478b3c6a719a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jan 30 13:29:51 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jan 30 13:29:51 2015 +0100

WHATS_NEW

---
 WHATS_NEW |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 401c8b9..c7e257b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,8 @@
 Version 2.02.116 - 
 ====================================
+  Support "udev" ext. dev. info for filters: PV min size, mpath, md, partition.
+  Add fw_raid_component_detection lvm.conf option to enable FW raid detection.
+  Add devices/external_device_info_source lvm.conf option ("none" by default).
   Scan pools in for_each_sub_lv() and add for_each_sub_lv_except_pools().
   Fix lvm2app lvm_lv_get_property return value for fields with info/status ioctl.
   Fix lvm2app regression in lvm_lv_get_attr causing unknown values (2.02.115).


