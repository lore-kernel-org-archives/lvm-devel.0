From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:29:54 +0000 (GMT)
Subject: main - gcc-fanalyzer: some explicit NULL checks for tests
Message-ID: <20210920132954.1429E3858C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=30b188857c51144cd4103850f93287004cc5acaa
Commit:        30b188857c51144cd4103850f93287004cc5acaa
Parent:        951263865603dd9b431c8625c8feefe216cf0c74
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 18 20:28:56 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 14:17:46 2021 +0200

gcc-fanalyzer: some explicit NULL checks for tests

Testing code being happier with these extra checks...
---
 test/unit/activation-generator_t.c |  3 ++-
 test/unit/bcache_t.c               | 24 ++++++++++++++++++++++--
 test/unit/bcache_utils_t.c         |  8 +++++++-
 test/unit/bitset_t.c               | 15 +++++++++++++--
 test/unit/config_t.c               | 17 +++++++++++++++--
 test/unit/io_engine_t.c            |  4 ++++
 6 files changed, 63 insertions(+), 8 deletions(-)

diff --git a/test/unit/activation-generator_t.c b/test/unit/activation-generator_t.c
index 75f8ae4ae..7a2aa337b 100644
--- a/test/unit/activation-generator_t.c
+++ b/test/unit/activation-generator_t.c
@@ -186,7 +186,8 @@ static const char *_fake_lvmconfig(const char *output)
 	fprintf(fp, "EOF\n");
 
 	fclose(fp);
-	chmod(path, 0770);
+	if (chmod(path, 0770))
+		test_fail("chmod 0777 failed on path %s", path);
 
 	return path;
 }
diff --git a/test/unit/bcache_t.c b/test/unit/bcache_t.c
index 399468ad4..878ed5996 100644
--- a/test/unit/bcache_t.c
+++ b/test/unit/bcache_t.c
@@ -81,6 +81,8 @@ static const char *_show_method(enum method m)
 static void _expect(struct mock_engine *e, enum method m)
 {
 	struct mock_call *mc = malloc(sizeof(*mc));
+
+	T_ASSERT(mc);
 	mc->m = m;
 	mc->match_args = false;
 	dm_list_add(&e->expected_calls, &mc->list);
@@ -89,6 +91,8 @@ static void _expect(struct mock_engine *e, enum method m)
 static void _expect_read(struct mock_engine *e, int di, block_address b)
 {
 	struct mock_call *mc = malloc(sizeof(*mc));
+
+	T_ASSERT(mc);
 	mc->m = E_ISSUE;
 	mc->match_args = true;
 	mc->d = DIR_READ;
@@ -102,6 +106,8 @@ static void _expect_read(struct mock_engine *e, int di, block_address b)
 static void _expect_read_any(struct mock_engine *e)
 {
 	struct mock_call *mc = malloc(sizeof(*mc));
+
+	T_ASSERT(mc);
 	mc->m = E_ISSUE;
 	mc->match_args = false;
 	mc->issue_r = true;
@@ -112,6 +118,8 @@ static void _expect_read_any(struct mock_engine *e)
 static void _expect_write(struct mock_engine *e, int di, block_address b)
 {
 	struct mock_call *mc = malloc(sizeof(*mc));
+
+	T_ASSERT(mc);
 	mc->m = E_ISSUE;
 	mc->match_args = true;
 	mc->d = DIR_WRITE;
@@ -125,6 +133,8 @@ static void _expect_write(struct mock_engine *e, int di, block_address b)
 static void _expect_read_bad_issue(struct mock_engine *e, int di, block_address b)
 {
 	struct mock_call *mc = malloc(sizeof(*mc));
+
+	T_ASSERT(mc);
 	mc->m = E_ISSUE;
 	mc->match_args = true;
 	mc->d = DIR_READ;
@@ -138,6 +148,8 @@ static void _expect_read_bad_issue(struct mock_engine *e, int di, block_address
 static void _expect_write_bad_issue(struct mock_engine *e, int di, block_address b)
 {
 	struct mock_call *mc = malloc(sizeof(*mc));
+
+	T_ASSERT(mc);
 	mc->m = E_ISSUE;
 	mc->match_args = true;
 	mc->d = DIR_WRITE;
@@ -151,6 +163,8 @@ static void _expect_write_bad_issue(struct mock_engine *e, int di, block_address
 static void _expect_read_bad_wait(struct mock_engine *e, int di, block_address b)
 {
 	struct mock_call *mc = malloc(sizeof(*mc));
+
+	T_ASSERT(mc);
 	mc->m = E_ISSUE;
 	mc->match_args = true;
 	mc->d = DIR_READ;
@@ -164,6 +178,8 @@ static void _expect_read_bad_wait(struct mock_engine *e, int di, block_address b
 static void _expect_write_bad_wait(struct mock_engine *e, int di, block_address b)
 {
 	struct mock_call *mc = malloc(sizeof(*mc));
+
+	T_ASSERT(mc);
 	mc->m = E_ISSUE;
 	mc->match_args = true;
 	mc->d = DIR_WRITE;
@@ -292,6 +308,8 @@ static struct mock_engine *_mock_create(unsigned max_io, sector_t block_size)
 {
 	struct mock_engine *m = malloc(sizeof(*m));
 
+	T_ASSERT(m);
+
 	m->e.destroy = _mock_destroy;
 	m->e.issue = _mock_issue;
 	m->e.wait = _mock_wait;
@@ -317,6 +335,8 @@ static struct fixture *_fixture_init(sector_t block_size, unsigned nr_cache_bloc
 {
 	struct fixture *f = malloc(sizeof(*f));
 
+	T_ASSERT(f);
+
 	f->me = _mock_create(16, block_size);
 	T_ASSERT(f->me);
 
@@ -605,7 +625,7 @@ static void test_flush_waits_for_all_dirty(void *context)
 			_expect(me, E_WAIT);
 	}
 
-	bcache_flush(cache);
+	T_ASSERT(bcache_flush(cache));
 	_no_outstanding_expectations(me);
 }
 
@@ -1008,7 +1028,7 @@ static struct test_suite *_large_tests(void)
 
 void bcache_tests(struct dm_list *all_tests)
 {
-        dm_list_add(all_tests, &_tiny_tests()->list);
+	dm_list_add(all_tests, &_tiny_tests()->list);
 	dm_list_add(all_tests, &_small_tests()->list);
 	dm_list_add(all_tests, &_large_tests()->list);
 }
diff --git a/test/unit/bcache_utils_t.c b/test/unit/bcache_utils_t.c
index ecc3ebb32..3dea17ac5 100644
--- a/test/unit/bcache_utils_t.c
+++ b/test/unit/bcache_utils_t.c
@@ -144,6 +144,10 @@ static void _verify(struct fixture *f, uint64_t byte_b, uint64_t byte_e, uint8_t
         	unsigned i;
         	size_t len2 = byte_e - byte_b;
 		uint8_t *buffer = malloc(len2);
+
+		T_ASSERT(buffer);
+		memset(buffer, 0, len2);
+
 		T_ASSERT(bcache_read_bytes(f->cache, f->di, byte_b, len2, buffer));
 		for (i = 0; i < len; i++)
         		T_ASSERT_EQUAL(buffer[i], _pattern_at(pat, byte_b + i));
@@ -197,7 +201,9 @@ static void _do_write(struct fixture *f, uint64_t byte_b, uint64_t byte_e, uint8
         unsigned i;
         size_t len = byte_e - byte_b;
         uint8_t *buffer = malloc(len);
-        T_ASSERT(buffer);
+
+	T_ASSERT(buffer);
+	memset(buffer, 0, len);
 
         for (i = 0; i < len; i++)
 		buffer[i] = _pattern_at(pat, byte_b + i);
diff --git a/test/unit/bitset_t.c b/test/unit/bitset_t.c
index 12b2a2092..4ee4f1c22 100644
--- a/test/unit/bitset_t.c
+++ b/test/unit/bitset_t.c
@@ -41,6 +41,8 @@ static void test_get_next(void *fixture)
         int i, j, last = 0, first;
         dm_bitset_t bs = dm_bitset_create(mem, NR_BITS);
 
+	T_ASSERT(bs);
+
         for (i = 0; i < NR_BITS; i++)
                 T_ASSERT(!dm_bit(bs, i));
 
@@ -76,7 +78,11 @@ static void test_equal(void *fixture)
         dm_bitset_t bs1 = dm_bitset_create(mem, NR_BITS);
         dm_bitset_t bs2 = dm_bitset_create(mem, NR_BITS);
 
-        int i, j;
+	int i, j;
+
+	T_ASSERT(bs1);
+	T_ASSERT(bs2);
+
         for (i = 0, j = 1; i < NR_BITS; i += j, j++) {
                 dm_bit_set(bs1, i);
                 dm_bit_set(bs2, i);
@@ -102,7 +108,12 @@ static void test_and(void *fixture)
         dm_bitset_t bs2 = dm_bitset_create(mem, NR_BITS);
         dm_bitset_t bs3 = dm_bitset_create(mem, NR_BITS);
 
-        int i, j;
+	int i, j;
+
+	T_ASSERT(bs1);
+	T_ASSERT(bs2);
+	T_ASSERT(bs3);
+
         for (i = 0, j = 1; i < NR_BITS; i += j, j++) {
                 dm_bit_set(bs1, i);
                 dm_bit_set(bs2, i);
diff --git a/test/unit/config_t.c b/test/unit/config_t.c
index 50d388f4f..cd539ab0f 100644
--- a/test/unit/config_t.c
+++ b/test/unit/config_t.c
@@ -96,9 +96,15 @@ static void test_parse(void *fixture)
 static void test_clone(void *fixture)
 {
 	struct dm_config_tree *tree = dm_config_from_string(conf);
-	struct dm_config_node *n = dm_config_clone_node(tree, tree->root, 1);
+	struct dm_config_node *n;
 	const struct dm_config_value *value;
 
+	T_ASSERT(tree);
+
+	n = dm_config_clone_node(tree, tree->root, 1);
+
+	T_ASSERT(n);
+
 	/* Check that the nodes are actually distinct. */
 	T_ASSERT(n != tree->root);
 	T_ASSERT(n->sib != tree->root->sib);
@@ -136,7 +142,14 @@ static void test_cascade(void *fixture)
 {
 	struct dm_config_tree *t1 = dm_config_from_string(conf),
 		              *t2 = dm_config_from_string(overlay),
-		              *tree = dm_config_insert_cascaded_tree(t2, t1);
+			      *tree;
+
+	T_ASSERT(t1);
+	T_ASSERT(t2);
+
+	tree = dm_config_insert_cascaded_tree(t2, t1);
+
+	T_ASSERT(tree);
 
 	T_ASSERT(!strcmp(dm_config_tree_find_str(tree, "id", "foo"), "yoda-soda"));
 	T_ASSERT(!strcmp(dm_config_tree_find_str(tree, "idt", "foo"), "foo"));
diff --git a/test/unit/io_engine_t.c b/test/unit/io_engine_t.c
index 431cca6d3..a1b219530 100644
--- a/test/unit/io_engine_t.c
+++ b/test/unit/io_engine_t.c
@@ -146,6 +146,8 @@ static void _test_read(void *fixture)
 
 	f->di = bcache_set_fd(f->fd);
 
+	T_ASSERT(f->di >= 0);
+
 	_io_init(&io);
 	T_ASSERT(f->e->issue(f->e, DIR_READ, f->di, 0, BLOCK_SIZE_SECTORS, f->data, &io));
 	T_ASSERT(f->e->wait(f->e, _complete_io));
@@ -164,6 +166,8 @@ static void _test_write(void *fixture)
 
 	f->di = bcache_set_fd(f->fd);
 
+	T_ASSERT(f->di >= 0);
+
 	_io_init(&io);
 	T_ASSERT(f->e->issue(f->e, DIR_WRITE, f->di, 0, BLOCK_SIZE_SECTORS, f->data, &io));
 	T_ASSERT(f->e->wait(f->e, _complete_io));


