From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 11 May 2015 12:41:23 +0000 (UTC)
Subject: master - makefiles: dist and rpm target
Message-ID: <20150511124123.3688F603E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7de615339571be4b0ee593b58d5e1c5abd661c4c
Commit:        7de615339571be4b0ee593b58d5e1c5abd661c4c
Parent:        ed8ea6cb2f0f915cc357c210d3112d3fed234854
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 11 14:28:55 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 11 14:36:58 2015 +0200

makefiles: dist and rpm target

Basic support for upstream 'build' of rpm packages.
Make spec file generated.

2 new simple targets:

make dist  - create LVM2.MAJOR.MINOR.PATCHLEVEL.tgz  from git files.

make rpm   - some generic rpmbuilder using spec files.
             Create packages in build/ subdir.
             DO NOT USE created rpms in any distribution!
---
 Makefile.in        |   20 +++++++++-
 configure          |    3 +-
 configure.in       |    1 +
 spec/source.inc.in |  113 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 135 insertions(+), 2 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index bce7bee..30c2c89 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -15,6 +15,8 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
+abs_top_builddir = @abs_top_builddir@
+abs_top_srcdir = @abs_top_srcdir@
 
 SUBDIRS = conf daemons include lib libdaemon libdm man scripts tools
 
@@ -97,6 +99,22 @@ check check_system check_cluster check_local check_lvmetad unit: all
 
 conf.generate: tools
 
+VER = LVM2. at LVM_MAJOR@. at LVM_MINOR@. at LVM_PATCHLEVEL@
+
+dist:
+	@echo "Generating $(VER).tgz";\
+	git ls-tree -r HEAD --name-only | xargs tar --transform "s,^,$(VER)/," -zcf $(VER).tgz
+
+rpm: dist
+	$(MKDIR_P) build/SPECS build/SOURCES
+	ln -sf $(abs_top_srcdir)/spec/lvm2.spec build/SPECS
+	ln -sf $(abs_top_srcdir)/spec/build.inc build/SOURCES
+	ln -sf $(abs_top_srcdir)/spec/macros.inc build/SOURCES
+	ln -sf $(abs_top_srcdir)/spec/packages.inc build/SOURCES
+	ln -sf $(abs_top_srcdir)/spec/source.inc build/SOURCES
+	ln -sf $(abs_top_builddir)/$(VER).tgz build/SOURCES
+	rpmbuild -v --define "_topdir $(abs_top_builddir)/build" -ba build/SPECS/lvm2.spec
+
 generate: conf.generate
 	$(MAKE) -C conf generate
 
diff --git a/configure b/configure
index 7c1ffe0..7e0146c 100755
--- a/configure
+++ b/configure
@@ -13241,7 +13241,7 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile daemons/lvmpolld/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile 
 liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/
 Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile daemons/lvmpolld/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile 
 liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile spec/source.inc test/Makefile test/api/Mak
 efile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -14002,6 +14002,7 @@ do
     "scripts/lvm2_pvscan_systemd_red_hat at .service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_pvscan_systemd_red_hat at .service" ;;
     "scripts/lvm2_tmpfiles_red_hat.conf") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_tmpfiles_red_hat.conf" ;;
     "scripts/Makefile") CONFIG_FILES="$CONFIG_FILES scripts/Makefile" ;;
+    "spec/source.inc") CONFIG_FILES="$CONFIG_FILES spec/source.inc" ;;
     "test/Makefile") CONFIG_FILES="$CONFIG_FILES test/Makefile" ;;
     "test/api/Makefile") CONFIG_FILES="$CONFIG_FILES test/api/Makefile" ;;
     "test/unit/Makefile") CONFIG_FILES="$CONFIG_FILES test/unit/Makefile" ;;
diff --git a/configure.in b/configure.in
index 83358f5..6ff5bbe 100644
--- a/configure.in
+++ b/configure.in
@@ -1944,6 +1944,7 @@ scripts/lvm2_monitoring_systemd_red_hat.service
 scripts/lvm2_pvscan_systemd_red_hat@.service
 scripts/lvm2_tmpfiles_red_hat.conf
 scripts/Makefile
+spec/source.inc
 test/Makefile
 test/api/Makefile
 test/unit/Makefile
diff --git a/spec/source.inc.in b/spec/source.inc.in
new file mode 100644
index 0000000..c1d1012
--- /dev/null
+++ b/spec/source.inc.in
@@ -0,0 +1,113 @@
+%import macros.inc
+
+##############################################################
+# Defaults (rawhide)... 
+
+%global enable_profiling 0
+%global enable_testsuite 0
+%global enable_udev 1
+%global enable_systemd 1
+%global enable_cmirror 1
+
+%global buildreq_cluster corosync-devel >= 1.99.9-1, dlm-devel >= 3.99.1-1
+%global req_cluster corosync >= 1.99.9-1, dlm >= 3.99.2-1
+%with clvmd corosync
+
+# TODO %global req_dm_persistent device-mapper-persistent-data >= 0.1.4
+%with cache internal
+%with thin internal
+%with thin_check %{_sbindir}/thin_check
+%with thin_repair %{_sbindir}/thin_repair
+%with thin_dump %{_sbindir}/thin_dump
+
+%global buildreq_udev systemd-devel
+%global req_udev udev >= 181-1
+
+%service lvmetad 1
+
+##############################################################
+
+%if %{fedora} == 16 || %{rhel} == 6
+%global enable_systemd 0
+
+%global buildreq_udev libudev-devel
+%global buildreq_cluster openaislib-devel >= 1.1.1-1, clusterlib-devel >= 3.0.6-1, corosynclib-devel >= 1.2.0-1
+
+%global req_udev udev >= 158-1
+%global req_cluster openais >= 1.1.1-1, cman >= 3.0.6-1, corosync >= 1.2.0-1
+
+%global _udevbasedir /lib/udev
+%global _udevdir %{_udevbasedir}/rules.d
+%endif
+
+%if %{fedora} == 16
+%with cache none
+%with thin none
+%with thin_check
+%with thin_repair
+%with thin_dump
+%endif
+
+##############################################################
+
+%if %{fedora} == 17
+%global buildreq_udev systemd-devel
+%global buildreq_cluster corosync-devel >= 1.99.9-1, dlm-devel >= 3.99.1-1
+
+%global req_udev udev >= 181-1
+%global req_dm_persistent device-mapper-persistent-data >= 0.1.4
+%global req_cluster corosync >= 1.99.9-1, dlm >= 3.99.2-1
+%endif
+
+##############################################################
+# same as FC 16 above, only with older udev
+
+%if %{rhel} == 6
+%define req_udev udev >= 147-2
+%global req_dm_persistent device-mapper-persistent-data >= 0.1.4
+%endif
+
+##############################################################
+
+# Do not reset Release to 1 unless both lvm2 and device-mapper
+# versions are increased together.
+
+%define device_mapper_version @DM_LIB_PATCHLEVEL@
+
+Summary: Userland logical volume management tools
+Name: lvm2
+Version: @LVM_MAJOR at .@LVM_MINOR at .@LVM_PATCHLEVEL@
+Release: 1%{?dist}
+License: GPLv2
+Group: System Environment/Base
+URL: http://sources.redhat.com/lvm2
+Source0: ftp://sources.redhat.com/pub/lvm2/LVM2.%{version}.tgz
+Source91: source.inc
+Source92: build.inc
+Source93: packages.inc
+Source94: macros.inc
+
+BuildRequires: libselinux-devel >= 1.30.19-4, libsepol-devel
+BuildRequires: ncurses-devel
+BuildRequires: readline-devel
+BuildRequires: module-init-tools
+BuildRequires: pkgconfig
+
+# Expands to nothing unless at least 2 arguments are given
+%define maybe() \
+%if %(test -n "%{?2}" && echo 1 || echo 0) \
+%* \
+%endif
+%define ifwith() \
+%if %(if echo %{with_flags} | grep -q %1; then echo 1; else echo 0; fi)
+
+%maybe BuildRequires: %{?buildreq_udev}
+%maybe BuildRequires: %{?buildreq_cluster}
+
+%description
+LVM2 includes all of the support for handling read/write operations on
+physical volumes (hard disks, RAID-Systems, magneto optical, etc.,
+multiple devices (MD), see mdadd(8) or even loop devices, see
+losetup(8)), creating volume groups (kind of virtual disks) from one
+or more physical volumes and creating one or more logical volumes
+(kind of logical partitions) in volume groups.


