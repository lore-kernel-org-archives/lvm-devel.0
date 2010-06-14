From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 14 Jun 2010 15:53:29 +0200
Subject: [PATCH] Fix udev rules to take into account recent changes in udev and deal with coldplug problem at boot
Message-ID: <4C163459.10005@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

So here's a little patch for the 10-dm.rules that makes a few
corrections:

1) We can't suppress node creation anymore (for udev version >= 154),
   so we need to remove NAME="" rule. From now on, we will *always* let
   the /dev/dm-X nodes to be created, not taking the event type into
   consideration (the suppression would be useless anyway when
   using devtmpfs). So, from now on, it's highly recommended to use
   only the symlinks (/dev/mapper, /dev/<vgname>) that are created
   in right time. Direct use of /dev/dm-X should be avoided as much
   as possible!

2) We can't rely on STARTUP environment variable to be set during
   coldplug anymore, Fedora udev init script has just removed that
   and others were complaining too :).

   The STARTUP was used with only one intention and that is to
   recognize artificial ADD events for which a user wants to
   reevaluate the rules (e.g. during boot when
   "udevadm trigger --action=ADD" is called, though we need to
   react on CHANGE events).

   Also, we need to recognize the (artificial) ADD events for which
   a user expects the rules to be reevaluated and ADD events that
   are part of normal device activation.

   We can use DM_UDEV_PRIMARY_SOURCE_FLAG to that so if this flag
   is present in udev db already, we know that the device has already
   been "created-->table loaded-->resumed" and therefore it is
   ready for use.

   *BIG FAT WARNING*
   We need the udev database to be right for this to work. That also
   means to *not remove* existing udev database taken from initrd
   stage where dm devices could be activated (e.g. the root fs on lvm).
   I've already filled a bug for Fedora to fix this - rhbz #603724
   (and this is also the thing I've discussed with Kay, so I hope
    that nobody will complain).

   If not, people will need to call a separate "udevadm trigger --action=change"
   for device-mapper devices (..maybe putting a filter so the trigger
   is run only for dm devices only).

   You've been warned :)

   (and I'd appreciate to not revisit this problem of ADD/CHANGE again)

3) I added a few lines of comments to explain which events
   are generated at which stage of device activation. Just for sure,
   so anyone can read it (an answer for the most common question
   why we do things a little bit different way :))

I hope that this will help. The only remaining issue now should be
the synchronisation with artificial events (the "udevadm trigger"
or "echo add/change > /sys/block/.../uevent"). If there's anyone with
any idea how to solve that, I'm really open to any (even crazy)
ideas :)

Peter
---
 udev/10-dm.rules.in |   35 ++++++++++++++++++++++++-----------
 1 files changed, 24 insertions(+), 11 deletions(-)

diff --git a/udev/10-dm.rules.in b/udev/10-dm.rules.in
index 0db8809..f0ef1c6 100644
--- a/udev/10-dm.rules.in
+++ b/udev/10-dm.rules.in
@@ -37,11 +37,16 @@ TEST!="$env{DM_SBIN_PATH}/dmsetup", GOTO="dm_end"
 # kernels >= 2.6.31 only.
 ENV{DM_COOKIE}=="?*", IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup udevflags $env{DM_COOKIE}"
 
-# Normally, we would test for DM_UDEV_DISABLE_DM_RULES_FLAG here and skip
-# the rules if set. However, we need to set DM_* environment variables
-# for now to properly filter out inappropriate events. This dependency
-# might be removed in the future.
-
+# Device created, major and minor number assigned - "add" event generated.
+# Table loaded - no event generated.
+# Device resumed (or renamed) - "change" event generated.
+# Device removed - "remove" event generated.
+#
+# The dm-X nodes are always created, even on "add" event, we can't suppress
+# that (the node is created even earlier with devtmpfs). All the symlinks
+# (e.g. /dev/mapper) are created in right time after a device has its table
+# loaded and is properly resumed. For this reason, direct use of dm-X nodes
+# is not recommended.
 ACTION!="add|change", GOTO="dm_end"
 
 # There is no cookie set nor any flags encoded in events not originating
@@ -55,6 +60,7 @@ IMPORT{db}="DM_UDEV_DISABLE_DISK_RULES_FLAG"
 IMPORT{db}="DM_UDEV_DISABLE_OTHER_RULES_FLAG"
 IMPORT{db}="DM_UDEV_LOW_PRIORITY_FLAG"
 IMPORT{db}="DM_UDEV_DISABLE_LIBRARY_FALLBACK_FLAG"
+IMPORT{db}="DM_UDEV_PRIMARY_SOURCE_FLAG"
 IMPORT{db}="DM_UDEV_FLAG7"
 IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG0"
 IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG1"
@@ -66,12 +72,19 @@ IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG6"
 IMPORT{db}="DM_SUBSYSTEM_UDEV_FLAG7"
 LABEL="dm_flags_done"
 
-# Normally, we operate on "change" events only. But when
-# coldplugging, there's an "add" event present. We have to
-# recognize this and do our actions in this particular
-# situation, too. Also, we don't want the nodes to be
-# created prematurely on "add" events while not coldplugging.
-ACTION=="add", ENV{STARTUP}!="1", NAME="", GOTO="dm_end"
+# Normally, we operate on "change" events. But when coldplugging, there's an
+# "add" event present. We have to recognize this and do our actions in this
+# particular situation, too. Also, we don't want the nodes to be created
+# prematurely on "add" events while not coldplugging. We check
+# DM_UDEV_PRIMARY_SOURCE_FLAG to see if the device was activated correctly
+# before and if not, we ignore the "add" event totally. This way we can support
+# udev triggers generating "add" events (e.g. "udevadm trigger --action=add" or
+# "echo add > /sys/block/<dm_device>/uevent"). The trigger with "add" event is
+# also used at boot to reevaluate udev rules for all existing devices activated
+# before (e.g. in initrd). If udev is used in initrd, we require the udev init
+# script to not remove the existing udev database so we can reuse the information
+# stored at the time of device activation in the initrd.
+ACTION=="add", ENV{DM_UDEV_PRIMARY_SOURCE_FLAG}!="1", GOTO="dm_disable"
 
 # "dm" sysfs subdirectory is available in newer versions of DM
 # only (kernels >= 2.6.29). We have to check for its existence


