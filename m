From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 30 Jan 2015 16:22:17 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20150130162217.7D749606FA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d0837dcceba4d75ed722c300fdf00c52b9892da5
Commit:        d0837dcceba4d75ed722c300fdf00c52b9892da5
Parent:        71e88f761d4d3517dbc810e28c807fb84b49ac20
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jan 30 16:16:51 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jan 30 16:16:51 2015 +0000

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    6 +++---
 WHATS_NEW_DM |    3 ---
 4 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/VERSION b/VERSION
index bc3587c..648e0da 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.116(2)-git (2015-01-21)
+2.02.116(2)-git (2015-01-30)
diff --git a/VERSION_DM b/VERSION_DM
index de76fb3..31e782b 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.94-git (2015-01-21)
+1.02.93-git (2015-01-30)
diff --git a/WHATS_NEW b/WHATS_NEW
index b99ce31..a9d3c25 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,8 +1,8 @@
-Version 2.02.116 - 
+Version 2.02.116 - 30th January 2015
 ====================================
-  Deactivate unused thin pools activated with lvm2 pre 2.02.112 version.
+  Deactivate unused thin pools activated with lvm2 pre-2.02.112 versions.
   Check lock holding LV when lvconverting stacked raid LV in cluster.
-  Support "udev" ext. dev. info for filters: PV min size, mpath, md, partition.
+  Support udev external dev info for filters: PV min size, mpath, md, partition.
   Add fw_raid_component_detection lvm.conf option to enable FW raid detection.
   Add devices/external_device_info_source lvm.conf option ("none" by default).
   Scan pools in for_each_sub_lv() and add for_each_sub_lv_except_pools().
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 3fb69cb..169831c 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,6 +1,3 @@
-Version 1.02.94 - 
-===================================
-
 Version 1.02.93 - 21st January 2015
 ===================================
   Reduce severity of ioctl error message when dmeventd waitevent is interrupted.


