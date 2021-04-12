From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 12 Apr 2021 07:55:49 +0000 (GMT)
Subject: main - make: generate
Message-ID: <20210412075549.E699E39FCC7D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=151377dd50b7ba84894f799d9e0957898748f882
Commit:        151377dd50b7ba84894f799d9e0957898748f882
Parent:        19ff0d983ee013711b88b66acc625a532f31b22b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 8 21:08:48 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 12 09:54:16 2021 +0200

make: generate

---
 conf/example.conf.in         |  38 ++--
 man/lvchange.8_pregen        | 505 +++++++++++++++++++++----------------------
 man/lvconvert.8_pregen       | 455 +++++++++++++++++++-------------------
 man/lvcreate.8_pregen        | 477 +++++++++++++++++++++-------------------
 man/lvdisplay.8_pregen       | 285 ++++++++++++------------
 man/lvextend.8_pregen        | 289 +++++++++++++------------
 man/lvm-fullreport.8_pregen  | 273 +++++++++++------------
 man/lvm-lvpoll.8_pregen      | 211 +++++++++---------
 man/lvmconfig.8_pregen       | 280 ++++++++++++------------
 man/lvmdevices.8_pregen      | 213 +++++++++---------
 man/lvmdiskscan.8_pregen     | 197 ++++++++---------
 man/lvreduce.8_pregen        | 223 +++++++++----------
 man/lvremove.8_pregen        | 221 +++++++++----------
 man/lvrename.8_pregen        | 205 +++++++++---------
 man/lvresize.8_pregen        | 281 +++++++++++++-----------
 man/lvs.8_pregen             | 287 ++++++++++++------------
 man/lvscan.8_pregen          | 209 +++++++++---------
 man/pvchange.8_pregen        | 265 +++++++++++------------
 man/pvck.8_pregen            | 247 +++++++++++----------
 man/pvcreate.8_pregen        | 251 ++++++++++-----------
 man/pvdisplay.8_pregen       | 281 ++++++++++++------------
 man/pvmove.8_pregen          | 238 ++++++++++----------
 man/pvremove.8_pregen        | 199 ++++++++---------
 man/pvresize.8_pregen        | 199 ++++++++---------
 man/pvs.8_pregen             | 281 ++++++++++++------------
 man/pvscan.8_pregen          | 235 ++++++++++----------
 man/vgcfgbackup.8_pregen     | 211 +++++++++---------
 man/vgcfgrestore.8_pregen    | 207 +++++++++---------
 man/vgchange.8_pregen        | 421 ++++++++++++++++++------------------
 man/vgck.8_pregen            | 201 ++++++++---------
 man/vgconvert.8_pregen       | 219 +++++++++----------
 man/vgcreate.8_pregen        | 304 ++++++++++++++------------
 man/vgdisplay.8_pregen       | 277 ++++++++++++------------
 man/vgexport.8_pregen        | 205 +++++++++---------
 man/vgextend.8_pregen        | 241 +++++++++++----------
 man/vgimport.8_pregen        | 211 +++++++++---------
 man/vgimportclone.8_pregen   | 203 ++++++++---------
 man/vgimportdevices.8_pregen | 209 +++++++++---------
 man/vgmerge.8_pregen         | 199 ++++++++---------
 man/vgmknodes.8_pregen       | 207 +++++++++---------
 man/vgreduce.8_pregen        | 217 ++++++++++---------
 man/vgremove.8_pregen        | 211 +++++++++---------
 man/vgrename.8_pregen        | 203 ++++++++---------
 man/vgs.8_pregen             | 277 ++++++++++++------------
 man/vgscan.8_pregen          | 205 +++++++++---------
 man/vgsplit.8_pregen         | 232 ++++++++++----------
 46 files changed, 5843 insertions(+), 5662 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 5275e76c5..19efe6b6d 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -1086,10 +1086,12 @@ global {
 	# Activate LVs based on system-generated device events.
 	# When a device appears on the system, a system-generated event runs
 	# the pvscan command to activate LVs if the new PV completes the VG.
-	# Use auto_activation_volume_list to select which LVs should be
-	# activated from these events (the default is all.)
 	# When event_activation is disabled, the system will generally run
 	# a direct activation command to activate LVs in complete VGs.
+	# Activation commands that are run by the system, either from events
+	# or at fixed points during startup, use autoactivation (-aay).  See
+	# the --setautoactivation option or the auto_activation_volume_list
+	# setting to configure autoactivation for specific VGs or LVs.
 	# This configuration option has an automatic default value.
 	# event_activation = 1
 
@@ -1430,22 +1432,22 @@ activation {
 	# This configuration option does not have a default value defined.
 
 	# Configuration option activation/auto_activation_volume_list.
-	# Only LVs selected by this list are auto-activated.
-	# This list works like volume_list, but it is used only by
-	# auto-activation commands. It does not apply to direct activation
-	# commands. If this list is defined, an LV is only auto-activated
-	# if it matches an entry in this list. If this list is undefined, it
-	# imposes no limits on LV auto-activation (all are allowed.) If this
-	# list is defined and empty, i.e. "[]", then no LVs are selected for
-	# auto-activation. An LV that is selected by this list for
-	# auto-activation, must also be selected by volume_list (if defined)
-	# before it is activated. Auto-activation is an activation command that
-	# includes the 'a' argument: --activate ay or -a ay. The 'a' (auto)
-	# argument for auto-activation is meant to be used by activation
-	# commands that are run automatically by the system, as opposed to LVM
-	# commands run directly by a user. A user may also use the 'a' flag
-	# directly to perform auto-activation. Also see pvscan(8) for more
-	# information about auto-activation.
+	# A list of VGs or LVs that should be autoactivated.
+	# Autoactivation is an activation command run with -aay,
+	# i.e. vgchange -aay, lvchange -aay, or pvscan --cache -aay.
+	# When this list is defined, an autoactivation command will only
+	# activate LVs included in the list. If this list is undefined,
+	# it has no effect. If this list is defined but empty, then no
+	# LVs will be autoactivated. LVs can be included in the list by
+	# LV name, VG name (applies to all LVs in the VG), or tag name.
+	# VGs and LVs can also have an autoactivation property set in
+	# metadata, see --setautoactivation. LVs included in this list
+	# will not be autoactivated if the VG or LV autoactivation
+	# property is disabled (see vgs or lvs "-o autoactivation").
+	# The volume_list setting and the "activation skip" property
+	# also apply to autoactivation.
+	# The -aay option is meant to be used by activation commands that
+	# are run automatically by the system, e.g. from systemd services.
 	#
 	# Accepted values:
 	#   vgname
diff --git a/man/lvchange.8_pregen b/man/lvchange.8_pregen
index fa7bdada0..3d376996f 100644
--- a/man/lvchange.8_pregen
+++ b/man/lvchange.8_pregen
@@ -21,7 +21,10 @@ lvchange - Change the attributes of logical volume(s)
 .ad b
 .br
 .ad l
-    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
+    \fB--alloc\fP 
+.nh
+\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+.hy
 .ad b
 .br
 .ad l
@@ -208,6 +211,10 @@ lvchange - Change the attributes of logical volume(s)
  \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP
 .ad b
 .br
+.ad l
+    \fB--setautoactivation\fP \fBy\fP|\fBn\fP
+.ad b
+.br
 .ad l
     \fB--[raid]syncaction\fP \fBcheck\fP|\fBrepair\fP
 .ad b
@@ -256,94 +263,55 @@ required, after which the others are optional.
 .P
 \fBlvchange\fP
 .RS 4
-( \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP,
-.ad b
+( \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP
 .br
-.ad l
-  \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP,
-.ad b
+  \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP
 .br
-.ad l
-  \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP,
-.ad b
+  \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP
 .br
-.ad l
-  \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP,
-.ad b
+  \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP
 .br
-.ad l
-  \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP,
-.ad b
+  \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
 .br
-.ad l
-  \fB-M\fP|\fB--persistent\fP \fBn\fP,
-.ad b
+  \fB-M\fP|\fB--persistent\fP \fBn\fP
 .br
-.ad l
-     \fB--addtag\fP \fITag\fP,
-.ad b
+     \fB--addtag\fP \fITag\fP
 .br
-.ad l
-     \fB--deltag\fP \fITag\fP,
-.ad b
+     \fB--deltag\fP \fITag\fP
 .br
-.ad l
-     \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP,
-.ad b
+     \fB--alloc\fP 
+.nh
+\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+.hy
 .br
-.ad l
-     \fB--compression\fP \fBy\fP|\fBn\fP,
-.ad b
+     \fB--compression\fP \fBy\fP|\fBn\fP
 .br
-.ad l
-     \fB--deduplication\fP \fBy\fP|\fBn\fP,
-.ad b
+     \fB--deduplication\fP \fBy\fP|\fBn\fP
 .br
-.ad l
-     \fB--detachprofile\fP,
-.ad b
+     \fB--detachprofile\fP
 .br
-.ad l
-     \fB--metadataprofile\fP \fIString\fP,
-.ad b
+     \fB--metadataprofile\fP \fIString\fP
 .br
-.ad l
-     \fB--profile\fP \fIString\fP,
-.ad b
+     \fB--profile\fP \fIString\fP
 .br
-.ad l
-     \fB--errorwhenfull\fP \fBy\fP|\fBn\fP,
-.ad b
+     \fB--setautoactivation\fP \fBy\fP|\fBn\fP
 .br
-.ad l
-     \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP,
-.ad b
+     \fB--errorwhenfull\fP \fBy\fP|\fBn\fP
 .br
-.ad l
-     \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP,
-.ad b
+     \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
 .br
-.ad l
-     \fB--cachepolicy\fP \fIString\fP,
-.ad b
+     \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP
 .br
-.ad l
-     \fB--cachesettings\fP \fIString\fP,
-.ad b
+     \fB--cachepolicy\fP \fIString\fP
 .br
-.ad l
-     \fB--[raid]minrecoveryrate\fP \fISize\fP[k|UNIT],
-.ad b
+     \fB--cachesettings\fP \fIString\fP
 .br
-.ad l
-     \fB--[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT],
-.ad b
+     \fB--[raid]minrecoveryrate\fP \fISize\fP[k|UNIT]
 .br
-.ad l
-     \fB--[raid]writebehind\fP \fINumber\fP,
-.ad b
+     \fB--[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT]
+.br
+     \fB--[raid]writebehind\fP \fINumber\fP
 .br
-.ad l
      \fB--[raid]writemostly\fP \fIPV\fP[\fB:t\fP|\fBn\fP|\fBy\fP] )
 .RE
 .RS 4
@@ -626,10 +594,11 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP
 .br
+.ad b
 Change the active state of LVs.
 An active LV can be used through a block device,
 allowing data on the LV to be accessed.
@@ -642,18 +611,23 @@ All software and scripts should access the device through the symbolic
 link and present this as the name of the device.
 The location and name of the underlying device node may depend on
 the distribution, configuration (e.g. udev), or release version.
-\fBay\fP specifies autoactivation, in which case an LV is activated
-only if it matches an item in lvm.conf activation/auto_activation_volume_list.
-If the list is not set, all LVs are considered to match, and if
-if the list is set but empty, no LVs match.
-Autoactivation should be used during system boot to make it possible
-to select which LVs should be automatically activated by the system.
+\fBay\fP specifies autoactivation, which is used by system-generated
+activation commands.  By default, LVs are autoactivated.
+An autoactivation property can be set on a VG or LV to disable autoactivation,
+see --setautoactivation y|n in vgchange, lvchange, vgcreate, and lvcreate.
+Display the property with vgs or lvs "-o autoactivation".
+The lvm.conf auto_activation_volume_list includes names of VGs or LVs
+that should be autoactivated, and anything not listed is not autoactivated.
+When auto_activation_volume_list is undefined (the default), it has no effect.
+If auto_activation_volume_list is defined and empty, no LVs are autoactivated.
+Items included by auto_activation_volume_list will not be autoactivated if
+the autoactivation property has been disabled.
 See \fBlvmlockd\fP(8) for more information about activation options \fBey\fP and \fBsy\fP for shared VGs.
-.ad b
-.HP
+.TP
 .ad l
 \fB--activationmode\fP \fBpartial\fP|\fBdegraded\fP|\fBcomplete\fP
 .br
+.ad b
 Determines if LV activation is allowed when PVs are missing,
 e.g. because of a device failure.
 \fBcomplete\fP only allows LVs with no missing PVs to be activated,
@@ -664,18 +638,21 @@ and is the most restrictive mode.
 should only be used for recovery or repair.
 For default, see lvm.conf/activation_mode.
 See \fBlvmraid\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--addtag\fP \fITag\fP
 .br
+.ad b
 Adds a tag to a PV, VG or LV. This option can be repeated to add
 multiple tags at once. See \fBlvm\fP(8) for information about tags.
-.ad b
-.HP
+.TP
 .ad l
-\fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
+\fB--alloc\fP 
+.nh
+\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+.hy
 .br
+.ad b
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
 which can be changed with vgchange/lvchange, or overridden on the
@@ -692,18 +669,18 @@ e.g. by placing two stripes on the same PV.
 Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
-.ad b
-.HP
+.TP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP
 .br
+.ad b
 Specifies when writes to a cache LV should be considered complete.
 \fBwriteback\fP considers a write complete as soon as it is
 stored in the cache pool.
@@ -715,18 +692,18 @@ cache pool LV. With \fBpassthrough\fP, all reads are served
 from the origin LV (all reads miss the cache) and all writes are
 forwarded to the origin LV; additionally, write hits cause cache
 block invalidates. See \fBlvmcache\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--cachepolicy\fP \fIString\fP
 .br
+.ad b
 Specifies the cache policy for a cache LV.
 See \fBlvmcache\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--cachesettings\fP \fIString\fP
 .br
+.ad b
 Specifies tunable values for a cache LV in "Key = Value" form.
 Repeat this option to specify multiple values.
 (The default values should usually be adequate.)
@@ -734,90 +711,90 @@ The special string value \fBdefault\fP switches
 settings back to their default kernel values and removes
 them from the list of settings stored in LVM metadata.
 See \fBlvmcache\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--compression\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Controls whether compression is enabled or disable for VDO volume.
 See \fBlvmvdo\fP(7) for more information about VDO usage.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Sets or resets the contiguous allocation policy for LVs.
 Default is no contiguous allocation based on a next free principle.
 It is only possible to change a non-contiguous allocation policy
 to contiguous if all of the allocated physical extents in the LV
 are already contiguous.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--deduplication\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Controls whether deduplication is enabled or disable for VDO volume.
 See \fBlvmvdo\fP(7) for more information about VDO usage.
-.ad b
-.HP
+.TP
 .ad l
 \fB--deltag\fP \fITag\fP
 .br
+.ad b
 Deletes a tag from a PV, VG or LV. This option can be repeated to delete
 multiple tags at once. See \fBlvm\fP(8) for information about tags.
-.ad b
-.HP
+.TP
 .ad l
 \fB--detachprofile\fP
 .br
+.ad b
 Detaches a metadata profile from a VG or LV.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
 .br
+.ad b
 Specifies how the device-mapper thin pool layer in the kernel should
 handle discards.
 \fBignore\fP causes the thin pool to ignore discards.
@@ -826,18 +803,18 @@ allow reuse of unneeded extents in the thin pool.
 \fBpassdown\fP causes the thin pool to process discards itself
 (like nopassdown) and pass the discards to the underlying device.
 See \fBlvmthin\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB--errorwhenfull\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Specifies thin pool behavior when data space is exhausted.
 When yes, device-mapper will immediately return an error
 when a thin pool is full and an I/O request requires space.
@@ -846,140 +823,140 @@ period of time to allow the thin pool to be extended.
 Errors are returned if no space is available after the timeout.
 (Also see dm-thin-pool kernel module option no_space_timeout.)
 See \fBlvmthin\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
+.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB-K\fP|\fB--ignoreactivationskip\fP
 .br
+.ad b
 Ignore the "activation skip" LV flag during activation
 to allow LVs with the flag set to be activated.
-.ad b
-.HP
+.TP
 .ad l
 \fB--ignorelockingfailure\fP
 .br
+.ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
-.ad b
-.HP
+.TP
 .ad l
 \fB--ignoremonitoring\fP
 .br
+.ad b
 Do not interact with dmeventd unless --monitor is specified.
 Do not use this if dmeventd is already monitoring a device.
-.ad b
-.HP
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB-j\fP|\fB--major\fP \fINumber\fP
 .br
-Sets the major number of an LV block device.
 .ad b
-.HP
+Sets the major number of an LV block device.
+.TP
 .ad l
 \fB--[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT]
 .br
+.ad b
 Sets the maximum recovery rate for a RAID LV.  The rate value
 is an amount of data per second for each device in the array.
 Setting the rate to 0 means it will be unbounded.
 See \fBlvmraid\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--metadataprofile\fP \fIString\fP
 .br
+.ad b
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--minor\fP \fINumber\fP
 .br
-Sets the minor number of an LV block device.
 .ad b
-.HP
+Sets the minor number of an LV block device.
+.TP
 .ad l
 \fB--[raid]minrecoveryrate\fP \fISize\fP[k|UNIT]
 .br
+.ad b
 Sets the minimum recovery rate for a RAID LV.  The rate value
 is an amount of data per second for each device in the array.
 Setting the rate to 0 means it will be unbounded.
 See \fBlvmraid\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--monitor\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Start (yes) or stop (no) monitoring an LV with dmeventd.
 dmeventd monitors kernel events for an LV, and performs
 automated maintenance for the LV in reponse to specific events.
 See \fBdmeventd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--noudevsync\fP
 .br
+.ad b
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
-.ad b
-.HP
+.TP
 .ad l
 \fB-P\fP|\fB--partial\fP
 .br
+.ad b
 Commands will do their best to activate LVs with missing PV extents.
 Missing extents may be replaced with error or zero segments
 according to the lvm.conf missing_stripe_filler setting.
 Metadata may not be changed with this option.
-.ad b
-.HP
+.TP
 .ad l
 \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP
 .br
-Set access permission to read only \fBr\fP or read and write \fBrw\fP.
 .ad b
-.HP
+Set access permission to read only \fBr\fP or read and write \fBrw\fP.
+.TP
 .ad l
 \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP
 .br
-When yes, makes the specified minor number persistent.
 .ad b
-.HP
+When yes, makes the specified minor number persistent.
+.TP
 .ad l
 \fB--poll\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 When yes, start the background transformation of an LV.
 An incomplete transformation, e.g. pvmove or lvconvert interrupted
 by reboot or crash, can be restarted from the last checkpoint with --poll y.
@@ -987,76 +964,76 @@ When no, background transformation of an LV will not occur, and the
 transformation will not complete. It may not be appropriate to immediately
 poll an LV after activation, in which case --poll n can be used to defer
 polling until a later --poll y command.
-.ad b
-.HP
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP
 .br
+.ad b
 Sets read ahead sector count of an LV.
 \fBauto\fP is the default which allows the kernel to choose
 a suitable value automatically.
 \fBnone\fP is equivalent to zero.
-.ad b
-.HP
+.TP
 .ad l
 \fB--readonly\fP
 .br
+.ad b
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
-.ad b
-.HP
+.TP
 .ad l
 \fB--rebuild\fP \fIPV\fP
 .br
+.ad b
 Selects a PV to rebuild in a raid LV. Multiple PVs can be rebuilt by
 repeating this option.
 Use this option in place of --resync or --syncaction repair when the
 PVs with corrupted data are known, and their data should be reconstructed
 rather than reconstructing default (rotating) data.
 See \fBlvmraid\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--refresh\fP
 .br
+.ad b
 If the LV is active, reload its metadata.
 This is not necessary in normal operation, but may be useful
 if something has gone wrong, or if some form of manual LV
 sharing is being used.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--resync\fP
 .br
+.ad b
 Initiates mirror synchronization. Synchronization generally happens
 automatically, but this option forces it to run.
 Also see --rebuild to synchronize a specific PV.
@@ -1064,11 +1041,11 @@ During synchronization, data is read from the primary mirror device
 and copied to the others. This can take considerable time, during
 which the LV is without a complete redundant copy of the data.
 See \fBlvmraid\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
+.ad b
 Select objects for processing and reporting based on specified criteria.
 The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
@@ -1077,22 +1054,36 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
-.ad b
-.HP
+.TP
 .ad l
 \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Persistently sets (yes) or clears (no) the "activation skip" flag on an LV.
 An LV with this flag set is not activated unless the
 --ignoreactivationskip option is used by the activation command.
 This flag is set by default on new thin snapshot LVs.
 The flag is not applied to deactivation.
 The current value of the flag is indicated in the lvs lv_attr bits.
+.TP
+.ad l
+\fB--setautoactivation\fP \fBy\fP|\fBn\fP
+.br
 .ad b
-.HP
+Set the autoactivation property on a VG or LV.
+Display the property with vgs or lvs "-o autoactivation".
+When the autoactivation property is disabled, the VG or LV
+will not be activated by a command doing autoactivation
+(vgchange, lvchange, or pvscan using -aay.)
+If autoactivation is disabled on a VG, no LVs will be autoactivated
+in that VG, and the LV autoactivation property has no effect.
+If autoactivation is enabled on a VG, autoactivation can be disabled
+for individual LVs.
+.TP
 .ad l
 \fB--[raid]syncaction\fP \fBcheck\fP|\fBrepair\fP
 .br
+.ad b
 Initiate different types of RAID synchronization.
 This causes the RAID LV to read all data and parity
 blocks in the array and check for discrepancies
@@ -1100,11 +1091,11 @@ blocks in the array and check for discrepancies
 \fBcheck\fP will count but not correct discrepancies.
 \fBrepair\fP will correct discrepancies.
 See lvs for reporting discrepancies found or repaired.
-.ad b
-.HP
+.TP
 .ad l
 \fB--sysinit\fP
 .br
+.ad b
 Indicates that vgchange/lvchange is being invoked from early system initialisation
 scripts (e.g. rc.sysinit or an initrd), before writable filesystems are
 available. As such, some functionality needs to be disabled and this option
@@ -1112,45 +1103,45 @@ acts as a shortcut which selects an appropriate set of options. Currently,
 this is equivalent to using --ignorelockingfailure, --ignoremonitoring,
 --poll n, and setting env var LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES.
 vgchange/lvchange skip autoactivation, and defer to pvscan autoactivation.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB--[raid]writebehind\fP \fINumber\fP
 .br
+.ad b
 The maximum number of outstanding writes that are allowed to
 devices in a RAID1 LV that is marked write-mostly.
 Once this value is exceeded, writes become synchronous (i.e. all writes
 to the constituent devices must complete before the array signals the
 write has completed). Setting the value to zero clears the preference
 and allows the system to choose the value arbitrarily.
-.ad b
-.HP
+.TP
 .ad l
 \fB--[raid]writemostly\fP \fIPV\fP[\fB:t\fP|\fBn\fP|\fBy\fP]
 .br
+.ad b
 Mark a device in a RAID1 LV as write-mostly.  All reads
 to these drives will be avoided unless absolutely necessary. This keeps
 the number of I/Os to the drive to a minimum. The default behavior is to
@@ -1159,50 +1150,49 @@ It is also possible to remove the write-mostly flag by adding the
 suffix \fB:n\fP at the end of the PV name, or to toggle the value with
 the suffix \fB:t\fP. Repeat this option to change the attribute on
 multiple PVs.
-.ad b
-.HP
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
-.HP
+.TP
 .ad l
 \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Set zeroing mode for thin pool. Note: already provisioned blocks from pool
 in non-zero mode are not cleared in unwritten parts when setting --zero y.
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
+.TP
 \fILV\fP
 .br
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
 LV followed by _<type> indicates that an LV of the
 given type is required. (raid represents raid<N> type)
-.HP
+.TP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.HP
+.TP
 \fISelect\fP
 .br
 Select indicates that a required positional parameter can
 be omitted if the \fB--select\fP option is used.
 No arg appears in this position.
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -1222,70 +1212,71 @@ Change LV permission to read-only:
 .sp
 .B lvchange -pr vg00/lvol1
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index f6b364611..cfe3a56ff 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -11,7 +11,10 @@ lvconvert - Change logical volume layout
 .br
 .P
 .ad l
-    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
+    \fB--alloc\fP 
+.nh
+\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+.hy
 .ad b
 .br
 .ad l
@@ -259,7 +262,10 @@ lvconvert - Change logical volume layout
 .ad b
 .br
 .ad l
-    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBraid\fP|\fBmirror\fP|\fBthin\fP|\fBthin-pool\fP|\fBvdo\fP|\fBvdo-pool\fP|\fBcache\fP|\fBcache-pool\fP|\fBwritecache\fP
+    \fB--type\fP 
+.nh
+\fBlinear\fP|\:\fBstriped\fP|\:\fBsnapshot\fP|\:\fBraid\fP|\:\fBmirror\fP|\:\fBthin\fP|\:\fBthin-pool\fP|\:\fBvdo\fP|\:\fBvdo-pool\fP|\:\fBcache\fP|\:\fBcache-pool\fP|\:\fBwritecache\fP
+.hy
 .ad b
 .br
 .ad l
@@ -1110,7 +1116,11 @@ Common options for command:
 .ad b
 .br
 .ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+[    \fB--alloc\fP 
+.nh
+\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+.hy
+]
 .ad b
 .br
 .ad l
@@ -1186,10 +1196,14 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
-\fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
+\fB--alloc\fP 
+.nh
+\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+.hy
 .br
+.ad b
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
 which can be changed with vgchange/lvchange, or overridden on the
@@ -1206,39 +1220,39 @@ e.g. by placing two stripes on the same PV.
 Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
-.ad b
-.HP
+.TP
 .ad l
 \fB-b\fP|\fB--background\fP
 .br
+.ad b
 If the operation requires polling, this option causes the command to
 return before the operation is complete, and polling is done in the
 background.
-.ad b
-.HP
+.TP
 .ad l
 \fB-H\fP|\fB--cache\fP
 .br
+.ad b
 Specifies the command is handling a cache LV or cache pool.
 See --type cache and --type cache-pool.
 See \fBlvmcache\fP(7) for more information about LVM caching.
-.ad b
-.HP
+.TP
 .ad l
 \fB--cachedevice\fP \fIPV\fP
 .br
-The name of a device to use for a cache.
 .ad b
-.HP
+The name of a device to use for a cache.
+.TP
 .ad l
 \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP
 .br
-Specifies the cache metadata format used by cache target.
 .ad b
-.HP
+Specifies the cache metadata format used by cache target.
+.TP
 .ad l
 \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP
 .br
+.ad b
 Specifies when writes to a cache LV should be considered complete.
 \fBwriteback\fP considers a write complete as soon as it is
 stored in the cache pool.
@@ -1250,24 +1264,24 @@ cache pool LV. With \fBpassthrough\fP, all reads are served
 from the origin LV (all reads miss the cache) and all writes are
 forwarded to the origin LV; additionally, write hits cause cache
 block invalidates. See \fBlvmcache\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--cachepolicy\fP \fIString\fP
 .br
+.ad b
 Specifies the cache policy for a cache LV.
 See \fBlvmcache\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--cachepool\fP \fILV\fP
 .br
-The name of a cache pool.
 .ad b
-.HP
+The name of a cache pool.
+.TP
 .ad l
 \fB--cachesettings\fP \fIString\fP
 .br
+.ad b
 Specifies tunable values for a cache LV in "Key = Value" form.
 Repeat this option to specify multiple values.
 (The default values should usually be adequate.)
@@ -1275,23 +1289,23 @@ The special string value \fBdefault\fP switches
 settings back to their default kernel values and removes
 them from the list of settings stored in LVM metadata.
 See \fBlvmcache\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--cachesize\fP \fISize\fP[m|UNIT]
 .br
-The size of cache to use.
 .ad b
-.HP
+The size of cache to use.
+.TP
 .ad l
 \fB--cachevol\fP \fILV\fP
 .br
-The name of a cache volume.
 .ad b
-.HP
+The name of a cache volume.
+.TP
 .ad l
 \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT]
 .br
+.ad b
 The size of chunks in a snapshot, cache pool or thin pool.
 For snapshots, the value must be a power of 2 between 4KiB and 512KiB
 and the default value is 4.
@@ -1302,66 +1316,66 @@ and the default value starts with 64 and scales up to fit the
 pool metadata size within 128MiB, if the pool metadata size is not specified.
 The value must be a multiple of 64KiB.
 See \fBlvmthin\fP(7) and \fBlvmcache\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--compression\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Controls whether compression is enabled or disable for VDO volume.
 See \fBlvmvdo\fP(7) for more information about VDO usage.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--deduplication\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Controls whether deduplication is enabled or disable for VDO volume.
 See \fBlvmvdo\fP(7) for more information about VDO usage.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
 .br
+.ad b
 Specifies how the device-mapper thin pool layer in the kernel should
 handle discards.
 \fBignore\fP causes the thin pool to ignore discards.
@@ -1370,18 +1384,18 @@ allow reuse of unneeded extents in the thin pool.
 \fBpassdown\fP causes the thin pool to process discards itself
 (like nopassdown) and pass the discards to the underlying device.
 See \fBlvmthin\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB--errorwhenfull\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Specifies thin pool behavior when data space is exhausted.
 When yes, device-mapper will immediately return an error
 when a thin pool is full and an I/O request requires space.
@@ -1390,57 +1404,57 @@ period of time to allow the thin pool to be extended.
 Errors are returned if no space is available after the timeout.
 (Also see dm-thin-pool kernel module option no_space_timeout.)
 See \fBlvmthin\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
+.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB-i\fP|\fB--interval\fP \fINumber\fP
 .br
-Report progress at regular intervals.
 .ad b
-.HP
+Report progress at regular intervals.
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB--merge\fP
 .br
+.ad b
 An alias for --mergethin, --mergemirrors, or --mergesnapshot,
 depending on the type of LV.
-.ad b
-.HP
+.TP
 .ad l
 \fB--mergemirrors\fP
 .br
+.ad b
 Merge LV images that were split from a raid1 LV.
 See --splitmirrors with --trackchanges.
-.ad b
-.HP
+.TP
 .ad l
 \fB--mergesnapshot\fP
 .br
+.ad b
 Merge COW snapshot LV into its origin.
 When merging a snapshot, if both the origin and snapshot LVs are not open,
 the merge will start immediately. Otherwise, the merge will start the
@@ -1453,27 +1467,27 @@ reads or writes to the origin appear as being directed to the snapshot
 being merged. When the merge finishes, the merged snapshot is removed.
 Multiple snapshots may be specified on the command line or a @tag may be
 used to specify multiple snapshots be merged to their respective origin.
-.ad b
-.HP
+.TP
 .ad l
 \fB--mergethin\fP
 .br
+.ad b
 Merge thin LV into its origin LV.
 The origin thin LV takes the content of the thin snapshot,
 and the thin snapshot LV is removed.
 See \fBlvmthin\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--metadataprofile\fP \fIString\fP
 .br
+.ad b
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP
 .br
+.ad b
 Specifies the type of mirror log for LVs with the "mirror" type
 (does not apply to the "raid1" type.)
 \fBdisk\fP is a persistent log and requires a small amount of
@@ -1483,11 +1497,11 @@ In this case, the mirror must be synchronized (by copying LV data from
 the first device to others) each time the LV is activated, e.g. after reboot.
 \fBmirrored\fP is a persistent log that is itself mirrored, but
 should be avoided. Instead, use the raid1 type for log redundancy.
-.ad b
-.HP
+.TP
 .ad l
 \fB-m\fP|\fB--mirrors\fP [\fB+\fP|\fB-\fP]\fINumber\fP
 .br
+.ad b
 Specifies the number of mirror images in addition to the original LV
 image, e.g. --mirrors 1 means there are two images of the data, the
 original and one mirror image.
@@ -1504,93 +1518,93 @@ the number is added to the current number of images,
 or the minus prefix \fB-\fP can be used, in which case
 the number is subtracted from the current number of images.
 See \fBlvmraid\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-n\fP|\fB--name\fP \fIString\fP
 .br
+.ad b
 Specifies the name of a new LV.
 When unspecified, a default name of "lvol#" is
 generated, where # is a number generated by LVM.
-.ad b
-.HP
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--noudevsync\fP
 .br
+.ad b
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
-.ad b
-.HP
+.TP
 .ad l
 \fB--originname\fP \fILV\fP
 .br
+.ad b
 Specifies the name to use for the external origin LV when converting an LV
 to a thin LV. The LV being converted becomes a read-only external origin
 with this name.
-.ad b
-.HP
+.TP
 .ad l
 \fB--poolmetadata\fP \fILV\fP
 .br
-The name of a an LV to use for storing pool metadata.
 .ad b
-.HP
+The name of a an LV to use for storing pool metadata.
+.TP
 .ad l
 \fB--poolmetadatasize\fP \fISize\fP[m|UNIT]
 .br
-Specifies the size of the new pool metadata LV.
 .ad b
-.HP
+Specifies the size of the new pool metadata LV.
+.TP
 .ad l
 \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Enable or disable the automatic creation and management of a
 spare pool metadata LV in the VG. A spare metadata LV is reserved
 space that can be used when repairing a pool.
-.ad b
-.HP
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--raidintegrity\fP \fBy\fP|\fBn\fP
 .br
-Enable or disable data integrity checksums for raid images.
 .ad b
-.HP
+Enable or disable data integrity checksums for raid images.
+.TP
 .ad l
 \fB--raidintegrityblocksize\fP \fINumber\fP
 .br
+.ad b
 The block size to use for dm-integrity on raid images.
 The integrity block size should usually match the device
 logical block size, or the file system block size.
 It may be less than the file system block size, but not
 less than the device logical block size.
 Possible values: 512, 1024, 2048, 4096.
-.ad b
-.HP
+.TP
 .ad l
 \fB--raidintegritymode\fP \fIString\fP
 .br
+.ad b
 Use a journal (default) or bitmap for keeping integrity checksums consistent
 in case of a crash. The bitmap areas are recalculated after a crash, so corruption
 in those areas would not be detected. A journal does not have this problem.
@@ -1598,135 +1612,135 @@ The journal mode doubles writes to storage, but can improve performance for
 scattered writes packed into a single journal write.
 bitmap mode can in theory achieve full write throughput of the device,
 but would not benefit from the potential scattered write optimization.
-.ad b
-.HP
+.TP
 .ad l
 \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP
 .br
+.ad b
 Sets read ahead sector count of an LV.
 \fBauto\fP is the default which allows the kernel to choose
 a suitable value automatically.
 \fBnone\fP is equivalent to zero.
-.ad b
-.HP
+.TP
 .ad l
 \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT]
 .br
+.ad b
 Size of each raid or mirror synchronization region.
 lvm.conf activation/raid_region_size can be used to
 configure a default.
-.ad b
-.HP
+.TP
 .ad l
 \fB--repair\fP
 .br
+.ad b
 Replace failed PVs in a raid or mirror LV, or run a repair
 utility on a thin pool. See \fBlvmraid\fP(7) and \fBlvmthin\fP(7)
 for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--replace\fP \fIPV\fP
 .br
+.ad b
 Replace a specific PV in a raid LV with another PV.
 The new PV to use can be optionally specified after the LV.
 Multiple PVs can be replaced by repeating this option.
 See \fBlvmraid\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-s\fP|\fB--snapshot\fP
 .br
+.ad b
 Combine a former COW snapshot LV with a former origin LV to reverse
 a previous --splitsnapshot command.
-.ad b
-.HP
+.TP
 .ad l
 \fB--splitcache\fP
 .br
+.ad b
 Separates a cache pool from a cache LV, and keeps the unused cache pool LV.
 Before the separation, the cache is flushed. Also see --uncache.
-.ad b
-.HP
+.TP
 .ad l
 \fB--splitmirrors\fP \fINumber\fP
 .br
+.ad b
 Splits the specified number of images from a raid1 or mirror LV
 and uses them to create a new LV. If --trackchanges is also specified,
 changes to the raid1 LV are tracked while the split LV remains detached.
 If --name is specified, then the images are permanently split from the
 original LV and changes are not tracked.
-.ad b
-.HP
+.TP
 .ad l
 \fB--splitsnapshot\fP
 .br
+.ad b
 Separates a COW snapshot from its origin LV. The LV that is split off
 contains the chunks that differ from the origin LV along with metadata
 describing them. This LV can be wiped and then destroyed with lvremove.
-.ad b
-.HP
+.TP
 .ad l
 \fB--startpoll\fP
 .br
-Start polling an LV to continue processing a conversion.
 .ad b
-.HP
+Start polling an LV to continue processing a conversion.
+.TP
 .ad l
 \fB--stripes\fP \fINumber\fP
 .br
+.ad b
 Specifies the number of stripes in a striped LV. This is the number of
 PVs (devices) that a striped LV is spread across. Data that
 appears sequential in the LV is spread across multiple devices in units of
 the stripe size (see --stripesize). This does not apply to
 existing allocated space, only newly allocated space can be striped.
-.ad b
-.HP
+.TP
 .ad l
 \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT]
 .br
+.ad b
 The amount of data that is written to one device before
 moving to the next in a striped LV.
-.ad b
-.HP
+.TP
 .ad l
 \fB--swapmetadata\fP
 .br
+.ad b
 Extracts the metadata LV from a pool and replaces it with another specified LV.
 The extracted LV is preserved and given the name of the LV that replaced it.
 Use for repair only. When the metadata LV is swapped out of the pool, it can
 be activated directly and used with thin provisioning tools:
 \fBcache_dump\fP(8), \fBcache_repair\fP(8), \fBcache_restore\fP(8),
 \fBthin_dump\fP(8), \fBthin_repair\fP(8), \fBthin_restore\fP(8).
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-T\fP|\fB--thin\fP
 .br
+.ad b
 Specifies the command is handling a thin LV or thin pool.
 See --type thin, --type thin-pool, and --virtualsize.
 See \fBlvmthin\fP(7) for more information about LVM thin provisioning.
-.ad b
-.HP
+.TP
 .ad l
 \fB--thinpool\fP \fILV\fP
 .br
-The name of a thin pool LV.
 .ad b
-.HP
+The name of a thin pool LV.
+.TP
 .ad l
 \fB--trackchanges\fP
 .br
+.ad b
 Can be used with --splitmirrors on a raid1 LV. This causes
 changes to the original raid1 LV to be tracked while the split images
 remain detached. This is a temporary state that allows the read-only
@@ -1735,11 +1749,14 @@ Only the regions with changed data are resynchronized during merge.
 While a raid1 LV is tracking changes, operations on it are limited to
 merging the split image (see --mergemirrors) or permanently splitting
 the image (see --splitmirrors with --name.
-.ad b
-.HP
+.TP
 .ad l
-\fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBraid\fP|\fBmirror\fP|\fBthin\fP|\fBthin-pool\fP|\fBvdo\fP|\fBvdo-pool\fP|\fBcache\fP|\fBcache-pool\fP|\fBwritecache\fP
+\fB--type\fP 
+.nh
+\fBlinear\fP|\:\fBstriped\fP|\:\fBsnapshot\fP|\:\fBraid\fP|\:\fBmirror\fP|\:\fBthin\fP|\:\fBthin-pool\fP|\:\fBvdo\fP|\:\fBvdo-pool\fP|\:\fBcache\fP|\:\fBcache-pool\fP|\:\fBwritecache\fP
+.hy
 .br
+.ad b
 The LV type, also known as "segment type" or "segtype".
 See usage descriptions for the specific ways to use these types.
 For more information about redundancy and performance (\fBraid\fP<N>, \fBmirror\fP, \fBstriped\fP, \fBlinear\fP) see \fBlvmraid\fP(7).
@@ -1751,45 +1768,45 @@ Several commands omit an explicit type option because the type
 is inferred from other options or shortcuts
 (e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache, --vdo).
 Use inferred types with care because it can lead to unexpected results.
-.ad b
-.HP
+.TP
 .ad l
 \fB--uncache\fP
 .br
+.ad b
 Separates a cache pool from a cache LV, and deletes the unused cache pool LV.
 Before the separation, the cache is flushed. Also see --splitcache.
-.ad b
-.HP
+.TP
 .ad l
 \fB--usepolicies\fP
 .br
+.ad b
 Perform an operation according to the policy configured in lvm.conf
 or a profile.
-.ad b
-.HP
+.TP
 .ad l
 \fB--vdopool\fP \fILV\fP
 .br
+.ad b
 The name of a VDO pool LV.
 See \fBlvmvdo\fP(7) for more information about VDO usage.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT]
 .br
+.ad b
 The virtual size of a new thin LV.
 See \fBlvmthin\fP(7) for more information about LVM thin provisioning.
 Using virtual size (-V) and actual size (-L) together creates
@@ -1802,37 +1819,36 @@ When using a snapshot to create a sparse LV, a hidden virtual device
 is created using the zero target, and the LV has the suffix _vorigin.
 Snapshots are less efficient than thin provisioning when creating
 large sparse LVs (GiB).
-.ad b
-.HP
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
-.HP
+.TP
 .ad l
 \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 For snapshots, this controls zeroing of the first 4KiB of data in the
 snapshot. If the LV is read-only, the snapshot will not be zeroed.
 For thin pools, this controls zeroing of provisioned blocks.
 Provisioning of large zeroed chunks negatively impacts performance.
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
+.TP
 \fILV\fP
 .br
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
 LV followed by _<type> indicates that an LV of the
 given type is required. (raid represents raid<N> type)
-.HP
+.TP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -1842,16 +1858,16 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
+.TP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -2295,70 +2311,71 @@ Detach and remove the cache pool from a cache LV.
 .br
 .B lvconvert --uncache vg/lvol1
 .SH SEE ALSO
-
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
-
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
-
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
-
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
-
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
-
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
+
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
+
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
+
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
+
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
+
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
+
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/lvcreate.8_pregen b/man/lvcreate.8_pregen
index c19b7da7b..e804f9ce0 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -19,7 +19,10 @@ lvcreate - Create a logical volume
 .ad b
 .br
 .ad l
-    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
+    \fB--alloc\fP 
+.nh
+\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+.hy
 .ad b
 .br
 .ad l
@@ -234,6 +237,10 @@ lvcreate - Create a logical volume
  \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP
 .ad b
 .br
+.ad l
+    \fB--setautoactivation\fP \fBy\fP|\fBn\fP
+.ad b
+.br
 .ad l
  \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT]
 .ad b
@@ -263,7 +270,10 @@ lvcreate - Create a logical volume
 .ad b
 .br
 .ad l
-    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBraid\fP|\fBmirror\fP|\fBthin\fP|\fBthin-pool\fP|\fBvdo\fP|\fBvdo-pool\fP|\fBcache\fP|\fBcache-pool\fP|\fBwritecache\fP
+    \fB--type\fP 
+.nh
+\fBlinear\fP|\:\fBstriped\fP|\:\fBsnapshot\fP|\:\fBraid\fP|\:\fBmirror\fP|\:\fBthin\fP|\:\fBthin-pool\fP|\:\fBvdo\fP|\:\fBvdo-pool\fP|\:\fBcache\fP|\:\fBcache-pool\fP|\:\fBwritecache\fP
+.hy
 .ad b
 .br
 .ad l
@@ -1139,7 +1149,11 @@ Common options for command:
 .ad b
 .br
 .ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+[    \fB--alloc\fP 
+.nh
+\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+.hy
+]
 .ad b
 .br
 .ad l
@@ -1169,6 +1183,10 @@ Common options for command:
 .ad l
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
 .ad b
+.br
+.ad l
+[    \fB--setautoactivation\fP \fBy\fP|\fBn\fP ]
+.ad b
 .RE
 
 Common options for lvm:
@@ -1239,10 +1257,11 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP
 .br
+.ad b
 Controls the active state of the new LV.
 \fBy\fP makes the LV active, or available.
 New LVs are made active by default.
@@ -1255,18 +1274,21 @@ If autoactivation \fBay\fP is used, the LV is only activated
 if it matches an item in lvm.conf activation/auto_activation_volume_list.
 \fBay\fP implies --zero n and --wipesignatures n.
 See \fBlvmlockd\fP(8) for more information about activation options for shared VGs.
-.ad b
-.HP
+.TP
 .ad l
 \fB--addtag\fP \fITag\fP
 .br
+.ad b
 Adds a tag to a PV, VG or LV. This option can be repeated to add
 multiple tags at once. See \fBlvm\fP(8) for information about tags.
-.ad b
-.HP
+.TP
 .ad l
-\fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
+\fB--alloc\fP 
+.nh
+\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+.hy
 .br
+.ad b
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
 which can be changed with vgchange/lvchange, or overridden on the
@@ -1283,38 +1305,38 @@ e.g. by placing two stripes on the same PV.
 Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
-.ad b
-.HP
+.TP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-H\fP|\fB--cache\fP
 .br
+.ad b
 Specifies the command is handling a cache LV or cache pool.
 See --type cache and --type cache-pool.
 See \fBlvmcache\fP(7) for more information about LVM caching.
-.ad b
-.HP
+.TP
 .ad l
 \fB--cachedevice\fP \fIPV\fP
 .br
-The name of a device to use for a cache.
 .ad b
-.HP
+The name of a device to use for a cache.
+.TP
 .ad l
 \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP
 .br
-Specifies the cache metadata format used by cache target.
 .ad b
-.HP
+Specifies the cache metadata format used by cache target.
+.TP
 .ad l
 \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP
 .br
+.ad b
 Specifies when writes to a cache LV should be considered complete.
 \fBwriteback\fP considers a write complete as soon as it is
 stored in the cache pool.
@@ -1326,24 +1348,24 @@ cache pool LV. With \fBpassthrough\fP, all reads are served
 from the origin LV (all reads miss the cache) and all writes are
 forwarded to the origin LV; additionally, write hits cause cache
 block invalidates. See \fBlvmcache\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--cachepolicy\fP \fIString\fP
 .br
+.ad b
 Specifies the cache policy for a cache LV.
 See \fBlvmcache\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--cachepool\fP \fILV\fP
 .br
-The name of a cache pool.
 .ad b
-.HP
+The name of a cache pool.
+.TP
 .ad l
 \fB--cachesettings\fP \fIString\fP
 .br
+.ad b
 Specifies tunable values for a cache LV in "Key = Value" form.
 Repeat this option to specify multiple values.
 (The default values should usually be adequate.)
@@ -1351,23 +1373,23 @@ The special string value \fBdefault\fP switches
 settings back to their default kernel values and removes
 them from the list of settings stored in LVM metadata.
 See \fBlvmcache\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--cachesize\fP \fISize\fP[m|UNIT]
 .br
-The size of cache to use.
 .ad b
-.HP
+The size of cache to use.
+.TP
 .ad l
 \fB--cachevol\fP \fILV\fP
 .br
-The name of a cache volume.
 .ad b
-.HP
+The name of a cache volume.
+.TP
 .ad l
 \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT]
 .br
+.ad b
 The size of chunks in a snapshot, cache pool or thin pool.
 For snapshots, the value must be a power of 2 between 4KiB and 512KiB
 and the default value is 4.
@@ -1378,76 +1400,76 @@ and the default value starts with 64 and scales up to fit the
 pool metadata size within 128MiB, if the pool metadata size is not specified.
 The value must be a multiple of 64KiB.
 See \fBlvmthin\fP(7) and \fBlvmcache\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--compression\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Controls whether compression is enabled or disable for VDO volume.
 See \fBlvmvdo\fP(7) for more information about VDO usage.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-C\fP|\fB--contiguous\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Sets or resets the contiguous allocation policy for LVs.
 Default is no contiguous allocation based on a next free principle.
 It is only possible to change a non-contiguous allocation policy
 to contiguous if all of the allocated physical extents in the LV
 are already contiguous.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--deduplication\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Controls whether deduplication is enabled or disable for VDO volume.
 See \fBlvmvdo\fP(7) for more information about VDO usage.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--discards\fP \fBpassdown\fP|\fBnopassdown\fP|\fBignore\fP
 .br
+.ad b
 Specifies how the device-mapper thin pool layer in the kernel should
 handle discards.
 \fBignore\fP causes the thin pool to ignore discards.
@@ -1456,18 +1478,18 @@ allow reuse of unneeded extents in the thin pool.
 \fBpassdown\fP causes the thin pool to process discards itself
 (like nopassdown) and pass the discards to the underlying device.
 See \fBlvmthin\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB--errorwhenfull\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Specifies thin pool behavior when data space is exhausted.
 When yes, device-mapper will immediately return an error
 when a thin pool is full and an I/O request requires space.
@@ -1476,11 +1498,11 @@ period of time to allow the thin pool to be extended.
 Errors are returned if no space is available after the timeout.
 (Also see dm-thin-pool kernel module option no_space_timeout.)
 See \fBlvmthin\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-l\fP|\fB--extents\fP \fINumber\fP[PERCENT]
 .br
+.ad b
 Specifies the size of the new LV in logical extents.
 The --size and --extents options are alternate methods of specifying size.
 The total number of physical extents used will be
@@ -1496,81 +1518,81 @@ the whole origin).
 When expressed as a percentage, the size defines an upper limit for the
 number of logical extents in the new LV. The precise number of logical
 extents in the new LV is not determined until the command has completed.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB-K\fP|\fB--ignoreactivationskip\fP
 .br
+.ad b
 Ignore the "activation skip" LV flag during activation
 to allow LVs with the flag set to be activated.
-.ad b
-.HP
+.TP
 .ad l
 \fB--ignoremonitoring\fP
 .br
+.ad b
 Do not interact with dmeventd unless --monitor is specified.
 Do not use this if dmeventd is already monitoring a device.
-.ad b
-.HP
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB-j\fP|\fB--major\fP \fINumber\fP
 .br
-Sets the major number of an LV block device.
 .ad b
-.HP
+Sets the major number of an LV block device.
+.TP
 .ad l
 \fB--[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT]
 .br
+.ad b
 Sets the maximum recovery rate for a RAID LV.  The rate value
 is an amount of data per second for each device in the array.
 Setting the rate to 0 means it will be unbounded.
 See \fBlvmraid\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--metadataprofile\fP \fIString\fP
 .br
+.ad b
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--minor\fP \fINumber\fP
 .br
-Sets the minor number of an LV block device.
 .ad b
-.HP
+Sets the minor number of an LV block device.
+.TP
 .ad l
 \fB--[raid]minrecoveryrate\fP \fISize\fP[k|UNIT]
 .br
+.ad b
 Sets the minimum recovery rate for a RAID LV.  The rate value
 is an amount of data per second for each device in the array.
 Setting the rate to 0 means it will be unbounded.
 See \fBlvmraid\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--mirrorlog\fP \fBcore\fP|\fBdisk\fP
 .br
+.ad b
 Specifies the type of mirror log for LVs with the "mirror" type
 (does not apply to the "raid1" type.)
 \fBdisk\fP is a persistent log and requires a small amount of
@@ -1580,11 +1602,11 @@ In this case, the mirror must be synchronized (by copying LV data from
 the first device to others) each time the LV is activated, e.g. after reboot.
 \fBmirrored\fP is a persistent log that is itself mirrored, but
 should be avoided. Instead, use the raid1 type for log redundancy.
-.ad b
-.HP
+.TP
 .ad l
 \fB-m\fP|\fB--mirrors\fP \fINumber\fP
 .br
+.ad b
 Specifies the number of mirror images in addition to the original LV
 image, e.g. --mirrors 1 means there are two images of the data, the
 original and one mirror image.
@@ -1598,34 +1620,34 @@ Use lvm.conf global/mirror_segtype_default and
 global/raid10_segtype_default to configure the default types.
 See the --nosync option for avoiding initial image synchronization.
 See \fBlvmraid\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--monitor\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Start (yes) or stop (no) monitoring an LV with dmeventd.
 dmeventd monitors kernel events for an LV, and performs
 automated maintenance for the LV in reponse to specific events.
 See \fBdmeventd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-n\fP|\fB--name\fP \fIString\fP
 .br
+.ad b
 Specifies the name of a new LV.
 When unspecified, a default name of "lvol#" is
 generated, where # is a number generated by LVM.
-.ad b
-.HP
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--nosync\fP
 .br
+.ad b
 Causes the creation of mirror, raid1, raid4, raid5 and raid10 to skip the
 initial synchronization. In case of mirror, raid1 and raid10, any data
 written afterwards will be mirrored, but the original contents will not be
@@ -1638,77 +1660,77 @@ This option is not valid for raid6, because raid6 relies on proper parity
 to reconstruct proper user date in case of device failures.
 raid0 and raid0_meta do not provide any data copies or parity support
 and thus do not support initial synchronization.
-.ad b
-.HP
+.TP
 .ad l
 \fB--noudevsync\fP
 .br
+.ad b
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
-.ad b
-.HP
+.TP
 .ad l
 \fB-p\fP|\fB--permission\fP \fBrw\fP|\fBr\fP
 .br
-Set access permission to read only \fBr\fP or read and write \fBrw\fP.
 .ad b
-.HP
+Set access permission to read only \fBr\fP or read and write \fBrw\fP.
+.TP
 .ad l
 \fB-M\fP|\fB--persistent\fP \fBy\fP|\fBn\fP
 .br
-When yes, makes the specified minor number persistent.
 .ad b
-.HP
+When yes, makes the specified minor number persistent.
+.TP
 .ad l
 \fB--poolmetadatasize\fP \fISize\fP[m|UNIT]
 .br
-Specifies the size of the new pool metadata LV.
 .ad b
-.HP
+Specifies the size of the new pool metadata LV.
+.TP
 .ad l
 \fB--poolmetadataspare\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Enable or disable the automatic creation and management of a
 spare pool metadata LV in the VG. A spare metadata LV is reserved
 space that can be used when repairing a pool.
-.ad b
-.HP
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--raidintegrity\fP \fBy\fP|\fBn\fP
 .br
-Enable or disable data integrity checksums for raid images.
 .ad b
-.HP
+Enable or disable data integrity checksums for raid images.
+.TP
 .ad l
 \fB--raidintegrityblocksize\fP \fINumber\fP
 .br
+.ad b
 The block size to use for dm-integrity on raid images.
 The integrity block size should usually match the device
 logical block size, or the file system block size.
 It may be less than the file system block size, but not
 less than the device logical block size.
 Possible values: 512, 1024, 2048, 4096.
-.ad b
-.HP
+.TP
 .ad l
 \fB--raidintegritymode\fP \fIString\fP
 .br
+.ad b
 Use a journal (default) or bitmap for keeping integrity checksums consistent
 in case of a crash. The bitmap areas are recalculated after a crash, so corruption
 in those areas would not be detected. A journal does not have this problem.
@@ -1716,59 +1738,73 @@ The journal mode doubles writes to storage, but can improve performance for
 scattered writes packed into a single journal write.
 bitmap mode can in theory achieve full write throughput of the device,
 but would not benefit from the potential scattered write optimization.
-.ad b
-.HP
+.TP
 .ad l
 \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP
 .br
+.ad b
 Sets read ahead sector count of an LV.
 \fBauto\fP is the default which allows the kernel to choose
 a suitable value automatically.
 \fBnone\fP is equivalent to zero.
-.ad b
-.HP
+.TP
 .ad l
 \fB-R\fP|\fB--regionsize\fP \fISize\fP[m|UNIT]
 .br
+.ad b
 Size of each raid or mirror synchronization region.
 lvm.conf activation/raid_region_size can be used to
 configure a default.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-k\fP|\fB--setactivationskip\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Persistently sets (yes) or clears (no) the "activation skip" flag on an LV.
 An LV with this flag set is not activated unless the
 --ignoreactivationskip option is used by the activation command.
 This flag is set by default on new thin snapshot LVs.
 The flag is not applied to deactivation.
 The current value of the flag is indicated in the lvs lv_attr bits.
+.TP
+.ad l
+\fB--setautoactivation\fP \fBy\fP|\fBn\fP
+.br
 .ad b
-.HP
+Set the autoactivation property on a VG or LV.
+Display the property with vgs or lvs "-o autoactivation".
+When the autoactivation property is disabled, the VG or LV
+will not be activated by a command doing autoactivation
+(vgchange, lvchange, or pvscan using -aay.)
+If autoactivation is disabled on a VG, no LVs will be autoactivated
+in that VG, and the LV autoactivation property has no effect.
+If autoactivation is enabled on a VG, autoactivation can be disabled
+for individual LVs.
+.TP
 .ad l
 \fB-L\fP|\fB--size\fP \fISize\fP[m|UNIT]
 .br
+.ad b
 Specifies the size of the new LV.
 The --size and --extents options are alternate methods of specifying size.
 The total number of physical extents used will be
 greater when redundant data is needed for RAID levels.
-.ad b
-.HP
+.TP
 .ad l
 \fB-s\fP|\fB--snapshot\fP
 .br
+.ad b
 Create a snapshot. Snapshots provide a "frozen image" of an origin LV.
 The snapshot LV can be used, e.g. for backups, while the origin LV
 continues to be used.
@@ -1794,11 +1830,11 @@ A small amount of the COW snapshot LV size is used to track COW block
 locations, so the full size is not available for COW data blocks.
 Use lvs to check how much space is used, and see --monitor to
 to automatically extend the size to avoid running out of space.
-.ad b
-.HP
+.TP
 .ad l
 \fB-i\fP|\fB--stripes\fP \fINumber\fP
 .br
+.ad b
 Specifies the number of stripes in a striped LV. This is the number of
 PVs (devices) that a striped LV is spread across. Data that
 appears sequential in the LV is spread across multiple devices in units of
@@ -1811,42 +1847,45 @@ when unspecified, the default depends on the RAID type
 (raid0: 2, raid10: 2, raid4/5: 3, raid6: 5.)
 To stripe a new raid LV across all PVs by default,
 see lvm.conf allocation/raid_stripe_all_devices.
-.ad b
-.HP
+.TP
 .ad l
 \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT]
 .br
+.ad b
 The amount of data that is written to one device before
 moving to the next in a striped LV.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-T\fP|\fB--thin\fP
 .br
+.ad b
 Specifies the command is handling a thin LV or thin pool.
 See --type thin, --type thin-pool, and --virtualsize.
 See \fBlvmthin\fP(7) for more information about LVM thin provisioning.
-.ad b
-.HP
+.TP
 .ad l
 \fB--thinpool\fP \fILV\fP
 .br
-The name of a thin pool LV.
 .ad b
-.HP
+The name of a thin pool LV.
+.TP
 .ad l
-\fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBraid\fP|\fBmirror\fP|\fBthin\fP|\fBthin-pool\fP|\fBvdo\fP|\fBvdo-pool\fP|\fBcache\fP|\fBcache-pool\fP|\fBwritecache\fP
+\fB--type\fP 
+.nh
+\fBlinear\fP|\:\fBstriped\fP|\:\fBsnapshot\fP|\:\fBraid\fP|\:\fBmirror\fP|\:\fBthin\fP|\:\fBthin-pool\fP|\:\fBvdo\fP|\:\fBvdo-pool\fP|\:\fBcache\fP|\:\fBcache-pool\fP|\:\fBwritecache\fP
+.hy
 .br
+.ad b
 The LV type, also known as "segment type" or "segtype".
 See usage descriptions for the specific ways to use these types.
 For more information about redundancy and performance (\fBraid\fP<N>, \fBmirror\fP, \fBstriped\fP, \fBlinear\fP) see \fBlvmraid\fP(7).
@@ -1858,39 +1897,39 @@ Several commands omit an explicit type option because the type
 is inferred from other options or shortcuts
 (e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache, --vdo).
 Use inferred types with care because it can lead to unexpected results.
-.ad b
-.HP
+.TP
 .ad l
 \fB--vdo\fP
 .br
+.ad b
 Specifies the command is handling VDO LV.
 See --type vdo.
 See \fBlvmvdo\fP(7) for more information about VDO usage.
-.ad b
-.HP
+.TP
 .ad l
 \fB--vdopool\fP \fILV\fP
 .br
+.ad b
 The name of a VDO pool LV.
 See \fBlvmvdo\fP(7) for more information about VDO usage.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-V\fP|\fB--virtualsize\fP \fISize\fP[m|UNIT]
 .br
+.ad b
 The virtual size of a new thin LV.
 See \fBlvmthin\fP(7) for more information about LVM thin provisioning.
 Using virtual size (-V) and actual size (-L) together creates
@@ -1903,11 +1942,11 @@ When using a snapshot to create a sparse LV, a hidden virtual device
 is created using the zero target, and the LV has the suffix _vorigin.
 Snapshots are less efficient than thin provisioning when creating
 large sparse LVs (GiB).
-.ad b
-.HP
+.TP
 .ad l
 \fB-W\fP|\fB--wipesignatures\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Controls detection and subsequent wiping of signatures on new LVs.
 There is a prompt for each signature detected to confirm its wiping
 (unless --yes is used to override confirmations.)
@@ -1921,42 +1960,41 @@ signatures that are recognized).
 Otherwise, native LVM code is used to detect signatures
 (only MD RAID, swap and LUKS signatures are detected in this case.)
 The LV is not wiped if the read only flag is set.
-.ad b
-.HP
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
-.HP
+.TP
 .ad l
 \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Controls zeroing of the first 4KiB of data in the new LV.
 Default is \fBy\fP.
 Snapshot COW volumes are always zeroed.
 For thin pools, this controls zeroing of provisioned blocks.
 LV is not zeroed if the read only flag is set.
 Warning: trying to mount an unzeroed LV can cause the system to hang.
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
 For lvcreate, the required VG positional arg may be
 omitted when the VG name is included in another option,
 e.g. --name VG/LV.
-.HP
+.TP
 \fILV\fP
 .br
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
 LV followed by _<type> indicates that an LV of the
 given type is required. (raid represents raid<N> type)
-.HP
+.TP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -1966,11 +2004,11 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -3192,70 +3230,71 @@ Create a VDO LV vdo0 with VDOPoolLV size of 10GiB and name vpool1.
 .br
 .B lvcreate --vdo --size 10G --name vdo0 vg00/vpool1
 .SH SEE ALSO
-
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
-
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
-
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
-
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
-
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
-
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
+
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
+
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
+
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
+
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
+
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
+
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/lvdisplay.8_pregen b/man/lvdisplay.8_pregen
index e19447c58..d1370d616 100644
--- a/man/lvdisplay.8_pregen
+++ b/man/lvdisplay.8_pregen
@@ -186,175 +186,176 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB--aligned\fP
 .br
-Use with --separator to align the output columns
 .ad b
-.HP
+Use with --separator to align the output columns
+.TP
 .ad l
 \fB-a\fP|\fB--all\fP
 .br
+.ad b
 Show information about internal LVs.
 These are components of normal LVs, such as mirrors,
 which are not independently accessible, e.g. not mountable.
-.ad b
-.HP
+.TP
 .ad l
 \fB--binary\fP
 .br
+.ad b
 Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
 the "unknown" value which denotes that the value could not be determined).
-.ad b
-.HP
+.TP
 .ad l
 \fB-c\fP|\fB--colon\fP
 .br
+.ad b
 Generate colon separated output for easier parsing in scripts or programs.
 Also see \fBvgs\fP(8) which provides considerably more control over the output.
-.ad b
-.HP
+.TP
 .ad l
 \fB-C\fP|\fB--columns\fP
 .br
+.ad b
 Display output in columns, the equivalent of \fBvgs\fP(8).
 Options listed are the same as options given in \fBvgs\fP(8).
-.ad b
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
-See \fBlvmreport\fP(7).
 .ad b
-.HP
+See \fBlvmreport\fP(7).
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB--foreign\fP
 .br
+.ad b
 Report/display foreign VGs that would otherwise be skipped.
 See \fBlvmsystemid\fP(7) for more information about foreign VGs.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB-H\fP|\fB--history\fP
 .br
+.ad b
 Include historical LVs in the output.
 (This has no effect unless LVs were removed while
 lvm.conf metadata/record_lvs_history was enabled.
-.ad b
-.HP
+.TP
 .ad l
 \fB--ignorelockingfailure\fP
 .br
+.ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
-.ad b
-.HP
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--logonly\fP
 .br
-Suppress command report and display only log report.
 .ad b
-.HP
+Suppress command report and display only log report.
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB-m\fP|\fB--maps\fP
 .br
+.ad b
 Display the mapping of logical extents to PVs and physical extents.
 To map physical extents to logical extents use:
 pvs --segments -o+lv_name,seg_start_pe,segtype
-.ad b
-.HP
+.TP
 .ad l
 \fB--noheadings\fP
 .br
+.ad b
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
-.ad b
-.HP
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--nosuffix\fP
 .br
+.ad b
 Suppress the suffix on output sizes. Use with --units
 (except h and H) if processing the output.
-.ad b
-.HP
+.TP
 .ad l
 \fB-o\fP|\fB--options\fP \fIString\fP
 .br
+.ad b
 Comma-separated, ordered list of fields to display in columns.
 String arg syntax is: [+|-|#]Field1[,Field2 ...]
 The prefix \fB+\fP will append the specified fields to the default fields,
@@ -372,52 +373,52 @@ Use field name \fBlv_all\fP to view all LV fields,
 \fBpvseg_all\fP all PV segment columns.
 See the lvm.conf report section for more config options.
 See \fBlvmreport\fP(7) for more information about reporting.
-.ad b
-.HP
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--readonly\fP
 .br
+.ad b
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--segments\fP
 .br
 .ad b
-.HP
+.TP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
+.ad b
 Select objects for processing and reporting based on specified criteria.
 The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
@@ -426,96 +427,95 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
-.ad b
-.HP
+.TP
 .ad l
 \fB--separator\fP \fIString\fP
 .br
-String to use to separate each column. Useful if grepping the output.
 .ad b
-.HP
+String to use to separate each column. Useful if grepping the output.
+.TP
 .ad l
 \fB--shared\fP
 .br
+.ad b
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
 See \fBlvmlockd\fP(8) for more information about shared VGs.
-.ad b
-.HP
+.TP
 .ad l
 \fB-O\fP|\fB--sort\fP \fIString\fP
 .br
+.ad b
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB--unbuffered\fP
 .br
-Produce output immediately without sorting or aligning the columns properly.
 .ad b
-.HP
+Produce output immediately without sorting or aligning the columns properly.
+.TP
 .ad l
 \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
 .br
+.ad b
 All sizes are output in these units:
 human-(r)eadable with '<' rounding indicator,
 (h)uman-readable, (b)ytes, (s)ectors, (k)ilobytes, (m)egabytes,
 (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
 Custom units can be specified, e.g. --units 3M.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
+.TP
 \fILV\fP
 .br
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-.HP
+.TP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -531,70 +531,71 @@ capital letters mean multiple of 1000.)
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/lvextend.8_pregen b/man/lvextend.8_pregen
index cf7925ee0..a4a90994d 100644
--- a/man/lvextend.8_pregen
+++ b/man/lvextend.8_pregen
@@ -11,7 +11,10 @@ lvextend - Add space to a logical volume
 .br
 .P
 .ad l
-    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
+    \fB--alloc\fP 
+.nh
+\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+.hy
 .ad b
 .br
 .ad l
@@ -119,7 +122,10 @@ lvextend - Add space to a logical volume
 .ad b
 .br
 .ad l
-    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBraid\fP|\fBmirror\fP|\fBthin\fP|\fBthin-pool\fP|\fBvdo\fP|\fBvdo-pool\fP|\fBcache\fP|\fBcache-pool\fP|\fBwritecache\fP
+    \fB--type\fP 
+.nh
+\fBlinear\fP|\:\fBstriped\fP|\:\fBsnapshot\fP|\:\fBraid\fP|\:\fBmirror\fP|\:\fBthin\fP|\:\fBthin-pool\fP|\:\fBvdo\fP|\:\fBvdo-pool\fP|\:\fBcache\fP|\:\fBcache-pool\fP|\:\fBwritecache\fP
+.hy
 .ad b
 .br
 .ad l
@@ -268,7 +274,11 @@ Common options for command:
 .ad b
 .br
 .ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+[    \fB--alloc\fP 
+.nh
+\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+.hy
+]
 .ad b
 .br
 .ad l
@@ -284,7 +294,11 @@ Common options for command:
 .ad b
 .br
 .ad l
-[    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBraid\fP|\fBmirror\fP|\fBthin\fP|\fBthin-pool\fP|\fBvdo\fP|\fBvdo-pool\fP|\fBcache\fP|\fBcache-pool\fP|\fBwritecache\fP ]
+[    \fB--type\fP 
+.nh
+\fBlinear\fP|\:\fBstriped\fP|\:\fBsnapshot\fP|\:\fBraid\fP|\:\fBmirror\fP|\:\fBthin\fP|\:\fBthin-pool\fP|\:\fBvdo\fP|\:\fBvdo-pool\fP|\:\fBcache\fP|\:\fBcache-pool\fP|\:\fBwritecache\fP
+.hy
+]
 .ad b
 .RE
 
@@ -356,10 +370,14 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
-\fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
+\fB--alloc\fP 
+.nh
+\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+.hy
 .br
+.ad b
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
 which can be changed with vgchange/lvchange, or overridden on the
@@ -376,66 +394,66 @@ e.g. by placing two stripes on the same PV.
 Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
-.ad b
-.HP
+.TP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB-l\fP|\fB--extents\fP [\fB+\fP]\fINumber\fP[PERCENT]
 .br
+.ad b
 Specifies the new size of the LV in logical extents.
 The --size and --extents options are alternate methods of specifying size.
 The total number of physical extents used will be
@@ -454,57 +472,57 @@ extents in the new LV is not determined until the command has completed.
 When the plus \fB+\fP or minus \fB-\fP prefix is used,
 the value is not an absolute size, but is relative and added or subtracted
 from the current size.
-.ad b
-.HP
+.TP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
+.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB-m\fP|\fB--mirrors\fP \fINumber\fP
 .br
-Not used.
 .ad b
-.HP
+Not used.
+.TP
 .ad l
 \fB-n\fP|\fB--nofsck\fP
 .br
+.ad b
 Do not perform fsck before resizing filesystem when filesystem
 requires it. You may need to use --force to proceed with
 this option.
-.ad b
-.HP
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--nosync\fP
 .br
+.ad b
 Causes the creation of mirror, raid1, raid4, raid5 and raid10 to skip the
 initial synchronization. In case of mirror, raid1 and raid10, any data
 written afterwards will be mirrored, but the original contents will not be
@@ -517,59 +535,59 @@ This option is not valid for raid6, because raid6 relies on proper parity
 to reconstruct proper user date in case of device failures.
 raid0 and raid0_meta do not provide any data copies or parity support
 and thus do not support initial synchronization.
-.ad b
-.HP
+.TP
 .ad l
 \fB--noudevsync\fP
 .br
+.ad b
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
-.ad b
-.HP
+.TP
 .ad l
 \fB--poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT]
 .br
+.ad b
 Specifies the new size of the pool metadata LV.
 The plus prefix \fB+\fP can be used, in which case
 the value is added to the current size.
-.ad b
-.HP
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-r\fP|\fB--resizefs\fP
 .br
-Resize underlying filesystem together with the LV using fsadm(8).
 .ad b
-.HP
+Resize underlying filesystem together with the LV using fsadm(8).
+.TP
 .ad l
 \fB-L\fP|\fB--size\fP [\fB+\fP]\fISize\fP[m|UNIT]
 .br
+.ad b
 Specifies the new size of the LV.
 The --size and --extents options are alternate methods of specifying size.
 The total number of physical extents used will be
@@ -577,11 +595,11 @@ greater when redundant data is needed for RAID levels.
 When the plus \fB+\fP or minus \fB-\fP prefix is used,
 the value is not an absolute size, but is relative and added or subtracted
 from the current size.
-.ad b
-.HP
+.TP
 .ad l
 \fB-i\fP|\fB--stripes\fP \fINumber\fP
 .br
+.ad b
 Specifies the number of stripes in a striped LV. This is the number of
 PVs (devices) that a striped LV is spread across. Data that
 appears sequential in the LV is spread across multiple devices in units of
@@ -594,28 +612,31 @@ when unspecified, the default depends on the RAID type
 (raid0: 2, raid10: 2, raid4/5: 3, raid6: 5.)
 To stripe a new raid LV across all PVs by default,
 see lvm.conf allocation/raid_stripe_all_devices.
-.ad b
-.HP
+.TP
 .ad l
 \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT]
 .br
+.ad b
 The amount of data that is written to one device before
 moving to the next in a striped LV.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
-\fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBraid\fP|\fBmirror\fP|\fBthin\fP|\fBthin-pool\fP|\fBvdo\fP|\fBvdo-pool\fP|\fBcache\fP|\fBcache-pool\fP|\fBwritecache\fP
+\fB--type\fP 
+.nh
+\fBlinear\fP|\:\fBstriped\fP|\:\fBsnapshot\fP|\:\fBraid\fP|\:\fBmirror\fP|\:\fBthin\fP|\:\fBthin-pool\fP|\:\fBvdo\fP|\:\fBvdo-pool\fP|\:\fBcache\fP|\:\fBcache-pool\fP|\:\fBwritecache\fP
+.hy
 .br
+.ad b
 The LV type, also known as "segment type" or "segtype".
 See usage descriptions for the specific ways to use these types.
 For more information about redundancy and performance (\fBraid\fP<N>, \fBmirror\fP, \fBstriped\fP, \fBlinear\fP) see \fBlvmraid\fP(7).
@@ -627,44 +648,43 @@ Several commands omit an explicit type option because the type
 is inferred from other options or shortcuts
 (e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache, --vdo).
 Use inferred types with care because it can lead to unexpected results.
-.ad b
-.HP
+.TP
 .ad l
 \fB--usepolicies\fP
 .br
+.ad b
 Perform an operation according to the policy configured in lvm.conf
 or a profile.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fILV\fP
 .br
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
 LV followed by _<type> indicates that an LV of the
 given type is required. (raid represents raid<N> type)
-.HP
+.TP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -674,11 +694,11 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -708,70 +728,71 @@ Extend an LV by 16MiB using specific physical extents.
 .br
 .B lvextend -L+16m vg01/lvol01 /dev/sda:8-9 /dev/sdb:8-9
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/lvm-fullreport.8_pregen b/man/lvm-fullreport.8_pregen
index 7fb7d046d..7a63dc4ad 100644
--- a/man/lvm-fullreport.8_pregen
+++ b/man/lvm-fullreport.8_pregen
@@ -178,150 +178,151 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB--aligned\fP
 .br
-Use with --separator to align the output columns
 .ad b
-.HP
+Use with --separator to align the output columns
+.TP
 .ad l
 \fB-a\fP|\fB--all\fP
 .br
 .ad b
-.HP
+.TP
 .ad l
 \fB--binary\fP
 .br
+.ad b
 Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
 the "unknown" value which denotes that the value could not be determined).
-.ad b
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
-See \fBlvmreport\fP(7).
 .ad b
-.HP
+See \fBlvmreport\fP(7).
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB--foreign\fP
 .br
+.ad b
 Report/display foreign VGs that would otherwise be skipped.
 See \fBlvmsystemid\fP(7) for more information about foreign VGs.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--ignorelockingfailure\fP
 .br
+.ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
-.ad b
-.HP
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--logonly\fP
 .br
-Suppress command report and display only log report.
 .ad b
-.HP
+Suppress command report and display only log report.
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB--nameprefixes\fP
 .br
+.ad b
 Add an "LVM2_" prefix plus the field name to the output. Useful
 with --noheadings to produce a list of field=value pairs that can
 be used to set environment variables (for example, in udev rules).
-.ad b
-.HP
+.TP
 .ad l
 \fB--noheadings\fP
 .br
+.ad b
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
-.ad b
-.HP
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--nosuffix\fP
 .br
+.ad b
 Suppress the suffix on output sizes. Use with --units
 (except h and H) if processing the output.
-.ad b
-.HP
+.TP
 .ad l
 \fB-o\fP|\fB--options\fP \fIString\fP
 .br
+.ad b
 Comma-separated, ordered list of fields to display in columns.
 String arg syntax is: [+|-|#]Field1[,Field2 ...]
 The prefix \fB+\fP will append the specified fields to the default fields,
@@ -339,53 +340,53 @@ Use field name \fBlv_all\fP to view all LV fields,
 \fBpvseg_all\fP all PV segment columns.
 See the lvm.conf report section for more config options.
 See \fBlvmreport\fP(7) for more information about reporting.
-.ad b
-.HP
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--readonly\fP
 .br
+.ad b
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--rows\fP
 .br
-Output columns as rows.
 .ad b
-.HP
+Output columns as rows.
+.TP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
+.ad b
 Select objects for processing and reporting based on specified criteria.
 The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
@@ -394,93 +395,92 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
-.ad b
-.HP
+.TP
 .ad l
 \fB--separator\fP \fIString\fP
 .br
-String to use to separate each column. Useful if grepping the output.
 .ad b
-.HP
+String to use to separate each column. Useful if grepping the output.
+.TP
 .ad l
 \fB--shared\fP
 .br
+.ad b
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
 See \fBlvmlockd\fP(8) for more information about shared VGs.
-.ad b
-.HP
+.TP
 .ad l
 \fB-O\fP|\fB--sort\fP \fIString\fP
 .br
+.ad b
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB--unbuffered\fP
 .br
-Produce output immediately without sorting or aligning the columns properly.
 .ad b
-.HP
+Produce output immediately without sorting or aligning the columns properly.
+.TP
 .ad l
 \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
 .br
+.ad b
 All sizes are output in these units:
 human-(r)eadable with '<' rounding indicator,
 (h)uman-readable, (b)ytes, (s)ectors, (k)ilobytes, (m)egabytes,
 (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
 Custom units can be specified, e.g. --units 3M.
-.ad b
-.HP
+.TP
 .ad l
 \fB--unquoted\fP
 .br
+.ad b
 When used with --nameprefixes, output values in the field=value
 pairs are not quoted.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -496,70 +496,71 @@ capital letters mean multiple of 1000.)
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/lvm-lvpoll.8_pregen b/man/lvm-lvpoll.8_pregen
index 87af9b925..328e980c0 100644
--- a/man/lvm-lvpoll.8_pregen
+++ b/man/lvm-lvpoll.8_pregen
@@ -104,167 +104,167 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB--abort\fP
 .br
-Stop processing a poll operation in lvmpolld.
 .ad b
-.HP
+Stop processing a poll operation in lvmpolld.
+.TP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB--handlemissingpvs\fP
 .br
+.ad b
 Allows a polling operation to continue when PVs are missing,
 e.g. for repairs due to faulty devices.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB-i\fP|\fB--interval\fP \fINumber\fP
 .br
-Report progress at regular intervals.
 .ad b
-.HP
+Report progress at regular intervals.
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--polloperation\fP \fBpvmove\fP|\fBconvert\fP|\fBmerge\fP|\fBmerge_thin\fP
 .br
-The command to perform from lvmpolld.
 .ad b
-.HP
+The command to perform from lvmpolld.
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fILV\fP
 .br
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -311,70 +311,71 @@ Continue thin snapshot merge.
 .br
 .B lvm lvpoll --polloperation merge_thin vg/thin_snapshot
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/lvmconfig.8_pregen b/man/lvmconfig.8_pregen
index afb890cc3..8ddee04a7 100644
--- a/man/lvmconfig.8_pregen
+++ b/man/lvmconfig.8_pregen
@@ -31,7 +31,11 @@ line settings from --config.
 .ad b
 .br
 .ad l
-[    \fB--typeconfig\fP \fBcurrent\fP|\fBdefault\fP|\fBdiff\fP|\fBfull\fP|\fBlist\fP|\fBmissing\fP|\fBnew\fP|\fBprofilable\fP|\fBprofilable-command\fP|\fBprofilable-metadata\fP ]
+[    \fB--typeconfig\fP 
+.nh
+\fBcurrent\fP|\:\fBdefault\fP|\:\fBdiff\fP|\:\fBfull\fP|\:\fBlist\fP|\:\fBmissing\fP|\:\fBnew\fP|\:\fBprofilable\fP|\:\fBprofilable-command\fP|\:\fBprofilable-metadata\fP
+.hy
+]
 .ad b
 .br
 .ad l
@@ -173,10 +177,11 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB--atversion\fP \fIString\fP
 .br
+.ad b
 Specify an LVM version in x.y.z format where x is the major version,
 the y is the minor version and z is the patchlevel (e.g. 2.2.106).
 When configuration is displayed, the configuration settings recognized
@@ -184,116 +189,116 @@ at this LVM version will be considered only. This can be used
 to display a configuration that a certain LVM version understands and
 which does not contain any newer settings for which LVM would
 issue a warning message when checking the configuration.
-.ad b
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB-f\fP|\fB--file\fP \fIString\fP
 .br
-Write output to the named file.
 .ad b
-.HP
+Write output to the named file.
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--ignoreadvanced\fP
 .br
-Exclude advanced configuration settings from the output.
 .ad b
-.HP
+Exclude advanced configuration settings from the output.
+.TP
 .ad l
 \fB--ignorelocal\fP
 .br
+.ad b
 Ignore the local section. The local section should be defined in
 the lvmlocal.conf file, and should contain config settings
 specific to the local host which should not be copied to
 other hosts.
-.ad b
-.HP
+.TP
 .ad l
 \fB--ignoreunsupported\fP
 .br
+.ad b
 Exclude unsupported configuration settings from the output. These settings are
 either used for debugging and development purposes only or their support is not
 yet complete and they are not meant to be used in production. The \fBcurrent\fP
 and \fBdiff\fP types include unsupported settings in their output by default,
 all the other types ignore unsupported settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB-l\fP|\fB--list\fP
 .br
+.ad b
 List config settings with summarizing comment. This is the same as using
 options --typeconfig list --withsummary.
-.ad b
-.HP
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB--mergedconfig\fP
 .br
+.ad b
 When the command is run with --config
 and/or --commandprofile (or using LVM_COMMAND_PROFILE
 environment variable), --profile, or --metadataprofile,
@@ -301,78 +306,81 @@ merge all the contents of the "config cascade" before displaying it.
 Without merging, only the configuration at the front of the
 cascade is displayed.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB--metadataprofile\fP \fIString\fP
 .br
+.ad b
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--showdeprecated\fP
 .br
+.ad b
 Include deprecated configuration settings in the output. These settings
 are deprecated after a certain version. If a concrete version is specified
 with --atversion, deprecated settings are automatically included
 if the specified version is lower than the version in which the settings were
 deprecated. The current and diff types include deprecated settings
 in their output by default, all the other types ignore deprecated settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--showunsupported\fP
 .br
+.ad b
 Include unsupported configuration settings in the output. These settings
 are either used for debugging or development purposes only, or their support
 is not yet complete and they are not meant to be used in production. The
 current and diff types include unsupported settings in their
 output by default, all the other types ignore unsupported settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--sinceversion\fP \fIString\fP
 .br
+.ad b
 Specify an LVM version in x.y.z format where x is the major version,
 the y is the minor version and z is the patchlevel (e.g. 2.2.106).
 This option is currently applicable only with --typeconfig new
 to display all configuration settings introduced since given version.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
-\fB--typeconfig\fP \fBcurrent\fP|\fBdefault\fP|\fBdiff\fP|\fBfull\fP|\fBlist\fP|\fBmissing\fP|\fBnew\fP|\fBprofilable\fP|\fBprofilable-command\fP|\fBprofilable-metadata\fP
+\fB--typeconfig\fP 
+.nh
+\fBcurrent\fP|\:\fBdefault\fP|\:\fBdiff\fP|\:\fBfull\fP|\:\fBlist\fP|\:\fBmissing\fP|\:\fBnew\fP|\:\fBprofilable\fP|\:\fBprofilable-command\fP|\:\fBprofilable-metadata\fP
+.hy
 .br
+.ad b
 \fBcurrent\fP prints the config settings that would be applied
 to an lvm command (assuming the command does not override them
 on the command line.) This includes:
@@ -405,89 +413,88 @@ with their default values.
 \fBprofilable-command\fP prints settings with their default values that can be set from a command profile.
 \fBprofilable-metadata\fP prints settings with their default values that can be set from a metadata profile.
 Also see \fBlvm.conf\fP(5).
-.ad b
-.HP
+.TP
 .ad l
 \fB--unconfigured\fP
 .br
-Internal option used for generating config file during build.
 .ad b
-.HP
+Internal option used for generating config file during build.
+.TP
 .ad l
 \fB--validate\fP
 .br
+.ad b
 Validate current configuration used and exit with appropriate
 return code. The validation is done only for the configuration
@the front of the "config cascade". To validate the whole
 merged configuration tree, also use --mergedconfig.
 The validation is done even if lvm.conf config/checks is disabled.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB--withcomments\fP
 .br
+.ad b
 Display a full comment for each configuration node. For deprecated
 settings, also display comments about deprecation.
-.ad b
-.HP
+.TP
 .ad l
 \fB--withgeneralpreamble\fP
 .br
-Include general config file preamble.
 .ad b
-.HP
+Include general config file preamble.
+.TP
 .ad l
 \fB--withlocalpreamble\fP
 .br
-Include local config file preamble.
 .ad b
-.HP
+Include local config file preamble.
+.TP
 .ad l
 \fB--withspaces\fP
 .br
-Where appropriate, add more spaces in output for better readability.
 .ad b
-.HP
+Where appropriate, add more spaces in output for better readability.
+.TP
 .ad l
 \fB--withsummary\fP
 .br
-Display a one line comment for each configuration node.
 .ad b
-.HP
+Display a one line comment for each configuration node.
+.TP
 .ad l
 \fB--withversions\fP
 .br
+.ad b
 Also display a comment containing the version of introduction for
 each configuration node. If the setting is deprecated, also display
 the version since which it is deprecated.
-.ad b
-.HP
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -503,70 +510,71 @@ capital letters mean multiple of 1000.)
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/lvmdevices.8_pregen b/man/lvmdevices.8_pregen
index 2922449bf..f576bdea4 100644
--- a/man/lvmdevices.8_pregen
+++ b/man/lvmdevices.8_pregen
@@ -309,166 +309,166 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB--adddev\fP \fIPV\fP
 .br
-Add a device to the devices file.
 .ad b
-.HP
+Add a device to the devices file.
+.TP
 .ad l
 \fB--addpvid\fP \fIString\fP
 .br
-Find a device with the PVID and add the device to the devices file.
 .ad b
-.HP
+Find a device with the PVID and add the device to the devices file.
+.TP
 .ad l
 \fB--check\fP
 .br
-Check the content of the devices file.
 .ad b
-.HP
+Check the content of the devices file.
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--deldev\fP \fIPV\fP
 .br
-Remove a device from the devices file.
 .ad b
-.HP
+Remove a device from the devices file.
+.TP
 .ad l
 \fB--delpvid\fP \fIString\fP
 .br
-Remove a device with the PVID from the devices file.
 .ad b
-.HP
+Remove a device with the PVID from the devices file.
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB--update\fP
 .br
-Update the content of the devices file.
 .ad b
-.HP
+Update the content of the devices file.
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -484,70 +484,71 @@ capital letters mean multiple of 1000.)
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/lvmdiskscan.8_pregen b/man/lvmdiskscan.8_pregen
index d47514027..0fb64dbe3 100644
--- a/man/lvmdiskscan.8_pregen
+++ b/man/lvmdiskscan.8_pregen
@@ -99,147 +99,147 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB-l\fP|\fB--lvmpartition\fP
 .br
-Only report PVs.
 .ad b
-.HP
+Only report PVs.
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--readonly\fP
 .br
+.ad b
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -255,70 +255,71 @@ capital letters mean multiple of 1000.)
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/lvreduce.8_pregen b/man/lvreduce.8_pregen
index 4fcc08f99..50c9ae453 100644
--- a/man/lvreduce.8_pregen
+++ b/man/lvreduce.8_pregen
@@ -130,65 +130,66 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB-l\fP|\fB--extents\fP [\fB-\fP]\fINumber\fP[PERCENT]
 .br
+.ad b
 Specifies the new size of the LV in logical extents.
 The --size and --extents options are alternate methods of specifying size.
 The total number of physical extents used will be
@@ -207,91 +208,91 @@ extents in the new LV is not determined until the command has completed.
 When the plus \fB+\fP or minus \fB-\fP prefix is used,
 the value is not an absolute size, but is relative and added or subtracted
 from the current size.
-.ad b
-.HP
+.TP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
+.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB-n\fP|\fB--nofsck\fP
 .br
+.ad b
 Do not perform fsck before resizing filesystem when filesystem
 requires it. You may need to use --force to proceed with
 this option.
-.ad b
-.HP
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--noudevsync\fP
 .br
+.ad b
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
-.ad b
-.HP
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-r\fP|\fB--resizefs\fP
 .br
-Resize underlying filesystem together with the LV using fsadm(8).
 .ad b
-.HP
+Resize underlying filesystem together with the LV using fsadm(8).
+.TP
 .ad l
 \fB-L\fP|\fB--size\fP [\fB-\fP]\fISize\fP[m|UNIT]
 .br
+.ad b
 Specifies the new size of the LV.
 The --size and --extents options are alternate methods of specifying size.
 The total number of physical extents used will be
@@ -299,49 +300,48 @@ greater when redundant data is needed for RAID levels.
 When the plus \fB+\fP or minus \fB-\fP prefix is used,
 the value is not an absolute size, but is relative and added or subtracted
 from the current size.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fILV\fP
 .br
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -362,70 +362,71 @@ Reduce the size of an LV by 3 logical extents:
 .br
 .B lvreduce -l -3 vg00/lvol1
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/lvremove.8_pregen b/man/lvremove.8_pregen
index b53b871cc..ca62d5d65 100644
--- a/man/lvremove.8_pregen
+++ b/man/lvremove.8_pregen
@@ -134,139 +134,140 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
+.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB--nohistory\fP
 .br
+.ad b
 Do not record history of LVs being removed.
 This has no effect unless the configuration setting
 metadata/record_lvs_history is enabled.
-.ad b
-.HP
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--noudevsync\fP
 .br
+.ad b
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
-.ad b
-.HP
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
+.ad b
 Select objects for processing and reporting based on specified criteria.
 The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
@@ -275,64 +276,63 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
+.TP
 \fILV\fP
 .br
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-.HP
+.TP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.HP
+.TP
 \fISelect\fP
 .br
 Select indicates that a required positional parameter can
 be omitted if the \fB--select\fP option is used.
 No arg appears in this position.
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -356,70 +356,71 @@ Remove all LVs the specified VG.
 .br
 .B lvremove vg00
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/lvrename.8_pregen b/man/lvrename.8_pregen
index 0a468aed3..7a3d78996 100644
--- a/man/lvrename.8_pregen
+++ b/man/lvrename.8_pregen
@@ -109,166 +109,166 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--noudevsync\fP
 .br
+.ad b
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
-.ad b
-.HP
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
+.TP
 \fILV\fP
 .br
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -293,70 +293,71 @@ An alternate syntax to rename "lvold" to "lvnew":
 .br
 .B lvrename vg02 lvold lvnew
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/lvresize.8_pregen b/man/lvresize.8_pregen
index 8c115198a..dfe30ca56 100644
--- a/man/lvresize.8_pregen
+++ b/man/lvresize.8_pregen
@@ -11,7 +11,10 @@ lvresize - Resize a logical volume
 .br
 .P
 .ad l
-    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
+    \fB--alloc\fP 
+.nh
+\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+.hy
 .ad b
 .br
 .ad l
@@ -115,7 +118,10 @@ lvresize - Resize a logical volume
 .ad b
 .br
 .ad l
-    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBraid\fP|\fBmirror\fP|\fBthin\fP|\fBthin-pool\fP|\fBvdo\fP|\fBvdo-pool\fP|\fBcache\fP|\fBcache-pool\fP|\fBwritecache\fP
+    \fB--type\fP 
+.nh
+\fBlinear\fP|\:\fBstriped\fP|\:\fBsnapshot\fP|\:\fBraid\fP|\:\fBmirror\fP|\:\fBthin\fP|\:\fBthin-pool\fP|\:\fBvdo\fP|\:\fBvdo-pool\fP|\:\fBcache\fP|\:\fBcache-pool\fP|\:\fBwritecache\fP
+.hy
 .ad b
 .br
 .ad l
@@ -216,7 +222,11 @@ Common options for command:
 .ad b
 .br
 .ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+[    \fB--alloc\fP 
+.nh
+\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+.hy
+]
 .ad b
 .br
 .ad l
@@ -232,7 +242,11 @@ Common options for command:
 .ad b
 .br
 .ad l
-[    \fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBraid\fP|\fBmirror\fP|\fBthin\fP|\fBthin-pool\fP|\fBvdo\fP|\fBvdo-pool\fP|\fBcache\fP|\fBcache-pool\fP|\fBwritecache\fP ]
+[    \fB--type\fP 
+.nh
+\fBlinear\fP|\:\fBstriped\fP|\:\fBsnapshot\fP|\:\fBraid\fP|\:\fBmirror\fP|\:\fBthin\fP|\:\fBthin-pool\fP|\:\fBvdo\fP|\:\fBvdo-pool\fP|\:\fBcache\fP|\:\fBcache-pool\fP|\:\fBwritecache\fP
+.hy
+]
 .ad b
 .RE
 
@@ -304,10 +318,14 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
-\fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
+\fB--alloc\fP 
+.nh
+\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+.hy
 .br
+.ad b
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
 which can be changed with vgchange/lvchange, or overridden on the
@@ -324,66 +342,66 @@ e.g. by placing two stripes on the same PV.
 Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
-.ad b
-.HP
+.TP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB-l\fP|\fB--extents\fP [\fB+\fP|\fB-\fP]\fINumber\fP[PERCENT]
 .br
+.ad b
 Specifies the new size of the LV in logical extents.
 The --size and --extents options are alternate methods of specifying size.
 The total number of physical extents used will be
@@ -402,51 +420,51 @@ extents in the new LV is not determined until the command has completed.
 When the plus \fB+\fP or minus \fB-\fP prefix is used,
 the value is not an absolute size, but is relative and added or subtracted
 from the current size.
-.ad b
-.HP
+.TP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
+.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB-n\fP|\fB--nofsck\fP
 .br
+.ad b
 Do not perform fsck before resizing filesystem when filesystem
 requires it. You may need to use --force to proceed with
 this option.
-.ad b
-.HP
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--nosync\fP
 .br
+.ad b
 Causes the creation of mirror, raid1, raid4, raid5 and raid10 to skip the
 initial synchronization. In case of mirror, raid1 and raid10, any data
 written afterwards will be mirrored, but the original contents will not be
@@ -459,59 +477,59 @@ This option is not valid for raid6, because raid6 relies on proper parity
 to reconstruct proper user date in case of device failures.
 raid0 and raid0_meta do not provide any data copies or parity support
 and thus do not support initial synchronization.
-.ad b
-.HP
+.TP
 .ad l
 \fB--noudevsync\fP
 .br
+.ad b
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
-.ad b
-.HP
+.TP
 .ad l
 \fB--poolmetadatasize\fP [\fB+\fP]\fISize\fP[m|UNIT]
 .br
+.ad b
 Specifies the new size of the pool metadata LV.
 The plus prefix \fB+\fP can be used, in which case
 the value is added to the current size.
-.ad b
-.HP
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-r\fP|\fB--resizefs\fP
 .br
-Resize underlying filesystem together with the LV using fsadm(8).
 .ad b
-.HP
+Resize underlying filesystem together with the LV using fsadm(8).
+.TP
 .ad l
 \fB-L\fP|\fB--size\fP [\fB+\fP|\fB-\fP]\fISize\fP[m|UNIT]
 .br
+.ad b
 Specifies the new size of the LV.
 The --size and --extents options are alternate methods of specifying size.
 The total number of physical extents used will be
@@ -519,11 +537,11 @@ greater when redundant data is needed for RAID levels.
 When the plus \fB+\fP or minus \fB-\fP prefix is used,
 the value is not an absolute size, but is relative and added or subtracted
 from the current size.
-.ad b
-.HP
+.TP
 .ad l
 \fB-i\fP|\fB--stripes\fP \fINumber\fP
 .br
+.ad b
 Specifies the number of stripes in a striped LV. This is the number of
 PVs (devices) that a striped LV is spread across. Data that
 appears sequential in the LV is spread across multiple devices in units of
@@ -536,28 +554,31 @@ when unspecified, the default depends on the RAID type
 (raid0: 2, raid10: 2, raid4/5: 3, raid6: 5.)
 To stripe a new raid LV across all PVs by default,
 see lvm.conf allocation/raid_stripe_all_devices.
-.ad b
-.HP
+.TP
 .ad l
 \fB-I\fP|\fB--stripesize\fP \fISize\fP[k|UNIT]
 .br
+.ad b
 The amount of data that is written to one device before
 moving to the next in a striped LV.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
-\fB--type\fP \fBlinear\fP|\fBstriped\fP|\fBsnapshot\fP|\fBraid\fP|\fBmirror\fP|\fBthin\fP|\fBthin-pool\fP|\fBvdo\fP|\fBvdo-pool\fP|\fBcache\fP|\fBcache-pool\fP|\fBwritecache\fP
+\fB--type\fP 
+.nh
+\fBlinear\fP|\:\fBstriped\fP|\:\fBsnapshot\fP|\:\fBraid\fP|\:\fBmirror\fP|\:\fBthin\fP|\:\fBthin-pool\fP|\:\fBvdo\fP|\:\fBvdo-pool\fP|\:\fBcache\fP|\:\fBcache-pool\fP|\:\fBwritecache\fP
+.hy
 .br
+.ad b
 The LV type, also known as "segment type" or "segtype".
 See usage descriptions for the specific ways to use these types.
 For more information about redundancy and performance (\fBraid\fP<N>, \fBmirror\fP, \fBstriped\fP, \fBlinear\fP) see \fBlvmraid\fP(7).
@@ -569,37 +590,36 @@ Several commands omit an explicit type option because the type
 is inferred from other options or shortcuts
 (e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache, --vdo).
 Use inferred types with care because it can lead to unexpected results.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fILV\fP
 .br
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
 LV followed by _<type> indicates that an LV of the
 given type is required. (raid represents raid<N> type)
-.HP
+.TP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -609,11 +629,11 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -634,70 +654,71 @@ Extend an LV by 16MB using specific physical extents:
 .br
 .B lvresize -L+16M vg1/lv1 /dev/sda:0-1 /dev/sdb:0-1
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/lvs.8_pregen b/man/lvs.8_pregen
index 8351aeea2..c45aacc61 100644
--- a/man/lvs.8_pregen
+++ b/man/lvs.8_pregen
@@ -182,161 +182,162 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB--aligned\fP
 .br
-Use with --separator to align the output columns
 .ad b
-.HP
+Use with --separator to align the output columns
+.TP
 .ad l
 \fB-a\fP|\fB--all\fP
 .br
+.ad b
 Show information about internal LVs.
 These are components of normal LVs, such as mirrors,
 which are not independently accessible, e.g. not mountable.
-.ad b
-.HP
+.TP
 .ad l
 \fB--binary\fP
 .br
+.ad b
 Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
 the "unknown" value which denotes that the value could not be determined).
-.ad b
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
-See \fBlvmreport\fP(7).
 .ad b
-.HP
+See \fBlvmreport\fP(7).
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB--foreign\fP
 .br
+.ad b
 Report/display foreign VGs that would otherwise be skipped.
 See \fBlvmsystemid\fP(7) for more information about foreign VGs.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB-H\fP|\fB--history\fP
 .br
+.ad b
 Include historical LVs in the output.
 (This has no effect unless LVs were removed while
 lvm.conf metadata/record_lvs_history was enabled.
-.ad b
-.HP
+.TP
 .ad l
 \fB--ignorelockingfailure\fP
 .br
+.ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
-.ad b
-.HP
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--logonly\fP
 .br
-Suppress command report and display only log report.
 .ad b
-.HP
+Suppress command report and display only log report.
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB--nameprefixes\fP
 .br
+.ad b
 Add an "LVM2_" prefix plus the field name to the output. Useful
 with --noheadings to produce a list of field=value pairs that can
 be used to set environment variables (for example, in udev rules).
-.ad b
-.HP
+.TP
 .ad l
 \fB--noheadings\fP
 .br
+.ad b
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
-.ad b
-.HP
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--nosuffix\fP
 .br
+.ad b
 Suppress the suffix on output sizes. Use with --units
 (except h and H) if processing the output.
-.ad b
-.HP
+.TP
 .ad l
 \fB-o\fP|\fB--options\fP \fIString\fP
 .br
+.ad b
 Comma-separated, ordered list of fields to display in columns.
 String arg syntax is: [+|-|#]Field1[,Field2 ...]
 The prefix \fB+\fP will append the specified fields to the default fields,
@@ -354,59 +355,59 @@ Use field name \fBlv_all\fP to view all LV fields,
 \fBpvseg_all\fP all PV segment columns.
 See the lvm.conf report section for more config options.
 See \fBlvmreport\fP(7) for more information about reporting.
-.ad b
-.HP
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--readonly\fP
 .br
+.ad b
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--rows\fP
 .br
-Output columns as rows.
 .ad b
-.HP
+Output columns as rows.
+.TP
 .ad l
 \fB--segments\fP
 .br
-Use default columns that emphasize segment information.
 .ad b
-.HP
+Use default columns that emphasize segment information.
+.TP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
+.ad b
 Select objects for processing and reporting based on specified criteria.
 The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
@@ -415,103 +416,102 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
-.ad b
-.HP
+.TP
 .ad l
 \fB--separator\fP \fIString\fP
 .br
-String to use to separate each column. Useful if grepping the output.
 .ad b
-.HP
+String to use to separate each column. Useful if grepping the output.
+.TP
 .ad l
 \fB--shared\fP
 .br
+.ad b
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
 See \fBlvmlockd\fP(8) for more information about shared VGs.
-.ad b
-.HP
+.TP
 .ad l
 \fB-O\fP|\fB--sort\fP \fIString\fP
 .br
+.ad b
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB--unbuffered\fP
 .br
-Produce output immediately without sorting or aligning the columns properly.
 .ad b
-.HP
+Produce output immediately without sorting or aligning the columns properly.
+.TP
 .ad l
 \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
 .br
+.ad b
 All sizes are output in these units:
 human-(r)eadable with '<' rounding indicator,
 (h)uman-readable, (b)ytes, (s)ectors, (k)ilobytes, (m)egabytes,
 (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
 Custom units can be specified, e.g. --units 3M.
-.ad b
-.HP
+.TP
 .ad l
 \fB--unquoted\fP
 .br
+.ad b
 When used with --nameprefixes, output values in the field=value
 pairs are not quoted.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
+.TP
 \fILV\fP
 .br
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-.HP
+.TP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -609,70 +609,71 @@ Related to writecache logical volumes: (E)rror.
 .IP 10 3
 s(k)ip activation: this volume is flagged to be skipped during activation.
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/lvscan.8_pregen b/man/lvscan.8_pregen
index 03c7806e2..ab3ed3670 100644
--- a/man/lvscan.8_pregen
+++ b/man/lvscan.8_pregen
@@ -109,173 +109,173 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB-a\fP|\fB--all\fP
 .br
+.ad b
 Show information about internal LVs.
 These are components of normal LVs, such as mirrors,
 which are not independently accessible, e.g. not mountable.
-.ad b
-.HP
+.TP
 .ad l
 \fB-b\fP|\fB--blockdevice\fP
 .br
-No longer used.
 .ad b
-.HP
+No longer used.
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--ignorelockingfailure\fP
 .br
+.ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
-.ad b
-.HP
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--readonly\fP
 .br
+.ad b
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -291,70 +291,71 @@ capital letters mean multiple of 1000.)
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/pvchange.8_pregen b/man/pvchange.8_pregen
index ccf7a613d..84b4e13e0 100644
--- a/man/pvchange.8_pregen
+++ b/man/pvchange.8_pregen
@@ -18,22 +18,14 @@ Change properties of all PVs.
 .P
 \fBpvchange\fP \fB-a\fP|\fB--all\fP
 .RS 4
-( \fB-x\fP|\fB--allocatable\fP \fBy\fP|\fBn\fP,
-.ad b
+( \fB-x\fP|\fB--allocatable\fP \fBy\fP|\fBn\fP
 .br
-.ad l
-  \fB-u\fP|\fB--uuid\fP,
-.ad b
+  \fB-u\fP|\fB--uuid\fP
 .br
-.ad l
-     \fB--addtag\fP \fITag\fP,
-.ad b
+     \fB--addtag\fP \fITag\fP
 .br
-.ad l
-     \fB--deltag\fP \fITag\fP,
-.ad b
+     \fB--deltag\fP \fITag\fP
 .br
-.ad l
      \fB--metadataignore\fP \fBy\fP|\fBn\fP )
 .RE
 .br
@@ -47,22 +39,14 @@ Change properties of specified PVs.
 .P
 \fBpvchange\fP
 .RS 4
-( \fB-x\fP|\fB--allocatable\fP \fBy\fP|\fBn\fP,
-.ad b
+( \fB-x\fP|\fB--allocatable\fP \fBy\fP|\fBn\fP
 .br
-.ad l
-  \fB-u\fP|\fB--uuid\fP,
-.ad b
+  \fB-u\fP|\fB--uuid\fP
 .br
-.ad l
-     \fB--addtag\fP \fITag\fP,
-.ad b
+     \fB--addtag\fP \fITag\fP
 .br
-.ad l
-     \fB--deltag\fP \fITag\fP,
-.ad b
+     \fB--deltag\fP \fITag\fP
 .br
-.ad l
      \fB--metadataignore\fP \fBy\fP|\fBn\fP )
 .RE
 .RS 4
@@ -166,157 +150,158 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB--addtag\fP \fITag\fP
 .br
+.ad b
 Adds a tag to a PV, VG or LV. This option can be repeated to add
 multiple tags at once. See \fBlvm\fP(8) for information about tags.
-.ad b
-.HP
+.TP
 .ad l
 \fB-a\fP|\fB--all\fP
 .br
-Change all visible PVs.
 .ad b
-.HP
+Change all visible PVs.
+.TP
 .ad l
 \fB-x\fP|\fB--allocatable\fP \fBy\fP|\fBn\fP
 .br
-Enable or disable allocation of physical extents on this PV.
 .ad b
-.HP
+Enable or disable allocation of physical extents on this PV.
+.TP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--deltag\fP \fITag\fP
 .br
+.ad b
 Deletes a tag from a PV, VG or LV. This option can be repeated to delete
 multiple tags at once. See \fBlvm\fP(8) for information about tags.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
+.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB--metadataignore\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Specifies the metadataignore property of a PV.
 If yes, metadata areas on the PV are ignored, and lvm will
 not store metadata in the metadata areas of the PV.
 If no, lvm will store metadata on the PV.
-.ad b
-.HP
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
+.ad b
 Select objects for processing and reporting based on specified criteria.
 The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
@@ -325,46 +310,45 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-u\fP|\fB--uuid\fP
 .br
-Generate new random UUID for specified PVs.
 .ad b
-.HP
+Generate new random UUID for specified PVs.
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -374,17 +358,17 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
+.TP
 \fISelect\fP
 .br
 Select indicates that a required positional parameter can
 be omitted if the \fB--select\fP option is used.
 No arg appears in this position.
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -406,70 +390,71 @@ disk errors, or because it will be removed after freeing it).
 .br
 .B pvchange -x n /dev/sdk1
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/pvck.8_pregen b/man/pvck.8_pregen
index 76671a515..8b1493b10 100644
--- a/man/pvck.8_pregen
+++ b/man/pvck.8_pregen
@@ -33,7 +33,10 @@ pvck - Check metadata on physical volumes
 .ad b
 .br
 .ad l
-    \fB--dump\fP \fBheaders\fP|\fBmetadata\fP|\fBmetadata_all\fP|\fBmetadata_search\fP
+    \fB--dump\fP 
+.nh
+\fBheaders\fP|\:\fBmetadata\fP|\:\fBmetadata_all\fP|\:\fBmetadata_search\fP
+.hy
 .ad b
 .br
 .ad l
@@ -252,7 +255,11 @@ Check for metadata on a device
 Check and print LVM headers and metadata on a device
 .br
 .P
-\fBpvck\fP \fB--dump\fP \fBheaders\fP|\fBmetadata\fP|\fBmetadata_all\fP|\fBmetadata_search\fP \fIPV\fP
+\fBpvck\fP \fB--dump\fP 
+.nh
+\fBheaders\fP|\:\fBmetadata\fP|\:\fBmetadata_all\fP|\:\fBmetadata_search\fP
+.hy 
+\fIPV\fP
 .br
 .RS 4
 .ad l
@@ -382,58 +389,62 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
-\fB--dump\fP \fBheaders\fP|\fBmetadata\fP|\fBmetadata_all\fP|\fBmetadata_search\fP
+\fB--dump\fP 
+.nh
+\fBheaders\fP|\:\fBmetadata\fP|\:\fBmetadata_all\fP|\:\fBmetadata_search\fP
+.hy
 .br
+.ad b
 Dump headers and metadata from a PV for debugging and repair.
 Option values include: \fBheaders\fP to print and check LVM headers,
 \fBmetadata\fP to print or save the current text metadata,
@@ -441,58 +452,58 @@ Option values include: \fBheaders\fP to print and check LVM headers,
 \fBmetadata_search\fP to list or save all versions of metadata,
 searching standard locations in case of damaged headers,
 \fBmetadata_area\fP to save an entire text metadata area to a file.
-.ad b
-.HP
+.TP
 .ad l
 \fB-f\fP|\fB--file\fP \fIString\fP
 .br
-Metadata file to read or write.
 .ad b
-.HP
+Metadata file to read or write.
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--labelsector\fP \fINumber\fP
 .br
+.ad b
 By default the PV is labelled with an LVM2 identifier in its second
 sector (sector 1). This lets you use a different sector near the
 start of the disk (between 0 and 3 inclusive - see LABEL_SCAN_SECTORS
 in the source). Use with care.
-.ad b
-.HP
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB--[pv]metadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
 .br
+.ad b
 The number of metadata areas to set aside on a PV for storing VG metadata.
 When 2, one copy of the VG metadata is stored at the front of the PV
 and a second copy is stored at the end.
@@ -500,67 +511,66 @@ When 1, one copy of the VG metadata is stored at the front of the PV.
 When 0, no copies of the VG metadata are stored on the given PV.
 This may be useful in VGs containing many PVs (this places limitations
 on the ability to use vgsplit later.)
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--repair\fP
 .br
-Repair headers and metadata on a PV.
 .ad b
-.HP
+Repair headers and metadata on a PV.
+.TP
 .ad l
 \fB--repairtype\fP \fBpv_header\fP|\fBmetadata\fP|\fBlabel_header\fP
 .br
-Repair headers and metadata on a PV. See command description.
 .ad b
-.HP
+Repair headers and metadata on a PV. See command description.
+.TP
 .ad l
 \fB--settings\fP \fIString\fP
 .br
+.ad b
 Specifies command specific settings in "Key = Value" form.
 Combine multiple settings in quotes, or repeat the settings
 option for each.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -570,11 +580,11 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -598,70 +608,71 @@ parameter with a value of 204800 (100 * 1024 * 1024 / 512 = 204800).
 .br
 .B pvck --labelsector 204800 /dev/sda
 .SH SEE ALSO
-
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
-
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
-
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
-
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
-
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
-
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
+
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
+
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
+
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
+
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
+
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
+
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/pvcreate.8_pregen b/man/pvcreate.8_pregen
index 0df67bd5d..52ad1d5ee 100644
--- a/man/pvcreate.8_pregen
+++ b/man/pvcreate.8_pregen
@@ -222,10 +222,11 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB--bootloaderareasize\fP \fISize\fP[m|UNIT]
 .br
+.ad b
 Reserve space for the bootloader between the LVM metadata area and the first PE.
 The bootloader area is reserved for bootloaders to embed their own data or
 metadata; LVM will not use it.
@@ -237,154 +238,154 @@ and --dataalignmentoffset. The bootloader area may be larger than requested
 due to the alignment, but it's never less than the requested size.
 To see the bootloader area start and size of
 an existing PV use pvs -o +pv_ba_start,pv_ba_size.
-.ad b
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB--dataalignment\fP \fISize\fP[k|UNIT]
 .br
+.ad b
 Align the start of a PV data area with a multiple of this number.
 To see the location of the first Physical Extent (PE) of an existing PV,
 use pvs -o +pe_start. In addition, it may be shifted by an alignment offset,
 see --dataalignmentoffset.
 Also specify an appropriate PE size when creating a VG.
-.ad b
-.HP
+.TP
 .ad l
 \fB--dataalignmentoffset\fP \fISize\fP[k|UNIT]
 .br
-Shift the start of the PV data area by this additional offset.
 .ad b
-.HP
+Shift the start of the PV data area by this additional offset.
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
+.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--labelsector\fP \fINumber\fP
 .br
+.ad b
 By default the PV is labelled with an LVM2 identifier in its second
 sector (sector 1). This lets you use a different sector near the
 start of the disk (between 0 and 3 inclusive - see LABEL_SCAN_SECTORS
 in the source). Use with care.
-.ad b
-.HP
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB--metadataignore\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Specifies the metadataignore property of a PV.
 If yes, metadata areas on the PV are ignored, and lvm will
 not store metadata in the metadata areas of the PV.
 If no, lvm will store metadata on the PV.
-.ad b
-.HP
+.TP
 .ad l
 \fB--metadatasize\fP \fISize\fP[m|UNIT]
 .br
+.ad b
 The approximate amount of space used for each VG metadata area.
 The size may be rounded.
-.ad b
-.HP
+.TP
 .ad l
 \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
 .br
+.ad b
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
 \fBlvm1\fP (or just \fB1\fP) is no longer used.
-.ad b
-.HP
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--norestorefile\fP
 .br
+.ad b
 In conjunction with --uuid, this allows a uuid to be specified
 without also requiring that a backup of the metadata be provided.
-.ad b
-.HP
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB--[pv]metadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
 .br
+.ad b
 The number of metadata areas to set aside on a PV for storing VG metadata.
 When 2, one copy of the VG metadata is stored at the front of the PV
 and a second copy is stored at the end.
@@ -392,29 +393,29 @@ When 1, one copy of the VG metadata is stored at the front of the PV.
 When 0, no copies of the VG metadata are stored on the given PV.
 This may be useful in VGs containing many PVs (this places limitations
 on the ability to use vgsplit later.)
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--restorefile\fP \fIString\fP
 .br
+.ad b
 In conjunction with --uuid, this reads the file (produced by
 vgcfgbackup), extracts the location and size of the data on the PV,
 and ensures that the metadata produced by the program is consistent
@@ -422,28 +423,28 @@ with the contents of the file, i.e. the physical extents will be in
 the same place and not be overwritten by new metadata. This provides
 a mechanism to upgrade the metadata format or to add/remove metadata
 areas. Use with care.
-.ad b
-.HP
+.TP
 .ad l
 \fB--setphysicalvolumesize\fP \fISize\fP[m|UNIT]
 .br
+.ad b
 Overrides the automatically detected size of the PV.
 Use with care, or prior to reducing the physical size of the device.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-u\fP|\fB--uuid\fP \fIString\fP
 .br
+.ad b
 Specify a UUID for the device.
 Without this option, a random UUID is generated.
 This option is needed before restoring a backup of LVM metadata
@@ -452,38 +453,37 @@ onto a replacement device; see \fBvgcfgrestore\fP(8). As such, use of
 All PVs must have unique UUIDs, and LVM will prevent certain operations
 if multiple devices are seen with the same UUID.
 See \fBvgimportclone\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
-.HP
+.TP
 .ad l
 \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Controls if the first 4 sectors (2048 bytes) of the device are wiped.
 The default is to wipe these sectors unless either or both of
 --restorefile or --uuid are specified.
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -493,11 +493,11 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -525,70 +525,71 @@ boundary) manually account for this when initializing for use by LVM.
 .br
 .B pvcreate --dataalignmentoffset 7s /dev/sdb
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/pvdisplay.8_pregen b/man/pvdisplay.8_pregen
index b560f9de2..1aebef484 100644
--- a/man/pvdisplay.8_pregen
+++ b/man/pvdisplay.8_pregen
@@ -182,164 +182,165 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB--aligned\fP
 .br
-Use with --separator to align the output columns
 .ad b
-.HP
+Use with --separator to align the output columns
+.TP
 .ad l
 \fB-a\fP|\fB--all\fP
 .br
+.ad b
 Show information about devices that have not been initialized
 by LVM, i.e. they are not PVs.
-.ad b
-.HP
+.TP
 .ad l
 \fB--binary\fP
 .br
+.ad b
 Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
 the "unknown" value which denotes that the value could not be determined).
-.ad b
-.HP
+.TP
 .ad l
 \fB-c\fP|\fB--colon\fP
 .br
+.ad b
 Generate colon separated output for easier parsing in scripts or programs.
 Also see \fBvgs\fP(8) which provides considerably more control over the output.
-.ad b
-.HP
+.TP
 .ad l
 \fB-C\fP|\fB--columns\fP
 .br
+.ad b
 Display output in columns, the equivalent of \fBvgs\fP(8).
 Options listed are the same as options given in \fBvgs\fP(8).
-.ad b
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
-See \fBlvmreport\fP(7).
 .ad b
-.HP
+See \fBlvmreport\fP(7).
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB--foreign\fP
 .br
+.ad b
 Report/display foreign VGs that would otherwise be skipped.
 See \fBlvmsystemid\fP(7) for more information about foreign VGs.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--ignorelockingfailure\fP
 .br
+.ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
-.ad b
-.HP
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--logonly\fP
 .br
-Suppress command report and display only log report.
 .ad b
-.HP
+Suppress command report and display only log report.
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB-m\fP|\fB--maps\fP
 .br
-Display the mapping of physical extents to LVs and logical extents.
 .ad b
-.HP
+Display the mapping of physical extents to LVs and logical extents.
+.TP
 .ad l
 \fB--noheadings\fP
 .br
+.ad b
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
-.ad b
-.HP
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--nosuffix\fP
 .br
+.ad b
 Suppress the suffix on output sizes. Use with --units
 (except h and H) if processing the output.
-.ad b
-.HP
+.TP
 .ad l
 \fB-o\fP|\fB--options\fP \fIString\fP
 .br
+.ad b
 Comma-separated, ordered list of fields to display in columns.
 String arg syntax is: [+|-|#]Field1[,Field2 ...]
 The prefix \fB+\fP will append the specified fields to the default fields,
@@ -357,47 +358,47 @@ Use field name \fBlv_all\fP to view all LV fields,
 \fBpvseg_all\fP all PV segment columns.
 See the lvm.conf report section for more config options.
 See \fBlvmreport\fP(7) for more information about reporting.
-.ad b
-.HP
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--readonly\fP
 .br
+.ad b
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
+.ad b
 Select objects for processing and reporting based on specified criteria.
 The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
@@ -406,84 +407,83 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
-.ad b
-.HP
+.TP
 .ad l
 \fB--separator\fP \fIString\fP
 .br
-String to use to separate each column. Useful if grepping the output.
 .ad b
-.HP
+String to use to separate each column. Useful if grepping the output.
+.TP
 .ad l
 \fB--shared\fP
 .br
+.ad b
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
 See \fBlvmlockd\fP(8) for more information about shared VGs.
-.ad b
-.HP
+.TP
 .ad l
 \fB-s\fP|\fB--short\fP
 .br
-Only display the size of the given PVs.
 .ad b
-.HP
+Only display the size of the given PVs.
+.TP
 .ad l
 \fB-O\fP|\fB--sort\fP \fIString\fP
 .br
+.ad b
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB--unbuffered\fP
 .br
-Produce output immediately without sorting or aligning the columns properly.
 .ad b
-.HP
+Produce output immediately without sorting or aligning the columns properly.
+.TP
 .ad l
 \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
 .br
+.ad b
 All sizes are output in these units:
 human-(r)eadable with '<' rounding indicator,
 (h)uman-readable, (b)ytes, (s)ectors, (k)ilobytes, (m)egabytes,
 (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
 Custom units can be specified, e.g. --units 3M.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -493,16 +493,16 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
+.TP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -518,70 +518,71 @@ capital letters mean multiple of 1000.)
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/pvmove.8_pregen b/man/pvmove.8_pregen
index a370e75ba..a9fab6eac 100644
--- a/man/pvmove.8_pregen
+++ b/man/pvmove.8_pregen
@@ -41,7 +41,11 @@ Move PV extents.
 .ad b
 .br
 .ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+[    \fB--alloc\fP 
+.nh
+\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+.hy
+]
 .ad b
 .br
 .ad l
@@ -157,19 +161,23 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB--abort\fP
 .br
+.ad b
 Abort any pvmove operations in progress. If a pvmove was started
 with the --atomic option, then all LVs will remain on the source PV.
 Otherwise, segments that have been moved will remain on the
 destination PV, while unmoved segments will remain on the source PV.
-.ad b
-.HP
+.TP
 .ad l
-\fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
+\fB--alloc\fP 
+.nh
+\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+.hy
 .br
+.ad b
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
 which can be changed with vgchange/lvchange, or overridden on the
@@ -186,181 +194,180 @@ e.g. by placing two stripes on the same PV.
 Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
-.ad b
-.HP
+.TP
 .ad l
 \fB--atomic\fP
 .br
+.ad b
 Makes a pvmove operation atomic, ensuring that all affected LVs are
 moved to the destination PV, or none are if the operation is aborted.
-.ad b
-.HP
+.TP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-b\fP|\fB--background\fP
 .br
+.ad b
 If the operation requires polling, this option causes the command to
 return before the operation is complete, and polling is done in the
 background.
-.ad b
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB-i\fP|\fB--interval\fP \fINumber\fP
 .br
-Report progress at regular intervals.
 .ad b
-.HP
+Report progress at regular intervals.
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB-n\fP|\fB--name\fP \fIString\fP
 .br
-Move only the extents belonging to the named LV.
 .ad b
-.HP
+Move only the extents belonging to the named LV.
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--noudevsync\fP
 .br
+.ad b
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
-.ad b
-.HP
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -370,11 +377,11 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -481,70 +488,71 @@ extents can also be picked out and moved.
 .br
 .B pvmove -n lvol1 /dev/sdb1:1000-1999 /dev/sdc1
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/pvremove.8_pregen b/man/pvremove.8_pregen
index 802e1d4a1..36577aff2 100644
--- a/man/pvremove.8_pregen
+++ b/man/pvremove.8_pregen
@@ -99,144 +99,144 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
+.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -246,11 +246,11 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -266,70 +266,71 @@ capital letters mean multiple of 1000.)
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/pvresize.8_pregen b/man/pvresize.8_pregen
index 01cbc099f..bb3ab4cb2 100644
--- a/man/pvresize.8_pregen
+++ b/man/pvresize.8_pregen
@@ -94,144 +94,144 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--setphysicalvolumesize\fP \fISize\fP[m|UNIT]
 .br
+.ad b
 Overrides the automatically detected size of the PV.
 Use with care, or prior to reducing the physical size of the device.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -241,11 +241,11 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -273,70 +273,71 @@ appropriate for the intended new partition size).
 .br
 .B pvresize --setphysicalvolumesize 40G /dev/sda1
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/pvs.8_pregen b/man/pvs.8_pregen
index cb43845d2..12160af0d 100644
--- a/man/pvs.8_pregen
+++ b/man/pvs.8_pregen
@@ -178,152 +178,153 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB--aligned\fP
 .br
-Use with --separator to align the output columns
 .ad b
-.HP
+Use with --separator to align the output columns
+.TP
 .ad l
 \fB-a\fP|\fB--all\fP
 .br
+.ad b
 Show information about devices that have not been initialized
 by LVM, i.e. they are not PVs.
-.ad b
-.HP
+.TP
 .ad l
 \fB--binary\fP
 .br
+.ad b
 Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
 the "unknown" value which denotes that the value could not be determined).
-.ad b
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
-See \fBlvmreport\fP(7).
 .ad b
-.HP
+See \fBlvmreport\fP(7).
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB--foreign\fP
 .br
+.ad b
 Report/display foreign VGs that would otherwise be skipped.
 See \fBlvmsystemid\fP(7) for more information about foreign VGs.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--ignorelockingfailure\fP
 .br
+.ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
-.ad b
-.HP
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--logonly\fP
 .br
-Suppress command report and display only log report.
 .ad b
-.HP
+Suppress command report and display only log report.
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB--nameprefixes\fP
 .br
+.ad b
 Add an "LVM2_" prefix plus the field name to the output. Useful
 with --noheadings to produce a list of field=value pairs that can
 be used to set environment variables (for example, in udev rules).
-.ad b
-.HP
+.TP
 .ad l
 \fB--noheadings\fP
 .br
+.ad b
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
-.ad b
-.HP
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--nosuffix\fP
 .br
+.ad b
 Suppress the suffix on output sizes. Use with --units
 (except h and H) if processing the output.
-.ad b
-.HP
+.TP
 .ad l
 \fB-o\fP|\fB--options\fP \fIString\fP
 .br
+.ad b
 Comma-separated, ordered list of fields to display in columns.
 String arg syntax is: [+|-|#]Field1[,Field2 ...]
 The prefix \fB+\fP will append the specified fields to the default fields,
@@ -341,61 +342,61 @@ Use field name \fBlv_all\fP to view all LV fields,
 \fBpvseg_all\fP all PV segment columns.
 See the lvm.conf report section for more config options.
 See \fBlvmreport\fP(7) for more information about reporting.
-.ad b
-.HP
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--readonly\fP
 .br
+.ad b
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--rows\fP
 .br
-Output columns as rows.
 .ad b
-.HP
+Output columns as rows.
+.TP
 .ad l
 \fB--segments\fP
 .br
+.ad b
 Produces one line of output for each contiguous allocation of space on each
 PV, showing the start (pvseg_start) and length (pvseg_size) in units of
 physical extents.
-.ad b
-.HP
+.TP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
+.ad b
 Select objects for processing and reporting based on specified criteria.
 The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
@@ -404,85 +405,84 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
-.ad b
-.HP
+.TP
 .ad l
 \fB--separator\fP \fIString\fP
 .br
-String to use to separate each column. Useful if grepping the output.
 .ad b
-.HP
+String to use to separate each column. Useful if grepping the output.
+.TP
 .ad l
 \fB--shared\fP
 .br
+.ad b
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
 See \fBlvmlockd\fP(8) for more information about shared VGs.
-.ad b
-.HP
+.TP
 .ad l
 \fB-O\fP|\fB--sort\fP \fIString\fP
 .br
+.ad b
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB--unbuffered\fP
 .br
-Produce output immediately without sorting or aligning the columns properly.
 .ad b
-.HP
+Produce output immediately without sorting or aligning the columns properly.
+.TP
 .ad l
 \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
 .br
+.ad b
 All sizes are output in these units:
 human-(r)eadable with '<' rounding indicator,
 (h)uman-readable, (b)ytes, (s)ectors, (k)ilobytes, (m)egabytes,
 (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
 Custom units can be specified, e.g. --units 3M.
-.ad b
-.HP
+.TP
 .ad l
 \fB--unquoted\fP
 .br
+.ad b
 When used with --nameprefixes, output values in the field=value
 pairs are not quoted.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -492,16 +492,16 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
+.TP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -526,70 +526,71 @@ e(x)ported
 .IP 3 3
 (m)issing
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/pvscan.8_pregen b/man/pvscan.8_pregen
index b604f9328..644c6a2fc 100644
--- a/man/pvscan.8_pregen
+++ b/man/pvscan.8_pregen
@@ -206,202 +206,202 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP
 .br
+.ad b
 Auto-activate LVs in a VG when the PVs scanned have completed the VG.
 (Only \fBay\fP is applicable.)
-.ad b
-.HP
+.TP
 .ad l
 \fB--cache\fP
 .br
-Scan one or more devices and record that they are online.
 .ad b
-.HP
+Scan one or more devices and record that they are online.
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB-e\fP|\fB--exported\fP
 .br
-Only show PVs belonging to exported VGs.
 .ad b
-.HP
+Only show PVs belonging to exported VGs.
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--ignorelockingfailure\fP
 .br
+.ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
-.ad b
-.HP
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB-j\fP|\fB--major\fP \fINumber\fP
 .br
-The major number of a device.
 .ad b
-.HP
+The major number of a device.
+.TP
 .ad l
 \fB--minor\fP \fINumber\fP
 .br
-The minor number of a device.
 .ad b
-.HP
+The minor number of a device.
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--noudevsync\fP
 .br
+.ad b
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
-.ad b
-.HP
+.TP
 .ad l
 \fB-n\fP|\fB--novolumegroup\fP
 .br
-Only show PVs not belonging to any VG.
 .ad b
-.HP
+Only show PVs not belonging to any VG.
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-s\fP|\fB--short\fP
 .br
-Short listing format.
 .ad b
-.HP
+Short listing format.
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-u\fP|\fB--uuid\fP
 .br
-Show UUIDs in addition to device names.
 .ad b
-.HP
+Show UUIDs in addition to device names.
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -411,11 +411,11 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -431,70 +431,71 @@ capital letters mean multiple of 1000.)
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/vgcfgbackup.8_pregen b/man/vgcfgbackup.8_pregen
index 8f662a7ad..5d359146a 100644
--- a/man/vgcfgbackup.8_pregen
+++ b/man/vgcfgbackup.8_pregen
@@ -125,178 +125,178 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB-f\fP|\fB--file\fP \fIString\fP
 .br
+.ad b
 Write the backup to the named file.
 When backing up more than one VG, the file name is
 treated as a template, and %s is replaced by the VG name.
-.ad b
-.HP
+.TP
 .ad l
 \fB--foreign\fP
 .br
+.ad b
 Report/display foreign VGs that would otherwise be skipped.
 See \fBlvmsystemid\fP(7) for more information about foreign VGs.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--ignorelockingfailure\fP
 .br
+.ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
-.ad b
-.HP
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--readonly\fP
 .br
+.ad b
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -312,70 +312,71 @@ capital letters mean multiple of 1000.)
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/vgcfgrestore.8_pregen b/man/vgcfgrestore.8_pregen
index 43d863541..eb1564f70 100644
--- a/man/vgcfgrestore.8_pregen
+++ b/man/vgcfgrestore.8_pregen
@@ -229,166 +229,166 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB-f\fP|\fB--file\fP \fIString\fP
 .br
+.ad b
 Read metadata backup from the named file.
 Usually this file was created by vgcfgbackup.
-.ad b
-.HP
+.TP
 .ad l
 \fB--force\fP ...
 .br
+.ad b
 Force metadata restore even with thin pool LVs.
 Use with extreme caution. Most changes to thin metadata
 cannot be reverted.
 You may lose data if you restore metadata that does not match the
 thin pool kernel metadata precisely.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB-l\fP|\fB--list\fP
 .br
+.ad b
 List metadata backup and archive files pertaining to the VG.
 May be used with --file. Does not restore the VG.
-.ad b
-.HP
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
 .br
+.ad b
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
 \fBlvm1\fP (or just \fB1\fP) is no longer used.
-.ad b
-.HP
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -413,70 +413,71 @@ arguments as appropriate) to initialise it with the same UUID as the
 missing PV. Repeat for all other missing PVs in the VG.  Then use
 \fBvgcfgrestore --file filename\fP to restore the VG's metadata.
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/vgchange.8_pregen b/man/vgchange.8_pregen
index 04cc23b8b..c5af0de36 100644
--- a/man/vgchange.8_pregen
+++ b/man/vgchange.8_pregen
@@ -23,7 +23,10 @@ vgchange - Change volume group attributes
 .ad b
 .br
 .ad l
-    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
+    \fB--alloc\fP 
+.nh
+\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+.hy
 .ad b
 .br
 .ad l
@@ -170,6 +173,10 @@ vgchange - Change volume group attributes
  \fB-S\fP|\fB--select\fP \fIString\fP
 .ad b
 .br
+.ad l
+    \fB--setautoactivation\fP \fBy\fP|\fBn\fP
+.ad b
+.br
 .ad l
     \fB--sysinit\fP
 .ad b
@@ -214,55 +221,36 @@ required, after which the others are optional.
 .P
 \fBvgchange\fP
 .RS 4
-( \fB-l\fP|\fB--logicalvolume\fP \fINumber\fP,
-.ad b
+( \fB-l\fP|\fB--logicalvolume\fP \fINumber\fP
 .br
-.ad l
-  \fB-p\fP|\fB--maxphysicalvolumes\fP \fINumber\fP,
-.ad b
+  \fB-p\fP|\fB--maxphysicalvolumes\fP \fINumber\fP
 .br
-.ad l
-  \fB-u\fP|\fB--uuid\fP,
-.ad b
+  \fB-u\fP|\fB--uuid\fP
 .br
-.ad l
-  \fB-s\fP|\fB--physicalextentsize\fP \fISize\fP[m|UNIT],
-.ad b
+  \fB-s\fP|\fB--physicalextentsize\fP \fISize\fP[m|UNIT]
 .br
-.ad l
-  \fB-x\fP|\fB--resizeable\fP \fBy\fP|\fBn\fP,
-.ad b
+  \fB-x\fP|\fB--resizeable\fP \fBy\fP|\fBn\fP
 .br
-.ad l
-     \fB--addtag\fP \fITag\fP,
-.ad b
+     \fB--addtag\fP \fITag\fP
 .br
-.ad l
-     \fB--deltag\fP \fITag\fP,
-.ad b
+     \fB--deltag\fP \fITag\fP
 .br
-.ad l
-     \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP,
-.ad b
+     \fB--alloc\fP 
+.nh
+\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+.hy
 .br
-.ad l
-     \fB--pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP,
-.ad b
+     \fB--pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
 .br
-.ad l
-     \fB--[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP,
-.ad b
+     \fB--[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP
 .br
-.ad l
-     \fB--profile\fP \fIString\fP,
-.ad b
+     \fB--profile\fP \fIString\fP
 .br
-.ad l
-     \fB--detachprofile\fP,
-.ad b
+     \fB--detachprofile\fP
 .br
-.ad l
-     \fB--metadataprofile\fP \fIString\fP )
+     \fB--metadataprofile\fP \fIString\fP
+.br
+     \fB--setautoactivation\fP \fBy\fP|\fBn\fP )
 .RE
 .br
 .RS 4
@@ -645,10 +633,11 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP
 .br
+.ad b
 Change the active state of LVs.
 An active LV can be used through a block device,
 allowing data on the LV to be accessed.
@@ -661,18 +650,23 @@ All software and scripts should access the device through the symbolic
 link and present this as the name of the device.
 The location and name of the underlying device node may depend on
 the distribution, configuration (e.g. udev), or release version.
-\fBay\fP specifies autoactivation, in which case an LV is activated
-only if it matches an item in lvm.conf activation/auto_activation_volume_list.
-If the list is not set, all LVs are considered to match, and if
-if the list is set but empty, no LVs match.
-Autoactivation should be used during system boot to make it possible
-to select which LVs should be automatically activated by the system.
+\fBay\fP specifies autoactivation, which is used by system-generated
+activation commands.  By default, LVs are autoactivated.
+An autoactivation property can be set on a VG or LV to disable autoactivation,
+see --setautoactivation y|n in vgchange, lvchange, vgcreate, and lvcreate.
+Display the property with vgs or lvs "-o autoactivation".
+The lvm.conf auto_activation_volume_list includes names of VGs or LVs
+that should be autoactivated, and anything not listed is not autoactivated.
+When auto_activation_volume_list is undefined (the default), it has no effect.
+If auto_activation_volume_list is defined and empty, no LVs are autoactivated.
+Items included by auto_activation_volume_list will not be autoactivated if
+the autoactivation property has been disabled.
 See \fBlvmlockd\fP(8) for more information about activation options \fBey\fP and \fBsy\fP for shared VGs.
-.ad b
-.HP
+.TP
 .ad l
 \fB--activationmode\fP \fBpartial\fP|\fBdegraded\fP|\fBcomplete\fP
 .br
+.ad b
 Determines if LV activation is allowed when PVs are missing,
 e.g. because of a device failure.
 \fBcomplete\fP only allows LVs with no missing PVs to be activated,
@@ -683,18 +677,21 @@ and is the most restrictive mode.
 should only be used for recovery or repair.
 For default, see lvm.conf/activation_mode.
 See \fBlvmraid\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--addtag\fP \fITag\fP
 .br
+.ad b
 Adds a tag to a PV, VG or LV. This option can be repeated to add
 multiple tags at once. See \fBlvm\fP(8) for information about tags.
-.ad b
-.HP
+.TP
 .ad l
-\fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
+\fB--alloc\fP 
+.nh
+\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+.hy
 .br
+.ad b
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
 which can be changed with vgchange/lvchange, or overridden on the
@@ -711,205 +708,205 @@ e.g. by placing two stripes on the same PV.
 Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
-.ad b
-.HP
+.TP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--deltag\fP \fITag\fP
 .br
+.ad b
 Deletes a tag from a PV, VG or LV. This option can be repeated to delete
 multiple tags at once. See \fBlvm\fP(8) for information about tags.
-.ad b
-.HP
+.TP
 .ad l
 \fB--detachprofile\fP
 .br
+.ad b
 Detaches a metadata profile from a VG or LV.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
+.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB-K\fP|\fB--ignoreactivationskip\fP
 .br
+.ad b
 Ignore the "activation skip" LV flag during activation
 to allow LVs with the flag set to be activated.
-.ad b
-.HP
+.TP
 .ad l
 \fB--ignorelockingfailure\fP
 .br
+.ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
-.ad b
-.HP
+.TP
 .ad l
 \fB--ignoremonitoring\fP
 .br
+.ad b
 Do not interact with dmeventd unless --monitor is specified.
 Do not use this if dmeventd is already monitoring a device.
-.ad b
-.HP
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--lockstart\fP
 .br
+.ad b
 Start the lockspace of a shared VG in lvmlockd.
 lvmlockd locks becomes available for the VG, allowing LVM to use the VG.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--lockstop\fP
 .br
+.ad b
 Stop the lockspace of a shared VG in lvmlockd.
 lvmlockd locks become unavailable for the VG, preventing LVM from using the VG.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--locktype\fP \fBsanlock\fP|\fBdlm\fP|\fBnone\fP
 .br
+.ad b
 Change the VG lock type to or from a shared lock type used with lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-l\fP|\fB--logicalvolume\fP \fINumber\fP
 .br
-Sets the maximum number of LVs allowed in a VG.
 .ad b
-.HP
+Sets the maximum number of LVs allowed in a VG.
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB-p\fP|\fB--maxphysicalvolumes\fP \fINumber\fP
 .br
+.ad b
 Sets the maximum number of PVs that can belong to the VG.
 The value 0 removes any limitation.
 For large numbers of PVs, also see options --pvmetadatacopies,
 and --vgmetadatacopies for improving performance.
-.ad b
-.HP
+.TP
 .ad l
 \fB--metadataprofile\fP \fIString\fP
 .br
+.ad b
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--monitor\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Start (yes) or stop (no) monitoring an LV with dmeventd.
 dmeventd monitors kernel events for an LV, and performs
 automated maintenance for the LV in reponse to specific events.
 See \fBdmeventd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--noudevsync\fP
 .br
+.ad b
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
-.ad b
-.HP
+.TP
 .ad l
 \fB-P\fP|\fB--partial\fP
 .br
+.ad b
 Commands will do their best to activate LVs with missing PV extents.
 Missing extents may be replaced with error or zero segments
 according to the lvm.conf missing_stripe_filler setting.
 Metadata may not be changed with this option.
-.ad b
-.HP
+.TP
 .ad l
 \fB-s\fP|\fB--physicalextentsize\fP \fISize\fP[m|UNIT]
 .br
+.ad b
 Sets the physical extent size of PVs in the VG.
 The value must be either a power of 2 of at least 1 sector
 (where the sector size is the largest sector size of the PVs
@@ -919,11 +916,11 @@ without recreating the VG, unless no extents need moving.
 Before increasing the physical extent size, you might need to use lvresize,
 pvresize and/or pvmove so that everything fits. For example, every
 contiguous range of extents used in a LV must start and end on an extent boundary.
-.ad b
-.HP
+.TP
 .ad l
 \fB--poll\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 When yes, start the background transformation of an LV.
 An incomplete transformation, e.g. pvmove or lvconvert interrupted
 by reboot or crash, can be restarted from the last checkpoint with --poll y.
@@ -931,18 +928,18 @@ When no, background transformation of an LV will not occur, and the
 transformation will not complete. It may not be appropriate to immediately
 poll an LV after activation, in which case --poll n can be used to defer
 polling until a later --poll y command.
-.ad b
-.HP
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB--pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
 .br
+.ad b
 The number of metadata areas to set aside on a PV for storing VG metadata.
 When 2, one copy of the VG metadata is stored at the front of the PV
 and a second copy is stored at the end.
@@ -950,56 +947,56 @@ When 1, one copy of the VG metadata is stored at the front of the PV.
 When 0, no copies of the VG metadata are stored on the given PV.
 This may be useful in VGs containing many PVs (this places limitations
 on the ability to use vgsplit later.)
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--readonly\fP
 .br
+.ad b
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
-.ad b
-.HP
+.TP
 .ad l
 \fB--refresh\fP
 .br
+.ad b
 If the LV is active, reload its metadata.
 This is not necessary in normal operation, but may be useful
 if something has gone wrong, or if some form of manual LV
 sharing is being used.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-x\fP|\fB--resizeable\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Enables or disables the addition or removal of PVs to/from a VG
 (by vgextend/vgreduce).
-.ad b
-.HP
+.TP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
+.ad b
 Select objects for processing and reporting based on specified criteria.
 The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
@@ -1008,11 +1005,25 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
+.TP
+.ad l
+\fB--setautoactivation\fP \fBy\fP|\fBn\fP
+.br
 .ad b
-.HP
+Set the autoactivation property on a VG or LV.
+Display the property with vgs or lvs "-o autoactivation".
+When the autoactivation property is disabled, the VG or LV
+will not be activated by a command doing autoactivation
+(vgchange, lvchange, or pvscan using -aay.)
+If autoactivation is disabled on a VG, no LVs will be autoactivated
+in that VG, and the LV autoactivation property has no effect.
+If autoactivation is enabled on a VG, autoactivation can be disabled
+for individual LVs.
+.TP
 .ad l
 \fB--sysinit\fP
 .br
+.ad b
 Indicates that vgchange/lvchange is being invoked from early system initialisation
 scripts (e.g. rc.sysinit or an initrd), before writable filesystems are
 available. As such, some functionality needs to be disabled and this option
@@ -1020,49 +1031,49 @@ acts as a shortcut which selects an appropriate set of options. Currently,
 this is equivalent to using --ignorelockingfailure, --ignoremonitoring,
 --poll n, and setting env var LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES.
 vgchange/lvchange skip autoactivation, and defer to pvscan autoactivation.
-.ad b
-.HP
+.TP
 .ad l
 \fB--systemid\fP \fIString\fP
 .br
+.ad b
 Changes the system ID of the VG.  Using this option requires caution
 because the VG may become foreign to the host running the command,
 leaving the host unable to access it.
 See \fBlvmsystemid\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-u\fP|\fB--uuid\fP
 .br
-Generate new random UUID for specified VGs.
 .ad b
-.HP
+Generate new random UUID for specified VGs.
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB--[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP
 .br
+.ad b
 Number of copies of the VG metadata that are kept.
 VG metadata is kept in VG metadata areas on PVs in the VG,
 i.e. reserved space at the start and/or end of the PVs.
@@ -1076,36 +1087,35 @@ The number can also be replaced with special string values:
 metadataignore flags.
 \fBall\fP causes LVM to first clear the metadataignore flags on
 all PVs, and then to become unmanaged.
-.ad b
-.HP
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
+.TP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.HP
+.TP
 \fISelect\fP
 .br
 Select indicates that a required positional parameter can
 be omitted if the \fB--select\fP option is used.
 No arg appears in this position.
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -1133,70 +1143,71 @@ Change the maximum number of LVs for an inactive VG.
 .br
 .B vgchange -l 128 vg00
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/vgck.8_pregen b/man/vgck.8_pregen
index 13f7a1eb9..7682431ff 100644
--- a/man/vgck.8_pregen
+++ b/man/vgck.8_pregen
@@ -112,118 +112,119 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB--updatemetadata\fP
 .br
+.ad b
 Update VG metadata to correct problems.
 If VG metadata was updated while a PV was missing, and the PV
 reappears with an old version of metadata, then this option
@@ -234,43 +235,42 @@ this option will clear the outdated metadata from the previously
 missing PV. If metadata text is damaged on one PV, using this
 option will replace the damaged metadata text. For more severe
 damage, e.g. with headers, see \fBpvck\fP(8).
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
+.TP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -286,70 +286,71 @@ capital letters mean multiple of 1000.)
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/vgconvert.8_pregen b/man/vgconvert.8_pregen
index ab7c083e9..2f2ba8b75 100644
--- a/man/vgconvert.8_pregen
+++ b/man/vgconvert.8_pregen
@@ -115,10 +115,11 @@ Common options for lvm:
 .RE
 
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB--bootloaderareasize\fP \fISize\fP[m|UNIT]
 .br
+.ad b
 Reserve space for the bootloader between the LVM metadata area and the first PE.
 The bootloader area is reserved for bootloaders to embed their own data or
 metadata; LVM will not use it.
@@ -130,122 +131,122 @@ and --dataalignmentoffset. The bootloader area may be larger than requested
 due to the alignment, but it's never less than the requested size.
 To see the bootloader area start and size of
 an existing PV use pvs -o +pv_ba_start,pv_ba_size.
-.ad b
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
+.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--labelsector\fP \fINumber\fP
 .br
+.ad b
 By default the PV is labelled with an LVM2 identifier in its second
 sector (sector 1). This lets you use a different sector near the
 start of the disk (between 0 and 3 inclusive - see LABEL_SCAN_SECTORS
 in the source). Use with care.
-.ad b
-.HP
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB--metadatasize\fP \fISize\fP[m|UNIT]
 .br
+.ad b
 The approximate amount of space used for each VG metadata area.
 The size may be rounded.
-.ad b
-.HP
+.TP
 .ad l
 \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
 .br
+.ad b
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
 \fBlvm1\fP (or just \fB1\fP) is no longer used.
-.ad b
-.HP
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB--pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
 .br
+.ad b
 The number of metadata areas to set aside on a PV for storing VG metadata.
 When 2, one copy of the VG metadata is stored at the front of the PV
 and a second copy is stored at the end.
@@ -253,66 +254,65 @@ When 1, one copy of the VG metadata is stored at the front of the PV.
 When 0, no copies of the VG metadata are stored on the given PV.
 This may be useful in VGs containing many PVs (this places limitations
 on the ability to use vgsplit later.)
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -329,70 +329,71 @@ See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/vgcreate.8_pregen b/man/vgcreate.8_pregen
index 0b7802ed7..61823d579 100644
--- a/man/vgcreate.8_pregen
+++ b/man/vgcreate.8_pregen
@@ -59,7 +59,11 @@ device.
 .ad b
 .br
 .ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+[    \fB--alloc\fP 
+.nh
+\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+.hy
+]
 .ad b
 .br
 .ad l
@@ -106,6 +110,10 @@ device.
 [    \fB--locktype\fP \fBsanlock\fP|\fBdlm\fP|\fBnone\fP ]
 .ad b
 .br
+.ad l
+[    \fB--setautoactivation\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -178,17 +186,21 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB--addtag\fP \fITag\fP
 .br
+.ad b
 Adds a tag to a PV, VG or LV. This option can be repeated to add
 multiple tags at once. See \fBlvm\fP(8) for information about tags.
-.ad b
-.HP
+.TP
 .ad l
-\fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
+\fB--alloc\fP 
+.nh
+\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+.hy
 .br
+.ad b
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
 which can be changed with vgchange/lvchange, or overridden on the
@@ -205,192 +217,192 @@ e.g. by placing two stripes on the same PV.
 Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
-.ad b
-.HP
+.TP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-c\fP|\fB--clustered\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 This option was specific to clvm and is now replaced by
 the --shared option with \fBlvmlockd\fP(8).
-.ad b
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB--dataalignment\fP \fISize\fP[k|UNIT]
 .br
+.ad b
 Align the start of a PV data area with a multiple of this number.
 To see the location of the first Physical Extent (PE) of an existing PV,
 use pvs -o +pe_start. In addition, it may be shifted by an alignment offset,
 see --dataalignmentoffset.
 Also specify an appropriate PE size when creating a VG.
-.ad b
-.HP
+.TP
 .ad l
 \fB--dataalignmentoffset\fP \fISize\fP[k|UNIT]
 .br
-Shift the start of the PV data area by this additional offset.
 .ad b
-.HP
+Shift the start of the PV data area by this additional offset.
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
+.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--labelsector\fP \fINumber\fP
 .br
+.ad b
 By default the PV is labelled with an LVM2 identifier in its second
 sector (sector 1). This lets you use a different sector near the
 start of the disk (between 0 and 3 inclusive - see LABEL_SCAN_SECTORS
 in the source). Use with care.
-.ad b
-.HP
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--locktype\fP \fBsanlock\fP|\fBdlm\fP|\fBnone\fP
 .br
+.ad b
 Specify the VG lock type directly in place of using --shared.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB-l\fP|\fB--maxlogicalvolumes\fP \fINumber\fP
 .br
-Sets the maximum number of LVs allowed in a VG.
 .ad b
-.HP
+Sets the maximum number of LVs allowed in a VG.
+.TP
 .ad l
 \fB-p\fP|\fB--maxphysicalvolumes\fP \fINumber\fP
 .br
+.ad b
 Sets the maximum number of PVs that can belong to the VG.
 The value 0 removes any limitation.
 For large numbers of PVs, also see options --pvmetadatacopies,
 and --vgmetadatacopies for improving performance.
-.ad b
-.HP
+.TP
 .ad l
 \fB--metadataprofile\fP \fIString\fP
 .br
+.ad b
 The metadata profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--metadatasize\fP \fISize\fP[m|UNIT]
 .br
+.ad b
 The approximate amount of space used for each VG metadata area.
 The size may be rounded.
-.ad b
-.HP
+.TP
 .ad l
 \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
 .br
+.ad b
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
 \fBlvm1\fP (or just \fB1\fP) is no longer used.
-.ad b
-.HP
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB-s\fP|\fB--physicalextentsize\fP \fISize\fP[m|UNIT]
 .br
+.ad b
 Sets the physical extent size of PVs in the VG.
 The value must be either a power of 2 of at least 1 sector
 (where the sector size is the largest sector size of the PVs
 currently used in the VG), or at least 128KiB.
 Once this value has been set, it is difficult to change
 without recreating the VG, unless no extents need moving.
-.ad b
-.HP
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB--pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
 .br
+.ad b
 The number of metadata areas to set aside on a PV for storing VG metadata.
 When 2, one copy of the VG metadata is stored at the front of the PV
 and a second copy is stored at the end.
@@ -398,39 +410,53 @@ When 1, one copy of the VG metadata is stored at the front of the PV.
 When 0, no copies of the VG metadata are stored on the given PV.
 This may be useful in VGs containing many PVs (this places limitations
 on the ability to use vgsplit later.)
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
+.TP
+.ad l
+\fB--setautoactivation\fP \fBy\fP|\fBn\fP
+.br
 .ad b
-.HP
+Set the autoactivation property on a VG or LV.
+Display the property with vgs or lvs "-o autoactivation".
+When the autoactivation property is disabled, the VG or LV
+will not be activated by a command doing autoactivation
+(vgchange, lvchange, or pvscan using -aay.)
+If autoactivation is disabled on a VG, no LVs will be autoactivated
+in that VG, and the LV autoactivation property has no effect.
+If autoactivation is enabled on a VG, autoactivation can be disabled
+for individual LVs.
+.TP
 .ad l
 \fB--shared\fP
 .br
+.ad b
 Create a shared VG using lvmlockd if LVM is compiled with lockd support.
 lvmlockd will select lock type sanlock or dlm depending on which lock
 manager is running. This allows multiple hosts to share a VG on shared
 devices. lvmlockd and a lock manager must be configured and running.
 See \fBlvmlockd\fP(8) for more information about shared VGs.
-.ad b
-.HP
+.TP
 .ad l
 \fB--systemid\fP \fIString\fP
 .br
+.ad b
 Specifies the system ID that will be given to the new VG, overriding the
 system ID of the host running the command. A VG is normally created
 without this option, in which case the new VG is given the system ID of
@@ -438,34 +464,34 @@ the host creating it. Using this option requires caution because the
 system ID of the new VG may not match the system ID of the host running
 the command, leaving the VG inaccessible to the host.
 See \fBlvmsystemid\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB--[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP
 .br
+.ad b
 Number of copies of the VG metadata that are kept.
 VG metadata is kept in VG metadata areas on PVs in the VG,
 i.e. reserved space at the start and/or end of the PVs.
@@ -479,29 +505,28 @@ The number can also be replaced with special string values:
 metadataignore flags.
 \fBall\fP causes LVM to first clear the metadataignore flags on
 all PVs, and then to become unmanaged.
-.ad b
-.HP
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
-.HP
+.TP
 .ad l
 \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Controls if the first 4 sectors (2048 bytes) of the device are wiped.
 The default is to wipe these sectors unless either or both of
 --restorefile or --uuid are specified.
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
+.TP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -511,11 +536,11 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -536,70 +561,71 @@ Create a VG with two PVs, using the default physical extent size.
 .br
 .B vgcreate myvg /dev/sdk1 /dev/sdl1
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/vgdisplay.8_pregen b/man/vgdisplay.8_pregen
index 559d64c25..1684a68ba 100644
--- a/man/vgdisplay.8_pregen
+++ b/man/vgdisplay.8_pregen
@@ -177,158 +177,159 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB-A\fP|\fB--activevolumegroups\fP
 .br
+.ad b
 Only select active VGs. The VG is considered active
 if at least one of its LVs is active.
-.ad b
-.HP
+.TP
 .ad l
 \fB--aligned\fP
 .br
-Use with --separator to align the output columns
 .ad b
-.HP
+Use with --separator to align the output columns
+.TP
 .ad l
 \fB--binary\fP
 .br
+.ad b
 Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
 the "unknown" value which denotes that the value could not be determined).
-.ad b
-.HP
+.TP
 .ad l
 \fB-c\fP|\fB--colon\fP
 .br
+.ad b
 Generate colon separated output for easier parsing in scripts or programs.
 Also see \fBvgs\fP(8) which provides considerably more control over the output.
-.ad b
-.HP
+.TP
 .ad l
 \fB-C\fP|\fB--columns\fP
 .br
+.ad b
 Display output in columns, the equivalent of \fBvgs\fP(8).
 Options listed are the same as options given in \fBvgs\fP(8).
-.ad b
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
-See \fBlvmreport\fP(7).
 .ad b
-.HP
+See \fBlvmreport\fP(7).
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB--foreign\fP
 .br
+.ad b
 Report/display foreign VGs that would otherwise be skipped.
 See \fBlvmsystemid\fP(7) for more information about foreign VGs.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--ignorelockingfailure\fP
 .br
+.ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
-.ad b
-.HP
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--logonly\fP
 .br
-Suppress command report and display only log report.
 .ad b
-.HP
+Suppress command report and display only log report.
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB--noheadings\fP
 .br
+.ad b
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
-.ad b
-.HP
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--nosuffix\fP
 .br
+.ad b
 Suppress the suffix on output sizes. Use with --units
 (except h and H) if processing the output.
-.ad b
-.HP
+.TP
 .ad l
 \fB-o\fP|\fB--options\fP \fIString\fP
 .br
+.ad b
 Comma-separated, ordered list of fields to display in columns.
 String arg syntax is: [+|-|#]Field1[,Field2 ...]
 The prefix \fB+\fP will append the specified fields to the default fields,
@@ -346,47 +347,47 @@ Use field name \fBlv_all\fP to view all LV fields,
 \fBpvseg_all\fP all PV segment columns.
 See the lvm.conf report section for more config options.
 See \fBlvmreport\fP(7) for more information about reporting.
-.ad b
-.HP
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--readonly\fP
 .br
+.ad b
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
+.ad b
 Select objects for processing and reporting based on specified criteria.
 The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
@@ -395,97 +396,96 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
-.ad b
-.HP
+.TP
 .ad l
 \fB--separator\fP \fIString\fP
 .br
-String to use to separate each column. Useful if grepping the output.
 .ad b
-.HP
+String to use to separate each column. Useful if grepping the output.
+.TP
 .ad l
 \fB--shared\fP
 .br
+.ad b
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
 See \fBlvmlockd\fP(8) for more information about shared VGs.
-.ad b
-.HP
+.TP
 .ad l
 \fB-s\fP|\fB--short\fP
 .br
-Give a short listing showing the existence of VGs.
 .ad b
-.HP
+Give a short listing showing the existence of VGs.
+.TP
 .ad l
 \fB-O\fP|\fB--sort\fP \fIString\fP
 .br
+.ad b
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB--unbuffered\fP
 .br
-Produce output immediately without sorting or aligning the columns properly.
 .ad b
-.HP
+Produce output immediately without sorting or aligning the columns properly.
+.TP
 .ad l
 \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
 .br
+.ad b
 All sizes are output in these units:
 human-(r)eadable with '<' rounding indicator,
 (h)uman-readable, (b)ytes, (s)ectors, (k)ilobytes, (m)egabytes,
 (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
 Custom units can be specified, e.g. --units 3M.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
+.TP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -501,70 +501,71 @@ capital letters mean multiple of 1000.)
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/vgexport.8_pregen b/man/vgexport.8_pregen
index e88d91922..eb10961ce 100644
--- a/man/vgexport.8_pregen
+++ b/man/vgexport.8_pregen
@@ -128,113 +128,114 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB-a\fP|\fB--all\fP
 .br
 .ad b
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
+.ad b
 Select objects for processing and reporting based on specified criteria.
 The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
@@ -243,59 +244,58 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
+.TP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.HP
+.TP
 \fISelect\fP
 .br
 Select indicates that a required positional parameter can
 be omitted if the \fB--select\fP option is used.
 No arg appears in this position.
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -311,70 +311,71 @@ capital letters mean multiple of 1000.)
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/vgextend.8_pregen b/man/vgextend.8_pregen
index 1aef95d6e..e82cdb4e8 100644
--- a/man/vgextend.8_pregen
+++ b/man/vgextend.8_pregen
@@ -143,153 +143,154 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB--dataalignment\fP \fISize\fP[k|UNIT]
 .br
+.ad b
 Align the start of a PV data area with a multiple of this number.
 To see the location of the first Physical Extent (PE) of an existing PV,
 use pvs -o +pe_start. In addition, it may be shifted by an alignment offset,
 see --dataalignmentoffset.
 Also specify an appropriate PE size when creating a VG.
-.ad b
-.HP
+.TP
 .ad l
 \fB--dataalignmentoffset\fP \fISize\fP[k|UNIT]
 .br
-Shift the start of the PV data area by this additional offset.
 .ad b
-.HP
+Shift the start of the PV data area by this additional offset.
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
+.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--labelsector\fP \fINumber\fP
 .br
+.ad b
 By default the PV is labelled with an LVM2 identifier in its second
 sector (sector 1). This lets you use a different sector near the
 start of the disk (between 0 and 3 inclusive - see LABEL_SCAN_SECTORS
 in the source). Use with care.
-.ad b
-.HP
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB--metadataignore\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Specifies the metadataignore property of a PV.
 If yes, metadata areas on the PV are ignored, and lvm will
 not store metadata in the metadata areas of the PV.
 If no, lvm will store metadata on the PV.
-.ad b
-.HP
+.TP
 .ad l
 \fB--metadatasize\fP \fISize\fP[m|UNIT]
 .br
+.ad b
 The approximate amount of space used for each VG metadata area.
 The size may be rounded.
-.ad b
-.HP
+.TP
 .ad l
 \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
 .br
+.ad b
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
 \fBlvm1\fP (or just \fB1\fP) is no longer used.
-.ad b
-.HP
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB--pvmetadatacopies\fP \fB0\fP|\fB1\fP|\fB2\fP
 .br
+.ad b
 The number of metadata areas to set aside on a PV for storing VG metadata.
 When 2, one copy of the VG metadata is stored at the front of the PV
 and a second copy is stored at the end.
@@ -297,77 +298,76 @@ When 1, one copy of the VG metadata is stored at the front of the PV.
 When 0, no copies of the VG metadata are stored on the given PV.
 This may be useful in VGs containing many PVs (this places limitations
 on the ability to use vgsplit later.)
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--restoremissing\fP
 .br
+.ad b
 Add a PV back into a VG after the PV was missing and then returned,
 e.g. due to a transient failure. The PV is not reinitialized.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
-.HP
+.TP
 .ad l
 \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Controls if the first 4 sectors (2048 bytes) of the device are wiped.
 The default is to wipe these sectors unless either or both of
 --restorefile or --uuid are specified.
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
+.TP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -377,11 +377,11 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -402,70 +402,71 @@ Add two PVs to a VG.
 .br
 .B vgextend vg00 /dev/sda4 /dev/sdn1
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/vgimport.8_pregen b/man/vgimport.8_pregen
index 2592fb4d9..b119a4e15 100644
--- a/man/vgimport.8_pregen
+++ b/man/vgimport.8_pregen
@@ -118,121 +118,122 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB-a\fP|\fB--all\fP
 .br
-Import all visible VGs.
 .ad b
-.HP
+Import all visible VGs.
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
+.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
+.ad b
 Select objects for processing and reporting based on specified criteria.
 The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
@@ -241,59 +242,58 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
+.TP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.HP
+.TP
 \fISelect\fP
 .br
 Select indicates that a required positional parameter can
 be omitted if the \fB--select\fP option is used.
 No arg appears in this position.
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -309,70 +309,71 @@ capital letters mean multiple of 1000.)
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/vgimportclone.8_pregen b/man/vgimportclone.8_pregen
index 8e0144655..42dfa3487 100644
--- a/man/vgimportclone.8_pregen
+++ b/man/vgimportclone.8_pregen
@@ -102,149 +102,149 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB-n\fP|\fB--basevgname\fP \fIString\fP
 .br
+.ad b
 By default the snapshot VG will be renamed to the original name plus a
 numeric suffix to avoid duplicate naming (e.g. 'test_vg' would be renamed
 to 'test_vg1'). This option will override the base VG name that is
 used for all VG renames. If a VG already exists with the specified name
 a numeric suffix will be added (like the previous example) to make it unique.
-.ad b
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB-i\fP|\fB--import\fP
 .br
+.ad b
 Import exported VGs. Otherwise VGs that have been exported
 will not be changed (nor will their associated PVs).
-.ad b
-.HP
+.TP
 .ad l
 \fB--importdevices\fP
 .br
-Add devices to the devices file.
 .ad b
-.HP
+Add devices to the devices file.
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -254,11 +254,11 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -282,70 +282,71 @@ Rename the VG associated with "/dev/sdc" and "/dev/sdd" from "vg00" to "vg00_sna
 .br
 .B vgimportclone --basevgname vg00_snap /dev/sdc /dev/sdd
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/vgimportdevices.8_pregen b/man/vgimportdevices.8_pregen
index b08c205cd..1472de265 100644
--- a/man/vgimportdevices.8_pregen
+++ b/man/vgimportdevices.8_pregen
@@ -124,120 +124,121 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB-a\fP|\fB--all\fP
 .br
 .ad b
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB--foreign\fP
 .br
+.ad b
 Report/display foreign VGs that would otherwise be skipped.
 See \fBlvmsystemid\fP(7) for more information about foreign VGs.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
+.ad b
 Select objects for processing and reporting based on specified criteria.
 The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
@@ -246,59 +247,58 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
+.TP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.HP
+.TP
 \fISelect\fP
 .br
 Select indicates that a required positional parameter can
 be omitted if the \fB--select\fP option is used.
 No arg appears in this position.
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -314,70 +314,71 @@ capital letters mean multiple of 1000.)
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/vgmerge.8_pregen b/man/vgmerge.8_pregen
index b555a8365..f0ef43ddc 100644
--- a/man/vgmerge.8_pregen
+++ b/man/vgmerge.8_pregen
@@ -95,147 +95,147 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB-l\fP|\fB--list\fP
 .br
-Display merged destination VG like vgdisplay -v.
 .ad b
-.HP
+Display merged destination VG like vgdisplay -v.
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -257,70 +257,71 @@ Merge an inactive VG named "vg00" into the active or inactive VG named
 .br
 .B vgmerge -v databases vg00
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/vgmknodes.8_pregen b/man/vgmknodes.8_pregen
index 66c16a9f6..476b76ed5 100644
--- a/man/vgmknodes.8_pregen
+++ b/man/vgmknodes.8_pregen
@@ -106,171 +106,171 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--ignorelockingfailure\fP
 .br
+.ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
-.ad b
-.HP
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--refresh\fP
 .br
+.ad b
 If the LV is active, reload its metadata.
 This is not necessary in normal operation, but may be useful
 if something has gone wrong, or if some form of manual LV
 sharing is being used.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
+.TP
 \fILV\fP
 .br
 Logical Volume name.  See \fBlvm\fP(8) for valid names.
 An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.
-.HP
+.TP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -286,70 +286,71 @@ capital letters mean multiple of 1000.)
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/vgreduce.8_pregen b/man/vgreduce.8_pregen
index 6aded0070..72937ce67 100644
--- a/man/vgreduce.8_pregen
+++ b/man/vgreduce.8_pregen
@@ -219,123 +219,124 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB-a\fP|\fB--all\fP
 .br
-Removes all empty PVs if none are named on the command line.
 .ad b
-.HP
+Removes all empty PVs if none are named on the command line.
+.TP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
+.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB--mirrorsonly\fP
 .br
-Only remove missing PVs from mirror LVs.
 .ad b
-.HP
+Only remove missing PVs from mirror LVs.
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--removemissing\fP
 .br
+.ad b
 Removes all missing PVs from the VG, if there are no LVs allocated
 on them. This resumes normal operation of the VG (new LVs may again
 be created, changed and so on).
@@ -346,55 +347,54 @@ were partly on the missing disks are removed completely, including
 those parts on disks that are still present.
 If LVs spanned several disks, including ones that are lost, salvaging
 some data first may be possible by activating LVs in partial mode.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
+.TP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -404,11 +404,11 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -424,70 +424,71 @@ capital letters mean multiple of 1000.)
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/vgremove.8_pregen b/man/vgremove.8_pregen
index f78f9b476..b80dc09ba 100644
--- a/man/vgremove.8_pregen
+++ b/man/vgremove.8_pregen
@@ -109,124 +109,125 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
+.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--noudevsync\fP
 .br
+.ad b
 Disables udev synchronisation. The process will not wait for notification
 from udev. It will continue irrespective of any possible udev processing
 in the background. Only use this if udev is not running or has rules that
 ignore the devices LVM creates.
-.ad b
-.HP
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
+.ad b
 Select objects for processing and reporting based on specified criteria.
 The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
@@ -235,59 +236,58 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
+.TP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.HP
+.TP
 \fISelect\fP
 .br
 Select indicates that a required positional parameter can
 be omitted if the \fB--select\fP option is used.
 No arg appears in this position.
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -303,70 +303,71 @@ capital letters mean multiple of 1000.)
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/vgrename.8_pregen b/man/vgrename.8_pregen
index 3444a64ac..e22bca88c 100644
--- a/man/vgrename.8_pregen
+++ b/man/vgrename.8_pregen
@@ -122,159 +122,159 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB-f\fP|\fB--force\fP ...
 .br
+.ad b
 Override various checks, confirmations and protections.
 Use with extreme caution.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -299,70 +299,71 @@ Rename the VG with the specified UUID to "myvg".
 .br
 .B vgrename Zvlifi-Ep3t-e0Ng-U42h-o0ye-KHu1-nl7Ns4 myvg
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/vgs.8_pregen b/man/vgs.8_pregen
index 29ed39e2a..ae18b1c10 100644
--- a/man/vgs.8_pregen
+++ b/man/vgs.8_pregen
@@ -174,151 +174,152 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB--aligned\fP
 .br
-Use with --separator to align the output columns
 .ad b
-.HP
+Use with --separator to align the output columns
+.TP
 .ad l
 \fB-a\fP|\fB--all\fP
 .br
-List all VGs. Equivalent to not specifying any VGs.
 .ad b
-.HP
+List all VGs. Equivalent to not specifying any VGs.
+.TP
 .ad l
 \fB--binary\fP
 .br
+.ad b
 Use binary values "0" or "1" instead of descriptive literal values
 for columns that have exactly two valid values to report (not counting
 the "unknown" value which denotes that the value could not be determined).
-.ad b
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB--configreport\fP \fBlog\fP|\fBvg\fP|\fBlv\fP|\fBpv\fP|\fBpvseg\fP|\fBseg\fP
 .br
-See \fBlvmreport\fP(7).
 .ad b
-.HP
+See \fBlvmreport\fP(7).
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB--foreign\fP
 .br
+.ad b
 Report/display foreign VGs that would otherwise be skipped.
 See \fBlvmsystemid\fP(7) for more information about foreign VGs.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--ignorelockingfailure\fP
 .br
+.ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
-.ad b
-.HP
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--logonly\fP
 .br
-Suppress command report and display only log report.
 .ad b
-.HP
+Suppress command report and display only log report.
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB--nameprefixes\fP
 .br
+.ad b
 Add an "LVM2_" prefix plus the field name to the output. Useful
 with --noheadings to produce a list of field=value pairs that can
 be used to set environment variables (for example, in udev rules).
-.ad b
-.HP
+.TP
 .ad l
 \fB--noheadings\fP
 .br
+.ad b
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
-.ad b
-.HP
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--nosuffix\fP
 .br
+.ad b
 Suppress the suffix on output sizes. Use with --units
 (except h and H) if processing the output.
-.ad b
-.HP
+.TP
 .ad l
 \fB-o\fP|\fB--options\fP \fIString\fP
 .br
+.ad b
 Comma-separated, ordered list of fields to display in columns.
 String arg syntax is: [+|-|#]Field1[,Field2 ...]
 The prefix \fB+\fP will append the specified fields to the default fields,
@@ -336,53 +337,53 @@ Use field name \fBlv_all\fP to view all LV fields,
 \fBpvseg_all\fP all PV segment columns.
 See the lvm.conf report section for more config options.
 See \fBlvmreport\fP(7) for more information about reporting.
-.ad b
-.HP
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--readonly\fP
 .br
+.ad b
 Run the command in a special read-only mode which will read on-disk
 metadata without needing to take any locks. This can be used to peek
 inside metadata used by a virtual machine image while the virtual
 machine is running. No attempt will be made to communicate with the
 device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--rows\fP
 .br
-Output columns as rows.
 .ad b
-.HP
+Output columns as rows.
+.TP
 .ad l
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
+.ad b
 Select objects for processing and reporting based on specified criteria.
 The criteria syntax is described by \fB--select help\fP and \fBlvmreport\fP(7).
 For reporting commands, one row is displayed for each object matching the criteria.
@@ -391,98 +392,97 @@ Rows can be displayed with an additional "selected" field (-o selected)
 showing 1 if the row matches the selection and 0 otherwise.
 For non-reporting commands which process LVM entities, the selection is
 used to choose items to process.
-.ad b
-.HP
+.TP
 .ad l
 \fB--separator\fP \fIString\fP
 .br
-String to use to separate each column. Useful if grepping the output.
 .ad b
-.HP
+String to use to separate each column. Useful if grepping the output.
+.TP
 .ad l
 \fB--shared\fP
 .br
+.ad b
 Report/display shared VGs that would otherwise be skipped when
 lvmlockd is not being used on the host.
 See \fBlvmlockd\fP(8) for more information about shared VGs.
-.ad b
-.HP
+.TP
 .ad l
 \fB-O\fP|\fB--sort\fP \fIString\fP
 .br
+.ad b
 Comma-separated ordered list of columns to sort by. Replaces the default
 selection. Precede any column with \fB-\fP for a reverse sort on that column.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB--unbuffered\fP
 .br
-Produce output immediately without sorting or aligning the columns properly.
 .ad b
-.HP
+Produce output immediately without sorting or aligning the columns properly.
+.TP
 .ad l
 \fB--units\fP \fBr\fP|\fBR\fP|\fBh\fP|\fBH\fP|\fBb\fP|\fBB\fP|\fBs\fP|\fBS\fP|\fBk\fP|\fBK\fP|\fBm\fP|\fBM\fP|\fBg\fP|\fBG\fP|\fBt\fP|\fBT\fP|\fBp\fP|\fBP\fP|\fBe\fP|\fBE\fP
 .br
+.ad b
 All sizes are output in these units:
 human-(r)eadable with '<' rounding indicator,
 (h)uman-readable, (b)ytes, (s)ectors, (k)ilobytes, (m)egabytes,
 (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.
 Custom units can be specified, e.g. --units 3M.
-.ad b
-.HP
+.TP
 .ad l
 \fB--unquoted\fP
 .br
+.ad b
 When used with --nameprefixes, output values in the field=value
 pairs are not quoted.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
+.TP
 \fITag\fP
 .br
 Tag name.  See \fBlvm\fP(8) for information about tag names and using tags
 in place of a VG, LV or PV.
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -514,70 +514,71 @@ Allocation policy: (c)ontiguous, c(l)ing, (n)ormal, @nywhere
 .IP 6 3
 (c)lustered, (s)hared
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/vgscan.8_pregen b/man/vgscan.8_pregen
index 1772a450d..4cbf08d91 100644
--- a/man/vgscan.8_pregen
+++ b/man/vgscan.8_pregen
@@ -101,163 +101,163 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--ignorelockingfailure\fP
 .br
+.ad b
 Allows a command to continue with read-only metadata
 operations after locking failures.
-.ad b
-.HP
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB--mknodes\fP
 .br
+.ad b
 Also checks the LVM special files in /dev that are needed for active
 LVs and creates any missing ones and removes unused ones.
-.ad b
-.HP
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--notifydbus\fP
 .br
+.ad b
 Send a notification to D-Bus. The command will exit with an error
 if LVM is not built with support for D-Bus notification, or if the
 notify_dbus config setting is disabled.
-.ad b
-.HP
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
 .br
+.ad b
 Overrides current output format for reports which is defined globally by
 the report/output_format setting in lvm.conf.
 \fBbasic\fP is the original format with columns and rows.
 If there is more than one report per command, each report is prefixed
 with the report name for identification. \fBjson\fP produces report
 output in JSON format. See \fBlvmreport\fP(7) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -273,70 +273,71 @@ capital letters mean multiple of 1000.)
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)
diff --git a/man/vgsplit.8_pregen b/man/vgsplit.8_pregen
index 9aa79e890..9a1a6083e 100644
--- a/man/vgsplit.8_pregen
+++ b/man/vgsplit.8_pregen
@@ -63,7 +63,11 @@ Common options for command:
 .ad b
 .br
 .ad l
-[    \fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP ]
+[    \fB--alloc\fP 
+.nh
+\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+.hy
+]
 .ad b
 .br
 .ad l
@@ -139,10 +143,14 @@ Common options for lvm:
 .ad b
 .RE
 .SH OPTIONS
-.HP
+.TP
 .ad l
-\fB--alloc\fP \fBcontiguous\fP|\fBcling\fP|\fBcling_by_tags\fP|\fBnormal\fP|\fBanywhere\fP|\fBinherit\fP
+\fB--alloc\fP 
+.nh
+\fBcontiguous\fP|\:\fBcling\fP|\:\fBcling_by_tags\fP|\:\fBnormal\fP|\:\fBanywhere\fP|\:\fBinherit\fP
+.hy
 .br
+.ad b
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
 which can be changed with vgchange/lvchange, or overridden on the
@@ -159,157 +167,157 @@ e.g. by placing two stripes on the same PV.
 Optional positional PV args on the command line can also be used to limit
 which PVs the command will use for allocation.
 See \fBlvm\fP(8) for more information about allocation.
-.ad b
-.HP
+.TP
 .ad l
 \fB-A\fP|\fB--autobackup\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 Specifies if metadata should be backed up automatically after a change.
 Enabling this is strongly advised! See \fBvgcfgbackup\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--commandprofile\fP \fIString\fP
 .br
+.ad b
 The command profile to use for command configuration.
 See \fBlvm.conf\fP(5) for more information about profiles.
-.ad b
-.HP
+.TP
 .ad l
 \fB--config\fP \fIString\fP
 .br
+.ad b
 Config settings for the command. These override lvm.conf settings.
 The String arg uses the same format as lvm.conf,
 or may use section/field syntax.
 See \fBlvm.conf\fP(5) for more information about config.
-.ad b
-.HP
+.TP
 .ad l
 \fB-d\fP|\fB--debug\fP ...
 .br
+.ad b
 Set debug level. Repeat from 1 to 6 times to increase the detail of
 messages sent to the log file and/or syslog (if configured).
-.ad b
-.HP
+.TP
 .ad l
 \fB--devices\fP \fIPV\fP
 .br
+.ad b
 Devices that the command can use. This option can be repeated
 or accepts a comma separated list of devices. This overrides
 the devices file.
-.ad b
-.HP
+.TP
 .ad l
 \fB--devicesfile\fP \fIString\fP
 .br
+.ad b
 A file listing devices that LVM should use.
 The file must exist in /etc/lvm/devices/ and is managed
 with the lvmdevices(8) command.
 This overrides the lvm.conf devices/devicesfile and
 devices/use_devicesfile settings.
-.ad b
-.HP
+.TP
 .ad l
 \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
+.ad b
 If set to no, the command will not attempt to use device-mapper.
 For testing and debugging.
-.ad b
-.HP
+.TP
 .ad l
 \fB-h\fP|\fB--help\fP
 .br
-Display help text.
 .ad b
-.HP
+Display help text.
+.TP
 .ad l
 \fB--lockopt\fP \fIString\fP
 .br
+.ad b
 Used to pass options for special cases to lvmlockd.
 See \fBlvmlockd\fP(8) for more information.
-.ad b
-.HP
+.TP
 .ad l
 \fB--longhelp\fP
 .br
-Display long help text.
 .ad b
-.HP
+Display long help text.
+.TP
 .ad l
 \fB-l\fP|\fB--maxlogicalvolumes\fP \fINumber\fP
 .br
-Sets the maximum number of LVs allowed in a VG.
 .ad b
-.HP
+Sets the maximum number of LVs allowed in a VG.
+.TP
 .ad l
 \fB-p\fP|\fB--maxphysicalvolumes\fP \fINumber\fP
 .br
+.ad b
 Sets the maximum number of PVs that can belong to the VG.
 The value 0 removes any limitation.
 For large numbers of PVs, also see options --pvmetadatacopies,
 and --vgmetadatacopies for improving performance.
-.ad b
-.HP
+.TP
 .ad l
 \fB-M\fP|\fB--metadatatype\fP \fBlvm2\fP
 .br
+.ad b
 Specifies the type of on-disk metadata to use.
 \fBlvm2\fP (or just \fB2\fP) is the current, standard format.
 \fBlvm1\fP (or just \fB1\fP) is no longer used.
-.ad b
-.HP
+.TP
 .ad l
 \fB-n\fP|\fB--name\fP \fIString\fP
 .br
-Move only PVs used by the named LV.
 .ad b
-.HP
+Move only PVs used by the named LV.
+.TP
 .ad l
 \fB--nolocking\fP
 .br
-Disable locking.
 .ad b
-.HP
+Disable locking.
+.TP
 .ad l
 \fB--profile\fP \fIString\fP
 .br
+.ad b
 An alias for --commandprofile or --metadataprofile, depending
 on the command.
-.ad b
-.HP
+.TP
 .ad l
 \fB-q\fP|\fB--quiet\fP ...
 .br
+.ad b
 Suppress output and log messages. Overrides --debug and --verbose.
 Repeat once to also suppress any prompts with answer 'no'.
-.ad b
-.HP
+.TP
 .ad l
 \fB-t\fP|\fB--test\fP
 .br
+.ad b
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
 returning success to the calling function. This may lead to unusual
 error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
-.ad b
-.HP
+.TP
 .ad l
 \fB-v\fP|\fB--verbose\fP ...
 .br
+.ad b
 Set verbose level. Repeat from 1 to 4 times to increase the detail
 of messages sent to stdout and stderr.
-.ad b
-.HP
+.TP
 .ad l
 \fB--version\fP
 .br
-Display version information.
 .ad b
-.HP
+Display version information.
+.TP
 .ad l
 \fB--[vg]metadatacopies\fP \fBall\fP|\fBunmanaged\fP|\fINumber\fP
 .br
+.ad b
 Number of copies of the VG metadata that are kept.
 VG metadata is kept in VG metadata areas on PVs in the VG,
 i.e. reserved space@the start and/or end of the PVs.
@@ -323,21 +331,20 @@ The number can also be replaced with special string values:
 metadataignore flags.
 \fBall\fP causes LVM to first clear the metadataignore flags on
 all PVs, and then to become unmanaged.
-.ad b
-.HP
+.TP
 .ad l
 \fB-y\fP|\fB--yes\fP
 .br
+.ad b
 Do not prompt for confirmation interactively but always assume the
 answer yes. Use with extreme caution.
 (For automatic no, see -qq.)
-.ad b
 .SH VARIABLES
-.HP
+.TP
 \fIVG\fP
 .br
 Volume Group name.  See \fBlvm\fP(8) for valid names.
-.HP
+.TP
 \fIPV\fP
 .br
 Physical Volume name, a device path under /dev.
@@ -347,11 +354,11 @@ of physical extents (PEs). When the first PE is omitted, it defaults
 to the start of the device, and when the last PE is omitted it defaults to end.
 Start and end range (inclusive): \fIPV\fP[\fB:\fP\fIPE\fP\fB-\fP\fIPE\fP]...
 Start and length range (counting from 0): \fIPV\fP[\fB:\fP\fIPE\fP\fB+\fP\fIPE\fP]...
-.HP
+.TP
 \fIString\fP
 .br
 See the option description for information about the string content.
-.HP
+.TP
 \fISize\fP[UNIT]
 .br
 Size is an input number that accepts an optional unit.
@@ -367,70 +374,71 @@ capital letters mean multiple of 1000.)
 See \fBlvm\fP(8) for information about environment variables used by lvm.
 For example, LVM_VG_NAME can generally be substituted for a required VG parameter.
 .SH SEE ALSO
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.BR lvmconfig (8),
+.BR lvmdevices (8),
 
-.BR lvm (8)
-.BR lvm.conf (5)
-.BR lvmconfig (8)
-.BR lvmdevices (8)
-
-.BR pvchange (8)
-.BR pvck (8)
-.BR pvcreate (8)
-.BR pvdisplay (8)
-.BR pvmove (8)
-.BR pvremove (8)
-.BR pvresize (8)
-.BR pvs (8)
-.BR pvscan (8) 
+.BR pvchange (8),
+.BR pvck (8),
+.BR pvcreate (8),
+.BR pvdisplay (8),
+.BR pvmove (8),
+.BR pvremove (8),
+.BR pvresize (8),
+.BR pvs (8),
+.BR pvscan (8),
 
-.BR vgcfgbackup (8)
-.BR vgcfgrestore (8)
-.BR vgchange (8)
-.BR vgck (8)
-.BR vgcreate (8)
-.BR vgconvert (8)
-.BR vgdisplay (8)
-.BR vgexport (8)
-.BR vgextend (8)
-.BR vgimport (8)
-.BR vgimportclone (8)
-.BR vgimportdevices (8)
-.BR vgmerge (8)
-.BR vgmknodes (8)
-.BR vgreduce (8)
-.BR vgremove (8)
-.BR vgrename (8)
-.BR vgs (8)
-.BR vgscan (8)
-.BR vgsplit (8) 
+.BR vgcfgbackup (8),
+.BR vgcfgrestore (8),
+.BR vgchange (8),
+.BR vgck (8),
+.BR vgcreate (8),
+.BR vgconvert (8),
+.BR vgdisplay (8),
+.BR vgexport (8),
+.BR vgextend (8),
+.BR vgimport (8),
+.BR vgimportclone (8),
+.BR vgimportdevices (8),
+.BR vgmerge (8),
+.BR vgmknodes (8),
+.BR vgreduce (8),
+.BR vgremove (8),
+.BR vgrename (8),
+.BR vgs (8),
+.BR vgscan (8),
+.BR vgsplit (8),
 
-.BR lvcreate (8)
-.BR lvchange (8)
-.BR lvconvert (8)
-.BR lvdisplay (8)
-.BR lvextend (8)
-.BR lvreduce (8)
-.BR lvremove (8)
-.BR lvrename (8)
-.BR lvresize (8)
-.BR lvs (8)
-.BR lvscan (8)
+.BR lvcreate (8),
+.BR lvchange (8),
+.BR lvconvert (8),
+.BR lvdisplay (8),
+.BR lvextend (8),
+.BR lvreduce (8),
+.BR lvremove (8),
+.BR lvrename (8),
+.BR lvresize (8),
+.BR lvs (8),
+.BR lvscan (8),
 
-.BR lvm-fullreport (8)
-.BR lvm-lvpoll (8)
-.BR lvm2-activation-generator (8)
-.BR blkdeactivate (8)
-.BR lvmdump (8)
+.BR lvm-fullreport (8),
+.BR lvm-lvpoll (8),
+.BR lvm2-activation-generator (8),
+.BR blkdeactivate (8),
+.BR lvmdump (8),
 
-.BR dmeventd (8)
-.BR lvmpolld (8)
-.BR lvmlockd (8)
-.BR lvmlockctl (8)
-.BR cmirrord (8)
-.BR lvmdbusd (8)
+.BR dmeventd (8),
+.BR lvmpolld (8),
+.BR lvmlockd (8),
+.BR lvmlockctl (8),
+.BR cmirrord (8),
+.BR lvmdbusd (8),
 
-.BR lvmsystemid (7)
-.BR lvmreport (7)
-.BR lvmraid (7)
-.BR lvmthin (7)
+.BR lvmsystemid (7),
+.BR lvmreport (7),
+.BR lvmraid (7),
+.BR lvmthin (7),
 .BR lvmcache (7)


