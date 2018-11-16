From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Nov 2018 18:33:11 -0500
Subject: master - tests: secure data erase
Message-ID: <201811162333.wAGNXBHh016119@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=83d9ea73486c92a48725648d2ee2b5fac2fb6b5c
Commit:        83d9ea73486c92a48725648d2ee2b5fac2fb6b5c
Parent:        55a8d6c86b4c6c6c707cfcc3dd887bca0632114f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 16 22:15:23 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 17 00:30:50 2018 +0100

tests: secure data erase

---
 test/Makefile.in           |   15 +++++++--
 test/lib/dmsecuretest.c    |   73 ++++++++++++++++++++++++++++++++++++++++++++
 test/shell/dmsecuretest.sh |   71 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 156 insertions(+), 3 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index f8571b7..6b6749a 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -28,7 +28,7 @@ datarootdir = @datarootdir@
 LVM_TEST_RESULTS ?= results
 
 # FIXME: resolve testing of: unit
-SOURCES = lib/not.c lib/harness.c
+SOURCES = lib/not.c lib/harness.c lib/dmsecuretest.c
 CXXSOURCES = lib/runner.cpp
 CXXFLAGS += $(EXTRA_EXEC_CFLAGS)
 
@@ -190,6 +190,8 @@ LIB_LVMLOCKD_CONF = \
 LIB_MKE2FS_CONF = \
   mke2fs.conf
 
+LIB_SECURETEST = securetest
+LIB_DMSECURETEST = dmsecuretest
 LIB_LOCAL = paths runner
 LIB_NOT = not
 LIB_LINK_NOT = invalid fail should
@@ -217,7 +219,7 @@ install: .tests-stamp lib/paths-installed
 	@cd $(DATADIR)/lib && for i in $(CMDS); do \
 		echo "$(LN_S) -f lvm-wrapper $$i"; \
 		$(LN_S) -f lvm-wrapper $$i; done
-	$(INSTALL_PROGRAM) lib/$(LIB_NOT) $(EXECDIR)
+	$(INSTALL_PROGRAM) lib/$(LIB_NOT) lib/$(LIB_SECURETEST) lib/$(LIB_DMSECURETEST) $(EXECDIR)
 	@cd $(EXECDIR) && for i in $(LIB_LINK_NOT); do \
 		echo "$(LN_S) -f not $$i"; \
 		$(LN_S) -f not $$i; done
@@ -235,9 +237,16 @@ lib/fail: lib/not
 lib/runner: lib/runner.o .lib-dir-stamp
 	$(CXX) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $<
 
+lib/dmsecuretest: lib/dmsecuretest.o .lib-dir-stamp $(INTERNAL_LIBS)
+	$(CC) -g $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $< $(INTERNAL_LIBS) $(UDEV_LIBS) -lm
+
+lib/securetest: lib/dmsecuretest.o .lib-dir-stamp
+	$(CC) -g $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $< -L$(top_builddir)/libdm/ioctl -ldevmapper
+
 lib/runner.o: $(wildcard $(srcdir)/lib/*.h)
 
 CFLAGS_runner.o += $(EXTRA_EXEC_CFLAGS)
+CFLAGS_dmsecuretest.o += $(EXTRA_EXEC_CFLAGS)
 
 lib/%: lib/%.o .lib-dir-stamp
 	$(CC) $(CFLAGS) $(LDFLAGS) $(ELDFLAGS) -o $@ $<
@@ -290,7 +299,7 @@ lib/dm-version-expected: $(top_srcdir)/VERSION_DM .lib-dir-stamp
 	cut -f 1 -d ' ' <$< >$@
 
 CMDS = lvm $(shell cat $(top_builddir)/tools/.commands 2>/dev/null)
-LIB = $(addprefix lib/, $(LIB_SHARED) $(LIB_LOCAL) $(LIB_NOT) $(LIB_LINK_NOT) $(LIB_FLAVOURS))
+LIB = $(addprefix lib/, $(LIB_SECURETEST) $(LIB_DMSECURETEST) $(LIB_SHARED) $(LIB_LOCAL) $(LIB_NOT) $(LIB_LINK_NOT) $(LIB_FLAVOURS))
 
 .tests-stamp: $(ALL) $(LIB) $(SUBDIRS) lib/version-expected lib/dm-version-expected
 	@if test "$(srcdir)" != . ; then \
diff --git a/test/lib/dmsecuretest.c b/test/lib/dmsecuretest.c
new file mode 100644
index 0000000..0428fac
--- /dev/null
+++ b/test/lib/dmsecuretest.c
@@ -0,0 +1,73 @@
+/*
+ * Test sample code to check for leftovers from secure table loading in
+ * userspace memory
+ *
+ * Compile with:  gcc -O2 -g -o tst dmcrypt.c -ldevmapper
+ *
+ * Search for string in coredump (needs 'raise', or using 'gcore' tool)
+ *
+ * grep "434e0cbab02ca68ffba9268222c3789d703fe62427b78b308518b3228f6a2122" core
+ *
+ */
+
+#include <unistd.h>
+#include <signal.h>
+#include <libdevmapper.h>
+
+/* Comment out this define to get coredump instead of sleeping */
+#define SLEEP 1
+
+static void rot13(char *s)
+{
+	unsigned i;
+
+	for (i = 0; s[i]; i++)
+		if (s[i] >= 'a' && s[i] <= 'm')
+			s[i] += 13;
+		else if (s[i] >= 'n' && s[i] <= 'z')
+			s[i] -= 13;
+}
+
+int main (int argc, char *argv[])
+{
+	const unsigned sz = 8192;
+	/* rot13: 434e0cbab02ca68ffba9268222c3789d703fe62427b78b308518b3228f6a2122  */
+	char aes[] = "434r0pono02pn68sson9268222p3789q703sr62427o78o308518o3228s6n2122";
+	const char *device = (argc > 1) ? argv[1] : "/dev/loop0";  /* device for use */
+	const char *devname = (argc > 2) ? argv[2] : "test-secure"; /* name of dm device */
+	uint32_t cookie = 0;
+	char table[300];
+	struct dm_task *dmt;
+
+	if (geteuid() != 0) {
+		fprintf(stderr, "Needs root UID for execution!\n");
+		exit(1);
+	}
+
+	printf("Going to create %s dm device using backend device: %s\n", devname, device);
+
+	if ((dmt = dm_task_create(DM_DEVICE_CREATE))) {
+		(void) dm_task_set_name(dmt, devname);
+		(void) dm_task_secure_data(dmt);
+		rot13(aes);
+		snprintf(table, sizeof(table), "aes-xts-plain64 %s 0 %s %u", aes, device, sz);
+		memset(aes, 0, sizeof(aes));
+		(void) dm_task_add_target(dmt, 0, sz, "crypt", table);
+		memset(table, 0, sizeof(table));
+		asm volatile ("" ::: "memory");/* Compiler barrier. */
+		(void) dm_task_set_cookie(dmt, &cookie, DM_UDEV_DISABLE_LIBRARY_FALLBACK);
+		(void) dm_task_run(dmt);
+		(void) dm_task_destroy(dmt);
+	}
+
+	dm_task_update_nodes();
+
+	/* At this point there should be no memory trace from a secure table line */
+
+#ifdef SLEEP
+	sleep(4);	/* Give time to other process to capture  'gcore pid' */
+#else
+	raise(SIGABRT); /* Generate core for search of any forgotten traces of key */
+#endif
+	return 0;
+}
diff --git a/test/shell/dmsecuretest.sh b/test/shell/dmsecuretest.sh
new file mode 100644
index 0000000..45abd00
--- /dev/null
+++ b/test/shell/dmsecuretest.sh
@@ -0,0 +1,71 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Test secure table is not leaking data in user land
+
+SKIP_WITH_LVMPOLLD=1
+
+# AES key matching rot13 string from dmsecuretest.c */
+SECURE="434e0cbab02ca68ffba9268222c3789d703fe62427b78b308518b3228f6a2122"
+
+. lib/inittest
+
+DMTEST="${PREFIX}-test-secure"
+
+aux driver_at_least 4 6 || skip
+
+# ensure we can create devices (uses dmsetup, etc)
+aux prepare_devs 1
+
+# check both code versions - linked libdm  and internal device_mapper version
+# there should not be any difference
+for i in securetest dmsecuretest ; do
+
+# 1st. try with empty table
+# 2nd. retry with already exiting DM node - exercize error path also wipes
+for j in empty existing ; do
+
+"$i" "$dev1" "$DMTEST" >cmdout 2>&1 &
+PID=$!
+sleep .5
+
+# crypt device should be loaded
+dmsetup table | tee tbl
+grep "$DMTEST" tbl
+
+# generate core file for running&sleeping binary
+gcore "$PID"
+kill "$PID"
+wait
+
+cat cmdout
+
+# $SECURE string must NOT be present in core file
+not grep "$SECURE" "core.$PID" || {
+	## cp "core.$PID" /dev/shm/core
+	rm -f "core.$PID"
+        dmsetup remove "$DMTEST"
+	die "!!! Secure string $SECURE found present in core.$PID !!!"
+}
+rm -f "core.$PID"
+
+if test "$j" = empty ; then
+	not grep "Device or resource busy" cmdout
+else
+	# Device should be already present resulting into error message
+	grep "Device or resource busy" cmdout
+	dmsetup remove "$DMTEST"
+fi
+
+done
+
+done


