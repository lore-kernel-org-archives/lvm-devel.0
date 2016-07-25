From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 25 Jul 2016 11:55:17 +0000 (UTC)
Subject: master - conf: regenerate example.conf.in
Message-ID: <20160725115517.0C4A960F3C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e4e29add685fce5473bec3c23013a1ddb72fd4b6
Commit:        e4e29add685fce5473bec3c23013a1ddb72fd4b6
Parent:        3bc1adc4048def6dd58f1232bea1f388f9456ef9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jul 25 13:54:59 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jul 25 13:54:59 2016 +0200

conf: regenerate example.conf.in

---
 conf/example.conf.in |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 8b79d7d..1dcbf52 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -377,6 +377,12 @@ allocation {
 	# The default setting changed in version 2.02.85.
 	mirror_logs_require_separate_pvs = 0
 
+	# Configuration option allocation/raid_stripe_all_devices.
+	# Stripe across all PVs when RAID stripes are not specified.
+	# If enabled, all PVs in the VG or on the command line are used for raid0/4/5/6/10
+	# when the command does not specify the number of stripes to use.
+	raid_stripe_all_devices = 0
+
 	# Configuration option allocation/cache_pool_metadata_require_separate_pvs.
 	# Cache pool metadata and data will always use different PVs.
 	cache_pool_metadata_require_separate_pvs = 0
@@ -472,13 +478,6 @@ allocation {
 	# Default physical extent size in KiB to use for new VGs.
 	# This configuration option has an automatic default value.
 	# physical_extent_size = 4096
-
-	# Configuration option striping across all PVs when RAID stripes are not specified.
-	# If enabled, all PVs in the VG or on the command line are used for raid0/4/5/6/10
-	# when the command does not specify the number of stripes to use.
-	#
-	# This configuration option has an automatic default value.
-	# raid_stripe_all_devices = 0
 }
 
 # Configuration section log.


