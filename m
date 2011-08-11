From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 11 Aug 2011 09:33:44 +0200
Subject: [PATCH 5/5] Do not decode DM flags for device removal
In-Reply-To: <cover.1313047685.git.zkabelac@redhat.com>
References: <cover.1313047685.git.zkabelac@redhat.com>
Message-ID: <b0e32f4c1ba601eac0746b2fc25267022eb665e1.1313047685.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Proposing to skip decoding of DM flags when device is removed.

We currently do some actions only on add|change event. So forking
dmsetup process for device removal is just waste of CPU time for now.

Udev is already quite slow - so make it just a tiny bit faster with
this patch.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 udev/10-dm.rules.in |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/udev/10-dm.rules.in b/udev/10-dm.rules.in
index 606a13d..9e8ad0f 100644
--- a/udev/10-dm.rules.in
+++ b/udev/10-dm.rules.in
@@ -24,12 +24,6 @@ ENV{DM_SBIN_PATH}="/sbin"
 TEST!="$env{DM_SBIN_PATH}/dmsetup", ENV{DM_SBIN_PATH}="/usr/sbin"
 TEST!="$env{DM_SBIN_PATH}/dmsetup", GOTO="dm_end"
 
-# Decode udev control flags and set environment variables appropriately.
-# These flags are encoded in DM_COOKIE variable that was introduced in
-# kernel version 2.6.31. Therefore, we can use this feature with
-# kernels >= 2.6.31 only.
-ENV{DM_COOKIE}=="?*", IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup udevflags $env{DM_COOKIE}"
-
 # Device created, major and minor number assigned - "add" event generated.
 # Table loaded - no event generated.
 # Device resumed (or renamed) - "change" event generated.
@@ -42,6 +36,12 @@ ENV{DM_COOKIE}=="?*", IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup udevflags $env
 # is not recommended.
 ACTION!="add|change", GOTO="dm_end"
 
+# Decode udev control flags and set environment variables appropriately.
+# These flags are encoded in DM_COOKIE variable that was introduced in
+# kernel version 2.6.31. Therefore, we can use this feature with
+# kernels >= 2.6.31 only.
+ENV{DM_COOKIE}=="?*", IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup udevflags $env{DM_COOKIE}"
+
 # Rule out easy-to-detect inappropriate events first.
 ENV{DISK_RO}=="1", GOTO="dm_disable"
 
-- 
1.7.6


