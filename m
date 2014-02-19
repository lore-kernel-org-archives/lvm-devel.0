From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 19 Feb 2014 15:27:41 +0000 (UTC)
Subject: master - cache-pool: Change segtype name from cache_pool to cache-pool
Message-ID: <20140219152741.EA73B61050@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=00ce01e52d7fe3a8512d2c5fbe155186638172fd
Commit:        00ce01e52d7fe3a8512d2c5fbe155186638172fd
Parent:        c71a3bcbc07c277b277201425567f7e0864f3819
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Feb 19 09:26:03 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Feb 19 09:26:03 2014 -0600

cache-pool:  Change segtype name from cache_pool to cache-pool

Thin pools use "thin-pool" for the segment type name.  To be consistent,
we use "cache-pool" instead of "cache_pool".
---
 lib/cache_segtype/cache.c    |    2 +-
 lib/metadata/lv_manip.c      |    5 +++--
 man/lvconvert.8.in           |    6 +++---
 man/lvcreate.8.in            |    2 +-
 man/lvm.8.in                 |    6 +++---
 test/shell/lvcreate-cache.sh |   22 +++++++++++-----------
 tools/lvconvert.c            |    6 +++---
 tools/toollib.c              |    2 +-
 8 files changed, 26 insertions(+), 25 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 90ed40e..57c7a5c 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -418,7 +418,7 @@ int init_cache_segtypes(struct cmd_context *cmd,
 	}
 	segtype->cmd = cmd;
 
-	segtype->name = "cache_pool";
+	segtype->name = "cache-pool";
 	segtype->flags = SEG_CACHE_POOL;
 	segtype->ops = &_cache_pool_ops;
 	segtype->private = NULL;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 5d49a70..2b1cdcc 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5917,11 +5917,12 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		}
 
 		if (lp->extents > org->le_count) {
-			log_error("Cache_Pool size cannot be larger than"
+			log_error("cache-pool size cannot be larger than"
 				  " the origin");
 			return NULL;
 		}
-		if (!(lp->segtype = get_segtype_from_string(vg->cmd, "cache_pool")))
+		if (!(lp->segtype = get_segtype_from_string(vg->cmd,
+							    "cache-pool")))
 			return_0;
 	} else if (seg_is_thin(lp) && lp->snapshot) {
 		if (!(org = find_lv(vg, lp->origin))) {
diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 32b251c..c496d74 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -113,7 +113,7 @@ lvconvert \- convert a logical volume from linear to mirror or snapshot
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
 .sp
-.B lvconvert \-\-type cache_pool
+.B lvconvert \-\-type cache-pool
 .RB [ \-c | \-\-chunksize
 .IR ChunkSize [ bBsSkKmMgG ]]
 .RB [ \-\-cachemode
@@ -207,7 +207,7 @@ A mirror is divided into regions of this size (in MB), and the mirror log
 uses this granularity to track which regions are in sync.
 .TP
 .B \-\-type \fISegmentType
-Used to convert a logical volume to another segment type, like cache_pool,
+Used to convert a logical volume to another segment type, like cache-pool,
 cache, raid1, mirror.  When converting a logical volume to a cached logical
 volume, the \-\-cachepool argument is required.
 .TP
@@ -481,7 +481,7 @@ For the read-only external origin use the new name "vg00/external".
 Convert an existing logical volume to a cache pool logical volume using the
 given pool metadata LV.
 .sp
-.B lvconvert --type cache_pool vg00/my_lv_data \-\-poolmetadata vg00/my_lv_meta
+.B lvconvert --type cache-pool vg00/my_lv_data \-\-poolmetadata vg00/my_lv_meta
 .B lvrename vg00/my_lv_data vg00/my_lv_cachepool
 
 Convert an existing logical volume to a cached logical volume using the given
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index f03fd48..682ff3a 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -532,7 +532,7 @@ in vg00 that will use an existing thin pool "vg00/pool":
 Create a cache pool logical volume that can later be used to cache one
 logical volume.
 .sp
-.B lvcreate --type cache_pool -L 1G -n my_lv_cachepool vg /dev/fast1
+.B lvcreate --type cache-pool -L 1G -n my_lv_cachepool vg /dev/fast1
 
 If there is an existing cache pool logical volume, create the large slow
 device (i.e. the origin) and link it to the supplied cache pool LV,
diff --git a/man/lvm.8.in b/man/lvm.8.in
index e5cfb82..363f6af 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -465,7 +465,7 @@ Step-1> lvcreate -L 1G -n cachepool my_vg /dev/fast_dev
 Step-2> lvcreate -L 8M -n meta my_vg /dev/fast_dev
 
 # Combine cache pool sub-LVs into a cache pool.
-Step-3> lvconvert --type cache_pool vg/cachepool --poolmetadata vg/meta
+Step-3> lvconvert --type cache-pool vg/cachepool --poolmetadata vg/meta
 
 # Combine the cache pool and origin to create a cached LV
 Step-4> lvconvert --type cache my_vg/my_lv --cachepool vg/cachepool
@@ -490,7 +490,7 @@ Step-01> lvcreate --type raid1 -L 1G -n cachepool my_vg /dev/fast[12]
 Step-2> lvcreate --type raid1 -L 8M -n meta my_vg /dev/fast1 /dev/fast2
 
 # Combine cache pool sub-LVs into a cache pool.
-Step-3> lvconvert --type cache_pool vg/cachepool --poolmetadata vg/meta
+Step-3> lvconvert --type cache-pool vg/cachepool --poolmetadata vg/meta
 
 # Combine the cache pool and origin to create a cached LV
 Step-4> lvconvert --type cache my_vg/my_lv --cachepool vg/cachepool
@@ -517,7 +517,7 @@ Step-1> lvcreate -L 1G -n cachepool my_vg /dev/fast_dev
 Step-2> lvcreate -L 8M -n meta my_vg /dev/fast_dev
 
 # Combine cache pool sub-LVs into a cache pool and specify "writethough".
-Step-3> lvconvert --type cache_pool vg/cachepool \\
+Step-3> lvconvert --type cache-pool vg/cachepool \\
 	--poolmetadata vg/meta --cachemode writethrough -n cachepool
 
 # Combine the cache pool and origin to create a cached LV
diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index 01e6f51..c4c0794 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -23,7 +23,7 @@ aux prepare_vg 5 80
 ####################
 
 # Full CLI (the advertised form)
-lvcreate --type cache_pool -l 1 -n ${lv}_cache_pool $vg
+lvcreate --type cache-pool -l 1 -n ${lv}_cache_pool $vg
 lvremove -ff $vg/${lv}_cache_pool
 
 # Shorthand CLI (not advertised) -- not yet implemented
@@ -42,34 +42,34 @@ lvremove -ff $vg/${lv}_cache_pool
 ################
 
 # Create/remove cache_pool
-lvcreate --type cache_pool -l 1 -n ${lv}_cache_pool $vg
+lvcreate --type cache-pool -l 1 -n ${lv}_cache_pool $vg
 lvremove -ff $vg
 
 # Create cache_pool, then origin with cache, then remove all
-lvcreate --type cache_pool -l 1 -n ${lv}_cache_pool $vg
+lvcreate --type cache-pool -l 1 -n ${lv}_cache_pool $vg
 lvcreate --type cache -l 2 $vg/${lv}_cache_pool -n $lv1
 dmsetup table ${vg}-$lv1 | grep cache  # ensure it is loaded in kernel
 lvremove -ff $vg
 
 # Create cache_pool, then origin with cache, then remove cache_pool/cache
-lvcreate --type cache_pool -l 1 -n ${lv}_cache_pool $vg
+lvcreate --type cache-pool -l 1 -n ${lv}_cache_pool $vg
 lvcreate --type cache -l 2 $vg/${lv}_cache_pool -n $lv1
 lvremove -ff $vg/${lv}_cache_pool
 lvremove -ff $vg/$lv1
 
 # Create cache_pool, then origin with cache, then remove origin
-lvcreate --type cache_pool -l 1 -n ${lv}_cache_pool $vg
+lvcreate --type cache-pool -l 1 -n ${lv}_cache_pool $vg
 lvcreate --type cache -l 2 $vg/${lv}_cache_pool -n $lv1
 lvremove -ff $vg/$lv1
 lvremove -ff $vg/${lv}_cache_pool
 
 # Shorthand CLI (cache_pool exists, create origin w/ cache)
-#lvcreate --type cache_pool -l 1 -n ${lv}_cache_pool $vg
+#lvcreate --type cache-pool -l 1 -n ${lv}_cache_pool $vg
 #lvcreate --cache -l 2 $vg/${lv}_cache_pool -n $lv1
 #lvremove -ff $vg
 
 # Shorthand CLI (cache_pool exists, create origin w/ cache)
-#lvcreate --type cache_pool -l 1 -n ${lv}_cache_pool $vg
+#lvcreate --type cache-pool -l 1 -n ${lv}_cache_pool $vg
 #lvcreate -H -l 2 $vg/${lv}_cache_pool -n $lv1
 #lvremove -ff $vg
 
@@ -94,22 +94,22 @@ lvremove -ff $vg
 # Repeat key tests with 'writethrough' cachemode
 ################################################
 # Create/remove cache_pool
-lvcreate --type cache_pool -l 1 -n ${lv}_cache_pool $vg --cachemode writethrough
+lvcreate --type cache-pool -l 1 -n ${lv}_cache_pool $vg --cachemode writethrough
 lvremove -ff $vg
 
 # Create cache_pool, then origin with cache, then remove all
-lvcreate --type cache_pool -l 1 -n ${lv}_cache_pool $vg
+lvcreate --type cache-pool -l 1 -n ${lv}_cache_pool $vg
 lvcreate --type cache -l 2 $vg/${lv}_cache_pool -n $lv1 --cachemode writethrough
 lvremove -ff $vg
 
 # Create cache_pool, then origin with cache, then remove cache_pool/cache
-lvcreate --type cache_pool -l 1 -n ${lv}_cache_pool $vg
+lvcreate --type cache-pool -l 1 -n ${lv}_cache_pool $vg
 lvcreate --type cache -l 2 $vg/${lv}_cache_pool -n $lv1 --cachemode writethrough
 lvremove -ff $vg/${lv}_cache_pool
 lvremove -ff $vg/$lv1
 
 # Create cache_pool, then origin with cache, then remove origin
-lvcreate --type cache_pool -l 1 -n ${lv}_cache_pool $vg
+lvcreate --type cache-pool -l 1 -n ${lv}_cache_pool $vg
 lvcreate --type cache -l 2 $vg/${lv}_cache_pool -n $lv1 --cachemode writethrough
 lvremove -ff $vg/$lv1
 lvremove -ff $vg/${lv}_cache_pool
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 7fc1949..814ac65 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -202,7 +202,7 @@ static int _check_conversion_type(struct cmd_context *cmd, const char *type_str)
 	/* FIXME: Check thin-pool and thin more thoroughly! */
 	if (!strcmp(type_str, "snapshot") ||
 	    !strncmp(type_str, "raid", 4) ||
-	    !strcmp(type_str, "cache_pool") || !strcmp(type_str, "cache") ||
+	    !strcmp(type_str, "cache-pool") || !strcmp(type_str, "cache") ||
 	    !strcmp(type_str, "thin-pool") || !strcmp(type_str, "thin"))
 		return 1;
 
@@ -255,7 +255,7 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (!strcmp(type_str, "cache_pool")) {
+	if (!strcmp(type_str, "cache-pool")) {
 		cache_pool = 1;
 		if ((tmp_str = arg_str_value(cmd, cachemode_ARG, NULL))) {
 			if (!strcmp(tmp_str, "writeback"))
@@ -520,7 +520,7 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			}
 		}
 
-		lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, cache_pool ? "cache_pool" : "thin-pool"));
+		lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, cache_pool ? "cache-pool" : "thin-pool"));
 		if (!lp->segtype)
 			return_0;
 	} else { /* Mirrors (and some RAID functions) */
diff --git a/tools/toollib.c b/tools/toollib.c
index 9662aa8..31033e6 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1662,7 +1662,7 @@ int get_pool_params(struct cmd_context *cmd,
 {
 	int cache_pool = 0;
 
-	if (!strcmp("cache_pool", arg_str_value(cmd, type_ARG, "none")))
+	if (!strcmp("cache-pool", arg_str_value(cmd, type_ARG, "none")))
 		cache_pool = 1;
 
 	if (!cache_pool && !arg_count(cmd, thinpool_ARG)) {


