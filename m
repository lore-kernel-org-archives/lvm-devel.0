From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 24 Apr 2014 10:14:22 +0000 (UTC)
Subject: master - config: use devices/ignore_suspended_devices=0 by default
Message-ID: <20140424101422.299C460EE6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8e8a47143fa920b49f279ec4d096022a1afb36ec
Commit:        8e8a47143fa920b49f279ec4d096022a1afb36ec
Parent:        2b09def6068e69a920972211572235a827e7c474
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Apr 24 12:12:28 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Apr 24 12:12:39 2014 +0200

config: use devices/ignore_suspended_devices=0 by default

ignore_suspended_devices=0 is already used in lvm.conf we distribute,
but it was still "1" in the code (so it was used when lvm.conf value
was not defined). It should be "0" too.
---
 WHATS_NEW             |    1 +
 lib/config/defaults.h |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e7c9b04..1615f37 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Use devices/ignore_suspended_devices=0 by default if not defined in lvm.conf.
   Use proper libmem mempool for allocation of unknown segment name.
   Add --readonly to reporting and display tools for lock-free metadata access.
   Add locking_type 5 for dummy locking for tools that do not need any locks.
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 2268e0b..137b4c8 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -35,7 +35,7 @@
 #define DEFAULT_MD_CHUNK_ALIGNMENT 1
 #define DEFAULT_IGNORE_LVM_MIRRORS 1
 #define DEFAULT_MULTIPATH_COMPONENT_DETECTION 1
-#define DEFAULT_IGNORE_SUSPENDED_DEVICES 1
+#define DEFAULT_IGNORE_SUSPENDED_DEVICES 0
 #define DEFAULT_DISABLE_AFTER_ERROR_COUNT 0
 #define DEFAULT_REQUIRE_RESTOREFILE_WITH_UUID 1
 #define DEFAULT_DATA_ALIGNMENT_OFFSET_DETECTION 1


