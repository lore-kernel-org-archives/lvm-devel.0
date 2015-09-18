From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Sep 2015 15:45:57 +0000 (UTC)
Subject: master - man: enhance dmsetup/dmstats
Message-ID: <20150918154557.B46D1606FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=11d6f81316bb49adee80e4e128b208c50c42cd1d
Commit:        11d6f81316bb49adee80e4e128b208c50c42cd1d
Parent:        f9c8cefd068194f10639d728e2e73a5cb93c1cbe
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 18 14:34:34 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 18 17:45:46 2015 +0200

man: enhance dmsetup/dmstats

Document more supported options.
Cleanup man-style when documenting options.
Use .PD 0  and .HP
---
 WHATS_NEW_DM     |    1 +
 man/dmsetup.8.in |  400 +++++++++++++++++++++++++++++-------------------------
 man/dmstats.8.in |  116 +++++++---------
 3 files changed, 265 insertions(+), 252 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index d69478c..55f5f0f 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.109 - 
 ======================================
+  Update man pages for dmsetup and dmstats.
   Improve help text for dmsetup.
   Use --noflush and --nolockfs when removing device with --force.
   Parse new Overflow status string for snapshot target.
diff --git a/man/dmsetup.8.in b/man/dmsetup.8.in
index ded7ca1..eff805a 100644
--- a/man/dmsetup.8.in
+++ b/man/dmsetup.8.in
@@ -3,168 +3,168 @@
 dmsetup \(em low level logical volume management
 .SH SYNOPSIS
 .ad l
+.PD 0
+.HP
 .B dmsetup clear
 .I device_name
-.br
+.HP
 .B dmsetup create
 .I device_name
+.RB [ \-\-addnodeoncreate | \-\-addnodeonresume ]
+.RB [ \-\-readahead
+.RB {[ + ] \fIsectors | auto | none }]
 .RB [ \-u
 .IR uuid ]
 .RB [ \-n | \-\-notable | \-\-table
-.RI < table >|
-.RS
-.IR table_file ]
-.RB [{ \-\-addnodeoncreate | \-\-addnodeonresume }]
-.RB [ \-\-readahead
-.RI [ + ]< sectors >| auto | none ]
-.RE
-.br
+.RI { table | table_file }]
+.HP
 .B dmsetup deps
 .RB [ \-o
 .IR options ]
 .RI [ device_name ]
-.br
+.HP
 .B dmsetup help
 .RB [ \-c | \-C | \-\-columns ]
-.br
+.HP
 .B dmsetup info
 .RI [ device_name ]
-.br
+.HP
 .B dmsetup info
 .BR \-c | \-C | \-\-columns
+.RB [ \-\-count
+.IR count ]
+.RB [ \-\-interval
+.IR seconds ]
 .RB [ \-\-nameprefixes ]
 .RB [ \-\-noheadings ]
-.RB [ \-\-separator
-.IR separator ]
-.RS
 .RB [ \-o
 .IR fields ]
 .RB [ \-O | \-\-sort
 .IR sort_fields ]
 .RB [ \-S | \-\-select
-.IR Selection ]
-.RB [ \-\-interval
-.IR seconds ]
-.RB [ \-\-count
-.IR count ]
+.IR selection ]
+.RB [ \-\-separator
+.IR separator ]
 .RI [ device_name ]
-.RE
-.br
+.HP
 .B dmsetup load
 .I device_name
 .RB [ \-\-table
-.RI < table >| table_file ]
-.br
+.RI { table | table_file }]
+.HP
 .B dmsetup ls
 .RB [ \-\-target
 .IR target_type ]
 .RB [ \-\-exec
 .IR command ]
 .RB [ \-\-tree ]
-.RS
 .RB [ \-o
 .IR options ]
-.RE
-.br
+.HP 
 .B dmsetup message
 .I device_name sector message
-.br
+.HP
 .B dmsetup mknodes
 .RI [ device_name ]
-.br
+.HP
 .B dmsetup mangle
 .RI [ device_name ]
-.br
+.HP
 .B dmsetup reload
 .I device_name
 .RB [ \-\-table
-.RI < table >| table_file ]
-.br
-.B dmsetup wipe_table
-.I device_name
-.br
+.RI { table | table_file }]
+.HP
 .B dmsetup remove
 .RB [ \-f | \-\-force ]
 .RB [ \-\-retry ]
 .RB [ \-\-deferred ]
 .I device_name
-.br
+.HP
 .B dmsetup remove_all
 .RB [ \-f | \-\-force ]
 .RB [ \-\-deferred ]
-.br
+.HP
 .B dmsetup rename
 .I device_name new_name
-.br
+.HP
 .B dmsetup rename
 .I device_name
 .B \-\-setuuid
 .I uuid
-.br
+.HP
 .B dmsetup resume
 .I device_name
-.RB [{ \-\-addnodeoncreate | \-\-addnodeonresume }]
-.RS
+.RB [ \-\-addnodeoncreate | \-\-addnodeonresume ]
 .RB [ \-\-readahead
-.RI [ + ]< sectors >| auto | none ]
-.RE
-.br
+.RB {[ + ] \fIsectors | auto | none }]
+.HP
 .B dmsetup setgeometry
 .I device_name cyl head sect start
-.br
+.HP
 .B dmsetup splitname
 .I device_name
 .RI [ subsystem ]
-.br
+.HP
+.B dmsetup stats
+.I command
+.RI [ options ]
+.HP
 .B dmsetup status
 .RB [ \-\-target
 .IR target_type ]
 .RB [ \-\-noflush ]
 .RI [ device_name ]
-.br
+.HP
 .B dmsetup suspend
 .RB [ \-\-nolockfs ]
 .RB [ \-\-noflush ]
 .I device_name
-.br
+.HP
 .B dmsetup table
 .RB [ \-\-target
 .IR target_type ]
 .RB [ \-\-showkeys ]
 .RI [ device_name ]
-.br
+.HP
 .B dmsetup targets
-.br
+.HP
 .B dmsetup udevcomplete
 .I cookie
-.br
+.HP
 .B dmsetup udevcomplete_all
 .RI [ age_in_minutes ]
-.br
+.HP
 .B dmsetup udevcookies
-.br
+.HP
 .B dmsetup udevcreatecookie
-.br
+.HP
 .B dmsetup udevflags
 .I cookie
-.br
+.HP
 .B dmsetup udevreleasecookie
 .RI [ cookie ]
-.br
+.HP
 .B dmsetup version
-.br
+.HP
 .B dmsetup wait
 .RB [ \-\-noflush ]
 .I device_name
 .RI [ event_nr ]
-.br
-
+.HP
+.B dmsetup wipe_table
+.I device_name
+.RB [ \-f | \-\-force ]
+.RB [ \-\-noflush ]
+.RB [ \-\-nolockfs ]
+.HP
 .B devmap_name
 .I major minor
-.br
+.HP
 .B devmap_name
 .I major:minor
 .ad b
+.PD
 .SH DESCRIPTION
 dmsetup manages logical devices that use the device-mapper driver.
 Devices are created by loading a table that specifies a target for
@@ -196,6 +196,9 @@ Display output in columns rather than as Field: Value lines.
 Specify the number of times to repeat a report. Set this to zero
 continue until interrupted.  The default interval is one second.
 .TP
+.BR \-f | \-\-force
+Try harder to complete operation.
+.TP
 .BR \-h | \-\-help
 Outputs a summary of the commands available, optionally including
 the list of report fields (synonym with \fBhelp\fP command).
@@ -207,20 +210,20 @@ Requires kernel driver version 4.16.0 or above.
 .TP
 .B \-\-interval \fIseconds
 Specify the interval in seconds between successive iterations for
-repeating reports. If \-\-interval is specified but \-\-count is not,
-reports will continue to repeat until interrupted.
+repeating reports. If \fB\-\-interval\fP is specified but \fB\-\-count\fP
+is not, reports will continue to repeat until interrupted.
 The default interval is one second.
 .TP
-.IR \fB\-\-manglename \ { none | hex | auto }
+.BR \-\-manglename \ { none | hex | auto }
 Mangle any character not on a whitelist using mangling_mode when
 processing device-mapper device names and UUIDs. The names and UUIDs
 are mangled on input and unmangled on output where the mangling mode
 is one of:
-\fInone\fP (no mangling),
-\fIhex\fP (always do the mangling) and
-\fIauto\fP (only do the mangling if not mangled yet, do nothing
+\fBnone\fP (no mangling),
+\fBhex\fP (always do the mangling) and
+\fBauto\fP (only do the mangling if not mangled yet, do nothing
 if already mangled, error on mixed)
-Default mode is \fI#DEFAULT_MANGLING#\fP.
+Default mode is \fB#DEFAULT_MANGLING#\fP.
 Character whitelist: 0-9, A-Z, a-z, #+-.:=@_. This whitelist is
 also supported by udev. Any character not on a whitelist is replaced
 with its hex value (two digits) prefixed by \\x.
@@ -238,12 +241,23 @@ Specify the minor number.
 When creating a device, don't load any table.
 .TP
 .BR \-\-nameprefixes
-Add a "DM_" prefix plus the field name to the output.  Useful with --noheadings to produce a list of
-field=value pairs that can be used to set environment variables (for example, in udev(7) rules).
+Add a "DM_" prefix plus the field name to the output.  Useful with
+\fB\-\-noheadings\fP to produce a list of
+field=value pairs that can be used to set environment variables
+(for example, in
+.BR udev (7)
+rules).
 .TP
 .BR \-\-noheadings
 Suppress the headings line when using columnar output.
 .TP
+.B \-\-noflush
+Do not flush outstading I/O when suspending a device, or do not
+commit thin-pool metadata when obtaining thin-pool status.
+.TP
+.B \-\-nolockfs
+Do not attempt to synchronize filesystem eg, when suspending a device.
+.TP
 .B \-\-noopencount
 Tell the kernel not to supply the open reference count for the device.
 .TP
@@ -256,29 +270,30 @@ Do not synchronise with udev when creating, renaming or removing devices.
 .BR \-o | \-\-options
 Specify which fields to display.
 .TP
-.IR \fB\-\-readahead \ [ + ]< sectors >| auto | none
+.BR \-\-readahead \ {[ + ] \fIsectors | auto | none }
 Specify read ahead size in units of sectors.
-The default value is \fIauto\fP which allows the kernel to choose
-a suitable value automatically.  The \fI+\fP prefix lets you
+The default value is \fBauto\fP which allows the kernel to choose
+a suitable value automatically.  The \fB+\fP prefix lets you
 specify a minimum value which will not be used if it is
 smaller than the value chosen by the kernel.
-The value \fInone\fP is equivalent to specifying zero.
+The value \fBnone\fP is equivalent to specifying zero.
 .TP
 .BR \-r | \-\-readonly
 Set the table being loaded read-only.
 .TP
-.BR \-S | \-\-select \ \fISelection
-Display only rows that match Selection criteria. All rows are displayed
-with the additional "selected" column (-o selected) showing 1 if the row
-matches the Selection and 0 otherwise. The Selection criteria are defined
+.BR \-S | \-\-select \ \fIselection
+Display only rows that match \fIselection\fP criteria. All rows are displayed
+with the additional "selected" column (\fB-o selected\fP) showing 1 if the row
+matches the \fIselection\fP and 0 otherwise. The selection criteria are defined
 by specifying column names and their valid values while making use of
 supported comparison operators. As a quick help and to see full list of
-column names that can be used in Selection and the set of supported
+column names that can be used in selection and the set of supported
 selection operators, check the output of \fBdmsetup info -c -S help\fP
 command.
 .TP
-.IR \fB\-\-table \ < table >
+.IR \fB\-\-table \  table
 Specify a one-line table directly on the command line.
+See below for more information on the table format.
 .TP
 .B \-\-udevcookie \fIcookie
 Use cookie for udev synchronisation.
@@ -287,7 +302,7 @@ multiple different devices. It's not adviced to combine different
 operations on the single device.
 .TP
 .BR \-u | \-\-uuid
-Specify the uuid.
+Specify the \fIuuid\fP.
 .TP
 .BR \-y | \-\-yes
 Answer yes to all prompts automatically.
@@ -303,51 +318,48 @@ correctly and try to fix up the device nodes afterwards if not.
 Display the library and kernel driver version.
 .br
 .SH COMMANDS
-.TP
+.HP
 .B clear
 .I device_name
 .br
 Destroys the table in the inactive table slot for device_name.
-.br
-.TP
+.HP
 .B create
 .I device_name
 .RB [ \-u
 .IR uuid ]
+.RB [ \-\-addnodeoncreate | \-\-addnodeonresume ]
 .RB [ \-n | \-\-notable | \-\-table
-.RI < \fItable >| table_file ]
-.RB [{ \-\-addnodeoncreate | \-\-addnodeonresume }]
+.RI { table | table_file }]
 .RB [ \-\-readahead
-.RI [ + ]< sectors >| auto | none ]
+.RB {[ + ] \fIsectors | auto | none }]
 .br
 Creates a device with the given name.
-If table_file or <table> is supplied, the table is loaded and made live.
+If \fItable\fP or \fItable_file\fP is supplied, the table is loaded and made live.
 Otherwise a table is read from standard input unless \fB\-\-notable\fP is used.
-The optional uuid can be used in place of
+The optional \fIuuid\fP can be used in place of
 device_name in subsequent dmsetup commands.
-If successful a device will appear as
-/dev/mapper/<device-name>.
-See below for information on the table format.
-.br
-.TP
+If successful the device will appear in table and for live
+device the node /dev/mapper/\fIdevice_name\fP is created.
+See below for more information on the table format.
+.HP
 .B deps
 .RB [ \-o
 .IR options ]
 .RI [ device_name ]
 .br
 Outputs a list of devices referenced by the live table for the specified
-device. Device names on output can be customised by following options:
-devno (major and minor pair, used by default), blkdevname (block device name),
-devname (map name for device-mapper devices, equal to blkdevname otherwise).
-.br
-.TP
+device. Device names on output can be customised by following \fIoptions\fP:
+\fBdevno\fP (major and minor pair, used by default),
+\fBblkdevname\fP (block device name),
+\fBdevname\fP (map name for device-mapper devices, equal to blkdevname otherwise).
+.HP
 .B help
 .RB [ \-c | \-C | \-\-columns ]
 .br
 Outputs a summary of the commands available, optionally including
 the list of report fields.
-.br
-.TP
+.HP
 .B info
 .RI [ device_name ]
 .br
@@ -363,32 +375,31 @@ Outputs some brief information about the device in the form:
  UUID
 .RE
 .RE
-.br
-.TP
+.HP
 .B info
 .BR \-c | \-C | \-\-columns
+.RB [ \-\-count
+.IR count ]
+.RB [ \-\-interval
+.IR seconds ]
+.RB [ \-\-nameprefixes ]
 .RB [ \-\-noheadings ]
-.RB [ \-\-separator
-.IR separator ]
 .RB [ \-o
 .IR fields ]
 .RB [ \-O | \-\-sort
 .IR sort_fields ]
-.RB [ \-\-interval
-.IR seconds ]
-.RB [ \-\-count
-.IR count ]
+.RB [ \-\-separator
+.IR separator ]
 .RI [ device_name ]
 .br
 Output you can customise.
 Fields are comma-separated and chosen from the following list:
 name, major, minor, attr, open, segments, events, uuid.
 Attributes are: (L)ive, (I)nactive, (s)uspended, (r)ead-only, read-(w)rite.
-Precede the list with '+' to append
+Precede the list with '\fB+\fP' to append
 to the default selection of columns instead of replacing it.
-Precede any sort_field with - for a reverse sort on that column.
-.br
-.TP
+Precede any sort_field with '\fB-\fP' for a reverse sort on that column.
+.HP
 .B ls
 .RB [ \-\-target
 .IR target_type ]
@@ -405,36 +416,39 @@ Device names on output can be customised by following options: devno (major
 and minor pair, used by default), blkdevname (block device name),
 devname (map name for device-mapper devices, equal to blkdevname otherwise).
 \fB\-\-tree\fP displays dependencies between devices as a tree.
-It accepts a comma-separate list of options.
+It accepts a comma-separate list of \fIoptions\fP.
 Some specify the information displayed against each node:
-device/nodevice; blkdevname; active, open, rw, uuid.
+.BR device / nodevice ;
+.BR blkdevname ;
+.BR active ", " open ", " rw ", " uuid .
 Others specify how the tree is displayed:
-ascii, utf, vt100; compact, inverted, notrunc.
-.br
+.BR ascii ", " utf ", " vt100 ;
+.BR compact ", " inverted ", " notrunc .
 .HP
 .BR load | reload
 .I device_name
 .RB [ \-\-table
-.RI < table >| table_file ]
+.RI { table | table_file }]
 .br
-Loads <table> or table_file into the inactive table slot for device_name.
+Loads \fItable\fP or \fItable_file\fP into the inactive table slot for device_name.
 If neither is supplied, reads a table from standard input.
-.br
 .HP
-.B wipe_table
-.I device_name
-.br
-Wait for any I/O in-flight through the device to complete, then
-replace the table with a new table that fails any new I/O
-sent to the device.  If successful, this should release any devices
-held open by the device's table(s).
+.B mangle
+.RI [ device_name ]
 .br
+Ensure existing device-mapper \fIdevice_name\fP and UUID is in the correct mangled
+form containing only whitelisted characters (supported by udev) and do
+a rename if necessary. Any character not on the whitelist will be mangled
+based on the \fB\-\-manglename\fP setting. Automatic rename works only for device
+names and not for device UUIDs because the kernel does not allow changing
+the UUID of active devices. Any incorrect UUIDs are reported only and they
+must be manually corrected by deactivating the device first and then
+reactivating it with proper mangling mode used (see also \fB\-\-manglename\fP).
 .HP
-.B message
+.B message 
 .I device_name sector message
 .br
 Send message to target. If sector not needed use 0.
-.br
 .HP
 .B mknodes
 .RI [ device_name ]
@@ -443,20 +457,6 @@ Ensure that the node in /dev/mapper for device_name is correct.
 If no device_name is supplied, ensure that all nodes in /dev/mapper
 correspond to mapped devices currently loaded by the device-mapper kernel
 driver, adding, changing or removing nodes as necessary.
-.br
-.HP
-.B mangle
-.RI [ device_name ]
-.br
-Ensure existing device-mapper device name and UUID is in the correct mangled
-form containing only whitelisted characters (supported by udev) and do
-a rename if necessary. Any character not on the whitelist will be mangled
-based on the \fB\-\-manglename\fP setting. Automatic rename works only for device
-names and not for device UUIDs because the kernel does not allow changing
-the UUID of active devices. Any incorrect UUIDs are reported only and they
-must be manually corrected by deactivating the device first and then
-reactivating it with proper mangling mode used (see also \fB\-\-manglename\fP).
-.br
 .HP
 .B remove
 .RB [ \-f | \-\-force ]
@@ -477,7 +477,6 @@ Do NOT combine
 \fB\-\-force\fP and \fB\-\-udevcookie\fP, as udev may start to process udev
 rules in the middle of error target replacement and result in nondeterministic
 result.
-.br
 .HP
 .B remove_all
 .RB [ \-f | \-\-force ]
@@ -489,14 +488,12 @@ adding \fB\-\-force\fP will replace the table with one that fails all I/O.
 \fB\-\-deferred\fP will enable deferred removal of open devices - the device
 will be removed when the last user closes it.  The deferred removal feature is
 supported since version 4.27.0 of the device-mapper driver available in
-upstream kernel version 3.13. 
-.br
+upstream kernel version 3.13.
 .HP
 .B rename
 .I device_name new_name
 .br
 Renames a device.
-.br
 .HP
 .B rename
 .I device_name
@@ -505,38 +502,46 @@ Renames a device.
 .br
 Sets the uuid of a device that was created without a uuid.
 After a uuid has been set it cannot be changed.
-.br
-.TP
+.HP
 .B resume
 .I device_name
-.RB [{ \-\-addnodeoncreate | \-\-addnodeonresume }]
+.RB [ \-\-addnodeoncreate | \-\-addnodeonresume ]
+.RB [ \-\-nolockfs ]
+.RB [ \-\-noflush ]
 .RB [ \-\-readahead
-.RI [ + ]< sectors >| auto | none ]
+.RB {[ + ] \fIsectors | auto | none }]
 .br
 Un-suspends a device.
 If an inactive table has been loaded, it becomes live.
 Postponed I/O then gets re-queued for processing.
-.br
-.TP
-.B setgeometry \fIdevice_name cyl head sect start
+.HP
+.B setgeometry 
+.I device_name cyl head sect start
 .br
 Sets the device geometry to C/H/S.
-.br
 .HP
 .B splitname
 .I device_name
 .RI [ subsystem ]
 .br
 Splits given device name into subsystem constituents.
-The default subsystem is LVM.  
+The default subsystem is LVM.
 LVM currently generates device names by concatenating the names of the Volume
 Group, Logical Volume and any internal Layer with a hyphen as separator.
 Any hyphens within the names are doubled to escape them.
 The precise encoding might change without notice in any future
 release, so we recommend you always decode using the current version of
 this command.
-.br
-.TP
+.HP
+.B stats
+.I command
+.RI [ options ]
+.br
+Manages IO statistics regions for devices.
+See  
+.BR dmstats (8)
+for more details.
+.HP
 .B status
 .RB [ \-\-target
 .IR target_type ]
@@ -547,7 +552,6 @@ Outputs status information for each of the device's targets.
 With \fB\-\-target\fP, only information relating to the specified target type
 any is displayed.  With \fB\-\-noflush\fP, the thin target (from version 1.3.0)
 doesn't commit any outstanding changes to disk before reporting its statistics.
-.br
 .HP
 .B suspend
 .RB [ \-\-nolockfs ]
@@ -562,8 +566,7 @@ an attempt will be made to sync it first unless \fB\-\-nolockfs\fP is specified.
 Some targets such as recent (October 2006) versions of multipath may support
 the \fB\-\-noflush\fP option.  This lets outstanding I/O that has not yet reached the
 device to remain unflushed.
-.br
-.TP
+.HP
 .B table
 .RB [ \-\-target
 .IR target_type ]
@@ -576,32 +579,27 @@ With \fB\-\-target\fP, only information relating to the specified target type
 is displayed.
 Encryption keys are suppressed in the table output for the crypt
 target unless the \fB\-\-showkeys\fP parameter is supplied.
-.br
-.TP
+.HP
 .B targets
 .br
 Displays the names and versions of the currently-loaded targets.
-.br
 .HP
 .B udevcomplete
 .I cookie
 .br
 Wake any processes that are waiting for udev to complete processing the specified cookie.
-.br
 .HP
 .B udevcomplete_all
 .RI [ age_in_minutes ]
 .br
 Remove all cookies older than the specified number of minutes.
 Any process waiting on a cookie will be resumed immediately.
-.br
 .HP
 .B udevcookies
 .br
 List all existing cookies. Cookies are system-wide semaphores with keys
 prefixed by two predefined bytes (0x0D4D).
-.br
-.TP
+.HP
 .B udevcreatecookie
 .br
 Creates a new cookie to synchronize actions with udev processing.
@@ -614,7 +612,6 @@ of the dmsetup process as \fBDM_UDEV_COOKIE\fP variable and it will be used auto
 with all subsequent commands until it is unset.
 Invoking this command will create system-wide semaphore that needs to be cleaned
 up explicitly by calling udevreleasecookie command.
-.br
 .HP
 .B udevflags
 .I cookie
@@ -626,7 +623,6 @@ DM_UDEV_FLAG_<flag_name>='1', DM_UDEV_FLAG<flag_position>='1' otherwise.
 Subsystem udev flags don't have symbolic names assigned and these ones are
 always reported as DM_SUBSYSTEM_UDEV_FLAG<flag_position>='1'. There are
 16 udev flags altogether.
-.br
 .HP
 .B udevreleasecookie
 .RI [ cookie ]
@@ -634,13 +630,11 @@ always reported as DM_SUBSYSTEM_UDEV_FLAG<flag_position>='1'. There are
 Waits for all pending udev processing bound to given cookie value and clean up
 the cookie with underlying semaphore. If the cookie is not given directly,
 the command will try to use a value defined by \fBDM_UDEV_COOKIE\fP environment variable.
-.br
-.TP
+.HP
 .B version
 .br
 Outputs version information.
-
-.TP
+.HP
 .B wait
 .RB [ \-\-noflush ]
 .I device_name
@@ -652,24 +646,38 @@ To wait until the next event is triggered, use \fBinfo\fP to find
 the last event number.
 With \fB\-\-noflush\fP, the thin target (from version 1.3.0) doesn't commit
 any outstanding changes to disk before reporting its statistics.
+.HP
+.B wipe_table
+.I device_name
+.RB [ \-f | \-\-force ]
+.RB [ \-\-noflush ]
+.RB [ \-\-nolockfs ]
+.br
+Wait for any I/O in-flight through the device to complete, then
+replace the table with a new table that fails any new I/O
+sent to the device.  If successful, this should release any devices
+held open by the device's table(s).
 .SH TABLE FORMAT
 Each line of the table specifies a single target and is of the form:
 .P
 .I logical_start_sector num_sectors
 .B target_type
-.RI < target_args >
+.I target_args
 .P
-Simple target types and <target_args> include:
+Simple target types and \fItarget_args\fP include:
 .HP
+.PD 0
 .B linear
-.I destination_device start_sector
+.I destination_device
+.I start_sector
 .br
 The traditional linear mapping.
 .HP
 .B striped
-.I num_stripes chunk_size
+.I num_stripes
+.I chunk_size
 .RI [ destination
-.IR start_sector ]+
+.IR start_sector ]...
 .br
 Creates a striped area.
 .br
@@ -684,34 +692,41 @@ will map the first chunk (16k) as follows:
  etc.
 .RE
 .RE
-.TP
+.HP
 .B error
 .br
 Errors any I/O that goes to this area.  Useful for testing or
 for creating devices with holes in them.
-.TP
+.HP
 .B zero
 .br
 Returns blocks of zeroes on reads.  Any data written is discarded silently.
 This is a block-device equivalent of the /dev/zero character-device data sink
 described in \fBnull\fP(4).
-.P
+.PD
+.HP
 More complex targets include:
-.TP
+.HP
+.PD 0
+.B cache
+.br
+Improves performance of a block device (eg, a spindle) by dynamically
+migrating some of its data to a faster smaller device (eg, an SSD).
+.HP
 .B crypt
 .br
 Transparent encryption of block devices using the kernel crypto API.
-.TP
+.HP
 .B delay
 .br
 Delays reads and/or writes to different devices.  Useful for testing.
-.TP
+.HP
 .B flakey
 .br
 Creates a similar mapping to the linear target but
 exhibits unreliable behaviour periodically.
 Useful for simulating failing devices when testing.
-.TP
+.HP
 .B mirror
 .br
 Mirrors data across two or more devices.
@@ -719,14 +734,19 @@ Mirrors data across two or more devices.
 .B multipath
 .br
 Mediates access through multiple paths to the same device.
-.TP
-.BR raid
+.HP
+.B raid
 .br
 Offers an interface to the kernel's software raid driver, md.
 .HP
 .B snapshot
 .br
 Supports snapshots of devices.
+.HP
+.BR thin ,\  thin-pool
+.br
+Supports thin provisioning of devices and also provides a better snapshot support.
+.PD
 .P
 To find out more about the various targets and their table formats and status
 lines, please read the files in the Documentation/device-mapper directory in
@@ -765,13 +785,17 @@ A cookie to use for all relevant commands to synchronize with udev processing.
 It is an alternative to using \fB\-\-udevcookie\fP option.
 .TP
 .B DM_DEFAULT_NAME_MANGLING_MODE
-A default mangling mode. Defaults to "\fI#DEFAULT_MANGLING#\fP"
+A default mangling mode. Defaults to "\fB#DEFAULT_MANGLING#\fP"
 and it is an alternative to using \fB\-\-manglename\fP option.
 
 .SH AUTHORS
 Original version: Joe Thornber (thornber at redhat.com)
 
 .SH SEE ALSO
+.BR dmstats (8),
+.BR udev (7),
+.BR udevadm (8)
+
 LVM2 resource page https://www.sourceware.org/lvm2/
 .br
 Device-mapper resource page: http://sources.redhat.com/dm/
diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index 326ab25..21e7685 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -6,80 +6,69 @@ dmstats \(em device-mapper statistics management
 .B dmsetup stats
 .I command
 .RB [ options ]
-.br
-
-.B dmstats <command>
-.RB [[
-.IR device_name ]
-.RB |[ \-\-uuid
-.IR uuid ]
-.RB |[ \-\-major
-.IR major
-.RB \-\-minor
-.IR minor ]]
-.br
-
+.HP
+.PD 0
+.B dmstats
+.RB < command >
+.RI [ device_name | \fB\-\-uuid
+.IR uuid | \fB\-\-major
+.I major
+.B \-\-minor
+.IR minor ]
+.HP
 .B dmstats clear
 .I device_name
-.RB [ \-\-allregions
-.RB | \-\-regionid
+.RB [ \-\-allregions | \-\-regionid
 .IR id ]
-.br
+.HP
 .B dmstats create
 .I device_name
 .RB [ \-\-alldevices ]
-.RB [[ \-\-areas
-.IR nr_areas ]
-.RB |[ \-\-areasize
-.IR area_size ]]
+.RB [ \-\-areas
+.IR nr_areas | \fB\-\-areasize
+.IR area_size ]
 .RB [ \-\-bounds
 .IR histogram_boundaries ]
 .RB [ \-\-precise ]
-.RB [[ \-\-start
-.IR start_sector ]
-.RB [ \-\-length
-.IR length ]
-.RB |[ \-\-segments ]]
+.RB [ \-\-start
+.I  start_sector
+.B  \-\-length
+.IR length | \fB\-\-segments ]
 .RB [ \-\-auxdata
 .IR data ]
 .RB [ \-\-programid
 .IR id ]
-.br
+.HP
 .B dmstats delete
 .I device_name
 .RB [ \-\-alldevices ]
-.RB [ \-\-allregions
-.RB | \-\-regionid
+.RB [ \-\-allregions | \-\-regionid
 .IR id ]
-.RB [ \-\-allprograms
-.RB | \-\-programid
+.RB [ \-\-allprograms | \-\-programid
 .IR id ]
-.br
+.HP
 .B dmstats help
 .RB [ \-c | \-C | \-\-columns ]
-.br
+.HP
 .B dmstats list
 .RI [ device_name ]
-.RB [ \-\-allprograms
-.RB | \-\-programid
+.RB [ \-\-allprograms | \-\-programid
 .IR id ]
 .RB [ \-\-histogram ]
 .RB [ \-\-units
 .IR units ]
 .RB [ \-\-nosuffix ]
 .RB [ \-\-notimesuffix ]
-.RB [ \-v | \-\-verbose \ [ \-v | \-\-verbose ]
-.br
+.RB [ \-v | \-\-verbose \ [ \-v | \-\-verbose ]]
+.HP
 .B dmstats print
 .RI [ device_name ]
 .RB [ \-\-clear ]
-.RB [ \-\-allprograms
-.RB | \-\-programid
+.RB [ \-\-allprograms | \-\-programid
 .IR id ]
-.RB [ \-\-allregions
-.RB | \-\-regionid
+.RB [ \-\-allregions | \-\-regionid
 .IR id ]
-.br
+.HP
 .B dmstats report
 .RI [ device_name ]
 .RB [ \-\-interval
@@ -102,7 +91,8 @@ dmstats \(em device-mapper statistics management
 .IR units ]
 .RB [ \-\-nosuffix ]
 .RB [ \-\-notimesuffix ]
-.br
+.PD
+.HP
 .ad b
 .SH DESCRIPTION
 The dmstats program manages IO statistics regions for devices that use
@@ -212,7 +202,7 @@ string is stored with the region. Subsequent operations may supply a
 program ID in order to select only regions with a matching value. The
 default program ID for dmstats-managed regions is "dmstats".
 .TP
-.BR \-\-regionid \fIid
+.B \-\-regionid \fIid
 Specify the region to operate on.
 .TP
 .BR \-\-relative
@@ -255,11 +245,11 @@ Produce additional output.
 .TP
 .B clear
 .I device_name
-.RB [ \-\-allregions
-.RB | \-\-regionid
+.RB [ \-\-allregions | \-\-regionid
 .IR id ]
 .RB [ \-\-allprograms
-.RB | \-\-programid
+.RB |
+.B \-\-programid
 .IR id ]
 .br
 Instructs the kernel to clear statistics counters for the speficied
@@ -275,11 +265,10 @@ regions (with the exception of in-flight IO counters).
 .RB [ --bounds
 .IR histogram_boundaries ]
 .RB [ \-\-precise ]
-.RB [[ \-\-start
-.IR start_sector ]
-.RB [ \-\-length
-.IR length ]
-.RB |[ \-\-segments ]]
+.RB [ \-\-start
+.I  start_sector
+.B  \-\-length
+.IR length | \fB\-\-segments ]
 .RB [ \-\-auxdata
 .IR data ]
 .RB [ \-\-programid
@@ -325,13 +314,13 @@ stdout.
 .br
 .TP
 .B delete
-.I [ device_name ]
+.RI [ device_name ]
 .RB [ \-\-alldevices ]
 .RB [ \-\-allregions
-.RB | \-\-regionid
+|
+.B \-\-regionid
 .IR id ]
-.RB [ \-\-allprograms
-.RB | \-\-programid
+.RB [ \-\-allprograms | \-\-programid
 .IR id ]
 .br
 Delete the specified statistics region. All counters and resources used
@@ -357,8 +346,8 @@ the list of report fields.
 .RB [ \-\-histogram ]
 .RB [ \-\-allprograms ]
 .RB [ \-\-programid
-.RB [ \-v | \-\-verbose \ [ \-v | \-\-verbose ]]
 .IR id ]
+.RB [ \-v | \-\-verbose \ [ \-v | \-\-verbose ]]
 .br
 List the statistics regions registered on the device. If the
 \fB\-\-allprograms\fP switch is given all regions will be listed
@@ -372,14 +361,11 @@ and latency boundary values for any configured histograms.
 .br
 .TP
 .B print
-.RB [ \-\-clear ]
-.IR
-.RB [ \-\-allregions
-.RB | \-\-regionid
+.RB [ \-\-allregions | \-\-regionid
 .IR id ]
-.RB [ \-\-allprograms
-.RB | \-\-programid
+.RB [ \-\-allprograms | \-\-programid
 .IR id ]
+.RB [ \-\-clear ]
 .br
 Print raw statistics counters for the specified region or for all
 present regions.
@@ -400,7 +386,7 @@ present regions.
 .RB [ \-O | \-\-sort
 .IR sort_fields ]
 .RB [ \-S | \-\-select
-.IR Selection ]
+.IR selection ]
 .RB [ \-\-units
 .IR units ]
 .br
@@ -845,6 +831,8 @@ Print raw counters for region 4 on device d0
 Bryn M. Reeves <bmr@redhat.com>
 
 .SH SEE ALSO
+.BR dmsetup (8)
+
 LVM2 resource page https://www.sourceware.org/lvm2/
 .br
 Device-mapper resource page: http://sources.redhat.com/dm/
@@ -852,4 +840,4 @@ Device-mapper resource page: http://sources.redhat.com/dm/
 
 Device-mapper statistics kernel documentation
 .br
-   Documentation/device-mapper/statistics.txt
+Documentation/device-mapper/statistics.txt


