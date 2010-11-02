From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue,  2 Nov 2010 15:10:43 +0100
Subject: [PATCH 3/3] ocf support
In-Reply-To: <cover.1288706876.git.zkabelac@redhat.com>
References: <cover.1288706876.git.zkabelac@redhat.com>
Message-ID: <23bf9e224c03d73cd1b4c82bf2e5e29d17d10efb.1288706876.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Updated patch from Florian Haas from Linux-HA project.

CF patch:
  user needs to configure --enable-ocf so it gets installed with
  make install target by default. Otherwise user can use:
  make install_ocf to get only ocf files installed.
  With disabled (default) ocf support - no files are installed.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 configure.in            |   10 ++
 make.tmpl.in            |    8 +-
 scripts/Makefile.in     |   14 ++-
 scripts/VolumeGroup.ocf |  279 +++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 309 insertions(+), 2 deletions(-)
 create mode 100644 scripts/VolumeGroup.ocf

diff --git a/configure.in b/configure.in
index ec53740..97f538e 100644
--- a/configure.in
+++ b/configure.in
@@ -361,6 +361,15 @@ AC_ARG_ENABLE(realtime,
 AC_MSG_RESULT($REALTIME)
 
 ################################################################################
+dnl -- disable OCF resource agents
+AC_MSG_CHECKING(whether to enable OCF resource agents)
+AC_ARG_ENABLE(ocf,
+	      AC_HELP_STRING([--enable-ocf],
+			     [enable Open Cluster Framework (OCF) compliant resource agents]),
+	      OCF=$enableval, OCF=no)
+AC_MSG_RESULT($OCF)
+
+################################################################################
 dnl -- Init pkg-config with dummy invokation:
 dnl -- this is required because PKG_CHECK_MODULES macro is expanded
 dnl -- to initialize the pkg-config environment only at the first invokation,
@@ -1317,6 +1326,7 @@ AC_SUBST(LVM_PATCHLEVEL)
 AC_SUBST(LVM_RELEASE)
 AC_SUBST(LVM_RELEASE_DATE)
 AC_SUBST(MIRRORS)
+AC_SUBST(OCF)
 AC_SUBST(REPLICATORS)
 AC_SUBST(MSGFMT)
 AC_SUBST(PKGCONFIG)
diff --git a/make.tmpl.in b/make.tmpl.in
index faccd60..0070b68 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -1,7 +1,7 @@
 # @configure_input@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -175,6 +175,7 @@ POTFILES = $(SOURCES:%.c=%.pot)
 .PHONY: all pofile distclean clean cleandir cflow device-mapper
 .PHONY: install install_cluster install_device-mapper install_lvm2
 .PHONY: install_lib_shared install_dm_plugin install_lvm2_plugin
+.PHONY: install_ocf
 .PHONY: $(SUBDIRS) $(SUBDIRS.install) $(SUBDIRS.clean) $(SUBDIRS.distclean)
 .PHONY: $(SUBDIRS.pofile) $(SUBDIRS.install_cluster) $(SUBDIRS.cflow)
 .PHONY: $(SUBDIRS.device-mapper) $(SUBDIRS.install-device-mapper)
@@ -184,6 +185,7 @@ SUBDIRS.install := $(SUBDIRS:=.install)
 SUBDIRS.install_cluster := $(SUBDIRS:=.install_cluster)
 SUBDIRS.install_device-mapper := $(SUBDIRS:=.install_device-mapper)
 SUBDIRS.install_lvm2 := $(SUBDIRS:=.install_lvm2)
+SUBDIRS.install_ocf := $(SUBDIRS:=.install_ocf)
 SUBDIRS.pofile := $(SUBDIRS:=.pofile)
 SUBDIRS.cflow := $(SUBDIRS:=.cflow)
 SUBDIRS.clean := $(SUBDIRS:=.clean)
@@ -197,6 +199,7 @@ install: all $(SUBDIRS.install)
 install_cluster: all $(SUBDIRS.install_cluster)
 install_device-mapper: $(SUBDIRS.install_device-mapper)
 install_lvm2: $(SUBDIRS.install_lvm2)
+install_ocf: $(SUBDIRS.install_ocf)
 cflow: $(SUBDIRS.cflow)
 
 $(SUBDIRS): $(SUBDIRS.device-mapper)
@@ -217,6 +220,9 @@ $(SUBDIRS.install_device-mapper): device-mapper
 $(SUBDIRS.install_lvm2): $(SUBDIRS)
 	$(MAKE) -C $(@:.install_lvm2=) install_lvm2
 
+$(SUBDIRS.install_ocf):
+	$(MAKE) -C $(@:.install_ocf=) install_ocf
+
 $(SUBDIRS.clean):
 	-$(MAKE) -C $(@:.clean=) clean
 
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index d859564..87c4b76 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -15,6 +15,7 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 initd_dir = $(DESTDIR)${prefix}/etc/rc.d/init.d
+ocf_scriptdir = $(DESTDIR)${prefix}/usr/lib/ocf/resource.d/lvm2
 
 include $(top_builddir)/make.tmpl
 
@@ -23,14 +24,25 @@ ifeq ("@FSADM@", "yes")
 	SCRIPTS += fsadm.sh
 endif
 
+OCF_SCRIPTS =
+ifeq ("@OCF@", "yes")
+        OCF_SCRIPTS += VolumeGroup.ocf
+endif
+
 vpath %.sh $(srcdir)
 
 %_install: %.sh
 	$(INSTALL_PROGRAM) -D $< $(sbindir)/$(basename $(<F))
 
+%_install: %.ocf
+	$(INSTALL_DIR) $(ocf_scriptdir)
+	$(INSTALL_SCRIPT) $< $(ocf_scriptdir)/$(basename $(<F))
+
 install_lvm2: $(SCRIPTS:.sh=_install)
 
-install: install_lvm2
+install_ocf: $(OCF_SCRIPTS:.ocf=_install)
+
+install: install_lvm2 install_ocf
 
 # FIXME Customise for other distributions
 install_initscripts:
diff --git a/scripts/VolumeGroup.ocf b/scripts/VolumeGroup.ocf
new file mode 100644
index 0000000..8a39582
--- /dev/null
+++ b/scripts/VolumeGroup.ocf
@@ -0,0 +1,279 @@
+#!/bin/sh
+#
+# VolumeGroup
+#
+# Description:	Manages an LVM2 volume group as an HA resource in
+#               an OCF-compliant cluster
+#
+#
+# Authors:	Alan Robertson, Lars Marowsky-Bree, Florian Haas,
+#               and others from the Linux-HA project
+# License:	GNU General Public License (GPL)
+# Copyright:	(C) 2002 - 2005 International Business Machines, Inc.
+#               (C) 2010 LINBIT HA-Solutions GmbH
+#
+#	This code significantly inspired by the LVM resource
+#	in FailSafe by Lars Marowsky-Bree
+#
+#######################################################################
+# Initialization:
+
+: ${OCF_FUNCTIONS_DIR=${OCF_ROOT}/resource.d/heartbeat}
+. ${OCF_FUNCTIONS_DIR}/.ocf-shellfuncs
+
+#######################################################################
+
+
+usage() {
+  methods=`VolumeGroup_methods`
+  methods=`echo $methods | tr ' ' '|'`
+  cat <<EOF
+	usage: $0 $methods
+
+	$0 manages an LVM Volume Group (VG) as an HA resource
+
+	The 'start' operation brings the given volume online
+	The 'stop' operation takes the given volume offline
+	The 'status' operation reports whether the volume is available
+	The 'monitor' operation reports whether the volume seems present
+	The 'validate-all' operation checks whether the OCF parameters are valid
+	The 'methods' operation reports on the methods $0 supports
+
+EOF
+}
+
+meta_data() {
+	cat <<EOF
+<?xml version="1.0"?>
+<!DOCTYPE resource-agent SYSTEM "ra-api-1.dtd">
+<resource-agent name="VolumeGroup">
+<version>1.0</version>
+
+<longdesc lang="en">
+Resource script for an LVM Volume Group.
+</longdesc>
+<shortdesc lang="en">Controls the availability of an LVM Volume Group</shortdesc>
+
+<parameters>
+<parameter name="volgrpname" unique="0" required="1">
+<longdesc lang="en">
+The name of volume group.
+</longdesc>
+<shortdesc lang="en">Volume group name</shortdesc>
+<content type="string" default="" />
+</parameter>
+<parameter name="exclusive" unique="0" required="0">
+<longdesc lang="en">
+If set, the volume group will be activated exclusively.
+</longdesc>
+<shortdesc lang="en">Exclusive activation</shortdesc>
+<content type="boolean" default="false" />
+</parameter>
+</parameters>
+
+<actions>
+<action name="start" timeout="30" />
+<action name="stop" timeout="30" />
+<action name="status" timeout="30" />
+<action name="monitor" depth="0" timeout="30" interval="10" />
+<action name="methods" timeout="5" />
+<action name="meta-data" timeout="5" />
+<action name="validate-all" timeout="5" />
+</actions>
+</resource-agent>
+EOF
+}
+
+#
+# methods: What methods/operations do we support?
+#
+VolumeGroup_methods() {
+  cat <<EOF
+	start
+	stop
+	status
+	monitor
+	methods
+	validate-all
+	usage
+EOF
+}
+
+#
+# Report on LVM volume status. VG may be reported as active
+# ($OCF_SUCCESS) or inactive ($OCF_NOT_RUNNING)
+#
+VolumeGroup_status() {
+
+    VGOUT=`vgdisplay -v $OCF_RESKEY_volgrpname 2>&1` || exit $OCF_ERR_GENERIC
+    echo "$VGOUT" | grep -i 'Status[ \t]*available' >/dev/null
+    rc=$?
+
+    if [ $rc -eq 0 ]; then
+	ocf_log debug "LVM Volume Group $OCF_RESKEY_volgrpname is available (started)"
+    else
+	ocf_log debug "LVM Volume Group $OCF_RESKEY_volgrpname is not available (stopped)"
+	return $OCF_NOT_RUNNING
+    fi
+
+    if echo "$VGOUT" | grep -i 'Access.*read/write' >/dev/null; then
+	ocf_log debug "Volume $OCF_RESKEY_volgrpname is available read/write (running)"
+    else
+	ocf_log debug "Volume $OCF_RESKEY_volgrpname is available read-only (running)"
+    fi
+
+    return $OCF_SUCCESS
+}
+
+#
+# Monitor the volume - does it really seem to be working? May report
+# $OCF_SUCCESS or $OCF_NOT_RUNNING like VolumeGroup_status, plus
+# $OCF_ERR_GENERIC in case vgck reports an error.
+#
+VolumeGroup_monitor() {
+    if ! VolumeGroup_status $OCF_RESKEY_volgrpname; then
+	ocf_log info "LVM Volume Group $OCF_RESKEY_volgrpname is offline"
+	return $OCF_NOT_RUNNING
+    fi
+
+    ocf_run vgck $OCF_RESKEY_volgrpname || exit $OCF_ERR_GENERIC
+
+    return $OCF_SUCCESS
+}
+
+#
+# Activate the volume group, either locally (if $OCF_RESKEY_exclusive
+# is false or unset), or exclusively (if $OCF_RESKEY_exclusive is
+# true).
+# Either returns successfully, or exits with $OCF_ERR_GENERIC.
+#
+VolumeGroup_start() {
+
+  ocf_log info "Activating volume group $OCF_RESKEY_volgrpname"
+  ocf_run vgscan
+
+  local active_mode
+  active_mode="ly"
+  if ocf_is_true "$OCF_RESKEY_exclusive" ; then
+      active_mode="ey"
+  fi
+
+  ocf_run vgchange -a $active_mode $OCF_RESKEY_volgrpname || exit $OCF_ERR_GENERIC
+
+  if ! VolumeGroup_status $OCF_RESKEY_volgrpname; then
+    ocf_log err "LVM: $OCF_RESKEY_volgrpname did not activate correctly"
+    exit $OCF_ERR_GENERIC
+  fi
+
+  return $OCF_SUCCESS
+}
+
+#
+# Deactivate the volume group.
+# Either returns successfully, or exits with $OCF_ERR_GENERIC.
+#
+VolumeGroup_stop() {
+    if ! VolumeGroup_status; then
+	ocf_log debug "Volume Group $OCF_RESKEY_volgrpname already stopped"
+	return $OCF_SUCCESS
+    fi
+
+    ocf_log info "Deactivating volume group $OCF_RESKEY_volgrpname"
+    ocf_run vgchange -a ln $OCF_RESKEY_volgrpname || exit $OCF_ERR_GENERIC
+
+    if VolumeGroup_status; then
+	ocf_log err "LVM: $OCF_RESKEY_volgrpname did not stop correctly"
+	exit $OCF_ERR_GENERIC
+    fi
+
+    return $OCF_SUCCESS
+}
+
+#
+# Check whether the OCF instance parameters are valid.
+# Either returns successfully, or exits with
+# $OCF_ERR_CONFIGURED if required parameters are missing;
+# $OCF_ERR_INSTALLED if required binaries are missing;
+# $OCF_ERR_GENERIC in case of any other error.
+#
+VolumeGroup_validate_all() {
+
+    if [ -z $OCF_RESKEY_volgrpname ]; then
+	ocf_log err 'Missing required parameter "volgrpname"!'
+	exit $OCF_ERR_CONFIGURED
+    fi
+
+    check_binary vgchange
+    check_binary vgck
+    check_binary vgdisplay
+
+    # Run the following tests only if we're not invoked by a probe
+    # operation
+    if ! ocf_is_probe; then
+        # Off-the-shelf tests...
+	vgck "$OCF_RESKEY_volgrpname" >/dev/null 2>&1
+	if [ $? -ne 0 ]; then
+	    ocf_log err "Volume group $OCF_RESKEY_volgrpname does not exist or contains error!"
+	    exit $OCF_ERR_GENERIC
+	fi
+
+        # Double-check
+	vgdisplay -v "$OCF_RESKEY_volgrpname" >/dev/null 2>&1
+	if [ $? -ne 0 ]; then
+	    ocf_log err "Volume group $OCF_RESKEY_volgrpname does not exist or contains error!"
+	    exit $OCF_ERR_GENERIC
+	fi
+    fi
+
+    return $OCF_SUCCESS
+}
+
+#
+# 'main' starts here...
+#
+if [ $# -ne 1 ]; then
+    usage
+    exit $OCF_ERR_ARGS
+fi
+
+case $1 in
+  meta-data)	meta_data
+		exit $OCF_SUCCESS;;
+
+  methods)	VolumeGroup_methods
+		exit $OCF_SUCCESS;;
+
+  usage)	usage
+		exit $OCF_SUCCESS;;
+  *)		;;
+esac
+
+# Everything except usage and meta-data must pass the validate test
+VolumeGroup_validate_all
+
+# What kind of method was invoked?
+case "$1" in
+    start)
+	VolumeGroup_start
+	;;
+    stop)
+	VolumeGroup_stop
+	;;
+    status)
+	VolumeGroup_status
+	;;
+    monitor)
+	VolumeGroup_monitor
+	;;
+    validate-all)
+	;;
+    notify|promote|demote|migrate_from|migrate_to)
+	usage
+	exit $OCF_ERR_UNIMPLEMENTED
+	;;
+    *)	usage
+	exit $OCF_ERR_ARGS
+	;;
+esac
+
+exit $?
-- 
1.7.3.2


