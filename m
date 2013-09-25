From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 25 Sep 2013 14:08:27 +0000 (UTC)
Subject: master - conf: add allocation/thin_pool_chunk_size_calculation
Message-ID: <20130925140827.8D72660F43@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8bf425005c8a25e9b99a617a6cf7d9d826ad5f6a
Commit:        8bf425005c8a25e9b99a617a6cf7d9d826ad5f6a
Parent:        c37c59e155813545c2e674eb370a4609e97aa769
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Sep 25 15:59:30 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Sep 25 16:06:38 2013 +0200

conf: add allocation/thin_pool_chunk_size_calculation

Add allocation/thin_pool_chunk_size_calculation lvm.conf
option to select a method for calculating thin pool chunk
sizes and define two possible values - "default" and "performance".
---
 WHATS_NEW                    |    1 +
 conf/example.conf.in         |   15 +++++++++++++++
 lib/config/config_settings.h |    2 ++
 lib/config/defaults.h        |    1 +
 4 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8a50122..04906f0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.103 - 
 ======================================
+  Add lvm.conf allocation/thin_pool_chunk_size_calculation option.
   Fix contiguous & cling allocation policies for parity RAID.  (2.02.100)
   Set use_lvmetad=0 on lvmconf --enable-cluster, reset to default on --disable-cluster.
   Don't install separate command symlink in binary directory for 'lvm devtypes'.
diff --git a/conf/example.conf.in b/conf/example.conf.in
index 6adcecf..f06b705 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -252,6 +252,21 @@ allocation {
     # be placed on different PVs from the pool data.
     thin_pool_metadata_require_separate_pvs = 0
 
+    # Specify chunk size calculation method for thin pool volumes.
+    # Possible options are:
+    # "default"        - if thin_pool_chunk_size is defined, use it.
+    #                    Otherwise, calcucate the chunk size based on
+    #                    estimation and device hints exposed in sysfs:
+    #                    the minimum_io_size. The chunk size is always
+    #                    at least 64KiB.
+    #
+    # "performance"    - if thin_pool_chunk_size is defined, use it.
+    # 			 Otherwise, calculate the chunk size for
+    # 			 performance based on device hints exposed in
+    # 			 sysfs: the optimal_io_size. The chunk size is
+    # 			 always at least 512KiB.
+    # thin_pool_chunk_size_calculation = "default"
+
     # Specify the minimal chunk size (in KB) for thin pool volumes.
     # Use of the larger chunk size may improve perfomance for plain
     # thin volumes, however using them for snapshot volumes is less efficient,
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 3549b6d..8ea2c92 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -107,8 +107,10 @@ cfg(allocation_mirror_logs_require_separate_pvs_CFG, "mirror_logs_require_separa
 cfg(allocation_thin_pool_metadata_require_separate_pvs_CFG, "thin_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 89), NULL)
 cfg(allocation_thin_pool_zero_CFG, "thin_pool_zero", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_ZERO, vsn(2, 2, 99), NULL)
 cfg(allocation_thin_pool_discards_CFG, "thin_pool_discards", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_THIN_POOL_DISCARDS, vsn(2, 2, 99), NULL)
+cfg(allocation_thin_pool_chunk_size_calculation_CFG, "thin_pool_chunk_size_calculation", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_THIN_POOL_CHUNK_SIZE_CALCULATION, vsn(2, 2, 101), NULL)
 cfg(allocation_thin_pool_chunk_size_CFG, "thin_pool_chunk_size", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_INT, DEFAULT_THIN_POOL_CHUNK_SIZE, vsn(2, 2, 99), NULL)
 
+
 cfg(log_verbose_CFG, "verbose", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_VERBOSE, vsn(1, 0, 0), NULL)
 cfg(log_silent_CFG, "silent", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SILENT, vsn(2, 2, 98), NULL)
 cfg(log_syslog_CFG, "syslog", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SYSLOG, vsn(1, 0, 0), NULL)
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index d200331..361d927 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -71,6 +71,7 @@
 #define DEFAULT_THIN_POOL_MAX_METADATA_SIZE (16 * 1024 * 1024)  /* KB */
 #define DEFAULT_THIN_POOL_MIN_METADATA_SIZE 2048  /* KB */
 #define DEFAULT_THIN_POOL_OPTIMAL_SIZE     (128 * 1024 * 1024)	/* KB */
+#define DEFAULT_THIN_POOL_CHUNK_SIZE_CALCULATION "default"
 #define DEFAULT_THIN_POOL_CHUNK_SIZE	    64	  /* KB */
 #define DEFAULT_THIN_POOL_DISCARDS "passdown"
 #define DEFAULT_THIN_POOL_ZERO 1


