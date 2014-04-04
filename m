From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  4 Apr 2014 00:27:21 +0000 (UTC)
Subject: master - lib: Share lvm_even_rand for random numbers.
Message-ID: <20140404002721.1D3E56024B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=12ddaa5f104a35df777b97802d9025ceaaadd0db
Commit:        12ddaa5f104a35df777b97802d9025ceaaadd0db
Parent:        e7b8e0a10c500f94f8d7815d83d88f0a45f2c570
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Apr 4 01:26:19 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Apr 4 01:26:19 2014 +0100

lib: Share lvm_even_rand for random numbers.

---
 WHATS_NEW               |    1 +
 lib/metadata/metadata.c |   25 +------------------------
 lib/misc/lvm-wrappers.c |   21 +++++++++++++++++++++
 lib/misc/lvm-wrappers.h |    5 +++++
 4 files changed, 28 insertions(+), 24 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 70b39c1..b5e96fd 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Export lvm_even_rand() for controlled provision of random numbers.
   Add lvmthin man page to section 7.
   Extend internal validation of lv names size is less then 128 chars.
   Fail in resume for lvrename will result in failing command.
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 798f3ab..65a288c 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1057,29 +1057,6 @@ uint64_t extents_from_size(struct cmd_context *cmd, uint64_t size,
 	return size / extent_size;
 }
 
-/*
- * Return random integer in [0,max) interval
- *
- * The loop rejects numbers that come from an "incomplete" slice of the
- * RAND_MAX space (considering the number space [0, RAND_MAX] is divided
- * into some "max"-sized slices and at most a single smaller slice,
- * between [n*max, RAND_MAX] for suitable n -- numbers from this last slice
- * are discarded because they could distort the distribution in favour of
- * smaller numbers.
- */
-static unsigned _even_rand( unsigned *seed, unsigned max )
-{
-	unsigned r, ret;
-
-	/* make sure distribution is even */
-	do {
-		r = (unsigned) rand_r( seed );
-		ret = r % max;
-	} while ( r - ret > RAND_MAX - max );
-
-	return ret;
-}
-
 static dm_bitset_t _bitset_with_random_bits(struct dm_pool *mem, uint32_t num_bits,
 					    uint32_t num_set_bits, unsigned *seed)
 {
@@ -1102,7 +1079,7 @@ static dm_bitset_t _bitset_with_random_bits(struct dm_pool *mem, uint32_t num_bi
 	/* Perform loop num_set_bits times, selecting one bit each time */
 	while (i++ < num_bits) {
 		/* Select a random bit between 0 and (i-1) inclusive. */
-		bit_selected = _even_rand(seed, i);
+		bit_selected = lvm_even_rand(seed, i);
 
 		/*
 		 * If the bit was already set, set the new bit that became
diff --git a/lib/misc/lvm-wrappers.c b/lib/misc/lvm-wrappers.c
index 7ea3ac5..5604ce7 100644
--- a/lib/misc/lvm-wrappers.c
+++ b/lib/misc/lvm-wrappers.c
@@ -118,3 +118,24 @@ int read_urandom(void *buf, size_t len)
 	return 1;
 }
 
+/*
+ * Return random integer in [0,max) interval
+ *
+ * The loop rejects numbers that come from an "incomplete" slice of the
+ * RAND_MAX space.  Considering the number space [0, RAND_MAX] is divided
+ * into some "max"-sized slices and@most a single smaller slice,
+ * between [n*max, RAND_MAX] for suitable n, numbers from this last slice
+ * are discarded because they could distort the distribution in favour of
+ * smaller numbers.
+ */
+unsigned lvm_even_rand(unsigned *seed, unsigned max)
+{
+	unsigned r, ret;
+
+	do {
+		r = (unsigned) rand_r(seed);
+		ret = r % max;
+	} while (r - ret > RAND_MAX - max);
+
+	return ret;
+}
diff --git a/lib/misc/lvm-wrappers.h b/lib/misc/lvm-wrappers.h
index b8d1217..9368e25 100644
--- a/lib/misc/lvm-wrappers.h
+++ b/lib/misc/lvm-wrappers.h
@@ -32,6 +32,11 @@ int lvm_getpagesize(void);
  */
 int read_urandom(void *buf, size_t len);
 
+/*
+ * Return random integer in [0,max) interval
+ */
+unsigned lvm_even_rand(unsigned *seed, unsigned max);
+
 #  ifndef HAVE_SIGINTERRUPT
 #    define siginterrupt(sig, flag) \
 	do { \


