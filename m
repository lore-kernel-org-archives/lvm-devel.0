From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 27 Apr 2018 11:55:56 -0400
Subject: master - unit-tests: Move to test/unit
Message-ID: <201804271555.w3RFtub8005261@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ab63923d19afe3f72d4806082fb8496c8c7900f9
Commit:        ab63923d19afe3f72d4806082fb8496c8c7900f9
Parent:        cdcea0bf55c170f538c3ffc114792eb3c993f4ac
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri Apr 27 16:55:07 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Fri Apr 27 16:55:07 2018 +0100

unit-tests: Move to test/unit

---
 .gitignore               |    2 +-
 Makefile.in              |    4 +-
 configure                |    4 +-
 configure.in             |    2 +-
 test/unit/Makefile.in    |   41 ++
 test/unit/bcache_t.c     |  871 +++++++++++++++++++++++++++++++++++++++
 test/unit/bitset_t.c     |  148 +++++++
 test/unit/config_t.c     |  167 ++++++++
 test/unit/dmlist_t.c     |   49 +++
 test/unit/dmstatus_t.c   |   84 ++++
 test/unit/framework.c    |   66 +++
 test/unit/framework.h    |   49 +++
 test/unit/io_engine_t.c  |  145 +++++++
 test/unit/matcher_data.h | 1013 ++++++++++++++++++++++++++++++++++++++++++++++
 test/unit/matcher_t.c    |   89 ++++
 test/unit/percent_t.c    |  102 +++++
 test/unit/run.c          |  309 ++++++++++++++
 test/unit/string_t.c     |   91 +++++
 test/unit/units.h        |   48 +++
 unit-test/Makefile.in    |   41 --
 unit-test/bcache_t.c     |  871 ---------------------------------------
 unit-test/bitset_t.c     |  148 -------
 unit-test/config_t.c     |  167 --------
 unit-test/dmlist_t.c     |   49 ---
 unit-test/dmstatus_t.c   |   84 ----
 unit-test/framework.c    |   66 ---
 unit-test/framework.h    |   49 ---
 unit-test/io_engine_t.c  |  145 -------
 unit-test/matcher_data.h | 1013 ----------------------------------------------
 unit-test/matcher_t.c    |   89 ----
 unit-test/percent_t.c    |  102 -----
 unit-test/run.c          |  309 --------------
 unit-test/string_t.c     |   91 -----
 unit-test/units.h        |   48 ---
 34 files changed, 3278 insertions(+), 3278 deletions(-)

diff --git a/.gitignore b/.gitignore
index 201cbe5..3038524 100644
--- a/.gitignore
+++ b/.gitignore
@@ -80,4 +80,4 @@ test/lib/vgs
 test/lib/vgscan
 test/lib/vgsplit
 
-unit-test/unit-test
+test/unit/unit-test
diff --git a/Makefile.in b/Makefile.in
index 2420267..916f54d 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -96,7 +96,7 @@ endif
 DISTCLEAN_TARGETS += cscope.out
 CLEAN_DIRS += autom4te.cache
 
-check check_system check_cluster check_local check_lvmetad check_lvmpolld check_lvmlockd_test check_lvmlockd_dlm check_lvmlockd_sanlock unit-test: all
+check check_system check_cluster check_local check_lvmetad check_lvmpolld check_lvmlockd_test check_lvmlockd_dlm check_lvmlockd_sanlock: all
 	$(MAKE) -C test $(@)
 
 conf.generate man.generate: tools
@@ -211,7 +211,7 @@ endif
 endif
 
 ifeq ("$(TESTING)", "yes")
-include unit-test/Makefile
+include test/unit/Makefile
 endif
 
 ifneq ($(shell which ctags),)
diff --git a/configure b/configure
index 7ef73f0..4cd950a 100755
--- a/configure
+++ b/configure
@@ -15689,7 +15689,7 @@ _ACEOF
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile include/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache
 _segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/
 lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile unit-test/Makefile tools/Makefile udev/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile include/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache
 _segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/
 lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -16462,7 +16462,7 @@ do
     "scripts/Makefile") CONFIG_FILES="$CONFIG_FILES scripts/Makefile" ;;
     "test/Makefile") CONFIG_FILES="$CONFIG_FILES test/Makefile" ;;
     "test/api/Makefile") CONFIG_FILES="$CONFIG_FILES test/api/Makefile" ;;
-    "unit-test/Makefile") CONFIG_FILES="$CONFIG_FILES unit-test/Makefile" ;;
+    "test/unit/Makefile") CONFIG_FILES="$CONFIG_FILES test/unit/Makefile" ;;
     "tools/Makefile") CONFIG_FILES="$CONFIG_FILES tools/Makefile" ;;
     "udev/Makefile") CONFIG_FILES="$CONFIG_FILES udev/Makefile" ;;
 
diff --git a/configure.in b/configure.in
index f65e35e..a7fcd18 100644
--- a/configure.in
+++ b/configure.in
@@ -2245,7 +2245,7 @@ scripts/lvmdump.sh
 scripts/Makefile
 test/Makefile
 test/api/Makefile
-unit-test/Makefile
+test/unit/Makefile
 tools/Makefile
 udev/Makefile
 ])
diff --git a/test/unit/Makefile.in b/test/unit/Makefile.in
new file mode 100644
index 0000000..63681f3
--- /dev/null
+++ b/test/unit/Makefile.in
@@ -0,0 +1,41 @@
+# Copyright (C) 2011-2018 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+UNIT_SOURCE=\
+	test/unit/bcache_t.c \
+	test/unit/bitset_t.c \
+	test/unit/config_t.c \
+	test/unit/dmlist_t.c \
+	test/unit/dmstatus_t.c \
+	test/unit/io_engine_t.c \
+	test/unit/matcher_t.c \
+	test/unit/framework.c \
+	test/unit/percent_t.c \
+	test/unit/run.c \
+	test/unit/string_t.c
+
+UNIT_DEPENDS=$(subst .c,.d,$(UNIT_SOURCE))
+UNIT_OBJECTS=$(UNIT_SOURCE:%.c=%.o)
+CLEAN_TARGETS+=$(UNIT_DEPENDS) $(UNIT_OBJECTS)
+UNIT_LDLIBS += $(LVMINTERNAL_LIBS) -ldevmapper -laio
+
+test/unit/unit-test: $(UNIT_OBJECTS) libdm/libdevmapper.$(LIB_SUFFIX) lib/liblvm-internal.a
+	@echo "    [LD] $@"
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) -L$(top_builddir)/libdm \
+	      -o $@ $(UNIT_OBJECTS) $(UNIT_LDLIBS)
+
+.PHONEY: run-unit-test
+run-unit-test: test/unit/unit-test
+	@echo Running unit tests
+	LD_LIBRARY_PATH=libdm test/unit/unit-test run
+
+-include $(UNIT_DEPENDS)
diff --git a/test/unit/bcache_t.c b/test/unit/bcache_t.c
new file mode 100644
index 0000000..d06d5fe
--- /dev/null
+++ b/test/unit/bcache_t.c
@@ -0,0 +1,871 @@
+/*
+ * Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include <errno.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+
+#include "bcache.h"
+#include "framework.h"
+#include "units.h"
+
+#define SHOW_MOCK_CALLS 0
+
+/*----------------------------------------------------------------
+ * Mock engine
+ *--------------------------------------------------------------*/
+struct mock_engine {
+	struct io_engine e;
+	struct dm_list expected_calls;
+	struct dm_list issued_io;
+	unsigned max_io;
+	sector_t block_size;
+};
+
+enum method {
+	E_DESTROY,
+	E_ISSUE,
+	E_WAIT,
+	E_MAX_IO
+};
+
+struct mock_call {
+	struct dm_list list;
+	enum method m;
+
+	bool match_args;
+	enum dir d;
+	int fd;
+	block_address b;
+	bool issue_r;
+	bool wait_r;
+};
+
+struct mock_io {
+	struct dm_list list;
+	int fd;
+	sector_t sb;
+	sector_t se;
+	void *data;
+	void *context;
+	bool r;
+};
+
+static const char *_show_method(enum method m)
+{
+	switch (m) {
+	case E_DESTROY:
+		return "destroy()";
+	case E_ISSUE:
+		return "issue()";
+	case E_WAIT:
+		return "wait()";
+	case E_MAX_IO:
+		return "max_io()";
+	}
+
+	return "<unknown>";
+}
+
+static void _expect(struct mock_engine *e, enum method m)
+{
+	struct mock_call *mc = malloc(sizeof(*mc));
+	mc->m = m;
+	mc->match_args = false;
+	dm_list_add(&e->expected_calls, &mc->list);
+}
+
+static void _expect_read(struct mock_engine *e, int fd, block_address b)
+{
+	struct mock_call *mc = malloc(sizeof(*mc));
+	mc->m = E_ISSUE;
+	mc->match_args = true;
+	mc->d = DIR_READ;
+	mc->fd = fd;
+	mc->b = b;
+	mc->issue_r = true;
+	mc->wait_r = true;
+	dm_list_add(&e->expected_calls, &mc->list);
+}
+
+static void _expect_write(struct mock_engine *e, int fd, block_address b)
+{
+	struct mock_call *mc = malloc(sizeof(*mc));
+	mc->m = E_ISSUE;
+	mc->match_args = true;
+	mc->d = DIR_WRITE;
+	mc->fd = fd;
+	mc->b = b;
+	mc->issue_r = true;
+	mc->wait_r = true;
+	dm_list_add(&e->expected_calls, &mc->list);
+}
+
+static void _expect_read_bad_issue(struct mock_engine *e, int fd, block_address b)
+{
+	struct mock_call *mc = malloc(sizeof(*mc));
+	mc->m = E_ISSUE;
+	mc->match_args = true;
+	mc->d = DIR_READ;
+	mc->fd = fd;
+	mc->b = b;
+	mc->issue_r = false;
+	mc->wait_r = true;
+	dm_list_add(&e->expected_calls, &mc->list);
+}
+
+static void _expect_write_bad_issue(struct mock_engine *e, int fd, block_address b)
+{
+	struct mock_call *mc = malloc(sizeof(*mc));
+	mc->m = E_ISSUE;
+	mc->match_args = true;
+	mc->d = DIR_WRITE;
+	mc->fd = fd;
+	mc->b = b;
+	mc->issue_r = false;
+	mc->wait_r = true;
+	dm_list_add(&e->expected_calls, &mc->list);
+}
+
+static void _expect_read_bad_wait(struct mock_engine *e, int fd, block_address b)
+{
+	struct mock_call *mc = malloc(sizeof(*mc));
+	mc->m = E_ISSUE;
+	mc->match_args = true;
+	mc->d = DIR_READ;
+	mc->fd = fd;
+	mc->b = b;
+	mc->issue_r = true;
+	mc->wait_r = false;
+	dm_list_add(&e->expected_calls, &mc->list);
+}
+
+static void _expect_write_bad_wait(struct mock_engine *e, int fd, block_address b)
+{
+	struct mock_call *mc = malloc(sizeof(*mc));
+	mc->m = E_ISSUE;
+	mc->match_args = true;
+	mc->d = DIR_WRITE;
+	mc->fd = fd;
+	mc->b = b;
+	mc->issue_r = true;
+	mc->wait_r = false;
+	dm_list_add(&e->expected_calls, &mc->list);
+}
+
+static struct mock_call *_match_pop(struct mock_engine *e, enum method m)
+{
+
+	struct mock_call *mc;
+
+	if (dm_list_empty(&e->expected_calls))
+		test_fail("unexpected call to method %s\n", _show_method(m));
+
+	mc = dm_list_item(e->expected_calls.n, struct mock_call);
+	dm_list_del(&mc->list);
+
+	if (mc->m != m)
+		test_fail("expected %s, but got %s\n", _show_method(mc->m), _show_method(m));
+#if SHOW_MOCK_CALLS
+	else
+		fprintf(stderr, "%s called (expected)\n", _show_method(m));
+#endif
+
+	return mc;
+}
+
+static void _match(struct mock_engine *e, enum method m)
+{
+	free(_match_pop(e, m));
+}
+
+static void _no_outstanding_expectations(struct mock_engine *e)
+{
+	struct mock_call *mc;
+
+	if (!dm_list_empty(&e->expected_calls)) {
+		fprintf(stderr, "unsatisfied expectations:\n");
+		dm_list_iterate_items (mc, &e->expected_calls)
+			fprintf(stderr, "  %s\n", _show_method(mc->m));
+	}
+	T_ASSERT(dm_list_empty(&e->expected_calls));
+}
+
+static struct mock_engine *_to_mock(struct io_engine *e)
+{
+	return container_of(e, struct mock_engine, e);
+}
+
+static void _mock_destroy(struct io_engine *e)
+{
+	struct mock_engine *me = _to_mock(e);
+
+	_match(me, E_DESTROY);
+	T_ASSERT(dm_list_empty(&me->issued_io));
+	T_ASSERT(dm_list_empty(&me->expected_calls));
+	free(_to_mock(e));
+}
+
+static bool _mock_issue(struct io_engine *e, enum dir d, int fd,
+	      		sector_t sb, sector_t se, void *data, void *context)
+{
+	bool r, wait_r;
+	struct mock_io *io;
+	struct mock_call *mc;
+	struct mock_engine *me = _to_mock(e);
+
+	mc = _match_pop(me, E_ISSUE);
+	if (mc->match_args) {
+		T_ASSERT(d == mc->d);
+		T_ASSERT(fd == mc->fd);
+		T_ASSERT(sb == mc->b * me->block_size);
+		T_ASSERT(se == (mc->b + 1) * me->block_size);
+	}
+	r = mc->issue_r;
+	wait_r = mc->wait_r;
+	free(mc);
+
+	if (r) {
+		io = malloc(sizeof(*io));
+		if (!io)
+			abort();
+
+		io->fd = fd;
+		io->sb = sb;
+		io->se = se;
+		io->data = data;
+		io->context = context;
+		io->r = wait_r;
+
+		dm_list_add(&me->issued_io, &io->list);
+	}
+
+	return r;
+}
+
+static bool _mock_wait(struct io_engine *e, io_complete_fn fn)
+{
+	struct mock_io *io;
+	struct mock_engine *me = _to_mock(e);
+	_match(me, E_WAIT);
+
+	// FIXME: provide a way to control how many are completed and whether
+	// they error.
+	T_ASSERT(!dm_list_empty(&me->issued_io));
+	io = dm_list_item(me->issued_io.n, struct mock_io);
+	dm_list_del(&io->list);
+	fn(io->context, io->r ? 0 : -EIO);
+	free(io);
+
+	return true;
+}
+
+static unsigned _mock_max_io(struct io_engine *e)
+{
+	struct mock_engine *me = _to_mock(e);
+	_match(me, E_MAX_IO);
+	return me->max_io;
+}
+
+static struct mock_engine *_mock_create(unsigned max_io, sector_t block_size)
+{
+	struct mock_engine *m = malloc(sizeof(*m));
+
+	m->e.destroy = _mock_destroy;
+	m->e.issue = _mock_issue;
+	m->e.wait = _mock_wait;
+	m->e.max_io = _mock_max_io;
+
+	m->max_io = max_io;
+	m->block_size = block_size;
+	dm_list_init(&m->expected_calls);
+	dm_list_init(&m->issued_io);
+
+	return m;
+}
+
+/*----------------------------------------------------------------
+ * Fixtures
+ *--------------------------------------------------------------*/
+struct fixture {
+	struct mock_engine *me;
+	struct bcache *cache;
+};
+
+static struct fixture *_fixture_init(sector_t block_size, unsigned nr_cache_blocks)
+{
+	struct fixture *f = malloc(sizeof(*f));
+
+	f->me = _mock_create(16, block_size);
+	T_ASSERT(f->me);
+
+	_expect(f->me, E_MAX_IO);
+	f->cache = bcache_create(block_size, nr_cache_blocks, &f->me->e);
+	T_ASSERT(f->cache);
+
+	return f;
+}
+
+static void _fixture_exit(struct fixture *f)
+{
+	_expect(f->me, E_DESTROY);
+	bcache_destroy(f->cache);
+
+	free(f);
+}
+
+static void *_small_fixture_init(void)
+{
+	return _fixture_init(128, 16);
+}
+
+static void _small_fixture_exit(void *context)
+{
+	_fixture_exit(context);
+}
+
+static void *_large_fixture_init(void)
+{
+	return _fixture_init(128, 1024);
+}
+
+static void _large_fixture_exit(void *context)
+{
+	_fixture_exit(context);
+}
+
+/*----------------------------------------------------------------
+ * Tests
+ *--------------------------------------------------------------*/
+#define MEG 2048
+#define SECTOR_SHIFT 9
+
+static void good_create(sector_t block_size, unsigned nr_cache_blocks)
+{
+	struct bcache *cache;
+	struct mock_engine *me = _mock_create(16, 128);
+
+	_expect(me, E_MAX_IO);
+	cache = bcache_create(block_size, nr_cache_blocks, &me->e);
+	T_ASSERT(cache);
+
+	_expect(me, E_DESTROY);
+	bcache_destroy(cache);
+}
+
+static void bad_create(sector_t block_size, unsigned nr_cache_blocks)
+{
+	struct bcache *cache;
+	struct mock_engine *me = _mock_create(16, 128);
+
+	_expect(me, E_MAX_IO);
+	cache = bcache_create(block_size, nr_cache_blocks, &me->e);
+	T_ASSERT(!cache);
+
+	_expect(me, E_DESTROY);
+	me->e.destroy(&me->e);
+}
+
+static void test_create(void *fixture)
+{
+	good_create(8, 16);
+}
+
+static void test_nr_cache_blocks_must_be_positive(void *fixture)
+{
+	bad_create(8, 0);
+}
+
+static void test_block_size_must_be_positive(void *fixture)
+{
+	bad_create(0, 16);
+}
+
+static void test_block_size_must_be_multiple_of_page_size(void *fixture)
+{
+	static unsigned _bad_examples[] = {3, 9, 13, 1025};
+
+	unsigned i;
+
+	for (i = 0; i < DM_ARRAY_SIZE(_bad_examples); i++)
+		bad_create(_bad_examples[i], 16);
+
+	for (i = 1; i < 1000; i++)
+		good_create(i * 8, 16);
+}
+
+static void test_get_triggers_read(void *context)
+{
+        int err;
+	struct fixture *f = context;
+
+	int fd = 17;   // arbitrary key
+	struct block *b;
+
+	_expect_read(f->me, fd, 0);
+	_expect(f->me, E_WAIT);
+	T_ASSERT(bcache_get(f->cache, fd, 0, 0, &b, &err));
+	bcache_put(b);
+}
+
+static void test_repeated_reads_are_cached(void *context)
+{
+        int err;
+	struct fixture *f = context;
+
+	int fd = 17;   // arbitrary key
+	unsigned i;
+	struct block *b;
+
+	_expect_read(f->me, fd, 0);
+	_expect(f->me, E_WAIT);
+	for (i = 0; i < 100; i++) {
+		T_ASSERT(bcache_get(f->cache, fd, 0, 0, &b, &err));
+		bcache_put(b);
+	}
+}
+
+static void test_block_gets_evicted_with_many_reads(void *context)
+{
+	struct fixture *f = context;
+
+	int err;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+	const unsigned nr_cache_blocks = 16;
+
+	int fd = 17;   // arbitrary key
+	unsigned i;
+	struct block *b;
+
+	for (i = 0; i < nr_cache_blocks; i++) {
+		_expect_read(me, fd, i);
+		_expect(me, E_WAIT);
+		T_ASSERT(bcache_get(cache, fd, i, 0, &b, &err));
+		bcache_put(b);
+	}
+
+	// Not enough cache blocks to hold this one
+	_expect_read(me, fd, nr_cache_blocks);
+	_expect(me, E_WAIT);
+	T_ASSERT(bcache_get(cache, fd, nr_cache_blocks, 0, &b, &err));
+	bcache_put(b);
+
+	// Now if we run through we should find one block has been
+	// evicted.  We go backwards because the oldest is normally
+	// evicted first.
+	_expect(me, E_ISSUE);
+	_expect(me, E_WAIT);
+	for (i = nr_cache_blocks; i; i--) {
+		T_ASSERT(bcache_get(cache, fd, i - 1, 0, &b, &err));
+		bcache_put(b);
+	}
+}
+
+static void test_prefetch_issues_a_read(void *context)
+{
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+	const unsigned nr_cache_blocks = 16;
+
+	int err;
+	int fd = 17;   // arbitrary key
+	unsigned i;
+	struct block *b;
+
+	for (i = 0; i < nr_cache_blocks; i++) {
+		// prefetch should not wait
+		_expect_read(me, fd, i);
+		bcache_prefetch(cache, fd, i);
+	}
+
+
+	for (i = 0; i < nr_cache_blocks; i++) {
+		_expect(me, E_WAIT);
+		T_ASSERT(bcache_get(cache, fd, i, 0, &b, &err));
+		bcache_put(b);
+	}
+}
+
+static void test_too_many_prefetches_does_not_trigger_a_wait(void *context)
+{
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+
+	const unsigned nr_cache_blocks = 16;
+	int fd = 17;   // arbitrary key
+	unsigned i;
+
+	for (i = 0; i < 10 * nr_cache_blocks; i++) {
+		// prefetch should not wait
+		if (i < nr_cache_blocks)
+			_expect_read(me, fd, i);
+		bcache_prefetch(cache, fd, i);
+	}
+
+	// Destroy will wait for any in flight IO triggered by prefetches.
+	for (i = 0; i < nr_cache_blocks; i++)
+		_expect(me, E_WAIT);
+}
+
+static void test_dirty_data_gets_written_back(void *context)
+{
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+
+	int err;
+	int fd = 17;   // arbitrary key
+	struct block *b;
+
+	// Expect the read
+	_expect_read(me, fd, 0);
+	_expect(me, E_WAIT);
+	T_ASSERT(bcache_get(cache, fd, 0, GF_DIRTY, &b, &err));
+	bcache_put(b);
+
+	// Expect the write
+	_expect_write(me, fd, 0);
+	_expect(me, E_WAIT);
+}
+
+static void test_zeroed_data_counts_as_dirty(void *context)
+{
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+
+	int err;
+	int fd = 17;   // arbitrary key
+	struct block *b;
+
+	// No read
+	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b, &err));
+	bcache_put(b);
+
+	// Expect the write
+	_expect_write(me, fd, 0);
+	_expect(me, E_WAIT);
+}
+
+static void test_flush_waits_for_all_dirty(void *context)
+{
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+
+	const unsigned count = 16;
+	int err;
+	int fd = 17;   // arbitrary key
+	unsigned i;
+	struct block *b;
+
+	for (i = 0; i < count; i++) {
+		if (i % 2) {
+			T_ASSERT(bcache_get(cache, fd, i, GF_ZERO, &b, &err));
+		} else {
+			_expect_read(me, fd, i);
+			_expect(me, E_WAIT);
+			T_ASSERT(bcache_get(cache, fd, i, 0, &b, &err));
+		}
+		bcache_put(b);
+	}
+
+	for (i = 0; i < count; i++) {
+		if (i % 2)
+			_expect_write(me, fd, i);
+	}
+
+	for (i = 0; i < count; i++) {
+		if (i % 2)
+			_expect(me, E_WAIT);
+	}
+
+	bcache_flush(cache);
+	_no_outstanding_expectations(me);
+}
+
+static void test_multiple_files(void *context)
+{
+	static int _fds[] = {1, 128, 345, 678, 890};
+
+	int err;
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+	struct block *b;
+	unsigned i;
+
+	for (i = 0; i < DM_ARRAY_SIZE(_fds); i++) {
+		_expect_read(me, _fds[i], 0);
+		_expect(me, E_WAIT);
+
+		T_ASSERT(bcache_get(cache, _fds[i], 0, 0, &b, &err));
+		bcache_put(b);
+	}
+}
+
+static void test_read_bad_issue(void *context)
+{
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+	struct block *b;
+	int err;
+
+	_expect_read_bad_issue(me, 17, 0);
+	T_ASSERT(!bcache_get(cache, 17, 0, 0, &b, &err));
+}
+
+static void test_read_bad_issue_intermittent(void *context)
+{
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+	struct block *b;
+	int fd = 17;
+	int err;
+
+	_expect_read_bad_issue(me, fd, 0);
+	T_ASSERT(!bcache_get(cache, fd, 0, 0, &b, &err));
+
+	_expect_read(me, fd, 0);
+	_expect(me, E_WAIT);
+	T_ASSERT(bcache_get(cache, fd, 0, 0, &b, &err));
+	bcache_put(b);
+}
+
+static void test_read_bad_wait(void *context)
+{
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+	struct block *b;
+	int fd = 17;
+	int err;
+
+	_expect_read_bad_wait(me, fd, 0);
+	_expect(me, E_WAIT);
+	T_ASSERT(!bcache_get(cache, fd, 0, 0, &b, &err));
+}
+
+static void test_read_bad_wait_intermittent(void *context)
+{
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+	struct block *b;
+	int fd = 17;
+	int err;
+
+	_expect_read_bad_wait(me, fd, 0);
+	_expect(me, E_WAIT);
+	T_ASSERT(!bcache_get(cache, fd, 0, 0, &b, &err));
+
+	_expect_read(me, fd, 0);
+	_expect(me, E_WAIT);
+	T_ASSERT(bcache_get(cache, fd, 0, 0, &b, &err));
+	bcache_put(b);
+}
+
+static void test_write_bad_issue_stops_flush(void *context)
+{
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+	struct block *b;
+	int fd = 17;
+	int err;
+
+	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b, &err));
+	_expect_write_bad_issue(me, fd, 0);
+	bcache_put(b);
+	T_ASSERT(!bcache_flush(cache));
+
+	// we'll let it succeed the second time
+	_expect_write(me, fd, 0);
+	_expect(me, E_WAIT);
+	T_ASSERT(bcache_flush(cache));
+}
+
+static void test_write_bad_io_stops_flush(void *context)
+{
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+	struct block *b;
+	int fd = 17;
+	int err;
+
+	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b, &err));
+	_expect_write_bad_wait(me, fd, 0);
+	_expect(me, E_WAIT);
+	bcache_put(b);
+	T_ASSERT(!bcache_flush(cache));
+
+	// we'll let it succeed the second time
+	_expect_write(me, fd, 0);
+	_expect(me, E_WAIT);
+	T_ASSERT(bcache_flush(cache));
+}
+
+static void test_invalidate_not_present(void *context)
+{
+	struct fixture *f = context;
+	struct bcache *cache = f->cache;
+	int fd = 17;
+
+	T_ASSERT(bcache_invalidate(cache, fd, 0));
+}
+
+static void test_invalidate_present(void *context)
+{
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+	struct block *b;
+	int fd = 17;
+	int err;
+
+	_expect_read(me, fd, 0);
+	_expect(me, E_WAIT);
+	T_ASSERT(bcache_get(cache, fd, 0, 0, &b, &err));
+	bcache_put(b);
+
+	T_ASSERT(bcache_invalidate(cache, fd, 0));
+}
+
+static void test_invalidate_after_read_error(void *context)
+{
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+	struct block *b;
+	int fd = 17;
+	int err;
+
+	_expect_read_bad_issue(me, fd, 0);
+	T_ASSERT(!bcache_get(cache, fd, 0, 0, &b, &err));
+	T_ASSERT(bcache_invalidate(cache, fd, 0));
+}
+
+static void test_invalidate_after_write_error(void *context)
+{
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+	struct block *b;
+	int fd = 17;
+	int err;
+
+	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b, &err));
+	bcache_put(b);
+
+	// invalidate should fail if the write fails
+	_expect_write_bad_wait(me, fd, 0);
+	_expect(me, E_WAIT);
+	T_ASSERT(!bcache_invalidate(cache, fd, 0));
+
+	// and should succeed if the write does
+	_expect_write(me, fd, 0);
+	_expect(me, E_WAIT);
+	T_ASSERT(bcache_invalidate(cache, fd, 0));
+
+	// a read is not required to get the block
+	_expect_read(me, fd, 0);
+	_expect(me, E_WAIT);
+	T_ASSERT(bcache_get(cache, fd, 0, 0, &b, &err));
+	bcache_put(b);
+}
+
+static void test_invalidate_held_block(void *context)
+{
+
+	struct fixture *f = context;
+	struct mock_engine *me = f->me;
+	struct bcache *cache = f->cache;
+	struct block *b;
+	int fd = 17;
+	int err;
+
+	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b, &err));
+
+	T_ASSERT(!bcache_invalidate(cache, fd, 0));
+
+	_expect_write(me, fd, 0);
+	_expect(me, E_WAIT);
+	bcache_put(b);
+}
+
+/*----------------------------------------------------------------
+ * Top level
+ *--------------------------------------------------------------*/
+#define T(path, desc, fn) register_test(ts, "/base/device/bcache/" path, desc, fn)
+
+static struct test_suite *_small_tests(void)
+{
+	struct test_suite *ts = test_suite_create(_small_fixture_init, _small_fixture_exit);
+	if (!ts) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
+	T("create-destroy", "simple create/destroy", test_create);
+	T("cache-blocks-positive", "nr cache blocks must be positive", test_nr_cache_blocks_must_be_positive);
+	T("block-size-positive", "block size must be positive", test_block_size_must_be_positive);
+	T("block-size-multiple-page", "block size must be a multiple of page size", test_block_size_must_be_multiple_of_page_size);
+	T("get-reads", "bcache_get() triggers read", test_get_triggers_read);
+	T("reads-cached", "repeated reads are cached", test_repeated_reads_are_cached);
+	T("blocks-get-evicted", "block get evicted with many reads", test_block_gets_evicted_with_many_reads);
+	T("prefetch-reads", "prefetch issues a read", test_prefetch_issues_a_read);
+	T("prefetch-never-waits", "too many prefetches does not trigger a wait", test_too_many_prefetches_does_not_trigger_a_wait);
+	T("writeback-occurs", "dirty data gets written back", test_dirty_data_gets_written_back);
+	T("zero-flag-dirties", "zeroed data counts as dirty", test_zeroed_data_counts_as_dirty);
+	T("read-multiple-files", "read from multiple files", test_multiple_files);
+	T("read-bad-issue", "read fails if io engine unable to issue", test_read_bad_issue);
+	T("read-bad-issue-intermittent", "failed issue, followed by succes", test_read_bad_issue_intermittent);
+	T("read-bad-io", "read issued ok, but io fails", test_read_bad_wait);
+	T("read-bad-io-intermittent", "failed io, followed by success", test_read_bad_wait_intermittent);
+	T("write-bad-issue-stops-flush", "flush fails temporarily if any block fails to write", test_write_bad_issue_stops_flush);
+	T("write-bad-io-stops-flush", "flush fails temporarily if any block fails to write", test_write_bad_io_stops_flush);
+	T("invalidate-not-present", "invalidate a block that isn't in the cache", test_invalidate_not_present);
+	T("invalidate-present", "invalidate a block that is in the cache", test_invalidate_present);
+	T("invalidate-read-error", "invalidate a block that errored", test_invalidate_after_read_error);
+	T("invalidate-write-error", "invalidate a block that errored", test_invalidate_after_write_error);
+	T("invalidate-fails-in-held", "invalidating a held block fails", test_invalidate_held_block);
+
+	return ts;
+}
+
+static struct test_suite *_large_tests(void)
+{
+	struct test_suite *ts = test_suite_create(_large_fixture_init, _large_fixture_exit);
+	if (!ts) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
+	T("flush-waits", "flush waits for all dirty", test_flush_waits_for_all_dirty);
+
+	return ts;
+}
+
+void bcache_tests(struct dm_list *all_tests)
+{
+	dm_list_add(all_tests, &_small_tests()->list);
+	dm_list_add(all_tests, &_large_tests()->list);
+}
diff --git a/test/unit/bitset_t.c b/test/unit/bitset_t.c
new file mode 100644
index 0000000..106f60f
--- /dev/null
+++ b/test/unit/bitset_t.c
@@ -0,0 +1,148 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "units.h"
+#include "libdevmapper.h"
+
+enum {
+        NR_BITS = 137
+};
+
+static void *_mem_init(void) {
+	struct dm_pool *mem = dm_pool_create("bitset test", 1024);
+	if (!mem) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
+	return mem;
+}
+
+static void _mem_exit(void *mem)
+{
+	dm_pool_destroy(mem);
+}
+
+static void test_get_next(void *fixture)
+{
+	struct dm_pool *mem = fixture;
+
+        int i, j, last = 0, first;
+        dm_bitset_t bs = dm_bitset_create(mem, NR_BITS);
+
+        for (i = 0; i < NR_BITS; i++)
+                T_ASSERT(!dm_bit(bs, i));
+
+        for (i = 0, j = 1; i < NR_BITS; i += j, j++)
+                dm_bit_set(bs, i);
+
+        first = 1;
+        for (i = 0, j = 1; i < NR_BITS; i += j, j++) {
+                if (first) {
+                        last = dm_bit_get_first(bs);
+                        first = 0;
+                } else
+                        last = dm_bit_get_next(bs, last);
+
+                T_ASSERT(last == i);
+        }
+
+        T_ASSERT(dm_bit_get_next(bs, last) == -1);
+}
+
+static void bit_flip(dm_bitset_t bs, int bit)
+{
+        int old = dm_bit(bs, bit);
+        if (old)
+                dm_bit_clear(bs, bit);
+        else
+                dm_bit_set(bs, bit);
+}
+
+static void test_equal(void *fixture)
+{
+	struct dm_pool *mem = fixture;
+        dm_bitset_t bs1 = dm_bitset_create(mem, NR_BITS);
+        dm_bitset_t bs2 = dm_bitset_create(mem, NR_BITS);
+
+        int i, j;
+        for (i = 0, j = 1; i < NR_BITS; i += j, j++) {
+                dm_bit_set(bs1, i);
+                dm_bit_set(bs2, i);
+        }
+
+        T_ASSERT(dm_bitset_equal(bs1, bs2));
+        T_ASSERT(dm_bitset_equal(bs2, bs1));
+
+        for (i = 0; i < NR_BITS; i++) {
+                bit_flip(bs1, i);
+                T_ASSERT(!dm_bitset_equal(bs1, bs2));
+                T_ASSERT(!dm_bitset_equal(bs2, bs1));
+
+                T_ASSERT(dm_bitset_equal(bs1, bs1)); /* comparing with self */
+                bit_flip(bs1, i);
+        }
+}
+
+static void test_and(void *fixture)
+{
+	struct dm_pool *mem = fixture;
+        dm_bitset_t bs1 = dm_bitset_create(mem, NR_BITS);
+        dm_bitset_t bs2 = dm_bitset_create(mem, NR_BITS);
+        dm_bitset_t bs3 = dm_bitset_create(mem, NR_BITS);
+
+        int i, j;
+        for (i = 0, j = 1; i < NR_BITS; i += j, j++) {
+                dm_bit_set(bs1, i);
+                dm_bit_set(bs2, i);
+        }
+
+        dm_bit_and(bs3, bs1, bs2);
+
+        T_ASSERT(dm_bitset_equal(bs1, bs2));
+        T_ASSERT(dm_bitset_equal(bs1, bs3));
+        T_ASSERT(dm_bitset_equal(bs2, bs3));
+
+        dm_bit_clear_all(bs1);
+        dm_bit_clear_all(bs2);
+
+        for (i = 0; i < NR_BITS; i++) {
+                if (i % 2)
+                        dm_bit_set(bs1, i);
+                else
+                        dm_bit_set(bs2, i);
+        }
+
+        dm_bit_and(bs3, bs1, bs2);
+        for (i = 0; i < NR_BITS; i++)
+                T_ASSERT(!dm_bit(bs3, i));
+}
+
+#define T(path, desc, fn) register_test(ts, "/base/data-struct/bitset/" path, desc, fn)
+
+void bitset_tests(struct dm_list *all_tests)
+{
+	struct test_suite *ts = test_suite_create(_mem_init, _mem_exit);
+	if (!ts) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
+	T("get_next", "get next set bit", test_get_next);
+	T("equal", "equality", test_equal);
+	T("and", "and all bits", test_and);
+
+	dm_list_add(all_tests, &ts->list);
+}
+
diff --git a/test/unit/config_t.c b/test/unit/config_t.c
new file mode 100644
index 0000000..5331f79
--- /dev/null
+++ b/test/unit/config_t.c
@@ -0,0 +1,167 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "units.h"
+#include "libdevmapper.h"
+
+static void *_mem_init(void)
+{
+	struct dm_pool *mem = dm_pool_create("config test", 1024);
+	if (!mem) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
+	return mem;
+}
+
+static void _mem_exit(void *mem)
+{
+	dm_pool_destroy(mem);
+}
+
+static const char *conf =
+	"id = \"yada-yada\"\n"
+	"seqno = 15\n"
+	"status = [\"READ\", \"WRITE\"]\n"
+	"flags = []\n"
+	"extent_size = 8192\n"
+	"physical_volumes {\n"
+	"    pv0 {\n"
+	"        id = \"abcd-efgh\"\n"
+	"    }\n"
+	"    pv1 {\n"
+	"        id = \"bbcd-efgh\"\n"
+	"    }\n"
+	"    pv2 {\n"
+	"        id = \"cbcd-efgh\"\n"
+	"    }\n"
+	"}\n";
+
+static const char *overlay =
+	"id = \"yoda-soda\"\n"
+	"flags = [\"FOO\"]\n"
+	"physical_volumes {\n"
+	"    pv1 {\n"
+	"        id = \"hgfe-dcba\"\n"
+	"    }\n"
+	"    pv3 {\n"
+	"        id = \"dbcd-efgh\"\n"
+	"    }\n"
+	"}\n";
+
+static void test_parse(void *fixture)
+{
+	struct dm_config_tree *tree = dm_config_from_string(conf);
+	const struct dm_config_value *value;
+
+	T_ASSERT((long) tree);
+	T_ASSERT(dm_config_has_node(tree->root, "id"));
+	T_ASSERT(dm_config_has_node(tree->root, "physical_volumes"));
+	T_ASSERT(dm_config_has_node(tree->root, "physical_volumes/pv0"));
+	T_ASSERT(dm_config_has_node(tree->root, "physical_volumes/pv0/id"));
+
+	T_ASSERT(!strcmp(dm_config_find_str(tree->root, "id", "foo"), "yada-yada"));
+	T_ASSERT(!strcmp(dm_config_find_str(tree->root, "idt", "foo"), "foo"));
+
+	T_ASSERT(!strcmp(dm_config_find_str(tree->root, "physical_volumes/pv0/bb", "foo"), "foo"));
+	T_ASSERT(!strcmp(dm_config_find_str(tree->root, "physical_volumes/pv0/id", "foo"), "abcd-efgh"));
+
+	T_ASSERT(!dm_config_get_uint32(tree->root, "id", NULL));
+	T_ASSERT(dm_config_get_uint32(tree->root, "extent_size", NULL));
+
+	/* FIXME: Currently everything parses as a list, even if it's not */
+	// T_ASSERT(!dm_config_get_list(tree->root, "id", NULL));
+	// T_ASSERT(!dm_config_get_list(tree->root, "extent_size", NULL));
+
+	T_ASSERT(dm_config_get_list(tree->root, "flags", &value));
+	T_ASSERT(value->next == NULL); /* an empty list */
+	T_ASSERT(dm_config_get_list(tree->root, "status", &value));
+	T_ASSERT(value->next != NULL); /* a non-empty list */
+
+	dm_config_destroy(tree);
+}
+
+static void test_clone(void *fixture)
+{
+	struct dm_config_tree *tree = dm_config_from_string(conf);
+	struct dm_config_node *n = dm_config_clone_node(tree, tree->root, 1);
+	const struct dm_config_value *value;
+
+	/* Check that the nodes are actually distinct. */
+	T_ASSERT(n != tree->root);
+	T_ASSERT(n->sib != tree->root->sib);
+	T_ASSERT(dm_config_find_node(n, "physical_volumes") != NULL);
+	T_ASSERT(dm_config_find_node(tree->root, "physical_volumes") != NULL);
+	T_ASSERT(dm_config_find_node(n, "physical_volumes") != dm_config_find_node(tree->root, "physical_volumes"));
+
+	T_ASSERT(dm_config_has_node(n, "id"));
+	T_ASSERT(dm_config_has_node(n, "physical_volumes"));
+	T_ASSERT(dm_config_has_node(n, "physical_volumes/pv0"));
+	T_ASSERT(dm_config_has_node(n, "physical_volumes/pv0/id"));
+
+	T_ASSERT(!strcmp(dm_config_find_str(n, "id", "foo"), "yada-yada"));
+	T_ASSERT(!strcmp(dm_config_find_str(n, "idt", "foo"), "foo"));
+
+	T_ASSERT(!strcmp(dm_config_find_str(n, "physical_volumes/pv0/bb", "foo"), "foo"));
+	T_ASSERT(!strcmp(dm_config_find_str(n, "physical_volumes/pv0/id", "foo"), "abcd-efgh"));
+
+	T_ASSERT(!dm_config_get_uint32(n, "id", NULL));
+	T_ASSERT(dm_config_get_uint32(n, "extent_size", NULL));
+
+	/* FIXME: Currently everything parses as a list, even if it's not */
+	// T_ASSERT(!dm_config_get_list(tree->root, "id", NULL));
+	// T_ASSERT(!dm_config_get_list(tree->root, "extent_size", NULL));
+
+	T_ASSERT(dm_config_get_list(n, "flags", &value));
+	T_ASSERT(value->next == NULL); /* an empty list */
+	T_ASSERT(dm_config_get_list(n, "status", &value));
+	T_ASSERT(value->next != NULL); /* a non-empty list */
+
+	dm_config_destroy(tree);
+}
+
+static void test_cascade(void *fixture)
+{
+	struct dm_config_tree *t1 = dm_config_from_string(conf),
+		              *t2 = dm_config_from_string(overlay),
+		              *tree = dm_config_insert_cascaded_tree(t2, t1);
+
+	T_ASSERT(!strcmp(dm_config_tree_find_str(tree, "id", "foo"), "yoda-soda"));
+	T_ASSERT(!strcmp(dm_config_tree_find_str(tree, "idt", "foo"), "foo"));
+
+	T_ASSERT(!strcmp(dm_config_tree_find_str(tree, "physical_volumes/pv0/bb", "foo"), "foo"));
+	T_ASSERT(!strcmp(dm_config_tree_find_str(tree, "physical_volumes/pv1/id", "foo"), "hgfe-dcba"));
+	T_ASSERT(!strcmp(dm_config_tree_find_str(tree, "physical_volumes/pv3/id", "foo"), "dbcd-efgh"));
+
+	dm_config_destroy(t1);
+	dm_config_destroy(t2);
+}
+
+#define T(path, desc, fn) register_test(ts, "/metadata/config/" path, desc, fn)
+
+void config_tests(struct dm_list *all_tests)
+{
+	struct test_suite *ts = test_suite_create(_mem_init, _mem_exit);
+	if (!ts) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
+	T("parse", "parsing various", test_parse);
+	T("clone", "duplicating a config tree", test_clone);
+	T("cascade", "cascade", test_cascade);
+
+	dm_list_add(all_tests, &ts->list);
+};
diff --git a/test/unit/dmlist_t.c b/test/unit/dmlist_t.c
new file mode 100644
index 0000000..82789ba
--- /dev/null
+++ b/test/unit/dmlist_t.c
@@ -0,0 +1,49 @@
+/*
+ * Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "units.h"
+#include "libdevmapper.h"
+
+static void test_dmlist_splice(void *fixture)
+{
+	unsigned i;
+	struct dm_list a[10];
+	struct dm_list list1;
+	struct dm_list list2;
+
+	dm_list_init(&list1);
+	dm_list_init(&list2);
+
+	for (i = 0; i < DM_ARRAY_SIZE@; i++)
+		dm_list_add(&list1, &a[i]);
+
+	dm_list_splice(&list2, &list1);
+	T_ASSERT(dm_list_size(&list1) == 0);
+	T_ASSERT(dm_list_size(&list2) == 10);
+}
+
+#define T(path, desc, fn) register_test(ts, "/base/data-struct/list/" path, desc, fn)
+
+void dm_list_tests(struct dm_list *all_tests)
+{
+	struct test_suite *ts = test_suite_create(NULL, NULL);
+	if (!ts) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
+	T("splice", "joining lists together", test_dmlist_splice);
+
+	dm_list_add(all_tests, &ts->list);
+}
diff --git a/test/unit/dmstatus_t.c b/test/unit/dmstatus_t.c
new file mode 100644
index 0000000..4b57f29
--- /dev/null
+++ b/test/unit/dmstatus_t.c
@@ -0,0 +1,84 @@
+/*
+ * Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "units.h"
+#include "libdevmapper.h"
+
+static void *_mem_init(void)
+{
+	struct dm_pool *mem = dm_pool_create("dmstatus test", 1024);
+	if (!mem) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
+	return mem;
+}
+
+static void _mem_exit(void *mem)
+{
+	dm_pool_destroy(mem);
+}
+
+static void _test_mirror_status(void *fixture)
+{
+	struct dm_pool *mem = fixture;
+	struct dm_status_mirror *s = NULL;
+
+	T_ASSERT(dm_get_status_mirror(mem,
+				       "2 253:1 253:2 80/81 1 AD 3 disk 253:0 A",
+				       &s));
+	if (s) {
+		T_ASSERT_EQUAL(s->total_regions, 81);
+		T_ASSERT_EQUAL(s->insync_regions, 80);
+		T_ASSERT_EQUAL(s->dev_count, 2);
+		T_ASSERT_EQUAL(s->devs[0].health, 'A');
+		T_ASSERT_EQUAL(s->devs[0].major, 253);
+		T_ASSERT_EQUAL(s->devs[0].minor, 1);
+		T_ASSERT_EQUAL(s->devs[1].health, 'D');
+		T_ASSERT_EQUAL(s->devs[1].major, 253);
+		T_ASSERT_EQUAL(s->devs[1].minor, 2);
+		T_ASSERT_EQUAL(s->log_count, 1);
+		T_ASSERT_EQUAL(s->logs[0].major, 253);
+		T_ASSERT_EQUAL(s->logs[0].minor, 0);
+		T_ASSERT_EQUAL(s->logs[0].health, 'A');
+		T_ASSERT(!strcmp(s->log_type, "disk"));
+	}
+
+	T_ASSERT(dm_get_status_mirror(mem,
+				       "4 253:1 253:2 253:3 253:4 10/10 1 ADFF 1 core",
+				       &s));
+	if (s) {
+		T_ASSERT_EQUAL(s->total_regions, 10);
+		T_ASSERT_EQUAL(s->insync_regions, 10);
+		T_ASSERT_EQUAL(s->dev_count, 4);
+		T_ASSERT_EQUAL(s->devs[3].minor, 4);
+		T_ASSERT_EQUAL(s->devs[3].health, 'F');
+		T_ASSERT_EQUAL(s->log_count, 0);
+		T_ASSERT(!strcmp(s->log_type, "core"));
+	}
+}
+
+void dm_status_tests(struct dm_list *all_tests)
+{
+	struct test_suite *ts = test_suite_create(_mem_init, _mem_exit);
+	if (!ts) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
+	register_test(ts, "/dm/target/mirror/status", "parsing mirror status", _test_mirror_status);
+	dm_list_add(all_tests, &ts->list);
+}
+
diff --git a/test/unit/framework.c b/test/unit/framework.c
new file mode 100644
index 0000000..de9a8b1
--- /dev/null
+++ b/test/unit/framework.c
@@ -0,0 +1,66 @@
+#include "framework.h"
+
+/*----------------------------------------------------------------
+ * Assertions
+ *--------------------------------------------------------------*/
+
+jmp_buf test_k;
+#define TEST_FAILED 1
+
+void test_fail(const char *fmt, ...)
+{
+	va_list ap;
+
+	va_start(ap, fmt);
+	vfprintf(stderr, fmt, ap);
+	va_end(ap);
+	fprintf(stderr, "\n");
+
+	longjmp(test_k, TEST_FAILED);
+}
+
+struct test_suite *test_suite_create(void *(*fixture_init)(void),
+				     void (*fixture_exit)(void *))
+{
+	struct test_suite *ts = malloc(sizeof(*ts));
+	if (ts) {
+		ts->fixture_init = fixture_init;
+		ts->fixture_exit = fixture_exit;
+		dm_list_init(&ts->tests);
+	}
+
+	return ts;
+}
+
+void test_suite_destroy(struct test_suite *ts)
+{
+	struct test_details *td, *tmp;
+
+	dm_list_iterate_items_safe (td, tmp, &ts->tests) {
+		dm_list_del(&td->list);
+		free(td);
+	}
+
+	free(ts);
+}
+
+bool register_test(struct test_suite *ts,
+		   const char *path, const char *desc,
+		   void (*fn)(void *))
+{
+	struct test_details *t = malloc(sizeof(*t));
+	if (!t) {
+		fprintf(stderr, "out of memory\n");
+		return false;
+	}
+
+	t->parent = ts;
+	t->path = path;
+	t->desc = desc;
+	t->fn = fn;
+	dm_list_add(&ts->tests, &t->list);
+
+	return true;
+}
+
+//-----------------------------------------------------------------
diff --git a/test/unit/framework.h b/test/unit/framework.h
new file mode 100644
index 0000000..5a33ca6
--- /dev/null
+++ b/test/unit/framework.h
@@ -0,0 +1,49 @@
+#ifndef TEST_UNIT_FRAMEWORK_H
+#define TEST_UNIT_FRAMEWORK_H
+
+#include "libdevmapper.h"
+
+#include <stdbool.h>
+#include <stdint.h>
+#include <setjmp.h>
+
+//-----------------------------------------------------------------
+
+// A test suite gathers a set of tests with a common fixture together.
+struct test_suite {
+	struct dm_list list;
+
+	void *(*fixture_init)(void);
+	void (*fixture_exit)(void *);
+	struct dm_list tests;
+};
+
+struct test_details {
+	struct test_suite *parent;
+	struct dm_list list;
+
+	const char *path;
+	const char *desc;
+	void (*fn)(void *);
+};
+
+struct test_suite *test_suite_create(void *(*fixture_init)(void),
+				     void (*fixture_exit)(void *));
+void test_suite_destroy(struct test_suite *ts);
+
+bool register_test(struct test_suite *ts,
+		   const char *path, const char *desc, void (*fn)(void *));
+
+void test_fail(const char *fmt, ...)
+	__attribute__((noreturn, format (printf, 1, 2)));
+
+#define T_ASSERT(e) do {if (!(e)) {test_fail("assertion failed: '%s'", # e);} } while(0)
+#define T_ASSERT_EQUAL(x, y) T_ASSERT((x) == (y))
+#define T_ASSERT_NOT_EQUAL(x, y) T_ASSERT((x) != (y))
+
+extern jmp_buf test_k;
+#define TEST_FAILED 1
+
+//-----------------------------------------------------------------
+
+#endif
diff --git a/test/unit/io_engine_t.c b/test/unit/io_engine_t.c
new file mode 100644
index 0000000..6219d79
--- /dev/null
+++ b/test/unit/io_engine_t.c
@@ -0,0 +1,145 @@
+/*
+ * Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#define _GNU_SOURCE
+
+#include <errno.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+#include <unistd.h>
+
+#include "bcache.h"
+#include "framework.h"
+#include "units.h"
+
+//----------------------------------------------------------------
+
+#define SECTOR_SIZE 512
+#define BLOCK_SIZE_SECTORS 64
+
+struct fixture {
+	struct io_engine *e;
+	void *data;
+
+	char fname[64];
+	int fd;
+};
+
+static void *_fix_init(void)
+{
+        struct fixture *f = malloc(sizeof(*f));
+
+        T_ASSERT(f);
+        f->e = create_async_io_engine();
+        T_ASSERT(f->e);
+        f->data = aligned_alloc(4096, SECTOR_SIZE * BLOCK_SIZE_SECTORS);
+        T_ASSERT(f->data);
+
+        snprintf(f->fname, sizeof(f->fname), "unit-test-XXXXXX");
+	f->fd = mkostemp(f->fname, O_RDWR | O_CREAT | O_EXCL);
+	T_ASSERT(f->fd >= 0);
+
+	memset(f->data, 0, SECTOR_SIZE * BLOCK_SIZE_SECTORS);
+	write(f->fd, f->data, SECTOR_SIZE * BLOCK_SIZE_SECTORS);
+	lseek(f->fd, 0, SEEK_SET);
+        return f;
+}
+
+static void _fix_exit(void *fixture)
+{
+        struct fixture *f = fixture;
+
+	close(f->fd);
+	unlink(f->fname);
+        free(f->data);
+        f->e->destroy(f->e);
+        free(f);
+}
+
+static void _test_create(void *fixture)
+{
+	// empty
+}
+
+struct io {
+	bool completed;
+	int error;
+};
+
+static void _io_init(struct io *io)
+{
+	io->completed = false;
+	io->error = 0;
+}
+
+static void _complete_io(void *context, int io_error)
+{
+	struct io *io = context;
+	io->completed = true;
+	io->error = io_error;
+}
+
+static void _test_read(void *fixture)
+{
+	struct fixture *f = fixture;
+
+	struct io io;
+
+	_io_init(&io);
+	T_ASSERT(f->e->issue(f->e, DIR_READ, f->fd, 0, BLOCK_SIZE_SECTORS, f->data, &io));
+	T_ASSERT(f->e->wait(f->e, _complete_io));
+	T_ASSERT(io.completed);
+	T_ASSERT(!io.error);
+}
+
+static void _test_write(void *fixture)
+{
+	struct fixture *f = fixture;
+
+	struct io io;
+
+	_io_init(&io);
+	T_ASSERT(f->e->issue(f->e, DIR_WRITE, f->fd, 0, BLOCK_SIZE_SECTORS, f->data, &io));
+	T_ASSERT(f->e->wait(f->e, _complete_io));
+	T_ASSERT(io.completed);
+	T_ASSERT(!io.error);
+}
+
+//----------------------------------------------------------------
+
+#define T(path, desc, fn) register_test(ts, "/base/device/bcache/io-engine/" path, desc, fn)
+
+static struct test_suite *_tests(void)
+{
+        struct test_suite *ts = test_suite_create(_fix_init, _fix_exit);
+        if (!ts) {
+                fprintf(stderr, "out of memory\n");
+                exit(1);
+        }
+
+        T("create-destroy", "simple create/destroy", _test_create);
+        T("create-read", "read sanity check", _test_read);
+        T("create-write", "write sanity check", _test_write);
+
+        return ts;
+}
+
+void io_engine_tests(struct dm_list *all_tests)
+{
+	dm_list_add(all_tests, &_tests()->list);
+}
+
diff --git a/test/unit/matcher_data.h b/test/unit/matcher_data.h
new file mode 100644
index 0000000..97dbbfe
--- /dev/null
+++ b/test/unit/matcher_data.h
@@ -0,0 +1,1013 @@
+struct check_item {
+	const char *str;
+	int expected;
+};
+
+static const char *dev_patterns[] = {
+	"loop/[0-9]+",
+	"hd[a-d][0-5]+",
+	NULL
+};
+
+static const char *nonprint_patterns[] = {
+	"foo\x80" "bar",
+	"foo\xc2" "b",
+	"\x80",
+	NULL
+};
+
+static const struct check_item nonprint[] = {
+	{ "foo\x2e" "bar", 0 },
+	{ "foo\x80" "bar", 3 },
+	{ "foo\xc2" "b", 2 },
+	{ "\x80", 3 },
+	{ NULL, 0 }
+};
+
+static const char *random_patterns[] = {
+	"(((a?)(([Ub]*)|z))((([qr]|X)+)([Qn]*)))+",
+	"[HZejtuw]*",
+	"((B|s)*)|(((([Fv]l)(N+))(([el]|C)(tJ)))?)",
+	"((([Ma]?)|(t*))*)|((([cm]E)|(M?))|(([BE][EV])|([Qj][Mh])))",
+	"(((([bw]*)|([IO]*))((zK)*))|(((pU)|(i|q))|((z?)|([HL]?))))*",
+	"((([Pt]?)|[Tr])?)((Hq)*)",
+	"[HOXcfgikosvwxz]",
+	"[BCEFGHNPTUWfjlprsy]",
+	"((((aD)*)|([Xo]+))+)(([HKn](([Eq]|[JQ])(I*)))*)",
+	"([LNWYeghv]|e)*",
+	"(((y(L*))*)|((([EP]+)(W+))*))*",
+	"U*",
+	"((((R+)(W|[Qr]))|([py]+))+)([LM]*)",
+	"(([DOjx](D(b?)))|([Ke]*))*",
+	"((([ls](c|[FT]))*)([JS]*))*",
+	"((l?)|(([Gz]+)|(D*)))*",
+	"[ABgjn]",
+	"(((q|[dg])?)|([Uk]*))((([Fl]?)|([Ry]+))|(([IR]|c)|(T?)))",
+	"((([an]|P)|[Jw])((a*)|(m*)))*",
+	"((((R[ht])(h+))?)|(([pz](n?))+))+",
+	"(((([Dc]b)([Sp][Ii]))|((k|F)*))|[Uiovz])*",
+	"[Res]*",
+	"[Zl]|a",
+	"^[ANZdf]$",
+	"[En]|(((Q+)(U+))([pt]*))",
+	"[ADEIMQUWXZhklrsvz]",
+	"(((S(y*))*)|(j*))*",
+	"n*",
+	"[NUau]*",
+	"((((Z*)(D|[Nd]))|(([np]|B)+))|(([Xy][Fi])*))+",
+	"((([EZ]?)|(d[HR]))*)((([Hg]|q)(P+))*)",
+	"q",
+	"((m*)|(p|B))|((((x?)|(t+))(([Sb][PX])(O|[HM])))+)",
+	"((((A*)(z[RS]))*)|(((z+)(Q*))+))*",
+	"(((M*)([Uu]*))+)|[Uk]",
+	"[imv]",
+	"[GLSchtw](([Yw]((F[Dd])|([Tw]+)))?)",
+	"([MOZj]*)(S|[Wknr])",
+	"((G|q)*)[BHKN]",
+	"((((NW)|([Ao]?))|((l|[UV])+))+)|((i|(z*))*)",
+	"((((Z+)|([IR]?))|(L*))|([JKQ]+))+",
+	"([Bdin](S*))+",
+	"[HLNSTp]*",
+	"(((J*)([Bq]|[Yu]))*)|([Kv]*)",
+	"(((([BJ]|[Zy])(wI))*)(y*))+",
+	"(((hF)+)|(H*))*",
+	"((([QU][Pj])([GQ]?))+)|[PWo]",
+	"(((([cq][BX])?)|((f[DI])*))*)(([GM]*)[SVYr])",
+	"(([Zt]*)|((qx)|(([BV]+)(f?))))*",
+	"[ILWYhsx]*",
+	"(([Uy]*)|[sv])|([NSc]*)",
+	"((c*)|([JUfhy]?))+",
+	"(((q*)([So]*))(((g[jq])(j?))+))*",
+	"((b+)|(((T+)([fw]T))?))*",
+	"((([DS]?)|([Th]|u))(Q*))*",
+	"[FKLX]|((([fw](L?))(([gq]*)|(O?)))?)",
+	"((([HZ]+)u)*)|[APWijn]",
+	"(e*)|(((v?)|((J+)(Hb)))?)",
+	"(e|((w+)f))*",
+	"[BEHKPQVdelnqy]",
+	"((((B|N)(s*))|[Rr])(((g?)|([rv]+))+))+",
+	"(((s*)|(K*))([AP]G))*",
+	"[CELTp]",
+	"(([Fq]?)|([Al]+))*",
+	"((((r?)|(y[jx]))|([mp]*))+)|((B(S*))*)",
+	"((([Eq]+)|(Y[ds]))|(x|(i|[Ku])))[IJNrvy]",
+	"((([NO]*)[Ix])+)([Jenq]+)",
+	"(((([HP]*)(j|y))*)[Ylqvy])*",
+	"[PTv]+",
+	"[AINSZhpx]|([EOYZ]*)",
+	"([ABCFQv]*)((([Zx]|h)+)|([ej]*))",
+	"((([pr]*)|(([Dq]|p)|(H?)))?)([NRUXmoq]*)",
+	"(([er]*)|([mx]*))(((nV)([am]?))+)",
+	"[BHPRlpu]",
+	"(((([Ah]|[tx])|(e|[uy]))?)((([fl]+)([Vz]|v))*))*",
+	"[AGdm]",
+	"(((K*)^(O*)$)|(B?))*",
+	"((([Ks]|[Ka])*)|([FSTab]?))?",
+	"(([kw]+)[ei])(([Hy]*)(([Mc]*)|(G|f)))",
+	"((((e*)|(Zf))|(R|[nq]))((([Jz]v)([Rj]+))+))*",
+	"(((a?)|(e?))(([Uc]*)(S+)))*",
+	"((((E+)([MZ]?))+)|(((s|[Az])|z)*))?",
+	"((((i[MO])*)|((LH)*))|(((BA)|([AI]+))|[Ug]))*",
+	"[EGHILcho]*",
+	"(((Z[vw])?)((z|g)+))(((H|U)([iv]Q))|([qw]?))",
+	"(([ehmr]|((L[Uw])*))+)((a+)I)",
+	"[EKNSWYagj](((v|[TX])|([Uk]+))*)",
+	"(((R[Mo])|(O*))|([Fm]|([qw]*)))((m*)|((S|[Ki])?))",
+	"((((kP)|c)?)((([do]+)|([Gi]?))*))*",
+	"((^(B|W)$|([Ww]+))([no]*))|((([iv]?)|(M*))|((x|L)?))",
+	"[AEGPRSbcfhsy]",
+	"[Wbcf]|((([MO]?)|([NT]|m))(([Oo]?)([Wg]*)))",
+	"(((YZ)*)[PQVei])*",
+	"[GJKYt][AEGWdegmnt]",
+	"^[CDEGJKNUVYZagkv]$",
+	"([DPWbx]*)|(((q|B)|(P|u))((M[Bq])*))",
+	"[FHIJRTVYZdiorsuvz]*",
+	"([MWoqvz]*)|^(l*)",
+	"(((I|[Rx])*)((X[Mf])([Xa]L)))([Ha]|([HY]*))",
+	"(((l|[Sd])*)((([Ix]+)|([XY]?))(Z*)))+",
+	NULL
+};
+
+struct check_item devices[] = {
+	{ "/dev", 0 },
+	{ "/dev/.devfsd", 0 },
+	{ "/dev/cpu", 0 },
+	{ "/dev/cpu/mtrr", 0 },
+	{ "/dev/netlink", 0 },
+	{ "/dev/netlink/route", 0 },
+	{ "/dev/netlink/skip", 0 },
+	{ "/dev/netlink/USERSOCK", 0 },
+	{ "/dev/netlink/fwmonitor", 0 },
+	{ "/dev/netlink/ARPD", 0 },
+	{ "/dev/netlink/ROUTE6", 0 },
+	{ "/dev/netlink/IP6_FW", 0 },
+	{ "/dev/netlink/tap0", 0 },
+	{ "/dev/netlink/tap1", 0 },
+	{ "/dev/netlink/tap2", 0 },
+	{ "/dev/netlink/tap3", 0 },
+	{ "/dev/netlink/tap4", 0 },
+	{ "/dev/netlink/tap5", 0 },
+	{ "/dev/netlink/tap6", 0 },
+	{ "/dev/netlink/tap7", 0 },
+	{ "/dev/netlink/tap8", 0 },
+	{ "/dev/netlink/tap9", 0 },
+	{ "/dev/netlink/tap10", 0 },
+	{ "/dev/netlink/tap11", 0 },
+	{ "/dev/netlink/tap12", 0 },
+	{ "/dev/netlink/tap13", 0 },
+	{ "/dev/netlink/tap14", 0 },
+	{ "/dev/netlink/tap15", 0 },
+	{ "/dev/shm", 0 },
+	{ "/dev/mem", 0 },
+	{ "/dev/kmem", 0 },
+	{ "/dev/null", 0 },
+	{ "/dev/port", 0 },
+	{ "/dev/zero", 0 },
+	{ "/dev/full", 0 },
+	{ "/dev/random", 0 },
+	{ "/dev/urandom", 0 },
+	{ "/dev/tty", 0 },
+	{ "/dev/console", 0 },
+	{ "/dev/vc", 0 },
+	{ "/dev/vc/1", 0 },
+	{ "/dev/vc/2", 0 },
+	{ "/dev/vc/3", 0 },
+	{ "/dev/vc/4", 0 },
+	{ "/dev/vc/5", 0 },
+	{ "/dev/vc/6", 0 },
+	{ "/dev/vc/7", 0 },
+	{ "/dev/vc/8", 0 },
+	{ "/dev/vc/9", 0 },
+	{ "/dev/vc/10", 0 },
+	{ "/dev/vc/11", 0 },
+	{ "/dev/vc/12", 0 },
+	{ "/dev/vc/13", 0 },
+	{ "/dev/vc/14", 0 },
+	{ "/dev/vc/15", 0 },
+	{ "/dev/vc/16", 0 },
+	{ "/dev/vc/17", 0 },
+	{ "/dev/vc/18", 0 },
+	{ "/dev/vc/19", 0 },
+	{ "/dev/vc/20", 0 },
+	{ "/dev/vc/21", 0 },
+	{ "/dev/vc/22", 0 },
+	{ "/dev/vc/23", 0 },
+	{ "/dev/vc/24", 0 },
+	{ "/dev/vc/25", 0 },
+	{ "/dev/vc/26", 0 },
+	{ "/dev/vc/27", 0 },
+	{ "/dev/vc/28", 0 },
+	{ "/dev/vc/29", 0 },
+	{ "/dev/vc/30", 0 },
+	{ "/dev/vc/31", 0 },
+	{ "/dev/vc/32", 0 },
+	{ "/dev/vc/33", 0 },
+	{ "/dev/vc/34", 0 },
+	{ "/dev/vc/35", 0 },
+	{ "/dev/vc/36", 0 },
+	{ "/dev/vc/37", 0 },
+	{ "/dev/vc/38", 0 },
+	{ "/dev/vc/39", 0 },
+	{ "/dev/vc/40", 0 },
+	{ "/dev/vc/41", 0 },
+	{ "/dev/vc/42", 0 },
+	{ "/dev/vc/43", 0 },
+	{ "/dev/vc/44", 0 },
+	{ "/dev/vc/45", 0 },
+	{ "/dev/vc/46", 0 },
+	{ "/dev/vc/47", 0 },
+	{ "/dev/vc/48", 0 },
+	{ "/dev/vc/49", 0 },
+	{ "/dev/vc/50", 0 },
+	{ "/dev/vc/51", 0 },
+	{ "/dev/vc/52", 0 },
+	{ "/dev/vc/53", 0 },
+	{ "/dev/vc/54", 0 },
+	{ "/dev/vc/55", 0 },
+	{ "/dev/vc/56", 0 },
+	{ "/dev/vc/57", 0 },
+	{ "/dev/vc/58", 0 },
+	{ "/dev/vc/59", 0 },
+	{ "/dev/vc/60", 0 },
+	{ "/dev/vc/61", 0 },
+	{ "/dev/vc/62", 0 },
+	{ "/dev/vc/63", 0 },
+	{ "/dev/vc/0", 0 },
+	{ "/dev/ptmx", 0 },
+	{ "/dev/misc", 0 },
+	{ "/dev/misc/psaux", 0 },
+	{ "/dev/pty", 0 },
+	{ "/dev/pty/m0", 0 },
+	{ "/dev/pty/m1", 0 },
+	{ "/dev/pty/m2", 0 },
+	{ "/dev/pty/m3", 0 },
+	{ "/dev/pty/m4", 0 },
+	{ "/dev/pty/m5", 0 },
+	{ "/dev/pty/m6", 0 },
+	{ "/dev/pty/m7", 0 },
+	{ "/dev/pty/m8", 0 },
+	{ "/dev/pty/m9", 0 },
+	{ "/dev/pty/m10", 0 },
+	{ "/dev/pty/m11", 0 },
+	{ "/dev/pty/m12", 0 },
+	{ "/dev/pty/m13", 0 },
+	{ "/dev/pty/m14", 0 },
+	{ "/dev/pty/m15", 0 },
+	{ "/dev/pty/m16", 0 },
+	{ "/dev/pty/m17", 0 },
+	{ "/dev/pty/m18", 0 },
+	{ "/dev/pty/m19", 0 },
+	{ "/dev/pty/m20", 0 },
+	{ "/dev/pty/m21", 0 },
+	{ "/dev/pty/m22", 0 },
+	{ "/dev/pty/m23", 0 },
+	{ "/dev/pty/m24", 0 },
+	{ "/dev/pty/m25", 0 },
+	{ "/dev/pty/m26", 0 },
+	{ "/dev/pty/m27", 0 },
+	{ "/dev/pty/m28", 0 },
+	{ "/dev/pty/m29", 0 },
+	{ "/dev/pty/m30", 0 },
+	{ "/dev/pty/m31", 0 },
+	{ "/dev/pty/m32", 0 },
+	{ "/dev/pty/m33", 0 },
+	{ "/dev/pty/m34", 0 },
+	{ "/dev/pty/m35", 0 },
+	{ "/dev/pty/m36", 0 },
+	{ "/dev/pty/m37", 0 },
+	{ "/dev/pty/m38", 0 },
+	{ "/dev/pty/m39", 0 },
+	{ "/dev/pty/m40", 0 },
+	{ "/dev/pty/m41", 0 },
+	{ "/dev/pty/m42", 0 },
+	{ "/dev/pty/m43", 0 },
+	{ "/dev/pty/m44", 0 },
+	{ "/dev/pty/m45", 0 },
+	{ "/dev/pty/m46", 0 },
+	{ "/dev/pty/m47", 0 },
+	{ "/dev/pty/m48", 0 },
+	{ "/dev/pty/m49", 0 },
+	{ "/dev/pty/m50", 0 },
+	{ "/dev/pty/m51", 0 },
+	{ "/dev/pty/m52", 0 },
+	{ "/dev/pty/m53", 0 },
+	{ "/dev/pty/m54", 0 },
+	{ "/dev/pty/m55", 0 },
+	{ "/dev/pty/m56", 0 },
+	{ "/dev/pty/m57", 0 },
+	{ "/dev/pty/m58", 0 },
+	{ "/dev/pty/m59", 0 },
+	{ "/dev/pty/m60", 0 },
+	{ "/dev/pty/m61", 0 },
+	{ "/dev/pty/m62", 0 },
+	{ "/dev/pty/m63", 0 },
+	{ "/dev/pty/m64", 0 },
+	{ "/dev/pty/m65", 0 },
+	{ "/dev/pty/m66", 0 },
+	{ "/dev/pty/m67", 0 },
+	{ "/dev/pty/m68", 0 },
+	{ "/dev/pty/m69", 0 },
+	{ "/dev/pty/m70", 0 },
+	{ "/dev/pty/m71", 0 },
+	{ "/dev/pty/m72", 0 },
+	{ "/dev/pty/m73", 0 },
+	{ "/dev/pty/m74", 0 },
+	{ "/dev/pty/m75", 0 },
+	{ "/dev/pty/m76", 0 },
+	{ "/dev/pty/m77", 0 },
+	{ "/dev/pty/m78", 0 },
+	{ "/dev/pty/m79", 0 },
+	{ "/dev/pty/m80", 0 },
+	{ "/dev/pty/m81", 0 },
+	{ "/dev/pty/m82", 0 },
+	{ "/dev/pty/m83", 0 },
+	{ "/dev/pty/m84", 0 },
+	{ "/dev/pty/m85", 0 },
+	{ "/dev/pty/m86", 0 },
+	{ "/dev/pty/m87", 0 },
+	{ "/dev/pty/m88", 0 },
+	{ "/dev/pty/m89", 0 },
+	{ "/dev/pty/m90", 0 },
+	{ "/dev/pty/m91", 0 },
+	{ "/dev/pty/m92", 0 },
+	{ "/dev/pty/m93", 0 },
+	{ "/dev/pty/m94", 0 },
+	{ "/dev/pty/m95", 0 },
+	{ "/dev/pty/m96", 0 },
+	{ "/dev/pty/m97", 0 },
+	{ "/dev/pty/m98", 0 },
+	{ "/dev/pty/m99", 0 },
+	{ "/dev/pty/m100", 0 },
+	{ "/dev/pty/m101", 0 },
+	{ "/dev/pty/m102", 0 },
+	{ "/dev/pty/m103", 0 },
+	{ "/dev/pty/m104", 0 },
+	{ "/dev/pty/m105", 0 },
+	{ "/dev/pty/m106", 0 },
+	{ "/dev/pty/m107", 0 },
+	{ "/dev/pty/m108", 0 },
+	{ "/dev/pty/m109", 0 },
+	{ "/dev/pty/m110", 0 },
+	{ "/dev/pty/m111", 0 },
+	{ "/dev/pty/m112", 0 },
+	{ "/dev/pty/m113", 0 },
+	{ "/dev/pty/m114", 0 },
+	{ "/dev/pty/m115", 0 },
+	{ "/dev/pty/m116", 0 },
+	{ "/dev/pty/m117", 0 },
+	{ "/dev/pty/m118", 0 },
+	{ "/dev/pty/m119", 0 },
+	{ "/dev/pty/m120", 0 },
+	{ "/dev/pty/m121", 0 },
+	{ "/dev/pty/m122", 0 },
+	{ "/dev/pty/m123", 0 },
+	{ "/dev/pty/m124", 0 },
+	{ "/dev/pty/m125", 0 },
+	{ "/dev/pty/m126", 0 },
+	{ "/dev/pty/m127", 0 },
+	{ "/dev/pty/m128", 0 },
+	{ "/dev/pty/m129", 0 },
+	{ "/dev/pty/m130", 0 },
+	{ "/dev/pty/m131", 0 },
+	{ "/dev/pty/m132", 0 },
+	{ "/dev/pty/m133", 0 },
+	{ "/dev/pty/m134", 0 },
+	{ "/dev/pty/m135", 0 },
+	{ "/dev/pty/m136", 0 },
+	{ "/dev/pty/m137", 0 },
+	{ "/dev/pty/m138", 0 },
+	{ "/dev/pty/m139", 0 },
+	{ "/dev/pty/m140", 0 },
+	{ "/dev/pty/m141", 0 },
+	{ "/dev/pty/m142", 0 },
+	{ "/dev/pty/m143", 0 },
+	{ "/dev/pty/m144", 0 },
+	{ "/dev/pty/m145", 0 },
+	{ "/dev/pty/m146", 0 },
+	{ "/dev/pty/m147", 0 },
+	{ "/dev/pty/m148", 0 },
+	{ "/dev/pty/m149", 0 },
+	{ "/dev/pty/m150", 0 },
+	{ "/dev/pty/m151", 0 },
+	{ "/dev/pty/m152", 0 },
+	{ "/dev/pty/m153", 0 },
+	{ "/dev/pty/m154", 0 },
+	{ "/dev/pty/m155", 0 },
+	{ "/dev/pty/m156", 0 },
+	{ "/dev/pty/m157", 0 },
+	{ "/dev/pty/m158", 0 },
+	{ "/dev/pty/m159", 0 },
+	{ "/dev/pty/m160", 0 },
+	{ "/dev/pty/m161", 0 },
+	{ "/dev/pty/m162", 0 },
+	{ "/dev/pty/m163", 0 },
+	{ "/dev/pty/m164", 0 },
+	{ "/dev/pty/m165", 0 },
+	{ "/dev/pty/m166", 0 },
+	{ "/dev/pty/m167", 0 },
+	{ "/dev/pty/m168", 0 },
+	{ "/dev/pty/m169", 0 },
+	{ "/dev/pty/m170", 0 },
+	{ "/dev/pty/m171", 0 },
+	{ "/dev/pty/m172", 0 },
+	{ "/dev/pty/m173", 0 },
+	{ "/dev/pty/m174", 0 },
+	{ "/dev/pty/m175", 0 },
+	{ "/dev/pty/m176", 0 },
+	{ "/dev/pty/m177", 0 },
+	{ "/dev/pty/m178", 0 },
+	{ "/dev/pty/m179", 0 },
+	{ "/dev/pty/m180", 0 },
+	{ "/dev/pty/m181", 0 },
+	{ "/dev/pty/m182", 0 },
+	{ "/dev/pty/m183", 0 },
+	{ "/dev/pty/m184", 0 },
+	{ "/dev/pty/m185", 0 },
+	{ "/dev/pty/m186", 0 },
+	{ "/dev/pty/m187", 0 },
+	{ "/dev/pty/m188", 0 },
+	{ "/dev/pty/m189", 0 },
+	{ "/dev/pty/m190", 0 },
+	{ "/dev/pty/m191", 0 },
+	{ "/dev/pty/m192", 0 },
+	{ "/dev/pty/m193", 0 },
+	{ "/dev/pty/m194", 0 },
+	{ "/dev/pty/m195", 0 },
+	{ "/dev/pty/m196", 0 },
+	{ "/dev/pty/m197", 0 },
+	{ "/dev/pty/m198", 0 },
+	{ "/dev/pty/m199", 0 },
+	{ "/dev/pty/m200", 0 },
+	{ "/dev/pty/m201", 0 },
+	{ "/dev/pty/m202", 0 },
+	{ "/dev/pty/m203", 0 },
+	{ "/dev/pty/m204", 0 },
+	{ "/dev/pty/m205", 0 },
+	{ "/dev/pty/m206", 0 },
+	{ "/dev/pty/m207", 0 },
+	{ "/dev/pty/m208", 0 },
+	{ "/dev/pty/m209", 0 },
+	{ "/dev/pty/m210", 0 },
+	{ "/dev/pty/m211", 0 },
+	{ "/dev/pty/m212", 0 },
+	{ "/dev/pty/m213", 0 },
+	{ "/dev/pty/m214", 0 },
+	{ "/dev/pty/m215", 0 },
+	{ "/dev/pty/m216", 0 },
+	{ "/dev/pty/m217", 0 },
+	{ "/dev/pty/m218", 0 },
+	{ "/dev/pty/m219", 0 },
+	{ "/dev/pty/m220", 0 },
+	{ "/dev/pty/m221", 0 },
+	{ "/dev/pty/m222", 0 },
+	{ "/dev/pty/m223", 0 },
+	{ "/dev/pty/m224", 0 },
+	{ "/dev/pty/m225", 0 },
+	{ "/dev/pty/m226", 0 },
+	{ "/dev/pty/m227", 0 },
+	{ "/dev/pty/m228", 0 },
+	{ "/dev/pty/m229", 0 },
+	{ "/dev/pty/m230", 0 },
+	{ "/dev/pty/m231", 0 },
+	{ "/dev/pty/m232", 0 },
+	{ "/dev/pty/m233", 0 },
+	{ "/dev/pty/m234", 0 },
+	{ "/dev/pty/m235", 0 },
+	{ "/dev/pty/m236", 0 },
+	{ "/dev/pty/m237", 0 },
+	{ "/dev/pty/m238", 0 },
+	{ "/dev/pty/m239", 0 },
+	{ "/dev/pty/m240", 0 },
+	{ "/dev/pty/m241", 0 },
+	{ "/dev/pty/m242", 0 },
+	{ "/dev/pty/m243", 0 },
+	{ "/dev/pty/m244", 0 },
+	{ "/dev/pty/m245", 0 },
+	{ "/dev/pty/m246", 0 },
+	{ "/dev/pty/m247", 0 },
+	{ "/dev/pty/m248", 0 },
+	{ "/dev/pty/m249", 0 },
+	{ "/dev/pty/m250", 0 },
+	{ "/dev/pty/m251", 0 },
+	{ "/dev/pty/m252", 0 },
+	{ "/dev/pty/m253", 0 },
+	{ "/dev/pty/m254", 0 },
+	{ "/dev/pty/m255", 0 },
+	{ "/dev/pts", 0 },
+	{ "/dev/pts/0", 0 },
+	{ "/dev/pts/1", 0 },
+	{ "/dev/pts/2", 0 },
+	{ "/dev/pts/3", 0 },
+	{ "/dev/pts/4", 0 },
+	{ "/dev/pts/5", 0 },
+	{ "/dev/pts/6", 0 },
+	{ "/dev/pts/7", 0 },
+	{ "/dev/vcc", 0 },
+	{ "/dev/vcc/0", 0 },
+	{ "/dev/vcc/a", 0 },
+	{ "/dev/vcc/1", 0 },
+	{ "/dev/vcc/a1", 0 },
+	{ "/dev/vcc/2", 0 },
+	{ "/dev/vcc/a2", 0 },
+	{ "/dev/vcc/3", 0 },
+	{ "/dev/vcc/a3", 0 },
+	{ "/dev/vcc/5", 0 },
+	{ "/dev/vcc/a5", 0 },
+	{ "/dev/vcc/4", 0 },
+	{ "/dev/vcc/a4", 0 },
+	{ "/dev/vcc/6", 0 },
+	{ "/dev/vcc/a6", 0 },
+	{ "/dev/vcc/7", 0 },
+	{ "/dev/vcc/a7", 0 },
+	{ "/dev/tts", 0 },
+	{ "/dev/tts/0", 0 },
+	{ "/dev/cua", 0 },
+	{ "/dev/cua/0", 0 },
+	{ "/dev/ide", 0 },
+	{ "/dev/ide/host0", 0 },
+	{ "/dev/ide/host0/bus0", 0 },
+	{ "/dev/ide/host0/bus0/target0", 0 },
+	{ "/dev/ide/host0/bus0/target0/lun0", 0 },
+	{ "/dev/ide/host0/bus0/target0/lun0/disc", 0 },
+	{ "/dev/ide/host0/bus0/target0/lun0/part1", 0 },
+	{ "/dev/ide/host0/bus0/target0/lun0/part2", 0 },
+	{ "/dev/ide/host0/bus0/target0/lun0/part3", 0 },
+	{ "/dev/ide/host0/bus0/target0/lun0/part4", 0 },
+	{ "/dev/ide/host0/bus0/target0/lun0/part5", 0 },
+	{ "/dev/ide/host0/bus0/target0/lun0/part6", 0 },
+	{ "/dev/ide/host0/bus0/target0/lun0/part7", 0 },
+	{ "/dev/ide/host0/bus0/target0/lun0/part8", 0 },
+	{ "/dev/ide/host0/bus0/target1", 0 },
+	{ "/dev/ide/host0/bus0/target1/lun0", 0 },
+	{ "/dev/ide/host0/bus0/target1/lun0/disc", 0 },
+	{ "/dev/ide/host0/bus0/target1/lun0/part1", 0 },
+	{ "/dev/ide/host0/bus1", 0 },
+	{ "/dev/ide/host0/bus1/target0", 0 },
+	{ "/dev/ide/host0/bus1/target0/lun0", 0 },
+	{ "/dev/ide/host0/bus1/target0/lun0/disc", 0 },
+	{ "/dev/ide/host0/bus1/target0/lun0/part1", 0 },
+	{ "/dev/ide/host0/bus1/target1", 0 },
+	{ "/dev/ide/host0/bus1/target1/lun0", 0 },
+	{ "/dev/discs", 0 },
+	{ "/dev/discs/disc0", 0 },
+	{ "/dev/discs/disc1", 0 },
+	{ "/dev/discs/disc2", 0 },
+	{ "/dev/floppy", 0 },
+	{ "/dev/floppy/0u1440", 0 },
+	{ "/dev/floppy/0u1680", 0 },
+	{ "/dev/floppy/0u1722", 0 },
+	{ "/dev/floppy/0u1743", 0 },
+	{ "/dev/floppy/0u1760", 0 },
+	{ "/dev/floppy/0u1920", 0 },
+	{ "/dev/floppy/0u1840", 0 },
+	{ "/dev/floppy/0u1600", 0 },
+	{ "/dev/floppy/0u360", 0 },
+	{ "/dev/floppy/0u720", 0 },
+	{ "/dev/floppy/0u820", 0 },
+	{ "/dev/floppy/0u830", 0 },
+	{ "/dev/floppy/0u1040", 0 },
+	{ "/dev/floppy/0u1120", 0 },
+	{ "/dev/floppy/0u800", 0 },
+	{ "/dev/floppy/0", 0 },
+	{ "/dev/loop", 0 },
+	{ "/dev/loop/0", 1 },
+	{ "/dev/loop/1", 1 },
+	{ "/dev/loop/2", 1 },
+	{ "/dev/loop/3", 1 },
+	{ "/dev/loop/4", 1 },
+	{ "/dev/loop/5", 1 },
+	{ "/dev/loop/6", 1 },
+	{ "/dev/loop/7", 1 },
+	{ "/dev/cdroms", 0 },
+	{ "/dev/sound", 0 },
+	{ "/dev/sound/dsp", 0 },
+	{ "/dev/sound/dsp1", 0 },
+	{ "/dev/sound/mixer", 0 },
+	{ "/dev/sound/midi", 0 },
+	{ "/dev/usb", 0 },
+	{ "/dev/root", 0 },
+	{ "/dev/initctl", 0 },
+	{ "/dev/xconsole", 0 },
+	{ "/dev/fd", 0 },
+	{ "/dev/stdin", 0 },
+	{ "/dev/stdout", 0 },
+	{ "/dev/stderr", 0 },
+	{ "/dev/route", 0 },
+	{ "/dev/skip", 0 },
+	{ "/dev/USERSOCK", 0 },
+	{ "/dev/fwmonitor", 0 },
+	{ "/dev/ARPD", 0 },
+	{ "/dev/ROUTE6", 0 },
+	{ "/dev/IP6_FW", 0 },
+	{ "/dev/tap0", 0 },
+	{ "/dev/tap1", 0 },
+	{ "/dev/tap2", 0 },
+	{ "/dev/tap3", 0 },
+	{ "/dev/tap4", 0 },
+	{ "/dev/tap5", 0 },
+	{ "/dev/tap6", 0 },
+	{ "/dev/tap7", 0 },
+	{ "/dev/tap8", 0 },
+	{ "/dev/tap9", 0 },
+	{ "/dev/tap10", 0 },
+	{ "/dev/tap11", 0 },
+	{ "/dev/tap12", 0 },
+	{ "/dev/tap13", 0 },
+	{ "/dev/tap14", 0 },
+	{ "/dev/tap15", 0 },
+	{ "/dev/tty1", 0 },
+	{ "/dev/tty2", 0 },
+	{ "/dev/tty3", 0 },
+	{ "/dev/tty4", 0 },
+	{ "/dev/tty5", 0 },
+	{ "/dev/tty6", 0 },
+	{ "/dev/tty7", 0 },
+	{ "/dev/tty8", 0 },
+	{ "/dev/tty9", 0 },
+	{ "/dev/tty10", 0 },
+	{ "/dev/tty11", 0 },
+	{ "/dev/tty12", 0 },
+	{ "/dev/tty13", 0 },
+	{ "/dev/tty14", 0 },
+	{ "/dev/tty15", 0 },
+	{ "/dev/tty16", 0 },
+	{ "/dev/tty17", 0 },
+	{ "/dev/tty18", 0 },
+	{ "/dev/tty19", 0 },
+	{ "/dev/tty20", 0 },
+	{ "/dev/tty21", 0 },
+	{ "/dev/tty22", 0 },
+	{ "/dev/tty23", 0 },
+	{ "/dev/tty24", 0 },
+	{ "/dev/tty25", 0 },
+	{ "/dev/tty26", 0 },
+	{ "/dev/tty27", 0 },
+	{ "/dev/tty28", 0 },
+	{ "/dev/tty29", 0 },
+	{ "/dev/tty30", 0 },
+	{ "/dev/tty31", 0 },
+	{ "/dev/tty32", 0 },
+	{ "/dev/tty33", 0 },
+	{ "/dev/tty34", 0 },
+	{ "/dev/tty35", 0 },
+	{ "/dev/tty36", 0 },
+	{ "/dev/tty37", 0 },
+	{ "/dev/tty38", 0 },
+	{ "/dev/tty39", 0 },
+	{ "/dev/tty40", 0 },
+	{ "/dev/tty41", 0 },
+	{ "/dev/tty42", 0 },
+	{ "/dev/tty43", 0 },
+	{ "/dev/tty44", 0 },
+	{ "/dev/tty45", 0 },
+	{ "/dev/tty46", 0 },
+	{ "/dev/tty47", 0 },
+	{ "/dev/tty48", 0 },
+	{ "/dev/tty49", 0 },
+	{ "/dev/tty50", 0 },
+	{ "/dev/tty51", 0 },
+	{ "/dev/tty52", 0 },
+	{ "/dev/tty53", 0 },
+	{ "/dev/tty54", 0 },
+	{ "/dev/tty55", 0 },
+	{ "/dev/tty56", 0 },
+	{ "/dev/tty57", 0 },
+	{ "/dev/tty58", 0 },
+	{ "/dev/tty59", 0 },
+	{ "/dev/tty60", 0 },
+	{ "/dev/tty61", 0 },
+	{ "/dev/tty62", 0 },
+	{ "/dev/tty63", 0 },
+	{ "/dev/tty0", 0 },
+	{ "/dev/psaux", 0 },
+	{ "/dev/ptyp0", 0 },
+	{ "/dev/ptyp1", 0 },
+	{ "/dev/ptyp2", 0 },
+	{ "/dev/ptyp3", 0 },
+	{ "/dev/ptyp4", 0 },
+	{ "/dev/ptyp5", 0 },
+	{ "/dev/ptyp6", 0 },
+	{ "/dev/ptyp7", 0 },
+	{ "/dev/ptyp8", 0 },
+	{ "/dev/ptyp9", 0 },
+	{ "/dev/ptypa", 0 },
+	{ "/dev/ptypb", 0 },
+	{ "/dev/ptypc", 0 },
+	{ "/dev/ptypd", 0 },
+	{ "/dev/ptype", 0 },
+	{ "/dev/ptypf", 0 },
+	{ "/dev/ptyq0", 0 },
+	{ "/dev/ptyq1", 0 },
+	{ "/dev/ptyq2", 0 },
+	{ "/dev/ptyq3", 0 },
+	{ "/dev/ptyq4", 0 },
+	{ "/dev/ptyq5", 0 },
+	{ "/dev/ptyq6", 0 },
+	{ "/dev/ptyq7", 0 },
+	{ "/dev/ptyq8", 0 },
+	{ "/dev/ptyq9", 0 },
+	{ "/dev/ptyqa", 0 },
+	{ "/dev/ptyqb", 0 },
+	{ "/dev/ptyqc", 0 },
+	{ "/dev/ptyqd", 0 },
+	{ "/dev/ptyqe", 0 },
+	{ "/dev/ptyqf", 0 },
+	{ "/dev/ptyr0", 0 },
+	{ "/dev/ptyr1", 0 },
+	{ "/dev/ptyr2", 0 },
+	{ "/dev/ptyr3", 0 },
+	{ "/dev/ptyr4", 0 },
+	{ "/dev/ptyr5", 0 },
+	{ "/dev/ptyr6", 0 },
+	{ "/dev/ptyr7", 0 },
+	{ "/dev/ptyr8", 0 },
+	{ "/dev/ptyr9", 0 },
+	{ "/dev/ptyra", 0 },
+	{ "/dev/ptyrb", 0 },
+	{ "/dev/ptyrc", 0 },
+	{ "/dev/ptyrd", 0 },
+	{ "/dev/ptyre", 0 },
+	{ "/dev/ptyrf", 0 },
+	{ "/dev/ptys0", 0 },
+	{ "/dev/ptys1", 0 },
+	{ "/dev/ptys2", 0 },
+	{ "/dev/ptys3", 0 },
+	{ "/dev/ptys4", 0 },
+	{ "/dev/ptys5", 0 },
+	{ "/dev/ptys6", 0 },
+	{ "/dev/ptys7", 0 },
+	{ "/dev/ptys8", 0 },
+	{ "/dev/ptys9", 0 },
+	{ "/dev/ptysa", 0 },
+	{ "/dev/ptysb", 0 },
+	{ "/dev/ptysc", 0 },
+	{ "/dev/ptysd", 0 },
+	{ "/dev/ptyse", 0 },
+	{ "/dev/ptysf", 0 },
+	{ "/dev/ptyt0", 0 },
+	{ "/dev/ptyt1", 0 },
+	{ "/dev/ptyt2", 0 },
+	{ "/dev/ptyt3", 0 },
+	{ "/dev/ptyt4", 0 },
+	{ "/dev/ptyt5", 0 },
+	{ "/dev/ptyt6", 0 },
+	{ "/dev/ptyt7", 0 },
+	{ "/dev/ptyt8", 0 },
+	{ "/dev/ptyt9", 0 },
+	{ "/dev/ptyta", 0 },
+	{ "/dev/ptytb", 0 },
+	{ "/dev/ptytc", 0 },
+	{ "/dev/ptytd", 0 },
+	{ "/dev/ptyte", 0 },
+	{ "/dev/ptytf", 0 },
+	{ "/dev/ptyu0", 0 },
+	{ "/dev/ptyu1", 0 },
+	{ "/dev/ptyu2", 0 },
+	{ "/dev/ptyu3", 0 },
+	{ "/dev/ptyu4", 0 },
+	{ "/dev/ptyu5", 0 },
+	{ "/dev/ptyu6", 0 },
+	{ "/dev/ptyu7", 0 },
+	{ "/dev/ptyu8", 0 },
+	{ "/dev/ptyu9", 0 },
+	{ "/dev/ptyua", 0 },
+	{ "/dev/ptyub", 0 },
+	{ "/dev/ptyuc", 0 },
+	{ "/dev/ptyud", 0 },
+	{ "/dev/ptyue", 0 },
+	{ "/dev/ptyuf", 0 },
+	{ "/dev/ptyv0", 0 },
+	{ "/dev/ptyv1", 0 },
+	{ "/dev/ptyv2", 0 },
+	{ "/dev/ptyv3", 0 },
+	{ "/dev/ptyv4", 0 },
+	{ "/dev/ptyv5", 0 },
+	{ "/dev/ptyv6", 0 },
+	{ "/dev/ptyv7", 0 },
+	{ "/dev/ptyv8", 0 },
+	{ "/dev/ptyv9", 0 },
+	{ "/dev/ptyva", 0 },
+	{ "/dev/ptyvb", 0 },
+	{ "/dev/ptyvc", 0 },
+	{ "/dev/ptyvd", 0 },
+	{ "/dev/ptyve", 0 },
+	{ "/dev/ptyvf", 0 },
+	{ "/dev/ptyw0", 0 },
+	{ "/dev/ptyw1", 0 },
+	{ "/dev/ptyw2", 0 },
+	{ "/dev/ptyw3", 0 },
+	{ "/dev/ptyw4", 0 },
+	{ "/dev/ptyw5", 0 },
+	{ "/dev/ptyw6", 0 },
+	{ "/dev/ptyw7", 0 },
+	{ "/dev/ptyw8", 0 },
+	{ "/dev/ptyw9", 0 },
+	{ "/dev/ptywa", 0 },
+	{ "/dev/ptywb", 0 },
+	{ "/dev/ptywc", 0 },
+	{ "/dev/ptywd", 0 },
+	{ "/dev/ptywe", 0 },
+	{ "/dev/ptywf", 0 },
+	{ "/dev/ptyx0", 0 },
+	{ "/dev/ptyx1", 0 },
+	{ "/dev/ptyx2", 0 },
+	{ "/dev/ptyx3", 0 },
+	{ "/dev/ptyx4", 0 },
+	{ "/dev/ptyx5", 0 },
+	{ "/dev/ptyx6", 0 },
+	{ "/dev/ptyx7", 0 },
+	{ "/dev/ptyx8", 0 },
+	{ "/dev/ptyx9", 0 },
+	{ "/dev/ptyxa", 0 },
+	{ "/dev/ptyxb", 0 },
+	{ "/dev/ptyxc", 0 },
+	{ "/dev/ptyxd", 0 },
+	{ "/dev/ptyxe", 0 },
+	{ "/dev/ptyxf", 0 },
+	{ "/dev/ptyy0", 0 },
+	{ "/dev/ptyy1", 0 },
+	{ "/dev/ptyy2", 0 },
+	{ "/dev/ptyy3", 0 },
+	{ "/dev/ptyy4", 0 },
+	{ "/dev/ptyy5", 0 },
+	{ "/dev/ptyy6", 0 },
+	{ "/dev/ptyy7", 0 },
+	{ "/dev/ptyy8", 0 },
+	{ "/dev/ptyy9", 0 },
+	{ "/dev/ptyya", 0 },
+	{ "/dev/ptyyb", 0 },
+	{ "/dev/ptyyc", 0 },
+	{ "/dev/ptyyd", 0 },
+	{ "/dev/ptyye", 0 },
+	{ "/dev/ptyyf", 0 },
+	{ "/dev/ptyz0", 0 },
+	{ "/dev/ptyz1", 0 },
+	{ "/dev/ptyz2", 0 },
+	{ "/dev/ptyz3", 0 },
+	{ "/dev/ptyz4", 0 },
+	{ "/dev/ptyz5", 0 },
+	{ "/dev/ptyz6", 0 },
+	{ "/dev/ptyz7", 0 },
+	{ "/dev/ptyz8", 0 },
+	{ "/dev/ptyz9", 0 },
+	{ "/dev/ptyza", 0 },
+	{ "/dev/ptyzb", 0 },
+	{ "/dev/ptyzc", 0 },
+	{ "/dev/ptyzd", 0 },
+	{ "/dev/ptyze", 0 },
+	{ "/dev/ptyzf", 0 },
+	{ "/dev/ptya0", 0 },
+	{ "/dev/ptya1", 0 },
+	{ "/dev/ptya2", 0 },
+	{ "/dev/ptya3", 0 },
+	{ "/dev/ptya4", 0 },
+	{ "/dev/ptya5", 0 },
+	{ "/dev/ptya6", 0 },
+	{ "/dev/ptya7", 0 },
+	{ "/dev/ptya8", 0 },
+	{ "/dev/ptya9", 0 },
+	{ "/dev/ptyaa", 0 },
+	{ "/dev/ptyab", 0 },
+	{ "/dev/ptyac", 0 },
+	{ "/dev/ptyad", 0 },
+	{ "/dev/ptyae", 0 },
+	{ "/dev/ptyaf", 0 },
+	{ "/dev/ptyb0", 0 },
+	{ "/dev/ptyb1", 0 },
+	{ "/dev/ptyb2", 0 },
+	{ "/dev/ptyb3", 0 },
+	{ "/dev/ptyb4", 0 },
+	{ "/dev/ptyb5", 0 },
+	{ "/dev/ptyb6", 0 },
+	{ "/dev/ptyb7", 0 },
+	{ "/dev/ptyb8", 0 },
+	{ "/dev/ptyb9", 0 },
+	{ "/dev/ptyba", 0 },
+	{ "/dev/ptybb", 0 },
+	{ "/dev/ptybc", 0 },
+	{ "/dev/ptybd", 0 },
+	{ "/dev/ptybe", 0 },
+	{ "/dev/ptybf", 0 },
+	{ "/dev/ptyc0", 0 },
+	{ "/dev/ptyc1", 0 },
+	{ "/dev/ptyc2", 0 },
+	{ "/dev/ptyc3", 0 },
+	{ "/dev/ptyc4", 0 },
+	{ "/dev/ptyc5", 0 },
+	{ "/dev/ptyc6", 0 },
+	{ "/dev/ptyc7", 0 },
+	{ "/dev/ptyc8", 0 },
+	{ "/dev/ptyc9", 0 },
+	{ "/dev/ptyca", 0 },
+	{ "/dev/ptycb", 0 },
+	{ "/dev/ptycc", 0 },
+	{ "/dev/ptycd", 0 },
+	{ "/dev/ptyce", 0 },
+	{ "/dev/ptycf", 0 },
+	{ "/dev/ptyd0", 0 },
+	{ "/dev/ptyd1", 0 },
+	{ "/dev/ptyd2", 0 },
+	{ "/dev/ptyd3", 0 },
+	{ "/dev/ptyd4", 0 },
+	{ "/dev/ptyd5", 0 },
+	{ "/dev/ptyd6", 0 },
+	{ "/dev/ptyd7", 0 },
+	{ "/dev/ptyd8", 0 },
+	{ "/dev/ptyd9", 0 },
+	{ "/dev/ptyda", 0 },
+	{ "/dev/ptydb", 0 },
+	{ "/dev/ptydc", 0 },
+	{ "/dev/ptydd", 0 },
+	{ "/dev/ptyde", 0 },
+	{ "/dev/ptydf", 0 },
+	{ "/dev/ptye0", 0 },
+	{ "/dev/ptye1", 0 },
+	{ "/dev/ptye2", 0 },
+	{ "/dev/ptye3", 0 },
+	{ "/dev/ptye4", 0 },
+	{ "/dev/ptye5", 0 },
+	{ "/dev/ptye6", 0 },
+	{ "/dev/ptye7", 0 },
+	{ "/dev/ptye8", 0 },
+	{ "/dev/ptye9", 0 },
+	{ "/dev/ptyea", 0 },
+	{ "/dev/ptyeb", 0 },
+	{ "/dev/ptyec", 0 },
+	{ "/dev/ptyed", 0 },
+	{ "/dev/ptyee", 0 },
+	{ "/dev/ptyef", 0 },
+	{ "/dev/vcs", 0 },
+	{ "/dev/vcsa", 0 },
+	{ "/dev/vcs1", 0 },
+	{ "/dev/vcsa1", 0 },
+	{ "/dev/ttyS0", 0 },
+	{ "/dev/cua0", 0 },
+	{ "/dev/hda", 0 },
+	{ "/dev/hda1", 2 },
+	{ "/dev/hda2", 2 },
+	{ "/dev/hda3", 2 },
+	{ "/dev/hda4", 2 },
+	{ "/dev/hda5", 2 },
+	{ "/dev/hda6", 0 },
+	{ "/dev/hda7", 0 },
+	{ "/dev/hda8", 0 },
+	{ "/dev/hdb", 0 },
+	{ "/dev/hdb1", 2 },
+	{ "/dev/hdc", 0 },
+	{ "/dev/hdc1", 2 },
+	{ "/dev/fd0u1440", 0 },
+	{ "/dev/fd0u1680", 0 },
+	{ "/dev/fd0u1722", 0 },
+	{ "/dev/fd0u1743", 0 },
+	{ "/dev/fd0u1760", 0 },
+	{ "/dev/fd0u1920", 0 },
+	{ "/dev/fd0u1840", 0 },
+	{ "/dev/fd0u1600", 0 },
+	{ "/dev/fd0u360", 0 },
+	{ "/dev/fd0u720", 0 },
+	{ "/dev/fd0u820", 0 },
+	{ "/dev/fd0u830", 0 },
+	{ "/dev/fd0u1040", 0 },
+	{ "/dev/fd0u1120", 0 },
+	{ "/dev/fd0u800", 0 },
+	{ "/dev/fd0", 0 },
+	{ "/dev/loop0", 0 },
+	{ "/dev/loop1", 0 },
+	{ "/dev/loop2", 0 },
+	{ "/dev/loop3", 0 },
+	{ "/dev/loop4", 0 },
+	{ "/dev/loop5", 0 },
+	{ "/dev/loop6", 0 },
+	{ "/dev/loop7", 0 },
+	{ "/dev/dsp", 0 },
+	{ "/dev/dsp1", 0 },
+	{ "/dev/mixer", 0 },
+	{ "/dev/midi", 0 },
+	{ "/dev/lvm", 0 },
+	{ "/dev/vg0", 0 },
+	{ "/dev/vg0/group", 0 },
+	{ "/dev/vg0/packages", 0 },
+	{ "/dev/vg0/photos", 0 },
+	{ "/dev/vg0/music", 0 },
+	{ "/dev/log", 0 },
+	{ "/dev/MAKEDEV", 0 },
+	{ "/dev/printer", 0 },
+	{ "/dev/vcs2", 0 },
+	{ "/dev/vcsa2", 0 },
+	{ "/dev/vcs3", 0 },
+	{ "/dev/vcsa3", 0 },
+	{ "/dev/vcs5", 0 },
+	{ "/dev/vcsa5", 0 },
+	{ "/dev/vcs4", 0 },
+	{ "/dev/vcsa4", 0 },
+	{ "/dev/vcs6", 0 },
+	{ "/dev/vcsa6", 0 },
+	{ "/dev/nvidia0", 0 },
+	{ "/dev/nvidia1", 0 },
+	{ "/dev/nvidia2", 0 },
+	{ "/dev/nvidia3", 0 },
+	{ "/dev/nvidiactl", 0 },
+	{ "/dev/vcs7", 0 },
+	{ "/dev/vcsa7", 0 },
+	{ NULL, 0 }
+};
diff --git a/test/unit/matcher_t.c b/test/unit/matcher_t.c
new file mode 100644
index 0000000..a5eb5f9
--- /dev/null
+++ b/test/unit/matcher_t.c
@@ -0,0 +1,89 @@
+/*
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+ * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "units.h"
+#include "libdevmapper.h"
+
+#include "matcher_data.h"
+
+static void *_mem_init(void)
+{
+	struct dm_pool *mem = dm_pool_create("bitset test", 1024);
+	if (!mem) {
+		fprintf(stderr, "out of memory");
+		exit(1);
+	}
+
+	return mem;
+}
+
+static void _mem_exit(void *mem)
+{
+	dm_pool_destroy(mem);
+}
+
+static struct dm_regex *make_scanner(struct dm_pool *mem, const char **rx)
+{
+	struct dm_regex *scanner;
+	int nrx = 0;
+	for (; rx[nrx]; ++nrx);
+
+	scanner = dm_regex_create(mem, rx, nrx);
+	T_ASSERT(scanner != NULL);
+	return scanner;
+}
+
+static void test_fingerprints(void *fixture)
+{
+	struct dm_pool *mem = fixture;
+	struct dm_regex *scanner;
+
+	scanner = make_scanner(mem, dev_patterns);
+	T_ASSERT_EQUAL(dm_regex_fingerprint(scanner), 0x7f556c09);
+
+	scanner = make_scanner(mem, random_patterns);
+	T_ASSERT_EQUAL(dm_regex_fingerprint(scanner), 0x9f11076c);
+}
+
+static void test_matching(void *fixture)
+{
+	struct dm_pool *mem = fixture;
+	struct dm_regex *scanner;
+	int i;
+
+	scanner = make_scanner(mem, dev_patterns);
+	for (i = 0; devices[i].str; ++i)
+		T_ASSERT_EQUAL(dm_regex_match(scanner, devices[i].str), devices[i].expected - 1);
+
+	scanner = make_scanner(mem, nonprint_patterns);
+	for (i = 0; nonprint[i].str; ++i)
+		T_ASSERT_EQUAL(dm_regex_match(scanner, nonprint[i].str), nonprint[i].expected - 1);
+}
+
+#define T(path, desc, fn) register_test(ts, "/base/regex/" path, desc, fn)
+
+void regex_tests(struct dm_list *all_tests)
+{
+	struct test_suite *ts = test_suite_create(_mem_init, _mem_exit);
+	if (!ts) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
+	T("fingerprints", "not sure", test_fingerprints);
+	T("matching", "test the matcher with a variety of regexes", test_matching);
+
+	dm_list_add(all_tests, &ts->list);
+}
diff --git a/test/unit/percent_t.c b/test/unit/percent_t.c
new file mode 100644
index 0000000..84dd3bd
--- /dev/null
+++ b/test/unit/percent_t.c
@@ -0,0 +1,102 @@
+/*
+ * Copyright (C) 2017 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "units.h"
+#include "libdevmapper.h"
+
+#include <stdio.h>
+#include <string.h>
+
+static void test_percent_100(void *fixture)
+{
+	char buf[32];
+
+        /* Check 100% is shown only for DM_PERCENT_100*/
+	dm_percent_t p_100 = dm_make_percent(100, 100);
+        dm_percent_t p1_100 = dm_make_percent(100000, 100000);
+        dm_percent_t n_100 = dm_make_percent(999999, 1000000);
+
+	T_ASSERT_EQUAL(p_100, DM_PERCENT_100);
+	T_ASSERT_EQUAL(p1_100, DM_PERCENT_100);
+	T_ASSERT_NOT_EQUAL(n_100, DM_PERCENT_100);
+
+        dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(p_100));
+	T_ASSERT_EQUAL(strcmp(buf, "100.00"), 0);
+
+	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(p1_100));
+	T_ASSERT_EQUAL(strcmp(buf, "100.00"), 0);
+
+	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(n_100));
+	T_ASSERT_NOT_EQUAL(strcmp(buf, "99.99"), 0); /* Would like to gett */
+
+	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_round_float(n_100, 2));
+	T_ASSERT_EQUAL(strcmp(buf, "99.99"), 0);
+
+	dm_snprintf(buf, sizeof(buf), "%.3f", dm_percent_to_round_float(n_100, 3));
+	T_ASSERT_EQUAL(strcmp(buf, "99.999"), 0);
+
+	dm_snprintf(buf, sizeof(buf), "%.4f", dm_percent_to_round_float(n_100, 4));
+	T_ASSERT_EQUAL(strcmp(buf, "99.9999"), 0);
+
+	dm_snprintf(buf, sizeof(buf), "%d", (int)dm_percent_to_round_float(n_100, 0));
+	T_ASSERT_EQUAL(strcmp(buf, "99"), 0);
+}
+
+static void test_percent_0(void *fixture)
+{
+	char buf[32];
+
+	/* Check 0% is shown only for DM_PERCENT_0 */
+	dm_percent_t p_0 = dm_make_percent(0, 100);
+        dm_percent_t p1_0 = dm_make_percent(0, 100000);
+        dm_percent_t n_0 = dm_make_percent(1, 1000000);
+
+	T_ASSERT_EQUAL(p_0, DM_PERCENT_0);
+	T_ASSERT_EQUAL(p1_0, DM_PERCENT_0);
+	T_ASSERT_NOT_EQUAL(n_0, DM_PERCENT_0);
+
+        dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(p_0));
+	T_ASSERT_EQUAL(strcmp(buf, "0.00"), 0);
+
+	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(p1_0));
+	T_ASSERT_EQUAL(strcmp(buf, "0.00"), 0);
+
+	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(n_0));
+	T_ASSERT_NOT_EQUAL(strcmp(buf, "0.01"), 0);
+
+	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_round_float(n_0, 2));
+	T_ASSERT_EQUAL(strcmp(buf, "0.01"), 0);
+
+	dm_snprintf(buf, sizeof(buf), "%.3f", dm_percent_to_round_float(n_0, 3));
+	T_ASSERT_EQUAL(strcmp(buf, "0.001"), 0);
+
+	dm_snprintf(buf, sizeof(buf), "%d", (int)dm_percent_to_round_float(n_0, 0));
+	T_ASSERT_EQUAL(strcmp(buf, "1"), 0);
+}
+
+#define T(path, desc, fn) register_test(ts, "/base/formatting/percent/" path, desc, fn)
+
+void percent_tests(struct dm_list *all_tests)
+{
+	struct test_suite *ts = test_suite_create(NULL, NULL);
+	if (!ts) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
+	T("100", "Pretty printing of percentages near 100%", test_percent_100);
+	T("0", "Pretty printing of percentages near 0%", test_percent_0);
+
+	dm_list_add(all_tests, &ts->list);
+}
diff --git a/test/unit/run.c b/test/unit/run.c
new file mode 100644
index 0000000..9cbb605
--- /dev/null
+++ b/test/unit/run.c
@@ -0,0 +1,309 @@
+#include "units.h"
+
+#include <getopt.h>
+#include <regex.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <setjmp.h>
+#include <unistd.h>
+
+//-----------------------------------------------------------------
+
+#define MAX_COMPONENTS 16
+
+struct token {
+	const char *b, *e;
+};
+
+static bool _pop_component(const char *path, struct token *result)
+{
+	const char *b, *e;
+
+	while (*path && *path == '/')
+		path++;
+
+	b = path;
+	while (*path && (*path != '/'))
+		path++;
+	e = path;
+
+	if (b == e)
+		return false;
+
+	result->b = b;
+	result->e = e;
+	return true;
+}
+
+static unsigned _split_components(const char *path, struct token *toks, unsigned len)
+{
+	unsigned count = 0;
+	struct token tok;
+	tok.e = path;
+
+	while (len && _pop_component(tok.e, &tok)) {
+		*toks = tok;
+		toks++;
+		count++;
+		len--;
+	}
+
+	return count;
+}
+
+static void _indent(FILE *stream, unsigned count)
+{
+	unsigned i;
+
+	for (i = 0; i < count; i++)
+		fprintf(stream, "  ");
+}
+
+static void _print_token(FILE *stream, struct token *t)
+{
+	const char *ptr;
+
+	for (ptr = t->b; ptr != t->e; ptr++)
+		fprintf(stream, "%c", *ptr);
+}
+
+static int _char_cmp(char l, char r)
+{
+	if (l < r)
+		return -1;
+
+	else if (r < l)
+		return 1;
+
+	else
+		return 0;
+}
+
+static int _tok_cmp(struct token *lhs, struct token *rhs)
+{
+	const char *l = lhs->b, *le = lhs->e;
+	const char *r = rhs->b, *re = rhs->e;
+
+	while ((l != le) && (r != re) && (*l == *r)) {
+		l++;
+		r++;
+	}
+
+	if ((l != le) && (r != re))
+		return _char_cmp(*l, *r);
+
+	else if (r != re)
+		return -1;
+
+	else if (l != le)
+		return 1;
+
+	else
+		return 0;
+}
+
+static void _print_path_delta(FILE *stream,
+			      struct token *old, unsigned old_len,
+			      struct token *new, unsigned new_len,
+			      const char *desc)
+{
+	unsigned i, common_prefix = 0, len, d;
+	unsigned max_prefix = old_len < new_len ? old_len : new_len;
+
+	for (i = 0; i < max_prefix; i++) {
+		if (_tok_cmp(old + i, new + i))
+			break;
+		else
+			common_prefix++;
+	}
+
+	for (; i < new_len; i++) {
+		_indent(stream, common_prefix);
+		_print_token(stream, new + i);
+		common_prefix++;
+		if (i < new_len - 1)
+			fprintf(stream, "\n");
+	}
+
+	len = common_prefix * 2 + (new[new_len - 1].e - new[new_len - 1].b);
+	fprintf(stream, "  ");
+	for (d = len; d < 60; d++)
+		fprintf(stream, ".");
+	fprintf(stream, "  ");
+	fprintf(stream, "%s", desc);
+	fprintf(stream, "\n");
+}
+
+typedef struct token comp_t[MAX_COMPONENTS];
+
+static void _list_tests(struct test_details **tests, unsigned nr)
+{
+	unsigned i, current = 0, current_len, last_len = 0;
+
+	comp_t components[2];
+
+	for (i = 0; i < nr; i++) {
+		struct test_details *t = tests[i];
+		current_len = _split_components(t->path, components[current], MAX_COMPONENTS);
+		_print_path_delta(stderr, components[!current], last_len,
+				  components[current], current_len, t->desc);
+
+		last_len = current_len;
+		current = !current;
+	}
+}
+
+static void _destroy_tests(struct dm_list *suites)
+{
+	struct test_suite *ts, *tmp;
+
+	dm_list_iterate_items_safe (ts, tmp, suites)
+		test_suite_destroy(ts);
+}
+
+static const char *red(bool c)
+{
+	return c ? "\x1B[31m" : "";
+}
+
+static const char *green(bool c)
+{
+	return c ? "\x1B[32m" : "";
+}
+
+static const char *normal(bool c)
+{
+	return c ? "\x1B[0m" : "";
+}
+
+static void _run_test(struct test_details *t, bool use_colour, unsigned *passed, unsigned *total)
+{
+	void *fixture;
+	struct test_suite *ts = t->parent;
+	fprintf(stderr, "[RUN    ] %s\n", t->path);
+
+	(*total)++;
+	if (setjmp(test_k))
+		fprintf(stderr, "%s[   FAIL]%s %s\n", red(use_colour), normal(use_colour), t->path);
+	else {
+		if (ts->fixture_init)
+			fixture = ts->fixture_init();
+		else
+			fixture = NULL;
+
+		t->fn(fixture);
+
+		if (ts->fixture_exit)
+			ts->fixture_exit(fixture);
+
+		(*passed)++;
+		fprintf(stderr, "%s[     OK]%s\n", green(use_colour), normal(use_colour));
+	}
+}
+
+static bool _run_tests(struct test_details **tests, unsigned nr)
+{
+	bool use_colour = isatty(fileno(stderr));
+	unsigned i, passed = 0, total = 0;
+
+	for (i = 0; i < nr; i++)
+		_run_test(tests[i], use_colour, &passed, &total);
+
+	fprintf(stderr, "\n%u/%u tests passed\n", passed, total);
+
+	return passed == total;
+}
+
+static void _usage(void)
+{
+	fprintf(stderr, "Usage: unit-test <list|run> [pattern]\n");
+}
+
+static int _cmp_paths(const void *lhs, const void *rhs)
+{
+	struct test_details *l = *((struct test_details **) lhs);
+	struct test_details *r = *((struct test_details **) rhs);
+
+	return strcmp(l->path, r->path);
+}
+
+static unsigned _filter(const char *pattern, struct test_details **tests, unsigned nr)
+{
+	unsigned i, found = 0;
+	regex_t rx;
+
+	if (regcomp(&rx, pattern, 0)) {
+		fprintf(stderr, "couldn't compile regex '%s'\n", pattern);
+		exit(1);
+	}
+
+	for (i = 0; i < nr; i++)
+		if (!regexec(&rx, tests[i]->path, 0, NULL, 0))
+			tests[found++] = tests[i];
+
+	regfree(&rx);
+
+	return found;
+}
+
+int main(int argc, char **argv)
+{
+	int r;
+	unsigned i, nr_tests;
+	struct test_suite *ts;
+	struct test_details *t, **t_array;
+	struct dm_list suites;
+
+	dm_list_init(&suites);
+	register_all_tests(&suites);
+
+	// count all tests
+	nr_tests = 0;
+	dm_list_iterate_items (ts, &suites)
+		dm_list_iterate_items (t, &ts->tests)
+			nr_tests++;
+
+	// stick them in an array
+	t_array = malloc(sizeof(*t_array) * nr_tests);
+	if (!t_array) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
+	i = 0;
+	dm_list_iterate_items (ts, &suites)
+		dm_list_iterate_items (t, &ts->tests)
+			t_array[i++] = t;
+
+	// filter
+	if (argc == 3)
+		nr_tests = _filter(argv[2], t_array, nr_tests);
+
+	// sort
+	qsort(t_array, nr_tests, sizeof(*t_array), _cmp_paths);
+
+	// run or list them
+	if (argc == 1)
+		r = !_run_tests(t_array, nr_tests);
+	else {
+		const char *cmd = argv[1];
+		if (!strcmp(cmd, "run"))
+			r = !_run_tests(t_array, nr_tests);
+
+		else if (!strcmp(cmd, "list")) {
+			_list_tests(t_array, nr_tests);
+			r = 0;
+
+		} else {
+			_usage();
+			r = 1;
+		}
+	}
+
+	free(t_array);
+	_destroy_tests(&suites);
+
+	return r;
+}
+
+//-----------------------------------------------------------------
diff --git a/test/unit/string_t.c b/test/unit/string_t.c
new file mode 100644
index 0000000..2af0f37
--- /dev/null
+++ b/test/unit/string_t.c
@@ -0,0 +1,91 @@
+/*
+ * Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "units.h"
+#include "libdevmapper.h"
+
+#include <stdio.h>
+#include <string.h>
+
+#if 0
+static int _mem_init(void)
+{
+	struct dm_pool *mem = dm_pool_create("string test", 1024);
+	if (!mem) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
+	return mem;
+}
+
+static void _mem_exit(void *mem)
+{
+	dm_pool_destroy(mem);
+}
+
+/* TODO: Add more string unit tests here */
+#endif
+
+static void test_strncpy(void *fixture)
+{
+	const char st[] = "1234567890";
+	char buf[sizeof(st)];
+
+	T_ASSERT_EQUAL(dm_strncpy(buf, st, sizeof(buf)), 1);
+	T_ASSERT_EQUAL(strcmp(buf, st), 0);
+
+	T_ASSERT_EQUAL(dm_strncpy(buf, st, sizeof(buf) - 1), 0);
+	T_ASSERT_EQUAL(strlen(buf) + 1, sizeof(buf) - 1);
+}
+
+static void test_asprint(void *fixture)
+{
+	const char st0[] = "";
+	const char st1[] = "12345678901";
+	const char st2[] = "1234567890123456789012345678901234567890123456789012345678901234567";
+	char *buf;
+	int a;
+
+	a = dm_asprintf(&buf, "%s", st0);
+	T_ASSERT_EQUAL(strcmp(buf, st0), 0);
+	T_ASSERT_EQUAL(a, sizeof(st0));
+	free(buf);
+
+	a = dm_asprintf(&buf, "%s", st1);
+	T_ASSERT_EQUAL(strcmp(buf, st1), 0);
+	T_ASSERT_EQUAL(a, sizeof(st1));
+	free(buf);
+
+	a = dm_asprintf(&buf, "%s", st2);
+	T_ASSERT_EQUAL(a, sizeof(st2));
+	T_ASSERT_EQUAL(strcmp(buf, st2), 0);
+	free(buf);
+}
+
+#define T(path, desc, fn) register_test(ts, "/base/data-struct/string/" path, desc, fn)
+
+void string_tests(struct dm_list *all_tests)
+{
+	struct test_suite *ts = test_suite_create(NULL, NULL);
+	if (!ts) {
+		fprintf(stderr, "out of memory\n");
+		exit(1);
+	}
+
+	T("asprint", "tests asprint", test_asprint);
+	T("strncpy", "tests string copying", test_strncpy);
+
+	dm_list_add(all_tests, &ts->list);
+}
diff --git a/test/unit/units.h b/test/unit/units.h
new file mode 100644
index 0000000..dbbd41e
--- /dev/null
+++ b/test/unit/units.h
@@ -0,0 +1,48 @@
+/*
+ * Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#ifndef TEST_UNIT_UNITS_H
+#define TEST_UNIT_UNITS_H
+
+#include "framework.h"
+
+//-----------------------------------------------------------------
+
+// Declare the function that adds tests suites here ...
+void bcache_tests(struct dm_list *suites);
+void bitset_tests(struct dm_list *suites);
+void config_tests(struct dm_list *suites);
+void dm_list_tests(struct dm_list *suites);
+void dm_status_tests(struct dm_list *suites);
+void io_engine_tests(struct dm_list *suites);
+void regex_tests(struct dm_list *suites);
+void percent_tests(struct dm_list *suites);
+void string_tests(struct dm_list *suites);
+
+// ... and call it in here.
+static inline void register_all_tests(struct dm_list *suites)
+{
+	bcache_tests(suites);
+	bitset_tests(suites);
+	config_tests(suites);
+	dm_list_tests(suites);
+	dm_status_tests(suites);
+	io_engine_tests(suites);
+	regex_tests(suites);
+	percent_tests(suites);
+	string_tests(suites);
+}
+
+//-----------------------------------------------------------------
+#endif
diff --git a/unit-test/Makefile.in b/unit-test/Makefile.in
deleted file mode 100644
index ad7c549..0000000
--- a/unit-test/Makefile.in
+++ /dev/null
@@ -1,41 +0,0 @@
-# Copyright (C) 2011-2018 Red Hat, Inc. All rights reserved.
-#
-# This file is part of LVM2.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-UNIT_SOURCE=\
-	unit-test/bcache_t.c \
-	unit-test/bitset_t.c \
-	unit-test/config_t.c \
-	unit-test/dmlist_t.c \
-	unit-test/dmstatus_t.c \
-	unit-test/io_engine_t.c \
-	unit-test/matcher_t.c \
-	unit-test/framework.c \
-	unit-test/percent_t.c \
-	unit-test/run.c \
-	unit-test/string_t.c
-
-UNIT_DEPENDS=$(subst .c,.d,$(UNIT_SOURCE))
-UNIT_OBJECTS=$(UNIT_SOURCE:%.c=%.o)
-CLEAN_TARGETS+=$(UNIT_DEPENDS) $(UNIT_OBJECTS)
-UNIT_LDLIBS += $(LVMINTERNAL_LIBS) -ldevmapper -laio
-
-unit-test/unit-test: $(UNIT_OBJECTS) libdm/libdevmapper.$(LIB_SUFFIX) lib/liblvm-internal.a
-	@echo "    [LD] $@"
-	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) -L$(top_builddir)/libdm \
-	      -o $@ $(UNIT_OBJECTS) $(UNIT_LDLIBS)
-
-.PHONEY: run-unit-test
-run-unit-test: unit-test/unit-test
-	@echo Running unit tests
-	LD_LIBRARY_PATH=libdm unit-test/unit-test run
-
--include $(UNIT_DEPENDS)
diff --git a/unit-test/bcache_t.c b/unit-test/bcache_t.c
deleted file mode 100644
index d06d5fe..0000000
--- a/unit-test/bcache_t.c
+++ /dev/null
@@ -1,871 +0,0 @@
-/*
- * Copyright (C) 2018 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
- */
-
-#include <errno.h>
-#include <stdio.h>
-#include <stdlib.h>
-#include <unistd.h>
-
-#include "bcache.h"
-#include "framework.h"
-#include "units.h"
-
-#define SHOW_MOCK_CALLS 0
-
-/*----------------------------------------------------------------
- * Mock engine
- *--------------------------------------------------------------*/
-struct mock_engine {
-	struct io_engine e;
-	struct dm_list expected_calls;
-	struct dm_list issued_io;
-	unsigned max_io;
-	sector_t block_size;
-};
-
-enum method {
-	E_DESTROY,
-	E_ISSUE,
-	E_WAIT,
-	E_MAX_IO
-};
-
-struct mock_call {
-	struct dm_list list;
-	enum method m;
-
-	bool match_args;
-	enum dir d;
-	int fd;
-	block_address b;
-	bool issue_r;
-	bool wait_r;
-};
-
-struct mock_io {
-	struct dm_list list;
-	int fd;
-	sector_t sb;
-	sector_t se;
-	void *data;
-	void *context;
-	bool r;
-};
-
-static const char *_show_method(enum method m)
-{
-	switch (m) {
-	case E_DESTROY:
-		return "destroy()";
-	case E_ISSUE:
-		return "issue()";
-	case E_WAIT:
-		return "wait()";
-	case E_MAX_IO:
-		return "max_io()";
-	}
-
-	return "<unknown>";
-}
-
-static void _expect(struct mock_engine *e, enum method m)
-{
-	struct mock_call *mc = malloc(sizeof(*mc));
-	mc->m = m;
-	mc->match_args = false;
-	dm_list_add(&e->expected_calls, &mc->list);
-}
-
-static void _expect_read(struct mock_engine *e, int fd, block_address b)
-{
-	struct mock_call *mc = malloc(sizeof(*mc));
-	mc->m = E_ISSUE;
-	mc->match_args = true;
-	mc->d = DIR_READ;
-	mc->fd = fd;
-	mc->b = b;
-	mc->issue_r = true;
-	mc->wait_r = true;
-	dm_list_add(&e->expected_calls, &mc->list);
-}
-
-static void _expect_write(struct mock_engine *e, int fd, block_address b)
-{
-	struct mock_call *mc = malloc(sizeof(*mc));
-	mc->m = E_ISSUE;
-	mc->match_args = true;
-	mc->d = DIR_WRITE;
-	mc->fd = fd;
-	mc->b = b;
-	mc->issue_r = true;
-	mc->wait_r = true;
-	dm_list_add(&e->expected_calls, &mc->list);
-}
-
-static void _expect_read_bad_issue(struct mock_engine *e, int fd, block_address b)
-{
-	struct mock_call *mc = malloc(sizeof(*mc));
-	mc->m = E_ISSUE;
-	mc->match_args = true;
-	mc->d = DIR_READ;
-	mc->fd = fd;
-	mc->b = b;
-	mc->issue_r = false;
-	mc->wait_r = true;
-	dm_list_add(&e->expected_calls, &mc->list);
-}
-
-static void _expect_write_bad_issue(struct mock_engine *e, int fd, block_address b)
-{
-	struct mock_call *mc = malloc(sizeof(*mc));
-	mc->m = E_ISSUE;
-	mc->match_args = true;
-	mc->d = DIR_WRITE;
-	mc->fd = fd;
-	mc->b = b;
-	mc->issue_r = false;
-	mc->wait_r = true;
-	dm_list_add(&e->expected_calls, &mc->list);
-}
-
-static void _expect_read_bad_wait(struct mock_engine *e, int fd, block_address b)
-{
-	struct mock_call *mc = malloc(sizeof(*mc));
-	mc->m = E_ISSUE;
-	mc->match_args = true;
-	mc->d = DIR_READ;
-	mc->fd = fd;
-	mc->b = b;
-	mc->issue_r = true;
-	mc->wait_r = false;
-	dm_list_add(&e->expected_calls, &mc->list);
-}
-
-static void _expect_write_bad_wait(struct mock_engine *e, int fd, block_address b)
-{
-	struct mock_call *mc = malloc(sizeof(*mc));
-	mc->m = E_ISSUE;
-	mc->match_args = true;
-	mc->d = DIR_WRITE;
-	mc->fd = fd;
-	mc->b = b;
-	mc->issue_r = true;
-	mc->wait_r = false;
-	dm_list_add(&e->expected_calls, &mc->list);
-}
-
-static struct mock_call *_match_pop(struct mock_engine *e, enum method m)
-{
-
-	struct mock_call *mc;
-
-	if (dm_list_empty(&e->expected_calls))
-		test_fail("unexpected call to method %s\n", _show_method(m));
-
-	mc = dm_list_item(e->expected_calls.n, struct mock_call);
-	dm_list_del(&mc->list);
-
-	if (mc->m != m)
-		test_fail("expected %s, but got %s\n", _show_method(mc->m), _show_method(m));
-#if SHOW_MOCK_CALLS
-	else
-		fprintf(stderr, "%s called (expected)\n", _show_method(m));
-#endif
-
-	return mc;
-}
-
-static void _match(struct mock_engine *e, enum method m)
-{
-	free(_match_pop(e, m));
-}
-
-static void _no_outstanding_expectations(struct mock_engine *e)
-{
-	struct mock_call *mc;
-
-	if (!dm_list_empty(&e->expected_calls)) {
-		fprintf(stderr, "unsatisfied expectations:\n");
-		dm_list_iterate_items (mc, &e->expected_calls)
-			fprintf(stderr, "  %s\n", _show_method(mc->m));
-	}
-	T_ASSERT(dm_list_empty(&e->expected_calls));
-}
-
-static struct mock_engine *_to_mock(struct io_engine *e)
-{
-	return container_of(e, struct mock_engine, e);
-}
-
-static void _mock_destroy(struct io_engine *e)
-{
-	struct mock_engine *me = _to_mock(e);
-
-	_match(me, E_DESTROY);
-	T_ASSERT(dm_list_empty(&me->issued_io));
-	T_ASSERT(dm_list_empty(&me->expected_calls));
-	free(_to_mock(e));
-}
-
-static bool _mock_issue(struct io_engine *e, enum dir d, int fd,
-	      		sector_t sb, sector_t se, void *data, void *context)
-{
-	bool r, wait_r;
-	struct mock_io *io;
-	struct mock_call *mc;
-	struct mock_engine *me = _to_mock(e);
-
-	mc = _match_pop(me, E_ISSUE);
-	if (mc->match_args) {
-		T_ASSERT(d == mc->d);
-		T_ASSERT(fd == mc->fd);
-		T_ASSERT(sb == mc->b * me->block_size);
-		T_ASSERT(se == (mc->b + 1) * me->block_size);
-	}
-	r = mc->issue_r;
-	wait_r = mc->wait_r;
-	free(mc);
-
-	if (r) {
-		io = malloc(sizeof(*io));
-		if (!io)
-			abort();
-
-		io->fd = fd;
-		io->sb = sb;
-		io->se = se;
-		io->data = data;
-		io->context = context;
-		io->r = wait_r;
-
-		dm_list_add(&me->issued_io, &io->list);
-	}
-
-	return r;
-}
-
-static bool _mock_wait(struct io_engine *e, io_complete_fn fn)
-{
-	struct mock_io *io;
-	struct mock_engine *me = _to_mock(e);
-	_match(me, E_WAIT);
-
-	// FIXME: provide a way to control how many are completed and whether
-	// they error.
-	T_ASSERT(!dm_list_empty(&me->issued_io));
-	io = dm_list_item(me->issued_io.n, struct mock_io);
-	dm_list_del(&io->list);
-	fn(io->context, io->r ? 0 : -EIO);
-	free(io);
-
-	return true;
-}
-
-static unsigned _mock_max_io(struct io_engine *e)
-{
-	struct mock_engine *me = _to_mock(e);
-	_match(me, E_MAX_IO);
-	return me->max_io;
-}
-
-static struct mock_engine *_mock_create(unsigned max_io, sector_t block_size)
-{
-	struct mock_engine *m = malloc(sizeof(*m));
-
-	m->e.destroy = _mock_destroy;
-	m->e.issue = _mock_issue;
-	m->e.wait = _mock_wait;
-	m->e.max_io = _mock_max_io;
-
-	m->max_io = max_io;
-	m->block_size = block_size;
-	dm_list_init(&m->expected_calls);
-	dm_list_init(&m->issued_io);
-
-	return m;
-}
-
-/*----------------------------------------------------------------
- * Fixtures
- *--------------------------------------------------------------*/
-struct fixture {
-	struct mock_engine *me;
-	struct bcache *cache;
-};
-
-static struct fixture *_fixture_init(sector_t block_size, unsigned nr_cache_blocks)
-{
-	struct fixture *f = malloc(sizeof(*f));
-
-	f->me = _mock_create(16, block_size);
-	T_ASSERT(f->me);
-
-	_expect(f->me, E_MAX_IO);
-	f->cache = bcache_create(block_size, nr_cache_blocks, &f->me->e);
-	T_ASSERT(f->cache);
-
-	return f;
-}
-
-static void _fixture_exit(struct fixture *f)
-{
-	_expect(f->me, E_DESTROY);
-	bcache_destroy(f->cache);
-
-	free(f);
-}
-
-static void *_small_fixture_init(void)
-{
-	return _fixture_init(128, 16);
-}
-
-static void _small_fixture_exit(void *context)
-{
-	_fixture_exit(context);
-}
-
-static void *_large_fixture_init(void)
-{
-	return _fixture_init(128, 1024);
-}
-
-static void _large_fixture_exit(void *context)
-{
-	_fixture_exit(context);
-}
-
-/*----------------------------------------------------------------
- * Tests
- *--------------------------------------------------------------*/
-#define MEG 2048
-#define SECTOR_SHIFT 9
-
-static void good_create(sector_t block_size, unsigned nr_cache_blocks)
-{
-	struct bcache *cache;
-	struct mock_engine *me = _mock_create(16, 128);
-
-	_expect(me, E_MAX_IO);
-	cache = bcache_create(block_size, nr_cache_blocks, &me->e);
-	T_ASSERT(cache);
-
-	_expect(me, E_DESTROY);
-	bcache_destroy(cache);
-}
-
-static void bad_create(sector_t block_size, unsigned nr_cache_blocks)
-{
-	struct bcache *cache;
-	struct mock_engine *me = _mock_create(16, 128);
-
-	_expect(me, E_MAX_IO);
-	cache = bcache_create(block_size, nr_cache_blocks, &me->e);
-	T_ASSERT(!cache);
-
-	_expect(me, E_DESTROY);
-	me->e.destroy(&me->e);
-}
-
-static void test_create(void *fixture)
-{
-	good_create(8, 16);
-}
-
-static void test_nr_cache_blocks_must_be_positive(void *fixture)
-{
-	bad_create(8, 0);
-}
-
-static void test_block_size_must_be_positive(void *fixture)
-{
-	bad_create(0, 16);
-}
-
-static void test_block_size_must_be_multiple_of_page_size(void *fixture)
-{
-	static unsigned _bad_examples[] = {3, 9, 13, 1025};
-
-	unsigned i;
-
-	for (i = 0; i < DM_ARRAY_SIZE(_bad_examples); i++)
-		bad_create(_bad_examples[i], 16);
-
-	for (i = 1; i < 1000; i++)
-		good_create(i * 8, 16);
-}
-
-static void test_get_triggers_read(void *context)
-{
-        int err;
-	struct fixture *f = context;
-
-	int fd = 17;   // arbitrary key
-	struct block *b;
-
-	_expect_read(f->me, fd, 0);
-	_expect(f->me, E_WAIT);
-	T_ASSERT(bcache_get(f->cache, fd, 0, 0, &b, &err));
-	bcache_put(b);
-}
-
-static void test_repeated_reads_are_cached(void *context)
-{
-        int err;
-	struct fixture *f = context;
-
-	int fd = 17;   // arbitrary key
-	unsigned i;
-	struct block *b;
-
-	_expect_read(f->me, fd, 0);
-	_expect(f->me, E_WAIT);
-	for (i = 0; i < 100; i++) {
-		T_ASSERT(bcache_get(f->cache, fd, 0, 0, &b, &err));
-		bcache_put(b);
-	}
-}
-
-static void test_block_gets_evicted_with_many_reads(void *context)
-{
-	struct fixture *f = context;
-
-	int err;
-	struct mock_engine *me = f->me;
-	struct bcache *cache = f->cache;
-	const unsigned nr_cache_blocks = 16;
-
-	int fd = 17;   // arbitrary key
-	unsigned i;
-	struct block *b;
-
-	for (i = 0; i < nr_cache_blocks; i++) {
-		_expect_read(me, fd, i);
-		_expect(me, E_WAIT);
-		T_ASSERT(bcache_get(cache, fd, i, 0, &b, &err));
-		bcache_put(b);
-	}
-
-	// Not enough cache blocks to hold this one
-	_expect_read(me, fd, nr_cache_blocks);
-	_expect(me, E_WAIT);
-	T_ASSERT(bcache_get(cache, fd, nr_cache_blocks, 0, &b, &err));
-	bcache_put(b);
-
-	// Now if we run through we should find one block has been
-	// evicted.  We go backwards because the oldest is normally
-	// evicted first.
-	_expect(me, E_ISSUE);
-	_expect(me, E_WAIT);
-	for (i = nr_cache_blocks; i; i--) {
-		T_ASSERT(bcache_get(cache, fd, i - 1, 0, &b, &err));
-		bcache_put(b);
-	}
-}
-
-static void test_prefetch_issues_a_read(void *context)
-{
-	struct fixture *f = context;
-	struct mock_engine *me = f->me;
-	struct bcache *cache = f->cache;
-	const unsigned nr_cache_blocks = 16;
-
-	int err;
-	int fd = 17;   // arbitrary key
-	unsigned i;
-	struct block *b;
-
-	for (i = 0; i < nr_cache_blocks; i++) {
-		// prefetch should not wait
-		_expect_read(me, fd, i);
-		bcache_prefetch(cache, fd, i);
-	}
-
-
-	for (i = 0; i < nr_cache_blocks; i++) {
-		_expect(me, E_WAIT);
-		T_ASSERT(bcache_get(cache, fd, i, 0, &b, &err));
-		bcache_put(b);
-	}
-}
-
-static void test_too_many_prefetches_does_not_trigger_a_wait(void *context)
-{
-	struct fixture *f = context;
-	struct mock_engine *me = f->me;
-	struct bcache *cache = f->cache;
-
-	const unsigned nr_cache_blocks = 16;
-	int fd = 17;   // arbitrary key
-	unsigned i;
-
-	for (i = 0; i < 10 * nr_cache_blocks; i++) {
-		// prefetch should not wait
-		if (i < nr_cache_blocks)
-			_expect_read(me, fd, i);
-		bcache_prefetch(cache, fd, i);
-	}
-
-	// Destroy will wait for any in flight IO triggered by prefetches.
-	for (i = 0; i < nr_cache_blocks; i++)
-		_expect(me, E_WAIT);
-}
-
-static void test_dirty_data_gets_written_back(void *context)
-{
-	struct fixture *f = context;
-	struct mock_engine *me = f->me;
-	struct bcache *cache = f->cache;
-
-	int err;
-	int fd = 17;   // arbitrary key
-	struct block *b;
-
-	// Expect the read
-	_expect_read(me, fd, 0);
-	_expect(me, E_WAIT);
-	T_ASSERT(bcache_get(cache, fd, 0, GF_DIRTY, &b, &err));
-	bcache_put(b);
-
-	// Expect the write
-	_expect_write(me, fd, 0);
-	_expect(me, E_WAIT);
-}
-
-static void test_zeroed_data_counts_as_dirty(void *context)
-{
-	struct fixture *f = context;
-	struct mock_engine *me = f->me;
-	struct bcache *cache = f->cache;
-
-	int err;
-	int fd = 17;   // arbitrary key
-	struct block *b;
-
-	// No read
-	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b, &err));
-	bcache_put(b);
-
-	// Expect the write
-	_expect_write(me, fd, 0);
-	_expect(me, E_WAIT);
-}
-
-static void test_flush_waits_for_all_dirty(void *context)
-{
-	struct fixture *f = context;
-	struct mock_engine *me = f->me;
-	struct bcache *cache = f->cache;
-
-	const unsigned count = 16;
-	int err;
-	int fd = 17;   // arbitrary key
-	unsigned i;
-	struct block *b;
-
-	for (i = 0; i < count; i++) {
-		if (i % 2) {
-			T_ASSERT(bcache_get(cache, fd, i, GF_ZERO, &b, &err));
-		} else {
-			_expect_read(me, fd, i);
-			_expect(me, E_WAIT);
-			T_ASSERT(bcache_get(cache, fd, i, 0, &b, &err));
-		}
-		bcache_put(b);
-	}
-
-	for (i = 0; i < count; i++) {
-		if (i % 2)
-			_expect_write(me, fd, i);
-	}
-
-	for (i = 0; i < count; i++) {
-		if (i % 2)
-			_expect(me, E_WAIT);
-	}
-
-	bcache_flush(cache);
-	_no_outstanding_expectations(me);
-}
-
-static void test_multiple_files(void *context)
-{
-	static int _fds[] = {1, 128, 345, 678, 890};
-
-	int err;
-	struct fixture *f = context;
-	struct mock_engine *me = f->me;
-	struct bcache *cache = f->cache;
-	struct block *b;
-	unsigned i;
-
-	for (i = 0; i < DM_ARRAY_SIZE(_fds); i++) {
-		_expect_read(me, _fds[i], 0);
-		_expect(me, E_WAIT);
-
-		T_ASSERT(bcache_get(cache, _fds[i], 0, 0, &b, &err));
-		bcache_put(b);
-	}
-}
-
-static void test_read_bad_issue(void *context)
-{
-	struct fixture *f = context;
-	struct mock_engine *me = f->me;
-	struct bcache *cache = f->cache;
-	struct block *b;
-	int err;
-
-	_expect_read_bad_issue(me, 17, 0);
-	T_ASSERT(!bcache_get(cache, 17, 0, 0, &b, &err));
-}
-
-static void test_read_bad_issue_intermittent(void *context)
-{
-	struct fixture *f = context;
-	struct mock_engine *me = f->me;
-	struct bcache *cache = f->cache;
-	struct block *b;
-	int fd = 17;
-	int err;
-
-	_expect_read_bad_issue(me, fd, 0);
-	T_ASSERT(!bcache_get(cache, fd, 0, 0, &b, &err));
-
-	_expect_read(me, fd, 0);
-	_expect(me, E_WAIT);
-	T_ASSERT(bcache_get(cache, fd, 0, 0, &b, &err));
-	bcache_put(b);
-}
-
-static void test_read_bad_wait(void *context)
-{
-	struct fixture *f = context;
-	struct mock_engine *me = f->me;
-	struct bcache *cache = f->cache;
-	struct block *b;
-	int fd = 17;
-	int err;
-
-	_expect_read_bad_wait(me, fd, 0);
-	_expect(me, E_WAIT);
-	T_ASSERT(!bcache_get(cache, fd, 0, 0, &b, &err));
-}
-
-static void test_read_bad_wait_intermittent(void *context)
-{
-	struct fixture *f = context;
-	struct mock_engine *me = f->me;
-	struct bcache *cache = f->cache;
-	struct block *b;
-	int fd = 17;
-	int err;
-
-	_expect_read_bad_wait(me, fd, 0);
-	_expect(me, E_WAIT);
-	T_ASSERT(!bcache_get(cache, fd, 0, 0, &b, &err));
-
-	_expect_read(me, fd, 0);
-	_expect(me, E_WAIT);
-	T_ASSERT(bcache_get(cache, fd, 0, 0, &b, &err));
-	bcache_put(b);
-}
-
-static void test_write_bad_issue_stops_flush(void *context)
-{
-	struct fixture *f = context;
-	struct mock_engine *me = f->me;
-	struct bcache *cache = f->cache;
-	struct block *b;
-	int fd = 17;
-	int err;
-
-	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b, &err));
-	_expect_write_bad_issue(me, fd, 0);
-	bcache_put(b);
-	T_ASSERT(!bcache_flush(cache));
-
-	// we'll let it succeed the second time
-	_expect_write(me, fd, 0);
-	_expect(me, E_WAIT);
-	T_ASSERT(bcache_flush(cache));
-}
-
-static void test_write_bad_io_stops_flush(void *context)
-{
-	struct fixture *f = context;
-	struct mock_engine *me = f->me;
-	struct bcache *cache = f->cache;
-	struct block *b;
-	int fd = 17;
-	int err;
-
-	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b, &err));
-	_expect_write_bad_wait(me, fd, 0);
-	_expect(me, E_WAIT);
-	bcache_put(b);
-	T_ASSERT(!bcache_flush(cache));
-
-	// we'll let it succeed the second time
-	_expect_write(me, fd, 0);
-	_expect(me, E_WAIT);
-	T_ASSERT(bcache_flush(cache));
-}
-
-static void test_invalidate_not_present(void *context)
-{
-	struct fixture *f = context;
-	struct bcache *cache = f->cache;
-	int fd = 17;
-
-	T_ASSERT(bcache_invalidate(cache, fd, 0));
-}
-
-static void test_invalidate_present(void *context)
-{
-	struct fixture *f = context;
-	struct mock_engine *me = f->me;
-	struct bcache *cache = f->cache;
-	struct block *b;
-	int fd = 17;
-	int err;
-
-	_expect_read(me, fd, 0);
-	_expect(me, E_WAIT);
-	T_ASSERT(bcache_get(cache, fd, 0, 0, &b, &err));
-	bcache_put(b);
-
-	T_ASSERT(bcache_invalidate(cache, fd, 0));
-}
-
-static void test_invalidate_after_read_error(void *context)
-{
-	struct fixture *f = context;
-	struct mock_engine *me = f->me;
-	struct bcache *cache = f->cache;
-	struct block *b;
-	int fd = 17;
-	int err;
-
-	_expect_read_bad_issue(me, fd, 0);
-	T_ASSERT(!bcache_get(cache, fd, 0, 0, &b, &err));
-	T_ASSERT(bcache_invalidate(cache, fd, 0));
-}
-
-static void test_invalidate_after_write_error(void *context)
-{
-	struct fixture *f = context;
-	struct mock_engine *me = f->me;
-	struct bcache *cache = f->cache;
-	struct block *b;
-	int fd = 17;
-	int err;
-
-	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b, &err));
-	bcache_put(b);
-
-	// invalidate should fail if the write fails
-	_expect_write_bad_wait(me, fd, 0);
-	_expect(me, E_WAIT);
-	T_ASSERT(!bcache_invalidate(cache, fd, 0));
-
-	// and should succeed if the write does
-	_expect_write(me, fd, 0);
-	_expect(me, E_WAIT);
-	T_ASSERT(bcache_invalidate(cache, fd, 0));
-
-	// a read is not required to get the block
-	_expect_read(me, fd, 0);
-	_expect(me, E_WAIT);
-	T_ASSERT(bcache_get(cache, fd, 0, 0, &b, &err));
-	bcache_put(b);
-}
-
-static void test_invalidate_held_block(void *context)
-{
-
-	struct fixture *f = context;
-	struct mock_engine *me = f->me;
-	struct bcache *cache = f->cache;
-	struct block *b;
-	int fd = 17;
-	int err;
-
-	T_ASSERT(bcache_get(cache, fd, 0, GF_ZERO, &b, &err));
-
-	T_ASSERT(!bcache_invalidate(cache, fd, 0));
-
-	_expect_write(me, fd, 0);
-	_expect(me, E_WAIT);
-	bcache_put(b);
-}
-
-/*----------------------------------------------------------------
- * Top level
- *--------------------------------------------------------------*/
-#define T(path, desc, fn) register_test(ts, "/base/device/bcache/" path, desc, fn)
-
-static struct test_suite *_small_tests(void)
-{
-	struct test_suite *ts = test_suite_create(_small_fixture_init, _small_fixture_exit);
-	if (!ts) {
-		fprintf(stderr, "out of memory\n");
-		exit(1);
-	}
-
-	T("create-destroy", "simple create/destroy", test_create);
-	T("cache-blocks-positive", "nr cache blocks must be positive", test_nr_cache_blocks_must_be_positive);
-	T("block-size-positive", "block size must be positive", test_block_size_must_be_positive);
-	T("block-size-multiple-page", "block size must be a multiple of page size", test_block_size_must_be_multiple_of_page_size);
-	T("get-reads", "bcache_get() triggers read", test_get_triggers_read);
-	T("reads-cached", "repeated reads are cached", test_repeated_reads_are_cached);
-	T("blocks-get-evicted", "block get evicted with many reads", test_block_gets_evicted_with_many_reads);
-	T("prefetch-reads", "prefetch issues a read", test_prefetch_issues_a_read);
-	T("prefetch-never-waits", "too many prefetches does not trigger a wait", test_too_many_prefetches_does_not_trigger_a_wait);
-	T("writeback-occurs", "dirty data gets written back", test_dirty_data_gets_written_back);
-	T("zero-flag-dirties", "zeroed data counts as dirty", test_zeroed_data_counts_as_dirty);
-	T("read-multiple-files", "read from multiple files", test_multiple_files);
-	T("read-bad-issue", "read fails if io engine unable to issue", test_read_bad_issue);
-	T("read-bad-issue-intermittent", "failed issue, followed by succes", test_read_bad_issue_intermittent);
-	T("read-bad-io", "read issued ok, but io fails", test_read_bad_wait);
-	T("read-bad-io-intermittent", "failed io, followed by success", test_read_bad_wait_intermittent);
-	T("write-bad-issue-stops-flush", "flush fails temporarily if any block fails to write", test_write_bad_issue_stops_flush);
-	T("write-bad-io-stops-flush", "flush fails temporarily if any block fails to write", test_write_bad_io_stops_flush);
-	T("invalidate-not-present", "invalidate a block that isn't in the cache", test_invalidate_not_present);
-	T("invalidate-present", "invalidate a block that is in the cache", test_invalidate_present);
-	T("invalidate-read-error", "invalidate a block that errored", test_invalidate_after_read_error);
-	T("invalidate-write-error", "invalidate a block that errored", test_invalidate_after_write_error);
-	T("invalidate-fails-in-held", "invalidating a held block fails", test_invalidate_held_block);
-
-	return ts;
-}
-
-static struct test_suite *_large_tests(void)
-{
-	struct test_suite *ts = test_suite_create(_large_fixture_init, _large_fixture_exit);
-	if (!ts) {
-		fprintf(stderr, "out of memory\n");
-		exit(1);
-	}
-
-	T("flush-waits", "flush waits for all dirty", test_flush_waits_for_all_dirty);
-
-	return ts;
-}
-
-void bcache_tests(struct dm_list *all_tests)
-{
-	dm_list_add(all_tests, &_small_tests()->list);
-	dm_list_add(all_tests, &_large_tests()->list);
-}
diff --git a/unit-test/bitset_t.c b/unit-test/bitset_t.c
deleted file mode 100644
index 106f60f..0000000
--- a/unit-test/bitset_t.c
+++ /dev/null
@@ -1,148 +0,0 @@
-/*
- * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
- */
-
-#include "units.h"
-#include "libdevmapper.h"
-
-enum {
-        NR_BITS = 137
-};
-
-static void *_mem_init(void) {
-	struct dm_pool *mem = dm_pool_create("bitset test", 1024);
-	if (!mem) {
-		fprintf(stderr, "out of memory\n");
-		exit(1);
-	}
-
-	return mem;
-}
-
-static void _mem_exit(void *mem)
-{
-	dm_pool_destroy(mem);
-}
-
-static void test_get_next(void *fixture)
-{
-	struct dm_pool *mem = fixture;
-
-        int i, j, last = 0, first;
-        dm_bitset_t bs = dm_bitset_create(mem, NR_BITS);
-
-        for (i = 0; i < NR_BITS; i++)
-                T_ASSERT(!dm_bit(bs, i));
-
-        for (i = 0, j = 1; i < NR_BITS; i += j, j++)
-                dm_bit_set(bs, i);
-
-        first = 1;
-        for (i = 0, j = 1; i < NR_BITS; i += j, j++) {
-                if (first) {
-                        last = dm_bit_get_first(bs);
-                        first = 0;
-                } else
-                        last = dm_bit_get_next(bs, last);
-
-                T_ASSERT(last == i);
-        }
-
-        T_ASSERT(dm_bit_get_next(bs, last) == -1);
-}
-
-static void bit_flip(dm_bitset_t bs, int bit)
-{
-        int old = dm_bit(bs, bit);
-        if (old)
-                dm_bit_clear(bs, bit);
-        else
-                dm_bit_set(bs, bit);
-}
-
-static void test_equal(void *fixture)
-{
-	struct dm_pool *mem = fixture;
-        dm_bitset_t bs1 = dm_bitset_create(mem, NR_BITS);
-        dm_bitset_t bs2 = dm_bitset_create(mem, NR_BITS);
-
-        int i, j;
-        for (i = 0, j = 1; i < NR_BITS; i += j, j++) {
-                dm_bit_set(bs1, i);
-                dm_bit_set(bs2, i);
-        }
-
-        T_ASSERT(dm_bitset_equal(bs1, bs2));
-        T_ASSERT(dm_bitset_equal(bs2, bs1));
-
-        for (i = 0; i < NR_BITS; i++) {
-                bit_flip(bs1, i);
-                T_ASSERT(!dm_bitset_equal(bs1, bs2));
-                T_ASSERT(!dm_bitset_equal(bs2, bs1));
-
-                T_ASSERT(dm_bitset_equal(bs1, bs1)); /* comparing with self */
-                bit_flip(bs1, i);
-        }
-}
-
-static void test_and(void *fixture)
-{
-	struct dm_pool *mem = fixture;
-        dm_bitset_t bs1 = dm_bitset_create(mem, NR_BITS);
-        dm_bitset_t bs2 = dm_bitset_create(mem, NR_BITS);
-        dm_bitset_t bs3 = dm_bitset_create(mem, NR_BITS);
-
-        int i, j;
-        for (i = 0, j = 1; i < NR_BITS; i += j, j++) {
-                dm_bit_set(bs1, i);
-                dm_bit_set(bs2, i);
-        }
-
-        dm_bit_and(bs3, bs1, bs2);
-
-        T_ASSERT(dm_bitset_equal(bs1, bs2));
-        T_ASSERT(dm_bitset_equal(bs1, bs3));
-        T_ASSERT(dm_bitset_equal(bs2, bs3));
-
-        dm_bit_clear_all(bs1);
-        dm_bit_clear_all(bs2);
-
-        for (i = 0; i < NR_BITS; i++) {
-                if (i % 2)
-                        dm_bit_set(bs1, i);
-                else
-                        dm_bit_set(bs2, i);
-        }
-
-        dm_bit_and(bs3, bs1, bs2);
-        for (i = 0; i < NR_BITS; i++)
-                T_ASSERT(!dm_bit(bs3, i));
-}
-
-#define T(path, desc, fn) register_test(ts, "/base/data-struct/bitset/" path, desc, fn)
-
-void bitset_tests(struct dm_list *all_tests)
-{
-	struct test_suite *ts = test_suite_create(_mem_init, _mem_exit);
-	if (!ts) {
-		fprintf(stderr, "out of memory\n");
-		exit(1);
-	}
-
-	T("get_next", "get next set bit", test_get_next);
-	T("equal", "equality", test_equal);
-	T("and", "and all bits", test_and);
-
-	dm_list_add(all_tests, &ts->list);
-}
-
diff --git a/unit-test/config_t.c b/unit-test/config_t.c
deleted file mode 100644
index 5331f79..0000000
--- a/unit-test/config_t.c
+++ /dev/null
@@ -1,167 +0,0 @@
-/*
- * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
- */
-
-#include "units.h"
-#include "libdevmapper.h"
-
-static void *_mem_init(void)
-{
-	struct dm_pool *mem = dm_pool_create("config test", 1024);
-	if (!mem) {
-		fprintf(stderr, "out of memory\n");
-		exit(1);
-	}
-
-	return mem;
-}
-
-static void _mem_exit(void *mem)
-{
-	dm_pool_destroy(mem);
-}
-
-static const char *conf =
-	"id = \"yada-yada\"\n"
-	"seqno = 15\n"
-	"status = [\"READ\", \"WRITE\"]\n"
-	"flags = []\n"
-	"extent_size = 8192\n"
-	"physical_volumes {\n"
-	"    pv0 {\n"
-	"        id = \"abcd-efgh\"\n"
-	"    }\n"
-	"    pv1 {\n"
-	"        id = \"bbcd-efgh\"\n"
-	"    }\n"
-	"    pv2 {\n"
-	"        id = \"cbcd-efgh\"\n"
-	"    }\n"
-	"}\n";
-
-static const char *overlay =
-	"id = \"yoda-soda\"\n"
-	"flags = [\"FOO\"]\n"
-	"physical_volumes {\n"
-	"    pv1 {\n"
-	"        id = \"hgfe-dcba\"\n"
-	"    }\n"
-	"    pv3 {\n"
-	"        id = \"dbcd-efgh\"\n"
-	"    }\n"
-	"}\n";
-
-static void test_parse(void *fixture)
-{
-	struct dm_config_tree *tree = dm_config_from_string(conf);
-	const struct dm_config_value *value;
-
-	T_ASSERT((long) tree);
-	T_ASSERT(dm_config_has_node(tree->root, "id"));
-	T_ASSERT(dm_config_has_node(tree->root, "physical_volumes"));
-	T_ASSERT(dm_config_has_node(tree->root, "physical_volumes/pv0"));
-	T_ASSERT(dm_config_has_node(tree->root, "physical_volumes/pv0/id"));
-
-	T_ASSERT(!strcmp(dm_config_find_str(tree->root, "id", "foo"), "yada-yada"));
-	T_ASSERT(!strcmp(dm_config_find_str(tree->root, "idt", "foo"), "foo"));
-
-	T_ASSERT(!strcmp(dm_config_find_str(tree->root, "physical_volumes/pv0/bb", "foo"), "foo"));
-	T_ASSERT(!strcmp(dm_config_find_str(tree->root, "physical_volumes/pv0/id", "foo"), "abcd-efgh"));
-
-	T_ASSERT(!dm_config_get_uint32(tree->root, "id", NULL));
-	T_ASSERT(dm_config_get_uint32(tree->root, "extent_size", NULL));
-
-	/* FIXME: Currently everything parses as a list, even if it's not */
-	// T_ASSERT(!dm_config_get_list(tree->root, "id", NULL));
-	// T_ASSERT(!dm_config_get_list(tree->root, "extent_size", NULL));
-
-	T_ASSERT(dm_config_get_list(tree->root, "flags", &value));
-	T_ASSERT(value->next == NULL); /* an empty list */
-	T_ASSERT(dm_config_get_list(tree->root, "status", &value));
-	T_ASSERT(value->next != NULL); /* a non-empty list */
-
-	dm_config_destroy(tree);
-}
-
-static void test_clone(void *fixture)
-{
-	struct dm_config_tree *tree = dm_config_from_string(conf);
-	struct dm_config_node *n = dm_config_clone_node(tree, tree->root, 1);
-	const struct dm_config_value *value;
-
-	/* Check that the nodes are actually distinct. */
-	T_ASSERT(n != tree->root);
-	T_ASSERT(n->sib != tree->root->sib);
-	T_ASSERT(dm_config_find_node(n, "physical_volumes") != NULL);
-	T_ASSERT(dm_config_find_node(tree->root, "physical_volumes") != NULL);
-	T_ASSERT(dm_config_find_node(n, "physical_volumes") != dm_config_find_node(tree->root, "physical_volumes"));
-
-	T_ASSERT(dm_config_has_node(n, "id"));
-	T_ASSERT(dm_config_has_node(n, "physical_volumes"));
-	T_ASSERT(dm_config_has_node(n, "physical_volumes/pv0"));
-	T_ASSERT(dm_config_has_node(n, "physical_volumes/pv0/id"));
-
-	T_ASSERT(!strcmp(dm_config_find_str(n, "id", "foo"), "yada-yada"));
-	T_ASSERT(!strcmp(dm_config_find_str(n, "idt", "foo"), "foo"));
-
-	T_ASSERT(!strcmp(dm_config_find_str(n, "physical_volumes/pv0/bb", "foo"), "foo"));
-	T_ASSERT(!strcmp(dm_config_find_str(n, "physical_volumes/pv0/id", "foo"), "abcd-efgh"));
-
-	T_ASSERT(!dm_config_get_uint32(n, "id", NULL));
-	T_ASSERT(dm_config_get_uint32(n, "extent_size", NULL));
-
-	/* FIXME: Currently everything parses as a list, even if it's not */
-	// T_ASSERT(!dm_config_get_list(tree->root, "id", NULL));
-	// T_ASSERT(!dm_config_get_list(tree->root, "extent_size", NULL));
-
-	T_ASSERT(dm_config_get_list(n, "flags", &value));
-	T_ASSERT(value->next == NULL); /* an empty list */
-	T_ASSERT(dm_config_get_list(n, "status", &value));
-	T_ASSERT(value->next != NULL); /* a non-empty list */
-
-	dm_config_destroy(tree);
-}
-
-static void test_cascade(void *fixture)
-{
-	struct dm_config_tree *t1 = dm_config_from_string(conf),
-		              *t2 = dm_config_from_string(overlay),
-		              *tree = dm_config_insert_cascaded_tree(t2, t1);
-
-	T_ASSERT(!strcmp(dm_config_tree_find_str(tree, "id", "foo"), "yoda-soda"));
-	T_ASSERT(!strcmp(dm_config_tree_find_str(tree, "idt", "foo"), "foo"));
-
-	T_ASSERT(!strcmp(dm_config_tree_find_str(tree, "physical_volumes/pv0/bb", "foo"), "foo"));
-	T_ASSERT(!strcmp(dm_config_tree_find_str(tree, "physical_volumes/pv1/id", "foo"), "hgfe-dcba"));
-	T_ASSERT(!strcmp(dm_config_tree_find_str(tree, "physical_volumes/pv3/id", "foo"), "dbcd-efgh"));
-
-	dm_config_destroy(t1);
-	dm_config_destroy(t2);
-}
-
-#define T(path, desc, fn) register_test(ts, "/metadata/config/" path, desc, fn)
-
-void config_tests(struct dm_list *all_tests)
-{
-	struct test_suite *ts = test_suite_create(_mem_init, _mem_exit);
-	if (!ts) {
-		fprintf(stderr, "out of memory\n");
-		exit(1);
-	}
-
-	T("parse", "parsing various", test_parse);
-	T("clone", "duplicating a config tree", test_clone);
-	T("cascade", "cascade", test_cascade);
-
-	dm_list_add(all_tests, &ts->list);
-};
diff --git a/unit-test/dmlist_t.c b/unit-test/dmlist_t.c
deleted file mode 100644
index 82789ba..0000000
--- a/unit-test/dmlist_t.c
+++ /dev/null
@@ -1,49 +0,0 @@
-/*
- * Copyright (C) 2015 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
- */
-
-#include "units.h"
-#include "libdevmapper.h"
-
-static void test_dmlist_splice(void *fixture)
-{
-	unsigned i;
-	struct dm_list a[10];
-	struct dm_list list1;
-	struct dm_list list2;
-
-	dm_list_init(&list1);
-	dm_list_init(&list2);
-
-	for (i = 0; i < DM_ARRAY_SIZE@; i++)
-		dm_list_add(&list1, &a[i]);
-
-	dm_list_splice(&list2, &list1);
-	T_ASSERT(dm_list_size(&list1) == 0);
-	T_ASSERT(dm_list_size(&list2) == 10);
-}
-
-#define T(path, desc, fn) register_test(ts, "/base/data-struct/list/" path, desc, fn)
-
-void dm_list_tests(struct dm_list *all_tests)
-{
-	struct test_suite *ts = test_suite_create(NULL, NULL);
-	if (!ts) {
-		fprintf(stderr, "out of memory\n");
-		exit(1);
-	}
-
-	T("splice", "joining lists together", test_dmlist_splice);
-
-	dm_list_add(all_tests, &ts->list);
-}
diff --git a/unit-test/dmstatus_t.c b/unit-test/dmstatus_t.c
deleted file mode 100644
index 4b57f29..0000000
--- a/unit-test/dmstatus_t.c
+++ /dev/null
@@ -1,84 +0,0 @@
-/*
- * Copyright (C) 2015 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
- */
-
-#include "units.h"
-#include "libdevmapper.h"
-
-static void *_mem_init(void)
-{
-	struct dm_pool *mem = dm_pool_create("dmstatus test", 1024);
-	if (!mem) {
-		fprintf(stderr, "out of memory\n");
-		exit(1);
-	}
-
-	return mem;
-}
-
-static void _mem_exit(void *mem)
-{
-	dm_pool_destroy(mem);
-}
-
-static void _test_mirror_status(void *fixture)
-{
-	struct dm_pool *mem = fixture;
-	struct dm_status_mirror *s = NULL;
-
-	T_ASSERT(dm_get_status_mirror(mem,
-				       "2 253:1 253:2 80/81 1 AD 3 disk 253:0 A",
-				       &s));
-	if (s) {
-		T_ASSERT_EQUAL(s->total_regions, 81);
-		T_ASSERT_EQUAL(s->insync_regions, 80);
-		T_ASSERT_EQUAL(s->dev_count, 2);
-		T_ASSERT_EQUAL(s->devs[0].health, 'A');
-		T_ASSERT_EQUAL(s->devs[0].major, 253);
-		T_ASSERT_EQUAL(s->devs[0].minor, 1);
-		T_ASSERT_EQUAL(s->devs[1].health, 'D');
-		T_ASSERT_EQUAL(s->devs[1].major, 253);
-		T_ASSERT_EQUAL(s->devs[1].minor, 2);
-		T_ASSERT_EQUAL(s->log_count, 1);
-		T_ASSERT_EQUAL(s->logs[0].major, 253);
-		T_ASSERT_EQUAL(s->logs[0].minor, 0);
-		T_ASSERT_EQUAL(s->logs[0].health, 'A');
-		T_ASSERT(!strcmp(s->log_type, "disk"));
-	}
-
-	T_ASSERT(dm_get_status_mirror(mem,
-				       "4 253:1 253:2 253:3 253:4 10/10 1 ADFF 1 core",
-				       &s));
-	if (s) {
-		T_ASSERT_EQUAL(s->total_regions, 10);
-		T_ASSERT_EQUAL(s->insync_regions, 10);
-		T_ASSERT_EQUAL(s->dev_count, 4);
-		T_ASSERT_EQUAL(s->devs[3].minor, 4);
-		T_ASSERT_EQUAL(s->devs[3].health, 'F');
-		T_ASSERT_EQUAL(s->log_count, 0);
-		T_ASSERT(!strcmp(s->log_type, "core"));
-	}
-}
-
-void dm_status_tests(struct dm_list *all_tests)
-{
-	struct test_suite *ts = test_suite_create(_mem_init, _mem_exit);
-	if (!ts) {
-		fprintf(stderr, "out of memory\n");
-		exit(1);
-	}
-
-	register_test(ts, "/dm/target/mirror/status", "parsing mirror status", _test_mirror_status);
-	dm_list_add(all_tests, &ts->list);
-}
-
diff --git a/unit-test/framework.c b/unit-test/framework.c
deleted file mode 100644
index de9a8b1..0000000
--- a/unit-test/framework.c
+++ /dev/null
@@ -1,66 +0,0 @@
-#include "framework.h"
-
-/*----------------------------------------------------------------
- * Assertions
- *--------------------------------------------------------------*/
-
-jmp_buf test_k;
-#define TEST_FAILED 1
-
-void test_fail(const char *fmt, ...)
-{
-	va_list ap;
-
-	va_start(ap, fmt);
-	vfprintf(stderr, fmt, ap);
-	va_end(ap);
-	fprintf(stderr, "\n");
-
-	longjmp(test_k, TEST_FAILED);
-}
-
-struct test_suite *test_suite_create(void *(*fixture_init)(void),
-				     void (*fixture_exit)(void *))
-{
-	struct test_suite *ts = malloc(sizeof(*ts));
-	if (ts) {
-		ts->fixture_init = fixture_init;
-		ts->fixture_exit = fixture_exit;
-		dm_list_init(&ts->tests);
-	}
-
-	return ts;
-}
-
-void test_suite_destroy(struct test_suite *ts)
-{
-	struct test_details *td, *tmp;
-
-	dm_list_iterate_items_safe (td, tmp, &ts->tests) {
-		dm_list_del(&td->list);
-		free(td);
-	}
-
-	free(ts);
-}
-
-bool register_test(struct test_suite *ts,
-		   const char *path, const char *desc,
-		   void (*fn)(void *))
-{
-	struct test_details *t = malloc(sizeof(*t));
-	if (!t) {
-		fprintf(stderr, "out of memory\n");
-		return false;
-	}
-
-	t->parent = ts;
-	t->path = path;
-	t->desc = desc;
-	t->fn = fn;
-	dm_list_add(&ts->tests, &t->list);
-
-	return true;
-}
-
-//-----------------------------------------------------------------
diff --git a/unit-test/framework.h b/unit-test/framework.h
deleted file mode 100644
index 5a33ca6..0000000
--- a/unit-test/framework.h
+++ /dev/null
@@ -1,49 +0,0 @@
-#ifndef TEST_UNIT_FRAMEWORK_H
-#define TEST_UNIT_FRAMEWORK_H
-
-#include "libdevmapper.h"
-
-#include <stdbool.h>
-#include <stdint.h>
-#include <setjmp.h>
-
-//-----------------------------------------------------------------
-
-// A test suite gathers a set of tests with a common fixture together.
-struct test_suite {
-	struct dm_list list;
-
-	void *(*fixture_init)(void);
-	void (*fixture_exit)(void *);
-	struct dm_list tests;
-};
-
-struct test_details {
-	struct test_suite *parent;
-	struct dm_list list;
-
-	const char *path;
-	const char *desc;
-	void (*fn)(void *);
-};
-
-struct test_suite *test_suite_create(void *(*fixture_init)(void),
-				     void (*fixture_exit)(void *));
-void test_suite_destroy(struct test_suite *ts);
-
-bool register_test(struct test_suite *ts,
-		   const char *path, const char *desc, void (*fn)(void *));
-
-void test_fail(const char *fmt, ...)
-	__attribute__((noreturn, format (printf, 1, 2)));
-
-#define T_ASSERT(e) do {if (!(e)) {test_fail("assertion failed: '%s'", # e);} } while(0)
-#define T_ASSERT_EQUAL(x, y) T_ASSERT((x) == (y))
-#define T_ASSERT_NOT_EQUAL(x, y) T_ASSERT((x) != (y))
-
-extern jmp_buf test_k;
-#define TEST_FAILED 1
-
-//-----------------------------------------------------------------
-
-#endif
diff --git a/unit-test/io_engine_t.c b/unit-test/io_engine_t.c
deleted file mode 100644
index 6219d79..0000000
--- a/unit-test/io_engine_t.c
+++ /dev/null
@@ -1,145 +0,0 @@
-/*
- * Copyright (C) 2018 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
- */
-
-#define _GNU_SOURCE
-
-#include <errno.h>
-#include <stdio.h>
-#include <stdlib.h>
-#include <sys/types.h>
-#include <sys/stat.h>
-#include <fcntl.h>
-#include <unistd.h>
-
-#include "bcache.h"
-#include "framework.h"
-#include "units.h"
-
-//----------------------------------------------------------------
-
-#define SECTOR_SIZE 512
-#define BLOCK_SIZE_SECTORS 64
-
-struct fixture {
-	struct io_engine *e;
-	void *data;
-
-	char fname[64];
-	int fd;
-};
-
-static void *_fix_init(void)
-{
-        struct fixture *f = malloc(sizeof(*f));
-
-        T_ASSERT(f);
-        f->e = create_async_io_engine();
-        T_ASSERT(f->e);
-        f->data = aligned_alloc(4096, SECTOR_SIZE * BLOCK_SIZE_SECTORS);
-        T_ASSERT(f->data);
-
-        snprintf(f->fname, sizeof(f->fname), "unit-test-XXXXXX");
-	f->fd = mkostemp(f->fname, O_RDWR | O_CREAT | O_EXCL);
-	T_ASSERT(f->fd >= 0);
-
-	memset(f->data, 0, SECTOR_SIZE * BLOCK_SIZE_SECTORS);
-	write(f->fd, f->data, SECTOR_SIZE * BLOCK_SIZE_SECTORS);
-	lseek(f->fd, 0, SEEK_SET);
-        return f;
-}
-
-static void _fix_exit(void *fixture)
-{
-        struct fixture *f = fixture;
-
-	close(f->fd);
-	unlink(f->fname);
-        free(f->data);
-        f->e->destroy(f->e);
-        free(f);
-}
-
-static void _test_create(void *fixture)
-{
-	// empty
-}
-
-struct io {
-	bool completed;
-	int error;
-};
-
-static void _io_init(struct io *io)
-{
-	io->completed = false;
-	io->error = 0;
-}
-
-static void _complete_io(void *context, int io_error)
-{
-	struct io *io = context;
-	io->completed = true;
-	io->error = io_error;
-}
-
-static void _test_read(void *fixture)
-{
-	struct fixture *f = fixture;
-
-	struct io io;
-
-	_io_init(&io);
-	T_ASSERT(f->e->issue(f->e, DIR_READ, f->fd, 0, BLOCK_SIZE_SECTORS, f->data, &io));
-	T_ASSERT(f->e->wait(f->e, _complete_io));
-	T_ASSERT(io.completed);
-	T_ASSERT(!io.error);
-}
-
-static void _test_write(void *fixture)
-{
-	struct fixture *f = fixture;
-
-	struct io io;
-
-	_io_init(&io);
-	T_ASSERT(f->e->issue(f->e, DIR_WRITE, f->fd, 0, BLOCK_SIZE_SECTORS, f->data, &io));
-	T_ASSERT(f->e->wait(f->e, _complete_io));
-	T_ASSERT(io.completed);
-	T_ASSERT(!io.error);
-}
-
-//----------------------------------------------------------------
-
-#define T(path, desc, fn) register_test(ts, "/base/device/bcache/io-engine/" path, desc, fn)
-
-static struct test_suite *_tests(void)
-{
-        struct test_suite *ts = test_suite_create(_fix_init, _fix_exit);
-        if (!ts) {
-                fprintf(stderr, "out of memory\n");
-                exit(1);
-        }
-
-        T("create-destroy", "simple create/destroy", _test_create);
-        T("create-read", "read sanity check", _test_read);
-        T("create-write", "write sanity check", _test_write);
-
-        return ts;
-}
-
-void io_engine_tests(struct dm_list *all_tests)
-{
-	dm_list_add(all_tests, &_tests()->list);
-}
-
diff --git a/unit-test/matcher_data.h b/unit-test/matcher_data.h
deleted file mode 100644
index 97dbbfe..0000000
--- a/unit-test/matcher_data.h
+++ /dev/null
@@ -1,1013 +0,0 @@
-struct check_item {
-	const char *str;
-	int expected;
-};
-
-static const char *dev_patterns[] = {
-	"loop/[0-9]+",
-	"hd[a-d][0-5]+",
-	NULL
-};
-
-static const char *nonprint_patterns[] = {
-	"foo\x80" "bar",
-	"foo\xc2" "b",
-	"\x80",
-	NULL
-};
-
-static const struct check_item nonprint[] = {
-	{ "foo\x2e" "bar", 0 },
-	{ "foo\x80" "bar", 3 },
-	{ "foo\xc2" "b", 2 },
-	{ "\x80", 3 },
-	{ NULL, 0 }
-};
-
-static const char *random_patterns[] = {
-	"(((a?)(([Ub]*)|z))((([qr]|X)+)([Qn]*)))+",
-	"[HZejtuw]*",
-	"((B|s)*)|(((([Fv]l)(N+))(([el]|C)(tJ)))?)",
-	"((([Ma]?)|(t*))*)|((([cm]E)|(M?))|(([BE][EV])|([Qj][Mh])))",
-	"(((([bw]*)|([IO]*))((zK)*))|(((pU)|(i|q))|((z?)|([HL]?))))*",
-	"((([Pt]?)|[Tr])?)((Hq)*)",
-	"[HOXcfgikosvwxz]",
-	"[BCEFGHNPTUWfjlprsy]",
-	"((((aD)*)|([Xo]+))+)(([HKn](([Eq]|[JQ])(I*)))*)",
-	"([LNWYeghv]|e)*",
-	"(((y(L*))*)|((([EP]+)(W+))*))*",
-	"U*",
-	"((((R+)(W|[Qr]))|([py]+))+)([LM]*)",
-	"(([DOjx](D(b?)))|([Ke]*))*",
-	"((([ls](c|[FT]))*)([JS]*))*",
-	"((l?)|(([Gz]+)|(D*)))*",
-	"[ABgjn]",
-	"(((q|[dg])?)|([Uk]*))((([Fl]?)|([Ry]+))|(([IR]|c)|(T?)))",
-	"((([an]|P)|[Jw])((a*)|(m*)))*",
-	"((((R[ht])(h+))?)|(([pz](n?))+))+",
-	"(((([Dc]b)([Sp][Ii]))|((k|F)*))|[Uiovz])*",
-	"[Res]*",
-	"[Zl]|a",
-	"^[ANZdf]$",
-	"[En]|(((Q+)(U+))([pt]*))",
-	"[ADEIMQUWXZhklrsvz]",
-	"(((S(y*))*)|(j*))*",
-	"n*",
-	"[NUau]*",
-	"((((Z*)(D|[Nd]))|(([np]|B)+))|(([Xy][Fi])*))+",
-	"((([EZ]?)|(d[HR]))*)((([Hg]|q)(P+))*)",
-	"q",
-	"((m*)|(p|B))|((((x?)|(t+))(([Sb][PX])(O|[HM])))+)",
-	"((((A*)(z[RS]))*)|(((z+)(Q*))+))*",
-	"(((M*)([Uu]*))+)|[Uk]",
-	"[imv]",
-	"[GLSchtw](([Yw]((F[Dd])|([Tw]+)))?)",
-	"([MOZj]*)(S|[Wknr])",
-	"((G|q)*)[BHKN]",
-	"((((NW)|([Ao]?))|((l|[UV])+))+)|((i|(z*))*)",
-	"((((Z+)|([IR]?))|(L*))|([JKQ]+))+",
-	"([Bdin](S*))+",
-	"[HLNSTp]*",
-	"(((J*)([Bq]|[Yu]))*)|([Kv]*)",
-	"(((([BJ]|[Zy])(wI))*)(y*))+",
-	"(((hF)+)|(H*))*",
-	"((([QU][Pj])([GQ]?))+)|[PWo]",
-	"(((([cq][BX])?)|((f[DI])*))*)(([GM]*)[SVYr])",
-	"(([Zt]*)|((qx)|(([BV]+)(f?))))*",
-	"[ILWYhsx]*",
-	"(([Uy]*)|[sv])|([NSc]*)",
-	"((c*)|([JUfhy]?))+",
-	"(((q*)([So]*))(((g[jq])(j?))+))*",
-	"((b+)|(((T+)([fw]T))?))*",
-	"((([DS]?)|([Th]|u))(Q*))*",
-	"[FKLX]|((([fw](L?))(([gq]*)|(O?)))?)",
-	"((([HZ]+)u)*)|[APWijn]",
-	"(e*)|(((v?)|((J+)(Hb)))?)",
-	"(e|((w+)f))*",
-	"[BEHKPQVdelnqy]",
-	"((((B|N)(s*))|[Rr])(((g?)|([rv]+))+))+",
-	"(((s*)|(K*))([AP]G))*",
-	"[CELTp]",
-	"(([Fq]?)|([Al]+))*",
-	"((((r?)|(y[jx]))|([mp]*))+)|((B(S*))*)",
-	"((([Eq]+)|(Y[ds]))|(x|(i|[Ku])))[IJNrvy]",
-	"((([NO]*)[Ix])+)([Jenq]+)",
-	"(((([HP]*)(j|y))*)[Ylqvy])*",
-	"[PTv]+",
-	"[AINSZhpx]|([EOYZ]*)",
-	"([ABCFQv]*)((([Zx]|h)+)|([ej]*))",
-	"((([pr]*)|(([Dq]|p)|(H?)))?)([NRUXmoq]*)",
-	"(([er]*)|([mx]*))(((nV)([am]?))+)",
-	"[BHPRlpu]",
-	"(((([Ah]|[tx])|(e|[uy]))?)((([fl]+)([Vz]|v))*))*",
-	"[AGdm]",
-	"(((K*)^(O*)$)|(B?))*",
-	"((([Ks]|[Ka])*)|([FSTab]?))?",
-	"(([kw]+)[ei])(([Hy]*)(([Mc]*)|(G|f)))",
-	"((((e*)|(Zf))|(R|[nq]))((([Jz]v)([Rj]+))+))*",
-	"(((a?)|(e?))(([Uc]*)(S+)))*",
-	"((((E+)([MZ]?))+)|(((s|[Az])|z)*))?",
-	"((((i[MO])*)|((LH)*))|(((BA)|([AI]+))|[Ug]))*",
-	"[EGHILcho]*",
-	"(((Z[vw])?)((z|g)+))(((H|U)([iv]Q))|([qw]?))",
-	"(([ehmr]|((L[Uw])*))+)((a+)I)",
-	"[EKNSWYagj](((v|[TX])|([Uk]+))*)",
-	"(((R[Mo])|(O*))|([Fm]|([qw]*)))((m*)|((S|[Ki])?))",
-	"((((kP)|c)?)((([do]+)|([Gi]?))*))*",
-	"((^(B|W)$|([Ww]+))([no]*))|((([iv]?)|(M*))|((x|L)?))",
-	"[AEGPRSbcfhsy]",
-	"[Wbcf]|((([MO]?)|([NT]|m))(([Oo]?)([Wg]*)))",
-	"(((YZ)*)[PQVei])*",
-	"[GJKYt][AEGWdegmnt]",
-	"^[CDEGJKNUVYZagkv]$",
-	"([DPWbx]*)|(((q|B)|(P|u))((M[Bq])*))",
-	"[FHIJRTVYZdiorsuvz]*",
-	"([MWoqvz]*)|^(l*)",
-	"(((I|[Rx])*)((X[Mf])([Xa]L)))([Ha]|([HY]*))",
-	"(((l|[Sd])*)((([Ix]+)|([XY]?))(Z*)))+",
-	NULL
-};
-
-struct check_item devices[] = {
-	{ "/dev", 0 },
-	{ "/dev/.devfsd", 0 },
-	{ "/dev/cpu", 0 },
-	{ "/dev/cpu/mtrr", 0 },
-	{ "/dev/netlink", 0 },
-	{ "/dev/netlink/route", 0 },
-	{ "/dev/netlink/skip", 0 },
-	{ "/dev/netlink/USERSOCK", 0 },
-	{ "/dev/netlink/fwmonitor", 0 },
-	{ "/dev/netlink/ARPD", 0 },
-	{ "/dev/netlink/ROUTE6", 0 },
-	{ "/dev/netlink/IP6_FW", 0 },
-	{ "/dev/netlink/tap0", 0 },
-	{ "/dev/netlink/tap1", 0 },
-	{ "/dev/netlink/tap2", 0 },
-	{ "/dev/netlink/tap3", 0 },
-	{ "/dev/netlink/tap4", 0 },
-	{ "/dev/netlink/tap5", 0 },
-	{ "/dev/netlink/tap6", 0 },
-	{ "/dev/netlink/tap7", 0 },
-	{ "/dev/netlink/tap8", 0 },
-	{ "/dev/netlink/tap9", 0 },
-	{ "/dev/netlink/tap10", 0 },
-	{ "/dev/netlink/tap11", 0 },
-	{ "/dev/netlink/tap12", 0 },
-	{ "/dev/netlink/tap13", 0 },
-	{ "/dev/netlink/tap14", 0 },
-	{ "/dev/netlink/tap15", 0 },
-	{ "/dev/shm", 0 },
-	{ "/dev/mem", 0 },
-	{ "/dev/kmem", 0 },
-	{ "/dev/null", 0 },
-	{ "/dev/port", 0 },
-	{ "/dev/zero", 0 },
-	{ "/dev/full", 0 },
-	{ "/dev/random", 0 },
-	{ "/dev/urandom", 0 },
-	{ "/dev/tty", 0 },
-	{ "/dev/console", 0 },
-	{ "/dev/vc", 0 },
-	{ "/dev/vc/1", 0 },
-	{ "/dev/vc/2", 0 },
-	{ "/dev/vc/3", 0 },
-	{ "/dev/vc/4", 0 },
-	{ "/dev/vc/5", 0 },
-	{ "/dev/vc/6", 0 },
-	{ "/dev/vc/7", 0 },
-	{ "/dev/vc/8", 0 },
-	{ "/dev/vc/9", 0 },
-	{ "/dev/vc/10", 0 },
-	{ "/dev/vc/11", 0 },
-	{ "/dev/vc/12", 0 },
-	{ "/dev/vc/13", 0 },
-	{ "/dev/vc/14", 0 },
-	{ "/dev/vc/15", 0 },
-	{ "/dev/vc/16", 0 },
-	{ "/dev/vc/17", 0 },
-	{ "/dev/vc/18", 0 },
-	{ "/dev/vc/19", 0 },
-	{ "/dev/vc/20", 0 },
-	{ "/dev/vc/21", 0 },
-	{ "/dev/vc/22", 0 },
-	{ "/dev/vc/23", 0 },
-	{ "/dev/vc/24", 0 },
-	{ "/dev/vc/25", 0 },
-	{ "/dev/vc/26", 0 },
-	{ "/dev/vc/27", 0 },
-	{ "/dev/vc/28", 0 },
-	{ "/dev/vc/29", 0 },
-	{ "/dev/vc/30", 0 },
-	{ "/dev/vc/31", 0 },
-	{ "/dev/vc/32", 0 },
-	{ "/dev/vc/33", 0 },
-	{ "/dev/vc/34", 0 },
-	{ "/dev/vc/35", 0 },
-	{ "/dev/vc/36", 0 },
-	{ "/dev/vc/37", 0 },
-	{ "/dev/vc/38", 0 },
-	{ "/dev/vc/39", 0 },
-	{ "/dev/vc/40", 0 },
-	{ "/dev/vc/41", 0 },
-	{ "/dev/vc/42", 0 },
-	{ "/dev/vc/43", 0 },
-	{ "/dev/vc/44", 0 },
-	{ "/dev/vc/45", 0 },
-	{ "/dev/vc/46", 0 },
-	{ "/dev/vc/47", 0 },
-	{ "/dev/vc/48", 0 },
-	{ "/dev/vc/49", 0 },
-	{ "/dev/vc/50", 0 },
-	{ "/dev/vc/51", 0 },
-	{ "/dev/vc/52", 0 },
-	{ "/dev/vc/53", 0 },
-	{ "/dev/vc/54", 0 },
-	{ "/dev/vc/55", 0 },
-	{ "/dev/vc/56", 0 },
-	{ "/dev/vc/57", 0 },
-	{ "/dev/vc/58", 0 },
-	{ "/dev/vc/59", 0 },
-	{ "/dev/vc/60", 0 },
-	{ "/dev/vc/61", 0 },
-	{ "/dev/vc/62", 0 },
-	{ "/dev/vc/63", 0 },
-	{ "/dev/vc/0", 0 },
-	{ "/dev/ptmx", 0 },
-	{ "/dev/misc", 0 },
-	{ "/dev/misc/psaux", 0 },
-	{ "/dev/pty", 0 },
-	{ "/dev/pty/m0", 0 },
-	{ "/dev/pty/m1", 0 },
-	{ "/dev/pty/m2", 0 },
-	{ "/dev/pty/m3", 0 },
-	{ "/dev/pty/m4", 0 },
-	{ "/dev/pty/m5", 0 },
-	{ "/dev/pty/m6", 0 },
-	{ "/dev/pty/m7", 0 },
-	{ "/dev/pty/m8", 0 },
-	{ "/dev/pty/m9", 0 },
-	{ "/dev/pty/m10", 0 },
-	{ "/dev/pty/m11", 0 },
-	{ "/dev/pty/m12", 0 },
-	{ "/dev/pty/m13", 0 },
-	{ "/dev/pty/m14", 0 },
-	{ "/dev/pty/m15", 0 },
-	{ "/dev/pty/m16", 0 },
-	{ "/dev/pty/m17", 0 },
-	{ "/dev/pty/m18", 0 },
-	{ "/dev/pty/m19", 0 },
-	{ "/dev/pty/m20", 0 },
-	{ "/dev/pty/m21", 0 },
-	{ "/dev/pty/m22", 0 },
-	{ "/dev/pty/m23", 0 },
-	{ "/dev/pty/m24", 0 },
-	{ "/dev/pty/m25", 0 },
-	{ "/dev/pty/m26", 0 },
-	{ "/dev/pty/m27", 0 },
-	{ "/dev/pty/m28", 0 },
-	{ "/dev/pty/m29", 0 },
-	{ "/dev/pty/m30", 0 },
-	{ "/dev/pty/m31", 0 },
-	{ "/dev/pty/m32", 0 },
-	{ "/dev/pty/m33", 0 },
-	{ "/dev/pty/m34", 0 },
-	{ "/dev/pty/m35", 0 },
-	{ "/dev/pty/m36", 0 },
-	{ "/dev/pty/m37", 0 },
-	{ "/dev/pty/m38", 0 },
-	{ "/dev/pty/m39", 0 },
-	{ "/dev/pty/m40", 0 },
-	{ "/dev/pty/m41", 0 },
-	{ "/dev/pty/m42", 0 },
-	{ "/dev/pty/m43", 0 },
-	{ "/dev/pty/m44", 0 },
-	{ "/dev/pty/m45", 0 },
-	{ "/dev/pty/m46", 0 },
-	{ "/dev/pty/m47", 0 },
-	{ "/dev/pty/m48", 0 },
-	{ "/dev/pty/m49", 0 },
-	{ "/dev/pty/m50", 0 },
-	{ "/dev/pty/m51", 0 },
-	{ "/dev/pty/m52", 0 },
-	{ "/dev/pty/m53", 0 },
-	{ "/dev/pty/m54", 0 },
-	{ "/dev/pty/m55", 0 },
-	{ "/dev/pty/m56", 0 },
-	{ "/dev/pty/m57", 0 },
-	{ "/dev/pty/m58", 0 },
-	{ "/dev/pty/m59", 0 },
-	{ "/dev/pty/m60", 0 },
-	{ "/dev/pty/m61", 0 },
-	{ "/dev/pty/m62", 0 },
-	{ "/dev/pty/m63", 0 },
-	{ "/dev/pty/m64", 0 },
-	{ "/dev/pty/m65", 0 },
-	{ "/dev/pty/m66", 0 },
-	{ "/dev/pty/m67", 0 },
-	{ "/dev/pty/m68", 0 },
-	{ "/dev/pty/m69", 0 },
-	{ "/dev/pty/m70", 0 },
-	{ "/dev/pty/m71", 0 },
-	{ "/dev/pty/m72", 0 },
-	{ "/dev/pty/m73", 0 },
-	{ "/dev/pty/m74", 0 },
-	{ "/dev/pty/m75", 0 },
-	{ "/dev/pty/m76", 0 },
-	{ "/dev/pty/m77", 0 },
-	{ "/dev/pty/m78", 0 },
-	{ "/dev/pty/m79", 0 },
-	{ "/dev/pty/m80", 0 },
-	{ "/dev/pty/m81", 0 },
-	{ "/dev/pty/m82", 0 },
-	{ "/dev/pty/m83", 0 },
-	{ "/dev/pty/m84", 0 },
-	{ "/dev/pty/m85", 0 },
-	{ "/dev/pty/m86", 0 },
-	{ "/dev/pty/m87", 0 },
-	{ "/dev/pty/m88", 0 },
-	{ "/dev/pty/m89", 0 },
-	{ "/dev/pty/m90", 0 },
-	{ "/dev/pty/m91", 0 },
-	{ "/dev/pty/m92", 0 },
-	{ "/dev/pty/m93", 0 },
-	{ "/dev/pty/m94", 0 },
-	{ "/dev/pty/m95", 0 },
-	{ "/dev/pty/m96", 0 },
-	{ "/dev/pty/m97", 0 },
-	{ "/dev/pty/m98", 0 },
-	{ "/dev/pty/m99", 0 },
-	{ "/dev/pty/m100", 0 },
-	{ "/dev/pty/m101", 0 },
-	{ "/dev/pty/m102", 0 },
-	{ "/dev/pty/m103", 0 },
-	{ "/dev/pty/m104", 0 },
-	{ "/dev/pty/m105", 0 },
-	{ "/dev/pty/m106", 0 },
-	{ "/dev/pty/m107", 0 },
-	{ "/dev/pty/m108", 0 },
-	{ "/dev/pty/m109", 0 },
-	{ "/dev/pty/m110", 0 },
-	{ "/dev/pty/m111", 0 },
-	{ "/dev/pty/m112", 0 },
-	{ "/dev/pty/m113", 0 },
-	{ "/dev/pty/m114", 0 },
-	{ "/dev/pty/m115", 0 },
-	{ "/dev/pty/m116", 0 },
-	{ "/dev/pty/m117", 0 },
-	{ "/dev/pty/m118", 0 },
-	{ "/dev/pty/m119", 0 },
-	{ "/dev/pty/m120", 0 },
-	{ "/dev/pty/m121", 0 },
-	{ "/dev/pty/m122", 0 },
-	{ "/dev/pty/m123", 0 },
-	{ "/dev/pty/m124", 0 },
-	{ "/dev/pty/m125", 0 },
-	{ "/dev/pty/m126", 0 },
-	{ "/dev/pty/m127", 0 },
-	{ "/dev/pty/m128", 0 },
-	{ "/dev/pty/m129", 0 },
-	{ "/dev/pty/m130", 0 },
-	{ "/dev/pty/m131", 0 },
-	{ "/dev/pty/m132", 0 },
-	{ "/dev/pty/m133", 0 },
-	{ "/dev/pty/m134", 0 },
-	{ "/dev/pty/m135", 0 },
-	{ "/dev/pty/m136", 0 },
-	{ "/dev/pty/m137", 0 },
-	{ "/dev/pty/m138", 0 },
-	{ "/dev/pty/m139", 0 },
-	{ "/dev/pty/m140", 0 },
-	{ "/dev/pty/m141", 0 },
-	{ "/dev/pty/m142", 0 },
-	{ "/dev/pty/m143", 0 },
-	{ "/dev/pty/m144", 0 },
-	{ "/dev/pty/m145", 0 },
-	{ "/dev/pty/m146", 0 },
-	{ "/dev/pty/m147", 0 },
-	{ "/dev/pty/m148", 0 },
-	{ "/dev/pty/m149", 0 },
-	{ "/dev/pty/m150", 0 },
-	{ "/dev/pty/m151", 0 },
-	{ "/dev/pty/m152", 0 },
-	{ "/dev/pty/m153", 0 },
-	{ "/dev/pty/m154", 0 },
-	{ "/dev/pty/m155", 0 },
-	{ "/dev/pty/m156", 0 },
-	{ "/dev/pty/m157", 0 },
-	{ "/dev/pty/m158", 0 },
-	{ "/dev/pty/m159", 0 },
-	{ "/dev/pty/m160", 0 },
-	{ "/dev/pty/m161", 0 },
-	{ "/dev/pty/m162", 0 },
-	{ "/dev/pty/m163", 0 },
-	{ "/dev/pty/m164", 0 },
-	{ "/dev/pty/m165", 0 },
-	{ "/dev/pty/m166", 0 },
-	{ "/dev/pty/m167", 0 },
-	{ "/dev/pty/m168", 0 },
-	{ "/dev/pty/m169", 0 },
-	{ "/dev/pty/m170", 0 },
-	{ "/dev/pty/m171", 0 },
-	{ "/dev/pty/m172", 0 },
-	{ "/dev/pty/m173", 0 },
-	{ "/dev/pty/m174", 0 },
-	{ "/dev/pty/m175", 0 },
-	{ "/dev/pty/m176", 0 },
-	{ "/dev/pty/m177", 0 },
-	{ "/dev/pty/m178", 0 },
-	{ "/dev/pty/m179", 0 },
-	{ "/dev/pty/m180", 0 },
-	{ "/dev/pty/m181", 0 },
-	{ "/dev/pty/m182", 0 },
-	{ "/dev/pty/m183", 0 },
-	{ "/dev/pty/m184", 0 },
-	{ "/dev/pty/m185", 0 },
-	{ "/dev/pty/m186", 0 },
-	{ "/dev/pty/m187", 0 },
-	{ "/dev/pty/m188", 0 },
-	{ "/dev/pty/m189", 0 },
-	{ "/dev/pty/m190", 0 },
-	{ "/dev/pty/m191", 0 },
-	{ "/dev/pty/m192", 0 },
-	{ "/dev/pty/m193", 0 },
-	{ "/dev/pty/m194", 0 },
-	{ "/dev/pty/m195", 0 },
-	{ "/dev/pty/m196", 0 },
-	{ "/dev/pty/m197", 0 },
-	{ "/dev/pty/m198", 0 },
-	{ "/dev/pty/m199", 0 },
-	{ "/dev/pty/m200", 0 },
-	{ "/dev/pty/m201", 0 },
-	{ "/dev/pty/m202", 0 },
-	{ "/dev/pty/m203", 0 },
-	{ "/dev/pty/m204", 0 },
-	{ "/dev/pty/m205", 0 },
-	{ "/dev/pty/m206", 0 },
-	{ "/dev/pty/m207", 0 },
-	{ "/dev/pty/m208", 0 },
-	{ "/dev/pty/m209", 0 },
-	{ "/dev/pty/m210", 0 },
-	{ "/dev/pty/m211", 0 },
-	{ "/dev/pty/m212", 0 },
-	{ "/dev/pty/m213", 0 },
-	{ "/dev/pty/m214", 0 },
-	{ "/dev/pty/m215", 0 },
-	{ "/dev/pty/m216", 0 },
-	{ "/dev/pty/m217", 0 },
-	{ "/dev/pty/m218", 0 },
-	{ "/dev/pty/m219", 0 },
-	{ "/dev/pty/m220", 0 },
-	{ "/dev/pty/m221", 0 },
-	{ "/dev/pty/m222", 0 },
-	{ "/dev/pty/m223", 0 },
-	{ "/dev/pty/m224", 0 },
-	{ "/dev/pty/m225", 0 },
-	{ "/dev/pty/m226", 0 },
-	{ "/dev/pty/m227", 0 },
-	{ "/dev/pty/m228", 0 },
-	{ "/dev/pty/m229", 0 },
-	{ "/dev/pty/m230", 0 },
-	{ "/dev/pty/m231", 0 },
-	{ "/dev/pty/m232", 0 },
-	{ "/dev/pty/m233", 0 },
-	{ "/dev/pty/m234", 0 },
-	{ "/dev/pty/m235", 0 },
-	{ "/dev/pty/m236", 0 },
-	{ "/dev/pty/m237", 0 },
-	{ "/dev/pty/m238", 0 },
-	{ "/dev/pty/m239", 0 },
-	{ "/dev/pty/m240", 0 },
-	{ "/dev/pty/m241", 0 },
-	{ "/dev/pty/m242", 0 },
-	{ "/dev/pty/m243", 0 },
-	{ "/dev/pty/m244", 0 },
-	{ "/dev/pty/m245", 0 },
-	{ "/dev/pty/m246", 0 },
-	{ "/dev/pty/m247", 0 },
-	{ "/dev/pty/m248", 0 },
-	{ "/dev/pty/m249", 0 },
-	{ "/dev/pty/m250", 0 },
-	{ "/dev/pty/m251", 0 },
-	{ "/dev/pty/m252", 0 },
-	{ "/dev/pty/m253", 0 },
-	{ "/dev/pty/m254", 0 },
-	{ "/dev/pty/m255", 0 },
-	{ "/dev/pts", 0 },
-	{ "/dev/pts/0", 0 },
-	{ "/dev/pts/1", 0 },
-	{ "/dev/pts/2", 0 },
-	{ "/dev/pts/3", 0 },
-	{ "/dev/pts/4", 0 },
-	{ "/dev/pts/5", 0 },
-	{ "/dev/pts/6", 0 },
-	{ "/dev/pts/7", 0 },
-	{ "/dev/vcc", 0 },
-	{ "/dev/vcc/0", 0 },
-	{ "/dev/vcc/a", 0 },
-	{ "/dev/vcc/1", 0 },
-	{ "/dev/vcc/a1", 0 },
-	{ "/dev/vcc/2", 0 },
-	{ "/dev/vcc/a2", 0 },
-	{ "/dev/vcc/3", 0 },
-	{ "/dev/vcc/a3", 0 },
-	{ "/dev/vcc/5", 0 },
-	{ "/dev/vcc/a5", 0 },
-	{ "/dev/vcc/4", 0 },
-	{ "/dev/vcc/a4", 0 },
-	{ "/dev/vcc/6", 0 },
-	{ "/dev/vcc/a6", 0 },
-	{ "/dev/vcc/7", 0 },
-	{ "/dev/vcc/a7", 0 },
-	{ "/dev/tts", 0 },
-	{ "/dev/tts/0", 0 },
-	{ "/dev/cua", 0 },
-	{ "/dev/cua/0", 0 },
-	{ "/dev/ide", 0 },
-	{ "/dev/ide/host0", 0 },
-	{ "/dev/ide/host0/bus0", 0 },
-	{ "/dev/ide/host0/bus0/target0", 0 },
-	{ "/dev/ide/host0/bus0/target0/lun0", 0 },
-	{ "/dev/ide/host0/bus0/target0/lun0/disc", 0 },
-	{ "/dev/ide/host0/bus0/target0/lun0/part1", 0 },
-	{ "/dev/ide/host0/bus0/target0/lun0/part2", 0 },
-	{ "/dev/ide/host0/bus0/target0/lun0/part3", 0 },
-	{ "/dev/ide/host0/bus0/target0/lun0/part4", 0 },
-	{ "/dev/ide/host0/bus0/target0/lun0/part5", 0 },
-	{ "/dev/ide/host0/bus0/target0/lun0/part6", 0 },
-	{ "/dev/ide/host0/bus0/target0/lun0/part7", 0 },
-	{ "/dev/ide/host0/bus0/target0/lun0/part8", 0 },
-	{ "/dev/ide/host0/bus0/target1", 0 },
-	{ "/dev/ide/host0/bus0/target1/lun0", 0 },
-	{ "/dev/ide/host0/bus0/target1/lun0/disc", 0 },
-	{ "/dev/ide/host0/bus0/target1/lun0/part1", 0 },
-	{ "/dev/ide/host0/bus1", 0 },
-	{ "/dev/ide/host0/bus1/target0", 0 },
-	{ "/dev/ide/host0/bus1/target0/lun0", 0 },
-	{ "/dev/ide/host0/bus1/target0/lun0/disc", 0 },
-	{ "/dev/ide/host0/bus1/target0/lun0/part1", 0 },
-	{ "/dev/ide/host0/bus1/target1", 0 },
-	{ "/dev/ide/host0/bus1/target1/lun0", 0 },
-	{ "/dev/discs", 0 },
-	{ "/dev/discs/disc0", 0 },
-	{ "/dev/discs/disc1", 0 },
-	{ "/dev/discs/disc2", 0 },
-	{ "/dev/floppy", 0 },
-	{ "/dev/floppy/0u1440", 0 },
-	{ "/dev/floppy/0u1680", 0 },
-	{ "/dev/floppy/0u1722", 0 },
-	{ "/dev/floppy/0u1743", 0 },
-	{ "/dev/floppy/0u1760", 0 },
-	{ "/dev/floppy/0u1920", 0 },
-	{ "/dev/floppy/0u1840", 0 },
-	{ "/dev/floppy/0u1600", 0 },
-	{ "/dev/floppy/0u360", 0 },
-	{ "/dev/floppy/0u720", 0 },
-	{ "/dev/floppy/0u820", 0 },
-	{ "/dev/floppy/0u830", 0 },
-	{ "/dev/floppy/0u1040", 0 },
-	{ "/dev/floppy/0u1120", 0 },
-	{ "/dev/floppy/0u800", 0 },
-	{ "/dev/floppy/0", 0 },
-	{ "/dev/loop", 0 },
-	{ "/dev/loop/0", 1 },
-	{ "/dev/loop/1", 1 },
-	{ "/dev/loop/2", 1 },
-	{ "/dev/loop/3", 1 },
-	{ "/dev/loop/4", 1 },
-	{ "/dev/loop/5", 1 },
-	{ "/dev/loop/6", 1 },
-	{ "/dev/loop/7", 1 },
-	{ "/dev/cdroms", 0 },
-	{ "/dev/sound", 0 },
-	{ "/dev/sound/dsp", 0 },
-	{ "/dev/sound/dsp1", 0 },
-	{ "/dev/sound/mixer", 0 },
-	{ "/dev/sound/midi", 0 },
-	{ "/dev/usb", 0 },
-	{ "/dev/root", 0 },
-	{ "/dev/initctl", 0 },
-	{ "/dev/xconsole", 0 },
-	{ "/dev/fd", 0 },
-	{ "/dev/stdin", 0 },
-	{ "/dev/stdout", 0 },
-	{ "/dev/stderr", 0 },
-	{ "/dev/route", 0 },
-	{ "/dev/skip", 0 },
-	{ "/dev/USERSOCK", 0 },
-	{ "/dev/fwmonitor", 0 },
-	{ "/dev/ARPD", 0 },
-	{ "/dev/ROUTE6", 0 },
-	{ "/dev/IP6_FW", 0 },
-	{ "/dev/tap0", 0 },
-	{ "/dev/tap1", 0 },
-	{ "/dev/tap2", 0 },
-	{ "/dev/tap3", 0 },
-	{ "/dev/tap4", 0 },
-	{ "/dev/tap5", 0 },
-	{ "/dev/tap6", 0 },
-	{ "/dev/tap7", 0 },
-	{ "/dev/tap8", 0 },
-	{ "/dev/tap9", 0 },
-	{ "/dev/tap10", 0 },
-	{ "/dev/tap11", 0 },
-	{ "/dev/tap12", 0 },
-	{ "/dev/tap13", 0 },
-	{ "/dev/tap14", 0 },
-	{ "/dev/tap15", 0 },
-	{ "/dev/tty1", 0 },
-	{ "/dev/tty2", 0 },
-	{ "/dev/tty3", 0 },
-	{ "/dev/tty4", 0 },
-	{ "/dev/tty5", 0 },
-	{ "/dev/tty6", 0 },
-	{ "/dev/tty7", 0 },
-	{ "/dev/tty8", 0 },
-	{ "/dev/tty9", 0 },
-	{ "/dev/tty10", 0 },
-	{ "/dev/tty11", 0 },
-	{ "/dev/tty12", 0 },
-	{ "/dev/tty13", 0 },
-	{ "/dev/tty14", 0 },
-	{ "/dev/tty15", 0 },
-	{ "/dev/tty16", 0 },
-	{ "/dev/tty17", 0 },
-	{ "/dev/tty18", 0 },
-	{ "/dev/tty19", 0 },
-	{ "/dev/tty20", 0 },
-	{ "/dev/tty21", 0 },
-	{ "/dev/tty22", 0 },
-	{ "/dev/tty23", 0 },
-	{ "/dev/tty24", 0 },
-	{ "/dev/tty25", 0 },
-	{ "/dev/tty26", 0 },
-	{ "/dev/tty27", 0 },
-	{ "/dev/tty28", 0 },
-	{ "/dev/tty29", 0 },
-	{ "/dev/tty30", 0 },
-	{ "/dev/tty31", 0 },
-	{ "/dev/tty32", 0 },
-	{ "/dev/tty33", 0 },
-	{ "/dev/tty34", 0 },
-	{ "/dev/tty35", 0 },
-	{ "/dev/tty36", 0 },
-	{ "/dev/tty37", 0 },
-	{ "/dev/tty38", 0 },
-	{ "/dev/tty39", 0 },
-	{ "/dev/tty40", 0 },
-	{ "/dev/tty41", 0 },
-	{ "/dev/tty42", 0 },
-	{ "/dev/tty43", 0 },
-	{ "/dev/tty44", 0 },
-	{ "/dev/tty45", 0 },
-	{ "/dev/tty46", 0 },
-	{ "/dev/tty47", 0 },
-	{ "/dev/tty48", 0 },
-	{ "/dev/tty49", 0 },
-	{ "/dev/tty50", 0 },
-	{ "/dev/tty51", 0 },
-	{ "/dev/tty52", 0 },
-	{ "/dev/tty53", 0 },
-	{ "/dev/tty54", 0 },
-	{ "/dev/tty55", 0 },
-	{ "/dev/tty56", 0 },
-	{ "/dev/tty57", 0 },
-	{ "/dev/tty58", 0 },
-	{ "/dev/tty59", 0 },
-	{ "/dev/tty60", 0 },
-	{ "/dev/tty61", 0 },
-	{ "/dev/tty62", 0 },
-	{ "/dev/tty63", 0 },
-	{ "/dev/tty0", 0 },
-	{ "/dev/psaux", 0 },
-	{ "/dev/ptyp0", 0 },
-	{ "/dev/ptyp1", 0 },
-	{ "/dev/ptyp2", 0 },
-	{ "/dev/ptyp3", 0 },
-	{ "/dev/ptyp4", 0 },
-	{ "/dev/ptyp5", 0 },
-	{ "/dev/ptyp6", 0 },
-	{ "/dev/ptyp7", 0 },
-	{ "/dev/ptyp8", 0 },
-	{ "/dev/ptyp9", 0 },
-	{ "/dev/ptypa", 0 },
-	{ "/dev/ptypb", 0 },
-	{ "/dev/ptypc", 0 },
-	{ "/dev/ptypd", 0 },
-	{ "/dev/ptype", 0 },
-	{ "/dev/ptypf", 0 },
-	{ "/dev/ptyq0", 0 },
-	{ "/dev/ptyq1", 0 },
-	{ "/dev/ptyq2", 0 },
-	{ "/dev/ptyq3", 0 },
-	{ "/dev/ptyq4", 0 },
-	{ "/dev/ptyq5", 0 },
-	{ "/dev/ptyq6", 0 },
-	{ "/dev/ptyq7", 0 },
-	{ "/dev/ptyq8", 0 },
-	{ "/dev/ptyq9", 0 },
-	{ "/dev/ptyqa", 0 },
-	{ "/dev/ptyqb", 0 },
-	{ "/dev/ptyqc", 0 },
-	{ "/dev/ptyqd", 0 },
-	{ "/dev/ptyqe", 0 },
-	{ "/dev/ptyqf", 0 },
-	{ "/dev/ptyr0", 0 },
-	{ "/dev/ptyr1", 0 },
-	{ "/dev/ptyr2", 0 },
-	{ "/dev/ptyr3", 0 },
-	{ "/dev/ptyr4", 0 },
-	{ "/dev/ptyr5", 0 },
-	{ "/dev/ptyr6", 0 },
-	{ "/dev/ptyr7", 0 },
-	{ "/dev/ptyr8", 0 },
-	{ "/dev/ptyr9", 0 },
-	{ "/dev/ptyra", 0 },
-	{ "/dev/ptyrb", 0 },
-	{ "/dev/ptyrc", 0 },
-	{ "/dev/ptyrd", 0 },
-	{ "/dev/ptyre", 0 },
-	{ "/dev/ptyrf", 0 },
-	{ "/dev/ptys0", 0 },
-	{ "/dev/ptys1", 0 },
-	{ "/dev/ptys2", 0 },
-	{ "/dev/ptys3", 0 },
-	{ "/dev/ptys4", 0 },
-	{ "/dev/ptys5", 0 },
-	{ "/dev/ptys6", 0 },
-	{ "/dev/ptys7", 0 },
-	{ "/dev/ptys8", 0 },
-	{ "/dev/ptys9", 0 },
-	{ "/dev/ptysa", 0 },
-	{ "/dev/ptysb", 0 },
-	{ "/dev/ptysc", 0 },
-	{ "/dev/ptysd", 0 },
-	{ "/dev/ptyse", 0 },
-	{ "/dev/ptysf", 0 },
-	{ "/dev/ptyt0", 0 },
-	{ "/dev/ptyt1", 0 },
-	{ "/dev/ptyt2", 0 },
-	{ "/dev/ptyt3", 0 },
-	{ "/dev/ptyt4", 0 },
-	{ "/dev/ptyt5", 0 },
-	{ "/dev/ptyt6", 0 },
-	{ "/dev/ptyt7", 0 },
-	{ "/dev/ptyt8", 0 },
-	{ "/dev/ptyt9", 0 },
-	{ "/dev/ptyta", 0 },
-	{ "/dev/ptytb", 0 },
-	{ "/dev/ptytc", 0 },
-	{ "/dev/ptytd", 0 },
-	{ "/dev/ptyte", 0 },
-	{ "/dev/ptytf", 0 },
-	{ "/dev/ptyu0", 0 },
-	{ "/dev/ptyu1", 0 },
-	{ "/dev/ptyu2", 0 },
-	{ "/dev/ptyu3", 0 },
-	{ "/dev/ptyu4", 0 },
-	{ "/dev/ptyu5", 0 },
-	{ "/dev/ptyu6", 0 },
-	{ "/dev/ptyu7", 0 },
-	{ "/dev/ptyu8", 0 },
-	{ "/dev/ptyu9", 0 },
-	{ "/dev/ptyua", 0 },
-	{ "/dev/ptyub", 0 },
-	{ "/dev/ptyuc", 0 },
-	{ "/dev/ptyud", 0 },
-	{ "/dev/ptyue", 0 },
-	{ "/dev/ptyuf", 0 },
-	{ "/dev/ptyv0", 0 },
-	{ "/dev/ptyv1", 0 },
-	{ "/dev/ptyv2", 0 },
-	{ "/dev/ptyv3", 0 },
-	{ "/dev/ptyv4", 0 },
-	{ "/dev/ptyv5", 0 },
-	{ "/dev/ptyv6", 0 },
-	{ "/dev/ptyv7", 0 },
-	{ "/dev/ptyv8", 0 },
-	{ "/dev/ptyv9", 0 },
-	{ "/dev/ptyva", 0 },
-	{ "/dev/ptyvb", 0 },
-	{ "/dev/ptyvc", 0 },
-	{ "/dev/ptyvd", 0 },
-	{ "/dev/ptyve", 0 },
-	{ "/dev/ptyvf", 0 },
-	{ "/dev/ptyw0", 0 },
-	{ "/dev/ptyw1", 0 },
-	{ "/dev/ptyw2", 0 },
-	{ "/dev/ptyw3", 0 },
-	{ "/dev/ptyw4", 0 },
-	{ "/dev/ptyw5", 0 },
-	{ "/dev/ptyw6", 0 },
-	{ "/dev/ptyw7", 0 },
-	{ "/dev/ptyw8", 0 },
-	{ "/dev/ptyw9", 0 },
-	{ "/dev/ptywa", 0 },
-	{ "/dev/ptywb", 0 },
-	{ "/dev/ptywc", 0 },
-	{ "/dev/ptywd", 0 },
-	{ "/dev/ptywe", 0 },
-	{ "/dev/ptywf", 0 },
-	{ "/dev/ptyx0", 0 },
-	{ "/dev/ptyx1", 0 },
-	{ "/dev/ptyx2", 0 },
-	{ "/dev/ptyx3", 0 },
-	{ "/dev/ptyx4", 0 },
-	{ "/dev/ptyx5", 0 },
-	{ "/dev/ptyx6", 0 },
-	{ "/dev/ptyx7", 0 },
-	{ "/dev/ptyx8", 0 },
-	{ "/dev/ptyx9", 0 },
-	{ "/dev/ptyxa", 0 },
-	{ "/dev/ptyxb", 0 },
-	{ "/dev/ptyxc", 0 },
-	{ "/dev/ptyxd", 0 },
-	{ "/dev/ptyxe", 0 },
-	{ "/dev/ptyxf", 0 },
-	{ "/dev/ptyy0", 0 },
-	{ "/dev/ptyy1", 0 },
-	{ "/dev/ptyy2", 0 },
-	{ "/dev/ptyy3", 0 },
-	{ "/dev/ptyy4", 0 },
-	{ "/dev/ptyy5", 0 },
-	{ "/dev/ptyy6", 0 },
-	{ "/dev/ptyy7", 0 },
-	{ "/dev/ptyy8", 0 },
-	{ "/dev/ptyy9", 0 },
-	{ "/dev/ptyya", 0 },
-	{ "/dev/ptyyb", 0 },
-	{ "/dev/ptyyc", 0 },
-	{ "/dev/ptyyd", 0 },
-	{ "/dev/ptyye", 0 },
-	{ "/dev/ptyyf", 0 },
-	{ "/dev/ptyz0", 0 },
-	{ "/dev/ptyz1", 0 },
-	{ "/dev/ptyz2", 0 },
-	{ "/dev/ptyz3", 0 },
-	{ "/dev/ptyz4", 0 },
-	{ "/dev/ptyz5", 0 },
-	{ "/dev/ptyz6", 0 },
-	{ "/dev/ptyz7", 0 },
-	{ "/dev/ptyz8", 0 },
-	{ "/dev/ptyz9", 0 },
-	{ "/dev/ptyza", 0 },
-	{ "/dev/ptyzb", 0 },
-	{ "/dev/ptyzc", 0 },
-	{ "/dev/ptyzd", 0 },
-	{ "/dev/ptyze", 0 },
-	{ "/dev/ptyzf", 0 },
-	{ "/dev/ptya0", 0 },
-	{ "/dev/ptya1", 0 },
-	{ "/dev/ptya2", 0 },
-	{ "/dev/ptya3", 0 },
-	{ "/dev/ptya4", 0 },
-	{ "/dev/ptya5", 0 },
-	{ "/dev/ptya6", 0 },
-	{ "/dev/ptya7", 0 },
-	{ "/dev/ptya8", 0 },
-	{ "/dev/ptya9", 0 },
-	{ "/dev/ptyaa", 0 },
-	{ "/dev/ptyab", 0 },
-	{ "/dev/ptyac", 0 },
-	{ "/dev/ptyad", 0 },
-	{ "/dev/ptyae", 0 },
-	{ "/dev/ptyaf", 0 },
-	{ "/dev/ptyb0", 0 },
-	{ "/dev/ptyb1", 0 },
-	{ "/dev/ptyb2", 0 },
-	{ "/dev/ptyb3", 0 },
-	{ "/dev/ptyb4", 0 },
-	{ "/dev/ptyb5", 0 },
-	{ "/dev/ptyb6", 0 },
-	{ "/dev/ptyb7", 0 },
-	{ "/dev/ptyb8", 0 },
-	{ "/dev/ptyb9", 0 },
-	{ "/dev/ptyba", 0 },
-	{ "/dev/ptybb", 0 },
-	{ "/dev/ptybc", 0 },
-	{ "/dev/ptybd", 0 },
-	{ "/dev/ptybe", 0 },
-	{ "/dev/ptybf", 0 },
-	{ "/dev/ptyc0", 0 },
-	{ "/dev/ptyc1", 0 },
-	{ "/dev/ptyc2", 0 },
-	{ "/dev/ptyc3", 0 },
-	{ "/dev/ptyc4", 0 },
-	{ "/dev/ptyc5", 0 },
-	{ "/dev/ptyc6", 0 },
-	{ "/dev/ptyc7", 0 },
-	{ "/dev/ptyc8", 0 },
-	{ "/dev/ptyc9", 0 },
-	{ "/dev/ptyca", 0 },
-	{ "/dev/ptycb", 0 },
-	{ "/dev/ptycc", 0 },
-	{ "/dev/ptycd", 0 },
-	{ "/dev/ptyce", 0 },
-	{ "/dev/ptycf", 0 },
-	{ "/dev/ptyd0", 0 },
-	{ "/dev/ptyd1", 0 },
-	{ "/dev/ptyd2", 0 },
-	{ "/dev/ptyd3", 0 },
-	{ "/dev/ptyd4", 0 },
-	{ "/dev/ptyd5", 0 },
-	{ "/dev/ptyd6", 0 },
-	{ "/dev/ptyd7", 0 },
-	{ "/dev/ptyd8", 0 },
-	{ "/dev/ptyd9", 0 },
-	{ "/dev/ptyda", 0 },
-	{ "/dev/ptydb", 0 },
-	{ "/dev/ptydc", 0 },
-	{ "/dev/ptydd", 0 },
-	{ "/dev/ptyde", 0 },
-	{ "/dev/ptydf", 0 },
-	{ "/dev/ptye0", 0 },
-	{ "/dev/ptye1", 0 },
-	{ "/dev/ptye2", 0 },
-	{ "/dev/ptye3", 0 },
-	{ "/dev/ptye4", 0 },
-	{ "/dev/ptye5", 0 },
-	{ "/dev/ptye6", 0 },
-	{ "/dev/ptye7", 0 },
-	{ "/dev/ptye8", 0 },
-	{ "/dev/ptye9", 0 },
-	{ "/dev/ptyea", 0 },
-	{ "/dev/ptyeb", 0 },
-	{ "/dev/ptyec", 0 },
-	{ "/dev/ptyed", 0 },
-	{ "/dev/ptyee", 0 },
-	{ "/dev/ptyef", 0 },
-	{ "/dev/vcs", 0 },
-	{ "/dev/vcsa", 0 },
-	{ "/dev/vcs1", 0 },
-	{ "/dev/vcsa1", 0 },
-	{ "/dev/ttyS0", 0 },
-	{ "/dev/cua0", 0 },
-	{ "/dev/hda", 0 },
-	{ "/dev/hda1", 2 },
-	{ "/dev/hda2", 2 },
-	{ "/dev/hda3", 2 },
-	{ "/dev/hda4", 2 },
-	{ "/dev/hda5", 2 },
-	{ "/dev/hda6", 0 },
-	{ "/dev/hda7", 0 },
-	{ "/dev/hda8", 0 },
-	{ "/dev/hdb", 0 },
-	{ "/dev/hdb1", 2 },
-	{ "/dev/hdc", 0 },
-	{ "/dev/hdc1", 2 },
-	{ "/dev/fd0u1440", 0 },
-	{ "/dev/fd0u1680", 0 },
-	{ "/dev/fd0u1722", 0 },
-	{ "/dev/fd0u1743", 0 },
-	{ "/dev/fd0u1760", 0 },
-	{ "/dev/fd0u1920", 0 },
-	{ "/dev/fd0u1840", 0 },
-	{ "/dev/fd0u1600", 0 },
-	{ "/dev/fd0u360", 0 },
-	{ "/dev/fd0u720", 0 },
-	{ "/dev/fd0u820", 0 },
-	{ "/dev/fd0u830", 0 },
-	{ "/dev/fd0u1040", 0 },
-	{ "/dev/fd0u1120", 0 },
-	{ "/dev/fd0u800", 0 },
-	{ "/dev/fd0", 0 },
-	{ "/dev/loop0", 0 },
-	{ "/dev/loop1", 0 },
-	{ "/dev/loop2", 0 },
-	{ "/dev/loop3", 0 },
-	{ "/dev/loop4", 0 },
-	{ "/dev/loop5", 0 },
-	{ "/dev/loop6", 0 },
-	{ "/dev/loop7", 0 },
-	{ "/dev/dsp", 0 },
-	{ "/dev/dsp1", 0 },
-	{ "/dev/mixer", 0 },
-	{ "/dev/midi", 0 },
-	{ "/dev/lvm", 0 },
-	{ "/dev/vg0", 0 },
-	{ "/dev/vg0/group", 0 },
-	{ "/dev/vg0/packages", 0 },
-	{ "/dev/vg0/photos", 0 },
-	{ "/dev/vg0/music", 0 },
-	{ "/dev/log", 0 },
-	{ "/dev/MAKEDEV", 0 },
-	{ "/dev/printer", 0 },
-	{ "/dev/vcs2", 0 },
-	{ "/dev/vcsa2", 0 },
-	{ "/dev/vcs3", 0 },
-	{ "/dev/vcsa3", 0 },
-	{ "/dev/vcs5", 0 },
-	{ "/dev/vcsa5", 0 },
-	{ "/dev/vcs4", 0 },
-	{ "/dev/vcsa4", 0 },
-	{ "/dev/vcs6", 0 },
-	{ "/dev/vcsa6", 0 },
-	{ "/dev/nvidia0", 0 },
-	{ "/dev/nvidia1", 0 },
-	{ "/dev/nvidia2", 0 },
-	{ "/dev/nvidia3", 0 },
-	{ "/dev/nvidiactl", 0 },
-	{ "/dev/vcs7", 0 },
-	{ "/dev/vcsa7", 0 },
-	{ NULL, 0 }
-};
diff --git a/unit-test/matcher_t.c b/unit-test/matcher_t.c
deleted file mode 100644
index a5eb5f9..0000000
--- a/unit-test/matcher_t.c
+++ /dev/null
@@ -1,89 +0,0 @@
-/*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
- */
-
-#include "units.h"
-#include "libdevmapper.h"
-
-#include "matcher_data.h"
-
-static void *_mem_init(void)
-{
-	struct dm_pool *mem = dm_pool_create("bitset test", 1024);
-	if (!mem) {
-		fprintf(stderr, "out of memory");
-		exit(1);
-	}
-
-	return mem;
-}
-
-static void _mem_exit(void *mem)
-{
-	dm_pool_destroy(mem);
-}
-
-static struct dm_regex *make_scanner(struct dm_pool *mem, const char **rx)
-{
-	struct dm_regex *scanner;
-	int nrx = 0;
-	for (; rx[nrx]; ++nrx);
-
-	scanner = dm_regex_create(mem, rx, nrx);
-	T_ASSERT(scanner != NULL);
-	return scanner;
-}
-
-static void test_fingerprints(void *fixture)
-{
-	struct dm_pool *mem = fixture;
-	struct dm_regex *scanner;
-
-	scanner = make_scanner(mem, dev_patterns);
-	T_ASSERT_EQUAL(dm_regex_fingerprint(scanner), 0x7f556c09);
-
-	scanner = make_scanner(mem, random_patterns);
-	T_ASSERT_EQUAL(dm_regex_fingerprint(scanner), 0x9f11076c);
-}
-
-static void test_matching(void *fixture)
-{
-	struct dm_pool *mem = fixture;
-	struct dm_regex *scanner;
-	int i;
-
-	scanner = make_scanner(mem, dev_patterns);
-	for (i = 0; devices[i].str; ++i)
-		T_ASSERT_EQUAL(dm_regex_match(scanner, devices[i].str), devices[i].expected - 1);
-
-	scanner = make_scanner(mem, nonprint_patterns);
-	for (i = 0; nonprint[i].str; ++i)
-		T_ASSERT_EQUAL(dm_regex_match(scanner, nonprint[i].str), nonprint[i].expected - 1);
-}
-
-#define T(path, desc, fn) register_test(ts, "/base/regex/" path, desc, fn)
-
-void regex_tests(struct dm_list *all_tests)
-{
-	struct test_suite *ts = test_suite_create(_mem_init, _mem_exit);
-	if (!ts) {
-		fprintf(stderr, "out of memory\n");
-		exit(1);
-	}
-
-	T("fingerprints", "not sure", test_fingerprints);
-	T("matching", "test the matcher with a variety of regexes", test_matching);
-
-	dm_list_add(all_tests, &ts->list);
-}
diff --git a/unit-test/percent_t.c b/unit-test/percent_t.c
deleted file mode 100644
index 84dd3bd..0000000
--- a/unit-test/percent_t.c
+++ /dev/null
@@ -1,102 +0,0 @@
-/*
- * Copyright (C) 2017 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
- */
-
-#include "units.h"
-#include "libdevmapper.h"
-
-#include <stdio.h>
-#include <string.h>
-
-static void test_percent_100(void *fixture)
-{
-	char buf[32];
-
-        /* Check 100% is shown only for DM_PERCENT_100*/
-	dm_percent_t p_100 = dm_make_percent(100, 100);
-        dm_percent_t p1_100 = dm_make_percent(100000, 100000);
-        dm_percent_t n_100 = dm_make_percent(999999, 1000000);
-
-	T_ASSERT_EQUAL(p_100, DM_PERCENT_100);
-	T_ASSERT_EQUAL(p1_100, DM_PERCENT_100);
-	T_ASSERT_NOT_EQUAL(n_100, DM_PERCENT_100);
-
-        dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(p_100));
-	T_ASSERT_EQUAL(strcmp(buf, "100.00"), 0);
-
-	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(p1_100));
-	T_ASSERT_EQUAL(strcmp(buf, "100.00"), 0);
-
-	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(n_100));
-	T_ASSERT_NOT_EQUAL(strcmp(buf, "99.99"), 0); /* Would like to gett */
-
-	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_round_float(n_100, 2));
-	T_ASSERT_EQUAL(strcmp(buf, "99.99"), 0);
-
-	dm_snprintf(buf, sizeof(buf), "%.3f", dm_percent_to_round_float(n_100, 3));
-	T_ASSERT_EQUAL(strcmp(buf, "99.999"), 0);
-
-	dm_snprintf(buf, sizeof(buf), "%.4f", dm_percent_to_round_float(n_100, 4));
-	T_ASSERT_EQUAL(strcmp(buf, "99.9999"), 0);
-
-	dm_snprintf(buf, sizeof(buf), "%d", (int)dm_percent_to_round_float(n_100, 0));
-	T_ASSERT_EQUAL(strcmp(buf, "99"), 0);
-}
-
-static void test_percent_0(void *fixture)
-{
-	char buf[32];
-
-	/* Check 0% is shown only for DM_PERCENT_0 */
-	dm_percent_t p_0 = dm_make_percent(0, 100);
-        dm_percent_t p1_0 = dm_make_percent(0, 100000);
-        dm_percent_t n_0 = dm_make_percent(1, 1000000);
-
-	T_ASSERT_EQUAL(p_0, DM_PERCENT_0);
-	T_ASSERT_EQUAL(p1_0, DM_PERCENT_0);
-	T_ASSERT_NOT_EQUAL(n_0, DM_PERCENT_0);
-
-        dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(p_0));
-	T_ASSERT_EQUAL(strcmp(buf, "0.00"), 0);
-
-	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(p1_0));
-	T_ASSERT_EQUAL(strcmp(buf, "0.00"), 0);
-
-	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(n_0));
-	T_ASSERT_NOT_EQUAL(strcmp(buf, "0.01"), 0);
-
-	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_round_float(n_0, 2));
-	T_ASSERT_EQUAL(strcmp(buf, "0.01"), 0);
-
-	dm_snprintf(buf, sizeof(buf), "%.3f", dm_percent_to_round_float(n_0, 3));
-	T_ASSERT_EQUAL(strcmp(buf, "0.001"), 0);
-
-	dm_snprintf(buf, sizeof(buf), "%d", (int)dm_percent_to_round_float(n_0, 0));
-	T_ASSERT_EQUAL(strcmp(buf, "1"), 0);
-}
-
-#define T(path, desc, fn) register_test(ts, "/base/formatting/percent/" path, desc, fn)
-
-void percent_tests(struct dm_list *all_tests)
-{
-	struct test_suite *ts = test_suite_create(NULL, NULL);
-	if (!ts) {
-		fprintf(stderr, "out of memory\n");
-		exit(1);
-	}
-
-	T("100", "Pretty printing of percentages near 100%", test_percent_100);
-	T("0", "Pretty printing of percentages near 0%", test_percent_0);
-
-	dm_list_add(all_tests, &ts->list);
-}
diff --git a/unit-test/run.c b/unit-test/run.c
deleted file mode 100644
index 9cbb605..0000000
--- a/unit-test/run.c
+++ /dev/null
@@ -1,309 +0,0 @@
-#include "units.h"
-
-#include <getopt.h>
-#include <regex.h>
-#include <stdio.h>
-#include <stdlib.h>
-#include <setjmp.h>
-#include <unistd.h>
-
-//-----------------------------------------------------------------
-
-#define MAX_COMPONENTS 16
-
-struct token {
-	const char *b, *e;
-};
-
-static bool _pop_component(const char *path, struct token *result)
-{
-	const char *b, *e;
-
-	while (*path && *path == '/')
-		path++;
-
-	b = path;
-	while (*path && (*path != '/'))
-		path++;
-	e = path;
-
-	if (b == e)
-		return false;
-
-	result->b = b;
-	result->e = e;
-	return true;
-}
-
-static unsigned _split_components(const char *path, struct token *toks, unsigned len)
-{
-	unsigned count = 0;
-	struct token tok;
-	tok.e = path;
-
-	while (len && _pop_component(tok.e, &tok)) {
-		*toks = tok;
-		toks++;
-		count++;
-		len--;
-	}
-
-	return count;
-}
-
-static void _indent(FILE *stream, unsigned count)
-{
-	unsigned i;
-
-	for (i = 0; i < count; i++)
-		fprintf(stream, "  ");
-}
-
-static void _print_token(FILE *stream, struct token *t)
-{
-	const char *ptr;
-
-	for (ptr = t->b; ptr != t->e; ptr++)
-		fprintf(stream, "%c", *ptr);
-}
-
-static int _char_cmp(char l, char r)
-{
-	if (l < r)
-		return -1;
-
-	else if (r < l)
-		return 1;
-
-	else
-		return 0;
-}
-
-static int _tok_cmp(struct token *lhs, struct token *rhs)
-{
-	const char *l = lhs->b, *le = lhs->e;
-	const char *r = rhs->b, *re = rhs->e;
-
-	while ((l != le) && (r != re) && (*l == *r)) {
-		l++;
-		r++;
-	}
-
-	if ((l != le) && (r != re))
-		return _char_cmp(*l, *r);
-
-	else if (r != re)
-		return -1;
-
-	else if (l != le)
-		return 1;
-
-	else
-		return 0;
-}
-
-static void _print_path_delta(FILE *stream,
-			      struct token *old, unsigned old_len,
-			      struct token *new, unsigned new_len,
-			      const char *desc)
-{
-	unsigned i, common_prefix = 0, len, d;
-	unsigned max_prefix = old_len < new_len ? old_len : new_len;
-
-	for (i = 0; i < max_prefix; i++) {
-		if (_tok_cmp(old + i, new + i))
-			break;
-		else
-			common_prefix++;
-	}
-
-	for (; i < new_len; i++) {
-		_indent(stream, common_prefix);
-		_print_token(stream, new + i);
-		common_prefix++;
-		if (i < new_len - 1)
-			fprintf(stream, "\n");
-	}
-
-	len = common_prefix * 2 + (new[new_len - 1].e - new[new_len - 1].b);
-	fprintf(stream, "  ");
-	for (d = len; d < 60; d++)
-		fprintf(stream, ".");
-	fprintf(stream, "  ");
-	fprintf(stream, "%s", desc);
-	fprintf(stream, "\n");
-}
-
-typedef struct token comp_t[MAX_COMPONENTS];
-
-static void _list_tests(struct test_details **tests, unsigned nr)
-{
-	unsigned i, current = 0, current_len, last_len = 0;
-
-	comp_t components[2];
-
-	for (i = 0; i < nr; i++) {
-		struct test_details *t = tests[i];
-		current_len = _split_components(t->path, components[current], MAX_COMPONENTS);
-		_print_path_delta(stderr, components[!current], last_len,
-				  components[current], current_len, t->desc);
-
-		last_len = current_len;
-		current = !current;
-	}
-}
-
-static void _destroy_tests(struct dm_list *suites)
-{
-	struct test_suite *ts, *tmp;
-
-	dm_list_iterate_items_safe (ts, tmp, suites)
-		test_suite_destroy(ts);
-}
-
-static const char *red(bool c)
-{
-	return c ? "\x1B[31m" : "";
-}
-
-static const char *green(bool c)
-{
-	return c ? "\x1B[32m" : "";
-}
-
-static const char *normal(bool c)
-{
-	return c ? "\x1B[0m" : "";
-}
-
-static void _run_test(struct test_details *t, bool use_colour, unsigned *passed, unsigned *total)
-{
-	void *fixture;
-	struct test_suite *ts = t->parent;
-	fprintf(stderr, "[RUN    ] %s\n", t->path);
-
-	(*total)++;
-	if (setjmp(test_k))
-		fprintf(stderr, "%s[   FAIL]%s %s\n", red(use_colour), normal(use_colour), t->path);
-	else {
-		if (ts->fixture_init)
-			fixture = ts->fixture_init();
-		else
-			fixture = NULL;
-
-		t->fn(fixture);
-
-		if (ts->fixture_exit)
-			ts->fixture_exit(fixture);
-
-		(*passed)++;
-		fprintf(stderr, "%s[     OK]%s\n", green(use_colour), normal(use_colour));
-	}
-}
-
-static bool _run_tests(struct test_details **tests, unsigned nr)
-{
-	bool use_colour = isatty(fileno(stderr));
-	unsigned i, passed = 0, total = 0;
-
-	for (i = 0; i < nr; i++)
-		_run_test(tests[i], use_colour, &passed, &total);
-
-	fprintf(stderr, "\n%u/%u tests passed\n", passed, total);
-
-	return passed == total;
-}
-
-static void _usage(void)
-{
-	fprintf(stderr, "Usage: unit-test <list|run> [pattern]\n");
-}
-
-static int _cmp_paths(const void *lhs, const void *rhs)
-{
-	struct test_details *l = *((struct test_details **) lhs);
-	struct test_details *r = *((struct test_details **) rhs);
-
-	return strcmp(l->path, r->path);
-}
-
-static unsigned _filter(const char *pattern, struct test_details **tests, unsigned nr)
-{
-	unsigned i, found = 0;
-	regex_t rx;
-
-	if (regcomp(&rx, pattern, 0)) {
-		fprintf(stderr, "couldn't compile regex '%s'\n", pattern);
-		exit(1);
-	}
-
-	for (i = 0; i < nr; i++)
-		if (!regexec(&rx, tests[i]->path, 0, NULL, 0))
-			tests[found++] = tests[i];
-
-	regfree(&rx);
-
-	return found;
-}
-
-int main(int argc, char **argv)
-{
-	int r;
-	unsigned i, nr_tests;
-	struct test_suite *ts;
-	struct test_details *t, **t_array;
-	struct dm_list suites;
-
-	dm_list_init(&suites);
-	register_all_tests(&suites);
-
-	// count all tests
-	nr_tests = 0;
-	dm_list_iterate_items (ts, &suites)
-		dm_list_iterate_items (t, &ts->tests)
-			nr_tests++;
-
-	// stick them in an array
-	t_array = malloc(sizeof(*t_array) * nr_tests);
-	if (!t_array) {
-		fprintf(stderr, "out of memory\n");
-		exit(1);
-	}
-
-	i = 0;
-	dm_list_iterate_items (ts, &suites)
-		dm_list_iterate_items (t, &ts->tests)
-			t_array[i++] = t;
-
-	// filter
-	if (argc == 3)
-		nr_tests = _filter(argv[2], t_array, nr_tests);
-
-	// sort
-	qsort(t_array, nr_tests, sizeof(*t_array), _cmp_paths);
-
-	// run or list them
-	if (argc == 1)
-		r = !_run_tests(t_array, nr_tests);
-	else {
-		const char *cmd = argv[1];
-		if (!strcmp(cmd, "run"))
-			r = !_run_tests(t_array, nr_tests);
-
-		else if (!strcmp(cmd, "list")) {
-			_list_tests(t_array, nr_tests);
-			r = 0;
-
-		} else {
-			_usage();
-			r = 1;
-		}
-	}
-
-	free(t_array);
-	_destroy_tests(&suites);
-
-	return r;
-}
-
-//-----------------------------------------------------------------
diff --git a/unit-test/string_t.c b/unit-test/string_t.c
deleted file mode 100644
index 2af0f37..0000000
--- a/unit-test/string_t.c
+++ /dev/null
@@ -1,91 +0,0 @@
-/*
- * Copyright (C) 2012 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
- */
-
-#include "units.h"
-#include "libdevmapper.h"
-
-#include <stdio.h>
-#include <string.h>
-
-#if 0
-static int _mem_init(void)
-{
-	struct dm_pool *mem = dm_pool_create("string test", 1024);
-	if (!mem) {
-		fprintf(stderr, "out of memory\n");
-		exit(1);
-	}
-
-	return mem;
-}
-
-static void _mem_exit(void *mem)
-{
-	dm_pool_destroy(mem);
-}
-
-/* TODO: Add more string unit tests here */
-#endif
-
-static void test_strncpy(void *fixture)
-{
-	const char st[] = "1234567890";
-	char buf[sizeof(st)];
-
-	T_ASSERT_EQUAL(dm_strncpy(buf, st, sizeof(buf)), 1);
-	T_ASSERT_EQUAL(strcmp(buf, st), 0);
-
-	T_ASSERT_EQUAL(dm_strncpy(buf, st, sizeof(buf) - 1), 0);
-	T_ASSERT_EQUAL(strlen(buf) + 1, sizeof(buf) - 1);
-}
-
-static void test_asprint(void *fixture)
-{
-	const char st0[] = "";
-	const char st1[] = "12345678901";
-	const char st2[] = "1234567890123456789012345678901234567890123456789012345678901234567";
-	char *buf;
-	int a;
-
-	a = dm_asprintf(&buf, "%s", st0);
-	T_ASSERT_EQUAL(strcmp(buf, st0), 0);
-	T_ASSERT_EQUAL(a, sizeof(st0));
-	free(buf);
-
-	a = dm_asprintf(&buf, "%s", st1);
-	T_ASSERT_EQUAL(strcmp(buf, st1), 0);
-	T_ASSERT_EQUAL(a, sizeof(st1));
-	free(buf);
-
-	a = dm_asprintf(&buf, "%s", st2);
-	T_ASSERT_EQUAL(a, sizeof(st2));
-	T_ASSERT_EQUAL(strcmp(buf, st2), 0);
-	free(buf);
-}
-
-#define T(path, desc, fn) register_test(ts, "/base/data-struct/string/" path, desc, fn)
-
-void string_tests(struct dm_list *all_tests)
-{
-	struct test_suite *ts = test_suite_create(NULL, NULL);
-	if (!ts) {
-		fprintf(stderr, "out of memory\n");
-		exit(1);
-	}
-
-	T("asprint", "tests asprint", test_asprint);
-	T("strncpy", "tests string copying", test_strncpy);
-
-	dm_list_add(all_tests, &ts->list);
-}
diff --git a/unit-test/units.h b/unit-test/units.h
deleted file mode 100644
index dbbd41e..0000000
--- a/unit-test/units.h
+++ /dev/null
@@ -1,48 +0,0 @@
-/*
- * Copyright (C) 2018 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
- */
-
-#ifndef TEST_UNIT_UNITS_H
-#define TEST_UNIT_UNITS_H
-
-#include "framework.h"
-
-//-----------------------------------------------------------------
-
-// Declare the function that adds tests suites here ...
-void bcache_tests(struct dm_list *suites);
-void bitset_tests(struct dm_list *suites);
-void config_tests(struct dm_list *suites);
-void dm_list_tests(struct dm_list *suites);
-void dm_status_tests(struct dm_list *suites);
-void io_engine_tests(struct dm_list *suites);
-void regex_tests(struct dm_list *suites);
-void percent_tests(struct dm_list *suites);
-void string_tests(struct dm_list *suites);
-
-// ... and call it in here.
-static inline void register_all_tests(struct dm_list *suites)
-{
-	bcache_tests(suites);
-	bitset_tests(suites);
-	config_tests(suites);
-	dm_list_tests(suites);
-	dm_status_tests(suites);
-	io_engine_tests(suites);
-	regex_tests(suites);
-	percent_tests(suites);
-	string_tests(suites);
-}
-
-//-----------------------------------------------------------------
-#endif


