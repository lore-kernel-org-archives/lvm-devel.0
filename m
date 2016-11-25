From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 25 Nov 2016 23:23:21 +0000 (UTC)
Subject: master - tests: ensure there is dbus config file
Message-ID: <20161125232321.8625B60CD3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b0bda090054db75995ea350f55b59ae8444690da
Commit:        b0bda090054db75995ea350f55b59ae8444690da
Parent:        4a59cfaa1d4ffbaa46a762422b5439e9f7ce476a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 26 00:17:40 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 26 00:22:38 2016 +0100

tests: ensure there is dbus config file

Copy lvmdbusd.profile to lib as installed place.
Use  TESTOLDPWD and avoid add new 'same' variable test_data_dir.
---
 test/Makefile.in                    |    7 +++----
 test/api/dbustest.sh                |   12 ++++++++----
 test/shell/thin-foreign-dmeventd.sh |    2 +-
 3 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index bc501d1..f152868 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -233,7 +233,7 @@ install: .tests-stamp lib/paths-installed
 		dm-version-expected \
 		version-expected \
 		$(DATADIR)/lib
-	@for i in cache-mq cache-smq thin-performance ; do \
+	@for i in cache-mq cache-smq thin-performance lvmdbusd ; do \
 		echo "$(INSTALL_DATA) $(abs_top_srcdir)/conf/$$i.profile $(DATADIR)/lib"; \
 		$(INSTALL_DATA) $(abs_top_srcdir)/conf/$$i.profile $(DATADIR)/lib; done
 	cd lib && $(INSTALL_SCRIPT) $(LIB_SHARED) $(DATADIR)/lib
@@ -295,14 +295,12 @@ lib/paths-installed: lib/paths-common
 	$(RM) $@-t
 	cat lib/paths-common > $@-t
 	echo 'installed_testsuite=1' >> $@-t
-	echo 'test_data_dir="@datadir@/lvm2-testsuite"' >> $@-t
 	echo 'export PATH=@libexecdir@/lvm2-testsuite:@datadir@/lvm2-testsuite/lib:@datadir@/lvm2-testsuite/api:$$PATH' >> $@-t
 	mv $@-t $@
 
 lib/paths: lib/paths-common
 	$(RM) $@-t
 	cat lib/paths-common > $@-t
-	echo 'test_data_dir="$(abs_top_builddir)/test"' >> $@-t
 	echo 'top_srcdir="$(top_srcdir)"' >> $@-t
 	echo 'abs_top_builddir="$(abs_top_builddir)"' >> $@-t
 	echo 'abs_top_srcdir="$(abs_top_srcdir)"' >> $@-t
@@ -338,6 +336,7 @@ LIB = $(addprefix lib/, $(LIB_SHARED) $(LIB_LOCAL) $(LIB_NOT) $(LIB_LINK_NOT) $(
 		daemons/lvmpolld/lvmpolld ; do \
 		$(LN_S) -f $(abs_top_builddir)/$$i lib/; done
 	$(LN_S) -f $(abs_top_builddir)/tools/dmsetup lib/dmstats
+	$(LN_S) -f $(abs_top_srcdir)/conf/lvmdbusd.profile lib/
 	$(LN_S) -f $(abs_top_srcdir)/conf/thin-performance.profile lib/
 	$(LN_S) -f $(abs_top_srcdir)/scripts/fsadm.sh lib/fsadm
 	test "$(srcdir)" = . || for i in $(LIB_LVMLOCKD_CONF); do \
@@ -351,7 +350,7 @@ endif
 
 CLEAN_TARGETS += .lib-dir-stamp .tests-stamp $(LIB) $(addprefix lib/,\
 	$(CMDS) clvmd dmeventd dmsetup dmstats lvmetad lvmpolld \
-	harness thin-performance.profile fsadm \
+	harness lvmdbusd.profile thin-performance.profile fsadm \
 	dm-version-expected version-expected \
 	paths-installed paths-installed-t paths-common paths-common-t)
 
diff --git a/test/api/dbustest.sh b/test/api/dbustest.sh
index 5ffe967..681e399 100644
--- a/test/api/dbustest.sh
+++ b/test/api/dbustest.sh
@@ -20,13 +20,17 @@ aux prepare_pvs 6
 
 # We need the lvmdbusd.profile for the daemon to utilize JSON
 # output
-mkdir -p $TESTDIR/etc/profile/
-cp -v $TESTOLDPWD/../conf/lvmdbusd.profile $TESTDIR/etc/profile/.
+mkdir -p "$TESTDIR/etc/profile"
+cp -v "$TESTOLDPWD/lib/lvmdbusd.profile" "$TESTDIR/etc/profile/"
 
 # Need to set this up so that the lvmdbusd service knows which
 # binary to be running, which should be the one we just built
-export LVM_BINARY=$TESTOLDPWD/../tools/lvm
+export LVM_BINARY=$(which lvm 2>/dev/null)
+# skip if we don't have our own lvmetad...
+if test -z "${installed_testsuite+varset}"; then
+	(echo "$LVM_BINARY" | grep -q "$abs_builddir") || skip
+fi
 
 aux prepare_lvmdbusd
 
-$test_data_dir/dbus/lvmdbustest.py -v
+$TESTOLDPWD/dbus/lvmdbustest.py -v
diff --git a/test/shell/thin-foreign-dmeventd.sh b/test/shell/thin-foreign-dmeventd.sh
index 5d7488e..50ff44e 100644
--- a/test/shell/thin-foreign-dmeventd.sh
+++ b/test/shell/thin-foreign-dmeventd.sh
@@ -39,7 +39,7 @@ which mkfs.ext4 || skip
 
 # Use our mkfs config file to get approximately same results
 # TODO: maybe use it for all test via some 'prepare' function
-export MKE2FS_CONFIG="$TESTDIR/lib/mke2fs.conf"
+export MKE2FS_CONFIG="$TESTOLDPWD/lib/mke2fs.conf"
 
 aux prepare_dmeventd
 aux prepare_pvs 2 64


