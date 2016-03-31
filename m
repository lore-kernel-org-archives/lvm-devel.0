From: mulhern <amulhern@redhat.com>
Date: Thu, 31 Mar 2016 15:25:31 -0400
Subject: [PATCH] Remove examples which require an implicit parse of DM_UUID value.
Message-ID: <1459452331-28229-1-git-send-email-amulhern@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

According to comments (https://bugzilla.redhat.com/show_bug.cgi?id=1322110)
the dm subsystems, e.g., kpartx, multipath, lvm, are at liberty to change
the format of the value after the subsystem prefix at will. This format
is not part of the public interface. The removed examples treat the format
of the values as if it is part of the public interface.
The remaining examples only treat the _prefix_ as if it is part of the
public interface.

Signed-off-by: mulhern <amulhern@redhat.com>
---
 udev/12-dm-permissions.rules | 15 ---------------
 1 file changed, 15 deletions(-)

diff --git a/udev/12-dm-permissions.rules b/udev/12-dm-permissions.rules
index a9d4c32..e8f9fda 100644
--- a/udev/12-dm-permissions.rules
+++ b/udev/12-dm-permissions.rules
@@ -50,26 +50,11 @@ ENV{DM_UDEV_RULES_VSN}!="?*", GOTO="dm_end"
 # ENV{DM_VG_NAME}!="VolGroup00", OWNER:="root", GROUP:="root", MODE:="660"
 
 
-# ENCRYPTED DEVICES (using cryptsetup >= 1.1)
-#
-# Set permissions for all encrypted devices created by cryptsetup (plain devices)
-# ENV{DM_UUID}=="CRYPT-PLAIN-?*", OWNER:="root", GROUP:="root", MODE:="660"
-
-# Set permissions for all encrypted devices created by cryptsetup (LUKS extension)
-# ENV{DM_UUID}=="CRYPT-LUKS1-?*", OWNER:="root", GROUP:="root", MODE:="660"
-
-# Set permissions for an encrypted device created by cryptsetup and having an exact luks UUID
-# ENV{DM_UUID}=="CRYPT-LUKS1-22fce5c8313c43c68d84b50a3b0fee78-?*", OWNER:="root", GROUP:="root", MODE:="660"
-
-
 # MULTIPATH DEVICES
 #
 # Set permissions for all multipath devices
 # ENV{DM_UUID}=="mpath-?*", OWNER:="root", GROUP:="root", MODE:="660"
 
-# Set permissions for first two partitions created on a multipath device (and detected by kpartx)
-# ENV{DM_UUID}=="part[1-2]-mpath-?*", OWNER:="root", GROUP:="root", MODE:="660"
-
 
 # ...you can use any combination of the comparisons with the environment variables
 # listed at the beginning of this file (udev provides simple pattern matching by
-- 
2.4.3


