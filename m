From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Wed, 23 Mar 2016 11:00:50 +0000 (UTC)
Subject: master - test: Fix lvmdbusd tests to work with installed testsuite
Message-ID: <20160323110050.F418D60D59@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bb93a28bc1d8b284c13ca5e5c925ce5b67d12204
Commit:        bb93a28bc1d8b284c13ca5e5c925ce5b67d12204
Parent:        c1d376b1abdb6b6a2410a5372a3a76748c1daa98
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Mar 23 11:56:25 2016 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Mar 23 11:59:04 2016 +0100

test: Fix lvmdbusd tests to work with installed testsuite

---
 test/Makefile.in     |    3 +++
 test/api/dbustest.sh |    5 +----
 test/lib/aux.sh      |   18 +++++++++++++-----
 3 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 43e321d..ded155d 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -205,6 +205,7 @@ install: .tests-stamp lib/paths-installed
 	$(INSTALL_DATA) shell/*.sh $(DATADIR)/shell
 	$(INSTALL_DATA) api/*.sh $(DATADIR)/api
 	$(INSTALL_PROGRAM) api/*.{t,py} $(DATADIR)/api
+	$(INSTALL_PROGRAM) dbus/*.py $(DATADIR)/dbus/
 	$(INSTALL_DATA) lib/paths-installed $(DATADIR)/lib/paths
 	cd lib && $(INSTALL_DATA) \
 		$(LIB_FLAVOURS) \
@@ -274,12 +275,14 @@ lib/paths-installed: lib/paths-common
 	$(RM) $@-t
 	cat lib/paths-common > $@-t
 	echo 'installed_testsuite=1' >> $@-t
+	echo 'test_data_dir="@datadir@/lvm2-testsuite"' >> $@-t
 	echo 'export PATH=@libexecdir@/lvm2-testsuite:@datadir@/lvm2-testsuite/lib:@datadir@/lvm2-testsuite/api:$$PATH' >> $@-t
 	mv $@-t $@
 
 lib/paths: lib/paths-common
 	$(RM) $@-t
 	cat lib/paths-common > $@-t
+	echo 'test_data_dir="$(abs_top_builddir)/test"' >> $@-t
 	echo 'top_srcdir="$(top_srcdir)"' >> $@-t
 	echo 'abs_top_builddir="$(abs_top_builddir)"' >> $@-t
 	echo 'abs_top_srcdir="$(abs_top_srcdir)"' >> $@-t
diff --git a/test/api/dbustest.sh b/test/api/dbustest.sh
index dd9b23d..79e3224 100644
--- a/test/api/dbustest.sh
+++ b/test/api/dbustest.sh
@@ -27,8 +27,5 @@ if [ ! -f /etc/dbus-1/system.d/com.redhat.lvmdbus1.conf ]; then
 	install -m 644 $abs_top_builddir/scripts/com.redhat.lvmdbus1.conf /etc/dbus-1/system.d/.
 fi
 
-# Setup the python path so we can run
-export PYTHONPATH=$abs_top_builddir/daemons
-
 aux prepare_lvmdbusd
-$abs_top_builddir/test/dbus/lvmdbustest.py -v
+$test_data_dir/dbus/lvmdbustest.py -v
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index ed1e3d8..4f5daaf 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -301,8 +301,11 @@ lvmpolld_dump() {
 }
 
 prepare_lvmdbusd() {
+	local daemon=
 	rm -f debug.log_LVMDBUSD_out
 
+	kill_sleep_kill_ LOCAL_LVMDBUSD 0
+
 	echo "checking lvmdbusd is NOT running..."
 	if ps -elf | grep lvmdbusd | grep python3; then
 		echo "Cannot run while existing lvmdbusd process exists"
@@ -311,16 +314,21 @@ prepare_lvmdbusd() {
 	echo ok
 
 	# skip if we don't have our own lvmdbusd...
-	# NOTE: this is always present - additional checks are needed:
-	[[ -x $abs_top_builddir/daemons/lvmdbusd/lvmdbusd ]] || skip
+	if test -z "${installed_testsuite+varset}"; then
+		# NOTE: this is always present - additional checks are needed:
+		daemon="$abs_top_builddir/daemons/lvmdbusd/lvmdbusd"
+		# Setup the python path so we can run
+		export PYTHONPATH=$abs_top_builddir/daemons
+	else
+		daemon="$(which lvmdbusd)"
+	fi
+	[[ -n $daemon && -x $daemon ]] || skip "The daemon is missing"
 
 	which python3 >/dev/null || skip "Missing python3"
 	python3 -c "import pyudev, dbus, gi.repository" || skip "Missing python modules"
 
-	kill_sleep_kill_ LOCAL_LVMDBUSD 0
-
 	echo "preparing lvmdbusd..."
-	$abs_top_builddir/daemons/lvmdbusd/lvmdbusd --debug --udev > debug.log_LVMDBUSD_out 2>&1 &
+	"$daemon" --debug --udev > debug.log_LVMDBUSD_out 2>&1 &
 	local pid=$!
 
 	sleep 1


