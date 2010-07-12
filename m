From: Florian Haas <florian.haas@linbit.com>
Date: Mon, 12 Jul 2010 15:51:44 +0200 (CEST)
Subject: [PATCH] OCF resource agent for an LVM Volume Group
Message-ID: <20100712135144.98F5D1059EBE@mail09.linbit.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello everybody,

this is to submit an Open Cluster Framework (OCF) compliant
resource agent (RA) to manage a highly available LVM Volume Group.
Alasdair and I discussed this at LinuxTag in Berlin just over a
month ago, and agreed it would be a good thing to carry this RA
with the LVM2 CVS. A diffstat and brief FAQ are below. 
Any comments are much appreciated. Hope this is useful.

Cheers,
Florian
 
 configure.in            |   11 ++
 scripts/Makefile.in     |    8 +-
 scripts/VolumeGroup.ocf |  279 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 297 insertions(+), 1 deletions(-)

- So what is this good for?

  This manages an LVM VG as a highly available cluster resource,
  enabling and disabling the VG on cluster nodes as needed.

- Which cluster manager does this play with?

  Most people will use this in conjunction with the Pacemaker
  cluster manager (http://www.clusterlabs.org). Pacemaker is
  maintained by Andrew Beekhof from Red Hat.

- But doesn't Pacemaker already support this?

  Yes it does, and it has for a number of years. The currently
  supported LVM resource agent for Pacemaker is documented here:
  http://www.linux-ha.org/doc/re-ra-LVM.html

- How does the submission relate to the existing RA?

  It is meant to eventually displace the RA currently living
  in the Linux-HA.org repository. It makes much more sense to
  carry the RA inside LVM2. The Linux-HA repository version will
  eventually be deprecated.

- How do the two versions differ at this time?

  The only functional change is that the Linux-HA version still
  contains support for LVM 1 metadata, which has been dropped from
  the version being submitted here.

- Can this RA act as a direct drop-in replacement for the Linux-HA one?

  For any VG with LVM2 metadata, yes.

- Does this work for clustered VGs too?

  Yes it does. Pacemaker supports running this resource in "clone"
  mode, which in conjunction with clvmd does support clustered VGs.
  In that configuration, the VG is simultaneously active on
  multiple nodes.

- How should this be packaged?

  This resource agent should probably be packaged in a separate sub-package 
  RPM, named lvm2-resource-agents which requires both lvm2 and
  resource-agents.

diff --git a/configure.in b/configure.in
index 439444f..4ba6b2a 100644
--- a/configure.in
+++ b/configure.in
@@ -345,6 +345,7 @@ case "$REPLICATORS" in
   *) AC_MSG_ERROR([--with-replicators parameter invalid ($REPLICATORS)]) ;;
 esac
 
+
 ################################################################################
 dnl -- Disable readline
 AC_MSG_CHECKING(whether to enable readline)
@@ -362,6 +363,15 @@ AC_ARG_ENABLE(realtime,
 AC_MSG_RESULT($REALTIME)
 
 ################################################################################
+dnl -- disable OCF resource agents
+AC_MSG_CHECKING(whether to enable OCF resource agents)
+AC_ARG_ENABLE(ocf,
+            AC_HELP_STRING([--disable-ocf],
+	                   [disable Open Cluster Framework (OCF) compliant resource agents]),
+            OCF=$enableval, OCF=yes)
+AC_MSG_RESULT($OCF)
+
+################################################################################
 dnl -- Init pkg-config with dummy invokation:
 dnl -- this is required because PKG_CHECK_MODULES macro is expanded
 dnl -- to initialize the pkg-config environment only at the first invokation,
@@ -1231,6 +1241,7 @@ AC_SUBST(LVM_PATCHLEVEL)
 AC_SUBST(LVM_RELEASE)
 AC_SUBST(LVM_RELEASE_DATE)
 AC_SUBST(MIRRORS)
+AC_SUBST(OCF)
 AC_SUBST(REPLICATORS)
 AC_SUBST(MSGFMT)
 AC_SUBST(PKGCONFIG)
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 2220b9c..58b3a89 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -29,7 +29,13 @@ vpath %.sh $(srcdir)
 
 install_lvm2: $(SCRIPTS:.sh=_install)
 
-install: install_lvm2
+install_ocf:
+ifeq ("@OCF@", "yes")
+	$(INSTALL_DIR) $(DESTDIR)/usr/lib/ocf/resource.d/lvm2
+	$(INSTALL_SCRIPT) VolumeGroup.ocf $(DESTDIR)/usr/lib/ocf/resource.d/lvm2/VolumeGroup
+endif
+
+install: install_lvm2 install_ocf
 
 # FIXME Customise for other distributions
 install_initscripts:
diff --git a/scripts/VolumeGroup.ocf b/scripts/VolumeGroup.ocf
new file mode 100755
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


