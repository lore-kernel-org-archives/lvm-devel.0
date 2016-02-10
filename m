From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 10 Feb 2016 14:02:11 +0000 (UTC)
Subject: master - conf: use use_blkid_wiping=0 if not defined in lvm.conf and support not compiled in
Message-ID: <20160210140211.1F15460E77@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8423be80eea3af40355edbdb1e14eed5cd3000a2
Commit:        8423be80eea3af40355edbdb1e14eed5cd3000a2
Parent:        c0e0f5a9234a5ad4083e370c127d394c94726a1c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Feb 10 14:53:10 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Feb 10 14:53:10 2016 +0100

conf: use use_blkid_wiping=0 if not defined in lvm.conf and support not compiled in

Normally, we generate and provide lvm.conf file where use_blkid_wiping
is set based on whether support for this is compiled in or not. This was
generated properly based on configure.

However, if lvm.conf is not used at all (someone deletes it) or the value
in lvm.conf is commented out (user edited it), we still need to use
proper default value that is based on DEFAULT_USE_BLKID_WIPING taken
from configure script - we used hardcoded value of "1" in this case
by mistake.
---
 WHATS_NEW                    |    1 +
 lib/config/config_settings.h |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 48fcd55..6ae8126 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.142 - 
 ====================================
+  Use use_blkid_wiping=0 if not defined in lvm.conf and support not compiled in.
   Do not check for suspended devices if scanning for lvmetad update.
   Fix part. table filter with external_device_info_source="udev" and blkid<2.20.
 
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 210a06f..e554b8e 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -420,7 +420,7 @@ cfg(allocation_maximise_cling_CFG, "maximise_cling", allocation_CFG_SECTION, 0,
 	"the same disks. This setting can be used to disable the changes\n"
 	"and revert to the previous algorithm.\n")
 
-cfg(allocation_use_blkid_wiping_CFG, "use_blkid_wiping", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 105), "@DEFAULT_USE_BLKID_WIPING@", 0, NULL,
+cfg(allocation_use_blkid_wiping_CFG, "use_blkid_wiping", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_USE_BLKID_WIPING, vsn(2, 2, 105), "@DEFAULT_USE_BLKID_WIPING@", 0, NULL,
 	"Use blkid to detect existing signatures on new PVs and LVs.\n"
 	"The blkid library can detect more signatures than the native LVM\n"
 	"detection code, but may take longer. LVM needs to be compiled with\n"


