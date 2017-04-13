From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 13 Apr 2017 10:11:27 -0400
Subject: master - lvcreate: raise default raid regionsize to 2MiB
Message-ID: <201704131411.v3DEBRf3017686@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5ae7a016b8e5796d36cf491345b1cf8e43ec9ea5
Commit:        5ae7a016b8e5796d36cf491345b1cf8e43ec9ea5
Parent:        4547218a7dcee0508f61561e3e319428651e8951
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Apr 13 16:10:49 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Apr 13 16:10:49 2017 +0200

lvcreate: raise default raid regionsize to 2MiB

Related: rhbz1392947.
---
 conf/example.conf.in  |    2 +-
 lib/config/defaults.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 78f11d1..ed34b91 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -1297,7 +1297,7 @@ activation {
 	# The clean/dirty state of data is tracked for each region.
 	# The value is rounded down to a power of two if necessary, and
 	# is ignored if it is not a multiple of the machine memory page size.
-	raid_region_size = 512
+	raid_region_size = 2048
 
 	# Configuration option activation/error_when_full.
 	# Return errors if a thin pool runs out of space.
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index b5d9983..65b81f1 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -202,7 +202,7 @@
 #define DEFAULT_ACTIVATION_MODE "degraded"
 #define DEFAULT_USE_LINEAR_TARGET 1
 #define DEFAULT_STRIPE_FILLER "error"
-#define DEFAULT_RAID_REGION_SIZE   512	/* KB */
+#define DEFAULT_RAID_REGION_SIZE   2048	/* KB */
 #define DEFAULT_INTERVAL 15
 
 #define DEFAULT_MAX_HISTORY 100


