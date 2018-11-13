From: David Teigland <teigland@sourceware.org>
Date: Tue, 13 Nov 2018 18:28:59 -0500
Subject: master - man pvscan: replace lvmetad text
Message-ID: <201811132328.wADNSxGC006737@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cbee4d3d8843e14368f5f68531ef8ab429287077
Commit:        cbee4d3d8843e14368f5f68531ef8ab429287077
Parent:        1c0b02e367a4686d2331f140c999aa3b4f26cea7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 13 17:23:32 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 13 17:23:32 2018 -0600

man pvscan: replace lvmetad text

---
 man/pvscan.8_des |  120 ++++++++++++++++++++---------------------------------
 1 files changed, 45 insertions(+), 75 deletions(-)

diff --git a/man/pvscan.8_des b/man/pvscan.8_des
index c3d80b4..5e24855 100644
--- a/man/pvscan.8_des
+++ b/man/pvscan.8_des
@@ -1,70 +1,49 @@
-pvscan scans all supported LVM block devices in the system for PVs.
-
-\fBScanning with lvmetad\fP
-
-pvscan operates differently when used with the
-.BR lvmetad (8)
-daemon.
-
-Scanning disks is required to read LVM metadata and identify LVM PVs.
-Once read, lvmetad caches the metadata so that LVM commands can read it
-without repeatedly scanning disks.  This is helpful because scanning disks
-is time consuming, and frequent scanning may interfere with the normal
-work of the system and disks.
-
-When lvmetad is not used, LVM commands revert to scanning disks to read
-metadata.  Any LVM command that needs metadata will scan disks for it;
-running the pvscan command is not necessary for the sake of other LVM
-commands.
-
-When lvmetad is used, LVM commands avoid scanning disks by reading
-metadata from lvmetad.  When new disks appear, they must be scanned so
-their metadata can be cached in lvmetad.  This is done by the command
-pvscan --cache, which scans disks and passes the metadata to lvmetad.
-
-The pvscan --cache command is typically run automatically by system
-services when a new device appears.  Users do not generally need to run
-this command if the system and lvmetad are running properly.
-
-Many scripts contain unnecessary pvscan (or vgscan) commands for
-historical reasons.  To avoid disrupting the system with extraneous disk
-scanning, an ordinary pvscan (without --cache) will simply read metadata
-from lvmetad like other LVM commands.  It does not do anything beyond
-displaying the current state of the cache.
-.IP \[bu] 2
-When given specific device name arguments, pvscan --cache will only
-read the named devices.
-.IP \[bu] 2
-LVM udev rules and systemd services are used to initiate automatic device
-scanning.
-.IP \[bu] 2
+pvscan reads all supported LVM block devices in the system for PVs.
+
+When called without the --cache option, pvscan lists PVs on the system,
+like
+.BR pvs (8)
+or
+.BR pvdisplay (8).
+
+When the --cache and -aay options are used, pvscan keeps track of PVs that
+have appeared on the system, and activates LVs in completed VGs.  A VG is
+complete when pvscan sees that the final PV in the VG has appeared.  This
+is used by event-based system startup (systemd, udev) to activate LVs.
+
+The four main variations of this are:
+
+.B pvscan --cache
+.IR device
+
+If device is present, lvm adds a record that the PV on device is online.
+If device is not present, lvm removes the online record for the PV.
+In most cases, the pvscan will only read the named devices.
+
+.B pvscan --cache -aay
+.IR device ...
+
+This begins by performing the same steps as above.  If the device is the
+final PV in the VG to appear on the system, then pvscan will activate LVs
+in the VG (the same as vgchange -aay vgname would do.)
+
+.B pvscan --cache
+
+This clears all existing PV online records, then scans all the devices on
+the system, adding PV online records for any PVs that it finds.
+
+.B pvscan --cache -aay
+
+This begins by performing the same steps as pvscan --cache.  Afterward, it
+activates LVs in any complete VGs.
+
 To prevent devices from being scanned by pvscan --cache, add them
 to
 .BR lvm.conf (5)
 .B devices/global_filter.
-The devices/filter setting does not
-apply to system level scanning.
 For more information, see:
 .br
 .B lvmconfig --withcomments devices/global_filter
-.IP \[bu] 2
-If lvmetad is started or restarted after devices are visible, or
-if the global_filter has changed, then all devices must be rescanned
-for metadata with the command pvscan --cache.
-.IP \[bu] 2
-lvmetad does not cache older metadata formats, e.g. lvm1, and will
-be temporarily disabled if they are seen.
-.IP \[bu] 2
-To notify lvmetad about a device that is no longer present, the major and
-minor numbers must be given, not the path.
-.P
-\fBAutomatic activation\fP
-
-When event-driven system services detect a new LVM device, the first step
-is to automatically scan and cache the metadata from the device.  This is
-done by pvscan --cache.  A second step is to automatically activate LVs
-that are present on the new device.  This auto-activation is done by the
-same pvscan --cache command when the option --activate ay is included.
 
 Auto-activation of VGs or LVs can be enabled/disabled using:
 .br
@@ -75,18 +54,9 @@ For more information, see:
 .br
 .B lvmconfig --withcomments activation/auto_activation_volume_list
 
-When this setting is undefined, all LVs are auto-activated (when lvm is
-fully integrated with the event-driven system services.)
-
-When a VG or LV is not auto-activated, traditional activation using
-vgchange or lvchange --activate is needed.
-.IP \[bu] 2
-pvscan auto-activation can be only done in combination with --cache.
-.IP \[bu] 2
-Auto-activation is designated by the "a" argument in --activate ay.
-This is meant to distinguish system generated commands from explicit user
-commands, although it can be used in any activation command.  Whenever it
-is used, the auto_activation_volume_list is applied.
-.IP \[bu] 2
-Auto-activation is not yet supported for LVs that are part of partial or
-clustered volume groups.
+To disable auto-activation, explicitly set this list to an empty list,
+i.e. auto_activation_volume_list = [ ].
+
+When this setting is undefined (e.g. commented), then all LVs are
+auto-activated.
+


