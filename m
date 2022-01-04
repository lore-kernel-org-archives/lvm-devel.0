From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue,  4 Jan 2022 16:16:24 +0000 (GMT)
Subject: stable-2.03.14 - make: generate
Message-ID: <20220104161624.BDEA23858C2C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4b26fb3543049f3d179b620ff937c44e922ada58
Commit:        4b26fb3543049f3d179b620ff937c44e922ada58
Parent:        61833dd5b6117e8ace84289cff656d1dfb0ed123
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Jan 4 17:15:56 2022 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Jan 4 17:15:56 2022 +0100

make: generate

---
 man/lvdisplay.8_pregen | 12 ----------
 man/pvdisplay.8_pregen | 12 ----------
 man/pvscan.8_pregen    | 63 ++++++++++++++++++++++----------------------------
 man/vgdisplay.8_pregen | 12 ----------
 4 files changed, 27 insertions(+), 72 deletions(-)

diff --git a/man/lvdisplay.8_pregen b/man/lvdisplay.8_pregen
index a1740ebed..04aab4c09 100644
--- a/man/lvdisplay.8_pregen
+++ b/man/lvdisplay.8_pregen
@@ -61,8 +61,6 @@ and more, using a more compact and configurable output format.
 .br
 [    \fB--readonly\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.br
 [    \fB--segments\fP ]
 .br
 [    \fB--separator\fP \fIString\fP ]
@@ -332,16 +330,6 @@ device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
-.br
-Overrides current output format for reports which is defined globally by
-the report/output_format setting in \fBlvm.conf\fP(5).
-\fBbasic\fP is the original format with columns and rows.
-If there is more than one report per command, each report is prefixed
-with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
-.
-.HP
 \fB--segments\fP
 .br
 .
diff --git a/man/pvdisplay.8_pregen b/man/pvdisplay.8_pregen
index 22a0992b5..2f26a8727 100644
--- a/man/pvdisplay.8_pregen
+++ b/man/pvdisplay.8_pregen
@@ -61,8 +61,6 @@ and more, using a more compact and configurable output format.
 .br
 [    \fB--readonly\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.br
 [    \fB--separator\fP \fIString\fP ]
 .br
 [    \fB--shared\fP ]
@@ -320,16 +318,6 @@ device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
-.br
-Overrides current output format for reports which is defined globally by
-the report/output_format setting in \fBlvm.conf\fP(5).
-\fBbasic\fP is the original format with columns and rows.
-If there is more than one report per command, each report is prefixed
-with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
-.
-.HP
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
 Select objects for processing and reporting based on specified criteria.
diff --git a/man/pvscan.8_pregen b/man/pvscan.8_pregen
index 9eb6b5bf9..1c96d5aab 100644
--- a/man/pvscan.8_pregen
+++ b/man/pvscan.8_pregen
@@ -91,59 +91,50 @@ like
 or
 .BR pvdisplay (8).
 .P
-When the --cache and -aay options are used, pvscan records which PVs are
-available on the system, and activates LVs in completed VGs.  A VG is
-complete when pvscan sees that the final PV in the VG has appeared.  This
-is used by event-based system startup (systemd, udev) to activate LVs.
-.P
-The four main variations of this are:
+When --cache is used, pvscan updates runtime lvm state on the system, or
+with -aay performs autoactivation.
 .P
 .B pvscan --cache
 .I device
 .P
-If device is present, lvm adds a record that the PV on device is online.
+If device is present, lvm records that the PV on device is online.
 If device is not present, lvm removes the online record for the PV.
-In most cases, the pvscan will only read the named devices.
+pvscan only reads the named device.
 .P
-.B pvscan --cache -aay
-.IR device ...
+.B pvscan --cache
 .P
-This begins by performing the same steps as above.  Afterward, if the VG
-for the specified PV is complete, then pvscan will activate LVs in the VG
-(the same as vgchange -aay vgname would do.)
+Updates the runtime state for all lvm devices.
 .P
-.B pvscan --cache
+.B pvscan --cache -aay
+.I device
 .P
-This first clears all existing PV online records, then scans all devices
-on the system, adding PV online records for any PVs that are found.
+Performs the --cache steps for the device, then checks if the VG using the
+device is complete.  If so, LVs in the VG are autoactivated, the same as
+vgchange -aay vgname would do.  (A device name may be replaced with major
+and minor numbers.)
 .P
 .B pvscan --cache -aay
 .P
-This begins by performing the same steps as pvscan --cache.  Afterward, it
-activates LVs in any complete VGs.
+Performs the --cache steps for all devices, then autoactivates any complete VGs.
 .P
-To prevent devices from being scanned by pvscan --cache, add them
-to
-.BR lvm.conf (5)
-.B devices/global_filter.
-For more information, see:
-.br
-.B lvmconfig --withcomments devices/global_filter
+.B pvscan --cache --listvg|--listlvs
+.I device
 .P
-Auto-activation of VGs or LVs can be enabled/disabled using:
-.br
+Performs the --cache steps for the device, then prints the name of the VG
+using the device, or the names of LVs using the device.  --checkcomplete
+is usually included to check if all PVs for the VG or LVs are online.
+When this command is called by a udev rule, the output must conform to
+udev rule specifications (see --udevoutput.)  The udev rule will use the
+results to perform autoactivation.
+.P
+Autoactivation of VGs or LVs can be enabled/disabled using vgchange or
+lvchange with --setautoactivation y|n, or by adding names to
 .BR lvm.conf (5)
 .B activation/auto_activation_volume_list
 .P
-For more information, see:
-.br
-.B lvmconfig --withcomments activation/auto_activation_volume_list
-.P
-To disable auto-activation, explicitly set this list to an empty list,
-i.e. auto_activation_volume_list = [ ].
-.P
-When this setting is undefined (e.g. commented), then all LVs are
-auto-activated.
+See
+.BR lvmautoactivation (7)
+for more information about how pvscan is used for autoactivation.
 .
 .SH USAGE
 .
diff --git a/man/vgdisplay.8_pregen b/man/vgdisplay.8_pregen
index 9c694921d..0a12b3c39 100644
--- a/man/vgdisplay.8_pregen
+++ b/man/vgdisplay.8_pregen
@@ -58,8 +58,6 @@ and more, using a more compact and configurable output format.
 .br
 [    \fB--readonly\fP ]
 .br
-[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
-.br
 [    \fB--shared\fP ]
 .br
 [    \fB--separator\fP \fIString\fP ]
@@ -312,16 +310,6 @@ device-mapper kernel driver, so this option is unable to report whether
 or not LVs are actually in use.
 .
 .HP
-\fB--reportformat\fP \fBbasic\fP|\fBjson\fP
-.br
-Overrides current output format for reports which is defined globally by
-the report/output_format setting in \fBlvm.conf\fP(5).
-\fBbasic\fP is the original format with columns and rows.
-If there is more than one report per command, each report is prefixed
-with the report name for identification. \fBjson\fP produces report
-output in JSON format. See \fBlvmreport\fP(7) for more information.
-.
-.HP
 \fB-S\fP|\fB--select\fP \fIString\fP
 .br
 Select objects for processing and reporting based on specified criteria.


