From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  1 May 2015 20:25:40 +0000 (UTC)
Subject: master - man: expanded explanation of pvscan
Message-ID: <20150501202540.29FEE610A7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9273b1a964c4edafbc59598f7a800f5cd524a8f3
Commit:        9273b1a964c4edafbc59598f7a800f5cd524a8f3
Parent:        9c7063ef893449742922a4bcbcbe6c38f191b8dc
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 1 13:44:31 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 1 15:23:32 2015 -0500

man: expanded explanation of pvscan

Related to it's role with lvmetad and auto-activation.
---
 man/pvscan.8.in |  146 ++++++++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 119 insertions(+), 27 deletions(-)

diff --git a/man/pvscan.8.in b/man/pvscan.8.in
index f976b40..010c091 100644
--- a/man/pvscan.8.in
+++ b/man/pvscan.8.in
@@ -1,6 +1,7 @@
 .TH PVSCAN 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
 .SH NAME
 pvscan \(em scan all disks for physical volumes
+
 .SH SYNOPSIS
 .B pvscan
 .RB [ \-\-commandprofile
@@ -30,9 +31,118 @@ pvscan \(em scan all disks for physical volumes
 .IR DevicePath
 |
 .IR major:minor ]...
+
 .SH DESCRIPTION
-pvscan scans all supported LVM block devices in the system for
-physical volumes.
+pvscan scans all supported LVM block devices in the system for physical
+volumes.
+
+.SS Scanning with lvmetad
+
+pvscan operates differently when used with the
+.BR lvmetad (8)
+daemon.
+
+Scanning disks is required to read LVM metadata and identify LVM PVs.
+Once read, lvmetad caches the metadata so that LVM commands can read it
+without repeatedly scanning disks.  This is helpful because scanning disks
+is time consuming, and frequent scanning may interfere with the normal
+work of the system and disks.
+
+When lvmetad is not used, LVM commands revert to scanning disks to read
+metadata.  Any LVM command that needs metadata will scan disks for it;
+running the pvscan command is not necessary for the sake of other LVM
+commands.
+
+When lvmetad is used, LVM commands avoid scanning disks by reading
+metadata from lvmetad.  When new disks appear, they must be scanned so
+their metadata can be cached in lvmetad.  This is done by the command
+pvscan \-\-cache, which scans disks and passes the metadata to lvmetad.
+
+The pvscan \-\-cache command is typically run automatically by system
+services when a new device appears.  Users do not generally need to run
+this command if the system and lvmetad are running properly.
+
+Many scripts contain unnecessary pvscan (or vgscan) commands for
+historical reasons.  To avoid disrupting the system with extraneous disk
+scanning, an ordinary pvscan (without \-\-cache) will simply read metadata
+from lvmetad like other LVM commands.  It does not do anything beyond
+displaying the current state of the cache.
+
+.I Notes
+
+.IP \[bu] 2
+When given specific device name arguments, pvscan \-\-cache will only
+read the named devices.
+
+.IP \[bu] 2
+LVM udev rules and systemd services are used to intiate automatic device
+scanning.
+
+.IP \[bu] 2
+To prevent devices from being scanned by pvscan --cache, add them
+to
+.BR lvm.conf (5)
+.B devices/global_filter.
+The devices/filter setting does not
+apply to system level scanning.
+For more information, see:
+.br
+.B lvmconfig --withcomments devices/global_filter
+
+.IP \[bu] 2
+If lvmetad is started or restarted after devices are visible, or
+if the global_filter has changed, then all devices must be rescanned
+for metadata with the command pvscan \-\-cache.
+
+.IP \[bu] 2
+lvmetad ignores older metadata formats, e.g. lvm1, and should not be
+used if they exist.
+
+.IP \[bu] 2
+To notify lvmetad about a device that is no longer present, the major and
+minor numbers must be given, not the path.
+
+.SS Automatic activation
+
+When event-driven system services detect a new LVM device, the first step
+is to automatically scan and cache the metadata from the device.  This is
+done by pvscan \-\-cache.  A second step is to automatically activate LVs
+that are present on the new device.  This auto-activation is done by the
+same pvscan \-\-cache command when the option '\-a|\-\-activate ay' is
+included.
+
+Auto-activation of VGs or LVs can be enabled/disabled using:
+.br
+.BR lvm.conf (5)
+.B activation/auto_activation_volume_list
+
+For more information, see:
+.br
+.B lvmconfig --withcomments activation/auto_activation_volume_list
+
+When this setting is undefined, all LVs are auto-activated (when lvm is
+fully integrated with the event-driven system services.)
+
+When a VG or LV is not auto-activated, traditional activation using
+vgchange or lvchange -a|--activate is needed.
+
+.I Notes
+
+.IP \[bu] 2
+pvscan auto-activation can be only done in combination with \-\-cache.
+
+.IP \[bu] 2
+Auto-activation is designated by the "a" argument in '-a|--activate ay'.
+This is meant to distinguish system generated commands from explicit user
+commands, although it can be used in any activation command.  Whenever it
+is used, the auto_activation_volume_list is applied.
+
+.IP \[bu] 2
+Auto-activation is not yet supported for LVs that are part of partial or
+clustered volume groups.
+
+.P
+
 .SH OPTIONS
 See \fBlvm\fP(8) for common options.
 .TP
@@ -46,37 +156,19 @@ Only show physical volumes not belonging to any volume group.
 Short listing format.
 .TP
 .BR \-u ", " \-\-uuid
-Show UUIDs (Uniform Unique Identifiers) in addition to device special names.
+Show UUIDs in addition to device names.
 .TP
 .BR \-a ", " \-\-activate " " \fIay
-Together with the information already cached in lvmetad, automatically activate
-any logical volumes that become activatable after the scan done on one or more devices.
-The logical volume to autoactivate is matched against the
-activation/auto_activation_volume_list set in lvm.conf. If this list is not set, then
-all volumes are considered for autoactivation. The autoactivation is not yet
-supported for logical volumes that are part of partial or clustered volume groups.
+Automatically activate any logical volumes that are possible to activate
+with the addition of the new devices.
 .TP
 .BR \-b ", " \-\-background
 Run the command in the background.
 .TP
 .BR \-\-cache " [" \-\-major " " \fImajor " " \-\-minor " " \fIminor " | " \fIDevicePath " | " \fImajor:minor " ]..."
-Scan one or more devices and instruct the lvmetad daemon to update its cached
-state accordingly.  Called internally by udev rules.
-All devices listed explicitly are processed \fBregardless\fP of any device
-filters set using \fBdevices/filter\fP configuration setting. To filter
-devices even in this case, the \fBdevices/global_filter\fP must be used.
-If lvmetad has not yet cached any metadata or the filters have recently been
-changed, then all devices may be scanned, effectively ignoring the rest of
-the command line.  Otherwise, if all the devices referenced on the command line
-contain metadata in the default lvm2 format, other devices are not accessed.
-If metadata written using the obsolete GFS pool or lvm1 format is encountered,
-this is ignored and so lvmetad should not be used.
-To notify lvmetad about a device that is not present in the system anymore,
-\fB\-\-major\fP and \fB\-\-minor\fP pair of that device must be always supplied,
-not \fBDevicePath\fP as pvscan is not able to translate the \fBDevicePath\fP
-into major and minor pair which lvmetad requires.
+Scan one or more devices and send the metadata to lvmetad.
+
 .SH SEE ALSO
 .BR lvm (8),
-.BR lvmetad (8),
-.BR pvcreate (8),
-.BR pvdisplay (8)
+.BR lvmconfig (8),
+.BR lvmetad (8)


