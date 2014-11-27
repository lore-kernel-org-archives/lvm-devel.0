From: saulery@free.fr <saulery@free.fr>
Date: Thu, 27 Nov 2014 02:32:40 +0100
Subject: Improve dmsetup.8 manpage and inline help of dmsetup
In-Reply-To: <1417051960-2920-1-git-send-email-saulery@free.fr>
References: <1417051960-2920-1-git-send-email-saulery@free.fr>
Message-ID: <1417051960-2920-4-git-send-email-saulery@free.fr>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: St?phane Aulery <saulery@free.fr>

- Make coherent manpage and inline options
- Document all options, but need some information missing about
  --nameprefixes, -G, -j, -m, -M, -U options
- References in bold
- Args in italic
- Add md, null, udev, lvm, multipath ref.c
- Correct some typos
- Sort identically options in manpage and inline help
- Document status and table missing values for --tree -o options of ls command

Signed-off-by: St?phane Aulery <saulery@free.fr>
---
 man/dmsetup.8.in | 343 ++++++++++++++++++++++++++++++++++---------------------
 tools/dmsetup.c  |  53 ++++-----
 2 files changed, 242 insertions(+), 154 deletions(-)

diff --git a/man/dmsetup.8.in b/man/dmsetup.8.in
index 57fbdf9..88cffaf 100644
--- a/man/dmsetup.8.in
+++ b/man/dmsetup.8.in
@@ -1,4 +1,4 @@
-.TH DMSETUP 8 "Apr 06 2006" "Linux" "MAINTENANCE COMMANDS"
+.TH DMSETUP 8 "LVM TOOLS #VERSION#" "Red Hat, Inc" "MAINTENANCE COMMANDS"
 .SH NAME
 dmsetup \(em low level logical volume management
 .SH SYNOPSIS
@@ -8,19 +8,28 @@ dmsetup \(em low level logical volume management
 .br
 .B dmsetup create
 .I device_name
-.RB [ \-u
+.RB [ \-j | \-\-major
+.RI < major >
+.BR \-m | \-\-minor
+.RI < minor >]
+.RB [ \-U | \-\-uid
+.RI < uid >]
+.RB [ \-G | \-\-gid
+.RI < gid >]
+.RB [ \-M | \-\-mode
+.RI < octal_mode >]
+.RS
+.RB [ \-u | \-\-uuid
 .IR uuid ]
 .RB [ \-n | \-\-notable | \-\-table
-.RI < table >|
-.RS
-.IR table_file ]
+.RI < table >| table_file ]
 .RB [{ \-\-addnodeoncreate | \-\-addnodeonresume }]
 .RB [ \-\-readahead
 .RI [ + ]< sectors >| auto | none ]
 .RE
 .br
 .B dmsetup deps
-.RB [ \-o
+.RB [ \-o | \-\-options
 .IR options ]
 .RI [ device_name ]
 .br
@@ -57,27 +66,24 @@ dmsetup \(em low level logical volume management
 .IR command ]
 .RB [ \-\-tree ]
 .RS
-.RB [ \-o
+.RB [ \-o | \-\-options
 .IR options ]
 .RE
 .br
+.B dmsetup mangle
+.RI [ device_name ]
+.br
 .B dmsetup message
 .I device_name sector message
 .br
 .B dmsetup mknodes
 .RI [ device_name ]
 .br
-.B dmsetup mangle
-.RI [ device_name ]
-.br
 .B dmsetup reload
 .I device_name
 .RB [ \-\-table
 .RI < table >| table_file ]
 .br
-.B dmsetup wipe_table
-.I device_name
-.br
 .B dmsetup remove
 .RB [ \-f | \-\-force ]
 .RB [ \-\-retry ]
@@ -112,10 +118,10 @@ dmsetup \(em low level logical volume management
 .RI [ subsystem ]
 .br
 .B dmsetup status
+.RI [ device_name ]
+.RB [ \-\-noflush ]
 .RB [ \-\-target
 .IR target_type ]
-.RB [ \-\-noflush ]
-.RI [ device_name ]
 .br
 .B dmsetup suspend
 .RB [ \-\-nolockfs ]
@@ -123,10 +129,10 @@ dmsetup \(em low level logical volume management
 .I device_name
 .br
 .B dmsetup table
+.RI [ device_name ]
+.RB [ \-\-showkeys ]
 .RB [ \-\-target
 .IR target_type ]
-.RB [ \-\-showkeys ]
-.RI [ device_name ]
 .br
 .B dmsetup targets
 .br
@@ -153,6 +159,9 @@ dmsetup \(em low level logical volume management
 .I device_name
 .RI [ event_nr ]
 .br
+.B dmsetup wipe_table
+.I device_name
+.br
 
 .B devmap_name
 .I major minor
@@ -161,23 +170,24 @@ dmsetup \(em low level logical volume management
 .I major:minor
 .ad b
 .SH DESCRIPTION
-dmsetup manages logical devices that use the device-mapper driver.
+\fBdmsetup\fP manages logical devices that use the device-mapper driver.
 Devices are created by loading a table that specifies a target for
 each sector (512 bytes) in the logical device.
 
-The first argument to dmsetup is a command.
-The second argument is the logical device name or uuid.
+The first argument to \fBdmsetup\fP is a command.
+The second argument is the logical \fIdevice name\fP or \fIuuid\fP.
 
-Invoking the command as \fBdevmap_name\fP is equivalent to
+Invoking the command as \fBdevmap_name\fP is equivalent to:
 .br
-\fBdmsetup info \-c \-\-noheadings \-j \fImajor\fB \-m \fIminor\fP.
+\fBdmsetup info \-c \-\-noheadings \-j \fImajor\fB \-m \fIminor\fP
 .SH OPTIONS
 .TP
 .B \-\-addnodeoncreate
-Ensure /dev/mapper node exists after dmsetup create.
+Ensure /dev/mapper node exists after \fBdmsetup\fP create.
 .TP
 .B \-\-addnodeonresume
-Ensure /dev/mapper node exists after dmsetup resume (default with udev).
+Ensure /dev/mapper node exists after \fBdmsetup\fP resume (default with
+\fBudev\fP(7)).
 .TP
 .B \-\-checks
 Perform additional checks on the operations requested and report
@@ -187,6 +197,9 @@ In some cases these checks may slow down operations noticeably.
 .BR \-c | \-C | \-\-columns
 Display output in columns rather than as Field: Value lines.
 .TP
+.BR \-G | \-\-gid \ \fIgid\fP
+Specify the \fIgid\fP.
+.TP
 .BR \-h | \-\-help
 Outputs a summary of the commands available, optionally including
 the list of report fields (synonym with \fBhelp\fP command).
@@ -196,16 +209,33 @@ When returning any table information from the kernel report on the
 inactive table instead of the live table.
 Requires kernel driver version 4.16.0 or above.
 .TP
-.IR \fB\-\-manglename \ { none | hex | auto }
-Mangle any character not on a whitelist using mangling_mode when
+.BR \-j | \-\-major \ \fImajor\fP
+Specify the \fImajor\fP number.
+.TP
+.BR \-m | \-\-minor \ \fIminor\fP
+Specify the \fIminor\fP number.
+.TP
+.BR \-M | \-\-mode \ \fIoctal_mode\fP
+Specify the \fIoctal mode\fP.
+.TP
+.BI \-\-manglename \ mangling_mode
+Mangle any character not on a whitelist using \fImangling_mode\fP when
 processing device-mapper device names and UUIDs. The names and UUIDs
 are mangled on input and unmangled on output where the mangling mode
 is one of:
-\fInone\fP (no mangling),
-\fIhex\fP (always do the mangling) and
-\fIauto\fP (only do the mangling if not mangled yet, do nothing
-if already mangled, error on mixed)
+.RS
+.IP \fInone\fP
+No mangling
+.IP \fIhex\fP
+Always do the mangling
+.IP \fIauto\fP
+Only do the mangling if not mangled yet, do nothing
+if already mangled, error on mixed.
+.RE
+.TP
+.BR
 Default mode is \fI#DEFAULT_MANGLING#\fP.
+
 Character whitelist: 0-9, A-Z, a-z, #+-.:=@_. This whitelist is
 also supported by udev. Any character not on a whitelist is replaced
 with its hex value (two digits) prefixed by \\x.
@@ -213,11 +243,8 @@ Mangling mode could be also set through
 .B DM_DEFAULT_NAME_MANGLING_MODE
 environment variable.
 .TP
-.BR \-j | \-\-major\ \fImajor
-Specify the major number.
-.TP
-.BR \-m | \-\-minor\ \fIminor
-Specify the minor number.
+.BR \-\-nameprefixes
+[FIXME].
 .TP
 .BR \-n | \-\-notable
 When creating a device, don't load any table.
@@ -238,7 +265,7 @@ Do not synchronise with udev when creating, renaming or removing devices.
 Specify which fields to display.
 .TP
 .IR \fB\-\-readahead \ [ + ]< sectors >| auto | none
-Specify read ahead size in units of sectors.
+Specify read ahead size in units of \fIsectors\fP.
 The default value is \fIauto\fP which allows the kernel to choose
 a suitable value automatically.  The \fI+\fP prefix lets you
 specify a minimum value which will not be used if it is
@@ -248,29 +275,32 @@ The value \fInone\fP is equivalent to specifying zero.
 .BR \-r | \-\-readonly
 Set the table being loaded read-only.
 .TP
-.BR \-S | \-\-select \ \fISelection
-Display only rows that match Selection criteria. All rows are displayed
-with the additional "selected" column (-o selected) showing 1 if the row
-matches the Selection and 0 otherwise. The Selection criteria are defined
+.BR \-S | \-\-select \ \fISelection\fP
+Display only rows that match \fISelection\fP criteria. All rows are displayed
+with the additional "selected" column (\fB-o\fP \fIselected\fP) showing 1 if the row
+matches the \fISelection\fP and 0 otherwise. The \fISelection\fP criteria are defined
 by specifying column names and their valid values while making use of
 supported comparison operators. As a quick help and to see full list of
-column names that can be used in Selection and the set of supported
+column names that can be used in \fISelection\fP and the set of supported
 selection operators, check the output of \fBdmsetup info -c -S help\fP
 command.
 .TP
 .IR \fB\-\-table \ < table >
-Specify a one-line table directly on the command line.
+Specify a one-line \fItable\fP directly on the command line.
 .TP
-.B \-\-udevcookie \fIcookie
-Use cookie for udev synchronisation.
-Note: Same cookie should be used for same type of operations i.e. creation of
-multiple different devices. It's not adviced to combine different
+.BR \-\-udevcookie \ \fIcookie\fP
+Use \fIcookie\fP for udev synchronisation.
+Note: Same \fIcookie\fP should be used for same type of operations i.e. creation of
+multiple different devices. It's not advised to combine different
 operations on the single device.
 .TP
-.BR \-u | \-\-uuid
-Specify the uuid.
+.BR \-u | \-\-uuid \ \fIuuid\fP
+Specify the \fIuuid\fP.
+.TP
+.BR \-U | \-\-uid \ \fIuid\fP
+Specify the \fIuid\fP.
 .TP
-.BR \-y | \-\-yes
+.BR\-y | \-\-yes
 Answer yes to all prompts automatically.
 .TP
 .BR \-v | \-\-verbose \ [ \-v | \-\-verbose ]
@@ -281,19 +311,29 @@ If udev synchronisation is enabled, verify that udev operations get performed
 correctly and try to fix up the device nodes afterwards if not.
 .TP
 .B \-\-version
-Display the library and kernel driver version.
+Display the library and kernel driver version  (synonym with \fBversion\fP command).
 .br
 .SH COMMANDS
 .TP
 .B clear
 .I device_name
 .br
-Destroys the table in the inactive table slot for device_name.
+Destroys the table in the inactive table slot for \fIdevice_name\fP.
 .br
 .TP
 .B create
 .I device_name
-.RB [ \-u
+.RB [ \-j | \-\-major
+.RI < major >
+.BR \-m | \-\-minor
+.RI < minor >]
+.RB [ \-U | \-\-uid
+.RI < uid > ]
+.RB [ \-G | \-\-gid
+.RI < gid > ]
+.RB [ \-M | \-\-mode
+.RI < octal_mode > ]
+.RB [ \-u | \-\-uuid
 .IR uuid ]
 .RB [ \-n | \-\-notable | \-\-table
 .RI < \fItable >| table_file ]
@@ -302,25 +342,30 @@ Destroys the table in the inactive table slot for device_name.
 .RI [ + ]< sectors >| auto | none ]
 .br
 Creates a device with the given name.
-If table_file or <table> is supplied, the table is loaded and made live.
+If <\fItable\fP> or \fItable_file\fP is supplied, the table is loaded and made live.
 Otherwise a table is read from standard input unless \fB\-\-notable\fP is used.
-The optional uuid can be used in place of
-device_name in subsequent dmsetup commands.
+The optional \fIuuid\fP can be used in place of
+\fIdevice_name\fP in subsequent \fBdmsetup\fP commands.
 If successful a device will appear as
 /dev/mapper/<device-name>.
-See below for information on the table format.
+See below for information on the \fItable\fP format.
 .br
 .TP
 .B deps
-.RB [ \-o
+.RB [ \-o | \-\-options
 .IR options ]
 .RI [ device_name ]
 .br
 Outputs a list of devices referenced by the live table for the specified
-device. Device names on output can be customised by following options:
-devno (major and minor pair, used by default), blkdevname (block device name),
-devname (map name for device-mapper devices, equal to blkdevname otherwise).
-.br
+device. Device names on output can be customised by following \fIoptions\fP:
+.RS
+.IP \fIdevno\fP
+Major and minor pair (used by default)
+.IP \fIblkdevname\fP
+Block device name
+.IP \fIdevname\fP
+Map name for device-mapper devices, equal to blkdevname otherwise
+.RE
 .TP
 .B help
 .RB [ \-c | \-C | \-\-columns ]
@@ -355,15 +400,38 @@ Outputs some brief information about the device in the form:
 .IR fields ]
 .RB [ \-O | \-\-sort
 .IR sort_fields ]
+.RB [ \-S | \-\-select
+.IR Selection ]
 .RI [ device_name ]
 .br
-Output you can customise.
-Fields are comma-separated and chosen from the following list:
-name, major, minor, attr, open, segments, events, uuid.
-Attributes are: (L)ive, (I)nactive, (s)uspended, (r)ead-only, read-(w)rite.
-Precede the list with '+' to append
-to the default selection of columns instead of replacing it.
-Precede any sort_field with - for a reverse sort on that column.
+You can customise output. \fIFields\fP are comma-separated and chosen from
+the following list:
+.IR name ,
+.IR major ,
+.IR minor ,
+.IR attr ,
+.IR open ,
+.IR segments ,
+.IR events ,
+.IR uuid .
+Attributes are:
+.RI ( L )ive,
+.RI ( I )nactive,
+.RI ( S )uspended,
+.RI ( R )ead-only,
+.RI read-( W )rite.
+Precede the list with \fI+\fP to append to the default selection of columns
+instead of replacing it. Precede any sort_field with \fI-\fP for a reverse sort on
+that column.
+.br
+.HP
+.BR load
+.I device_name
+.RB [ \-\-table
+.RI < table >| table_file ]
+.br
+Loads <\fItable\fP> or \fItable_file\fP into the inactive table slot for
+\fIdevice_name\fP. If neither is supplied, reads a table from standard input.
 .br
 .TP
 .B ls
@@ -372,76 +440,80 @@ Precede any sort_field with - for a reverse sort on that column.
 .RB [ \-\-exec
 .IR command ]
 .RB [ \-\-tree ]
-.RB [ \-o
+.RB [ \-o | \-\-options
 .IR options ]
 .br
 List device names.  Optionally only list devices that have at least
-one target of the specified type.  Optionally execute a command for
+one target of the specified type.  Optionally execute a \fIcommand\fP for
 each device.  The device name is appended to the supplied command.
-Device names on output can be customised by following options: devno (major
-and minor pair, used by default), blkdevname (block device name),
-devname (map name for device-mapper devices, equal to blkdevname otherwise).
+Device names on output can be customised by following options: \fIdevno\fP (major
+and minor pair, used by default), \fIblkdevname\fP (block device name),
+\fIdevname\fP (map name for device-mapper devices, equal to blkdevname otherwise).
 \fB\-\-tree\fP displays dependencies between devices as a tree.
-It accepts a comma-separate list of options.
+It accepts a comma-separate list of \fIoptions\fP.
 Some specify the information displayed against each node:
-device/nodevice; blkdevname; active, open, rw, uuid.
+.IR device ,
+.IR nodevice ;
+.IR blkdevname ;
+.IR status ,
+.IR table ,
+.IR active ,
+.IR open ,
+.IR rw ,
+.IR uuid .
 Others specify how the tree is displayed:
-ascii, utf, vt100; compact, inverted, notrunc.
-.br
-.HP
-.BR load | reload
-.I device_name
-.RB [ \-\-table
-.RI < table >| table_file ]
-.br
-Loads <table> or table_file into the inactive table slot for device_name.
-If neither is supplied, reads a table from standard input.
+.IR ascii ,
+.IR utf ,
+.IR vt100 ;
+.IR compact ,
+.IR inverted ,
+.IR notrunc .
 .br
 .HP
-.B wipe_table
-.I device_name
+.B mangle
+.RI [ device_name ]
 .br
-Wait for any I/O in-flight through the device to complete, then
-replace the table with a new table that fails any new I/O
-sent to the device.  If successful, this should release any devices
-held open by the device's table(s).
+Ensure existing device-mapper device name and UUID is in the correct mangled
+form containing only whitelisted characters (supported by udev) and do
+a rename if necessary. Any character not on the whitelist will be mangled
+based on the \fB\-\-manglename\fP setting. Automatic rename works only for device
+names and not for device UUIDs because the kernel does not allow changing
+the UUID of active devices. Any incorrect UUIDs are reported only and they
+must be manually corrected by deactivating the device first and then
+reactivating it with proper mangling mode used (see also \fB\-\-manglename\fP).
 .br
 .HP
 .B message
 .I device_name sector message
 .br
-Send message to target. If sector not needed use 0.
+Send \fImessage\fP to target. If \fIsector\fP not needed use \fI0\fP.
 .br
 .HP
 .B mknodes
 .RI [ device_name ]
 .br
-Ensure that the node in /dev/mapper for device_name is correct.
+Ensure that the node in /dev/mapper for \fIdevice_name\fP is correct.
 If no device_name is supplied, ensure that all nodes in /dev/mapper
 correspond to mapped devices currently loaded by the device-mapper kernel
 driver, adding, changing or removing nodes as necessary.
 .br
 .HP
-.B mangle
-.RI [ device_name ]
+.BR reload
+.I device_name
+.RB [ \-\-table
+.RI < table >| table_file ]
 .br
-Ensure existing device-mapper device name and UUID is in the correct mangled
-form containing only whitelisted characters (supported by udev) and do
-a rename if necessary. Any character not on the whitelist will be mangled
-based on the \fB\-\-manglename\fP setting. Automatic rename works only for device
-names and not for device UUIDs because the kernel does not allow changing
-the UUID of active devices. Any incorrect UUIDs are reported only and they
-must be manually corrected by deactivating the device first and then
-reactivating it with proper mangling mode used (see also \fB\-\-manglename\fP).
+Reloads <\fItable\fP> or \fItable_file\fP into the inactive table slot for
+\fIdevice_name\fP. If neither is supplied, reads a table from standard input.
 .br
 .HP
 .B remove
 .RB [ \-f | \-\-force ]
-.RB [ \-\-retry ]
 .RB [ \-\-deferred ]
+.RB [ \-\-retry ]
 .I device_name
 .br
-Removes a device.  It will no longer be visible to dmsetup.  Open devices
+Removes a device.  It will no longer be visible to \fBdmsetup\fP.  Open devices
 cannot be removed, but adding \fB\-\-force\fP will replace the table with one
 that fails all I/O.  \fB\-\-deferred\fP will enable deferred removal of open
 devices - the device will be removed when the last user closes it. The deferred
@@ -480,8 +552,8 @@ Renames a device.
 .B \-\-setuuid
 .I uuid
 .br
-Sets the uuid of a device that was created without a uuid.
-After a uuid has been set it cannot be changed.
+Sets the \fIuuid\fP of a device that was created without a \fIuuid\fP.
+After a \fIuuid\fP has been set it cannot be changed.
 .br
 .TP
 .B resume
@@ -504,8 +576,8 @@ Sets the device geometry to C/H/S.
 .I device_name
 .RI [ subsystem ]
 .br
-Splits given device name into subsystem constituents.
-The default subsystem is LVM.  
+Splits given \fIdevice_name\fP into \fIsubsystem\fP constituents.
+The default \fIsubsystem\fP is \fBLVM\fP(8).
 LVM currently generates device names by concatenating the names of the Volume
 Group, Logical Volume and any internal Layer with a hyphen as separator.
 Any hyphens within the names are doubled to escape them.
@@ -515,15 +587,16 @@ this command.
 .br
 .TP
 .B status
+.RI [ device_name ]
+.RB [ \-\-noflush ]
 .RB [ \-\-target
 .IR target_type ]
-.RB [ \-\-noflush ]
-.RI [ device_name ]
 .br
-Outputs status information for each of the device's targets.
-With \fB\-\-target\fP, only information relating to the specified target type
-any is displayed.  With \fB\-\-noflush\fP, the thin target (from version 1.3.0)
-doesn't commit any outstanding changes to disk before reporting its statistics.
+Outputs status information for each of the device's targets. With
+\fB\-\-target\fP, only information relating to the specified \fItarget_type\fP
+any is displayed. With \fB\-\-noflush\fP, the thin target (from version
+1.3.0) doesn't commit any outstanding changes to disk before reporting its
+statistics.
 .br
 .HP
 .B suspend
@@ -536,21 +609,21 @@ but has not yet completed will be flushed.  Any further I/O to that
 device will be postponed for as long as the device is suspended.
 If there's a filesystem on the device which supports the operation,
 an attempt will be made to sync it first unless \fB\-\-nolockfs\fP is specified.
-Some targets such as recent (October 2006) versions of multipath may support
+Some targets such as recent (October 2006) versions of \fBmultipath\fP(8) may support
 the \fB\-\-noflush\fP option.  This lets outstanding I/O that has not yet reached the
 device to remain unflushed.
 .br
 .TP
 .B table
+.RI [ device_name ]
+.RB [ \-\-showkeys ]
 .RB [ \-\-target
 .IR target_type ]
-.RB [ \-\-showkeys ]
-.RI [ device_name ]
 .br
 Outputs the current table for the device in a format that can be fed
-back in using the create or load commands.
-With \fB\-\-target\fP, only information relating to the specified target type
-is displayed.
+back in using the \fBcreate\fP or \fBload\fP commands.
+With \fB\-\-target\fP, only information relating to the specified
+\fItarget_type\fP is displayed.
 Encryption keys are suppressed in the table output for the crypt
 target unless the \fB\-\-showkeys\fP parameter is supplied.
 .br
@@ -583,11 +656,11 @@ prefixed by two predefined bytes (0x0D4D).
 .br
 Creates a new cookie to synchronize actions with udev processing.
 The output is a cookie value. Normally we don't need to create cookies since
-dmsetup creates and destroys them for each action automatically. However, we can
+\fBdmsetup\fP creates and destroys them for each action automatically. However, we can
 generate one explicitly to group several actions together and use only one
 cookie instead. We can define a cookie to use for each relevant command by using
 \fB\-\-udevcookie\fP option. Alternatively, we can export this value into the environment
-of the dmsetup process as \fBDM_UDEV_COOKIE\fP variable and it will be used automatically
+of the \fBdmsetup\fP process as \fBDM_UDEV_COOKIE\fP variable and it will be used automatically
 with all subsequent commands until it is unset.
 Invoking this command will create system-wide semaphore that needs to be cleaned
 up explicitly by calling udevreleasecookie command.
@@ -608,8 +681,8 @@ always reported as DM_SUBSYSTEM_UDEV_FLAG<flag_position>='1'. There are
 .B udevreleasecookie
 .RI [ cookie ]
 .br
-Waits for all pending udev processing bound to given cookie value and clean up
-the cookie with underlying semaphore. If the cookie is not given directly,
+Waits for all pending udev processing bound to given \fIcookie\fP value and clean up
+the \fIcookie\fP with underlying semaphore. If the \fIcookie\fP is not given directly,
 the command will try to use a value defined by \fBDM_UDEV_COOKIE\fP environment variable.
 .br
 .TP
@@ -623,12 +696,21 @@ Outputs version information.
 .I device_name
 .RI [ event_nr ]
 .br
-Sleeps until the event counter for device_name exceeds event_nr.
+Sleeps until the event counter for \fIdevice_name\fP exceeds \fIevent_nr\fP.
 Use \fB\-v\fP to see the event number returned.
 To wait until the next event is triggered, use \fBinfo\fP to find
 the last event number.
 With \fB\-\-noflush\fP, the thin target (from version 1.3.0) doesn't commit
 any outstanding changes to disk before reporting its statistics.
+.br
+.HP
+.B wipe_table
+.I device_name
+.br
+Wait for any I/O in-flight through the device to complete, then
+replace the table with a new table that fails any new I/O
+sent to the device.  If successful, this should release any devices
+held open by the device's table(s).
 .SH TABLE FORMAT
 Each line of the table specifies a single target and is of the form:
 .P
@@ -670,7 +752,7 @@ for creating devices with holes in them.
 .B zero
 .br
 Returns blocks of zeroes on reads.  Any data written is discarded silently.
-This is a block-device equivalent of the /dev/zero character-device data sink
+This is a block-device equivalent of the \fI/dev/zero\fP character-device data sink
 described in \fBnull\fP(4).
 .P
 More complex targets include:
@@ -699,7 +781,7 @@ Mediates access through multiple paths to the same device.
 .TP
 .BR raid
 .br
-Offers an interface to the kernel's software raid driver, md.
+Offers an interface to the kernel's software raid driver, \fBmd\fP(4).
 .HP
 .B snapshot
 .br
@@ -749,6 +831,11 @@ and it is an alternative to using \fB\-\-manglename\fP option.
 Original version: Joe Thornber (thornber at redhat.com)
 
 .SH SEE ALSO
+.BR md (4),
+.BR null (4),
+.BR udev (7),
+.BR lvm (8),
+.BR multipath (8),
 LVM2 resource page https://www.sourceware.org/lvm2/
 .br
 Device-mapper resource page: http://sources.redhat.com/dm/
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 4202dbb..5377285 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -3066,40 +3066,41 @@ static int _help(CMD_ARGS);
  * Dispatch table
  */
 static struct command _commands[] = {
+	{"clear", "<device>", 0, -1, 1, _clear},
+	{"create", "<device> [-j|--major <major> -m|--minor <minor>]\n"
+	  "\t                [-U|--uid <uid>] [-G|--gid <gid>] [-M|--mode <octal_mode>]\n"
+	  "\t                [-u|uuid <uuid>] [--notable | --table <table> | <table_file>]\n"
+	  "\t                [{--addnodeonresume|--addnodeoncreate}]",
+	  "\t                [--readahead [+]<sectors>|auto|none]",
+	 1, 2, 0,  _create},
+	{"deps", "[-o|--options options] [<device>]", 0, -1, 1, _deps},
 	{"help", "[-c|-C|--columns]", 0, 0, 0, _help},
-	{"create", "<dev_name> [-j|--major <major> -m|--minor <minor>]\n"
-	  "\t                  [-U|--uid <uid>] [-G|--gid <gid>] [-M|--mode <octal_mode>]\n"
-	  "\t                  [-u|uuid <uuid>] [{--addnodeonresume|--addnodeoncreate}]\n"
-	  "\t                  [--notable | --table <table> | <table_file>]",
-	 1, 2,0,  _create},
-	{"remove", "[-f|--force] [--deferred] <device>", 0, -1, 1, _remove},
-	{"remove_all", "[-f|--force]", 0, 0, 0,  _remove_all},
-	{"suspend", "[--noflush] <device>", 0, -1, 1, _suspend},
-	{"resume", "<device> [{--addnodeonresume|--addnodeoncreate}]", 0, -1, 1, _resume},
+	{"info", "[<device>]", 0, -1, 1, _info},
 	{"load", "<device> [<table_file>]", 0, 2, 0, _load},
-	{"clear", "<device>", 0, -1, 1, _clear},
+	{"ls", "[--target <target_type>] [--exec <command>] [--tree] [-o options]", 0, 0, 0, _ls},
+	{"mangle", "[<device>]", 0, -1, 1, _mangle},
+	{"message", "<device> <sector> <message>", 2, -1, 0, _message},
+	{"mknodes", "[<device>]", 0, -1, 1, _mknodes},
 	{"reload", "<device> [<table_file>]", 0, 2, 0, _load},
-	{"wipe_table", "<device>", 0, -1, 1, _error_device},
+	{"remove", "[-f|--force] [--deferred] [--retry] <device>", 0, -1, 1, _remove},
+	{"remove_all", "[-f|--force]", 0, 0, 0,  _remove_all},
 	{"rename", "<device> [--setuuid] <new_name_or_uuid>", 1, 2, 0, _rename},
-	{"message", "<device> <sector> <message>", 2, -1, 0, _message},
-	{"ls", "[--target <target_type>] [--exec <command>] [-o options] [--tree]", 0, 0, 0, _ls},
-	{"info", "[<device>]", 0, -1, 1, _info},
-	{"deps", "[-o options] [<device>]", 0, -1, 1, _deps},
+	{"resume", "<device> [{--addnodeonresume|--addnodeoncreate}]", 0, -1, 1, _resume},
+	{"setgeometry", "<device> <cyl> <head> <sect> <start>", 5, 5, 0, _setgeometry},
+	{"splitname", "<device> [<subsystem>]", 1, 2, 0, _splitname},
 	{"status", "[<device>] [--noflush] [--target <target_type>]", 0, -1, 1, _status},
-	{"table", "[<device>] [--target <target_type>] [--showkeys]", 0, -1, 1, _status},
-	{"wait", "<device> [<event_nr>] [--noflush]", 0, 2, 0, _wait},
-	{"mknodes", "[<device>]", 0, -1, 1, _mknodes},
-	{"mangle", "[<device>]", 0, -1, 1, _mangle},
-	{"udevcreatecookie", "", 0, 0, 0, _udevcreatecookie},
-	{"udevreleasecookie", "[<cookie>]", 0, 1, 0, _udevreleasecookie},
-	{"udevflags", "<cookie>", 1, 1, 0, _udevflags},
+	{"suspend", "[--nolockfs] [--noflush] <device>", 0, -1, 1, _suspend},
+	{"table", "[<device>] [--showkeys] [--target <target_type>]", 0, -1, 1, _status},
+	{"targets", "", 0, 0, 0, _targets},
 	{"udevcomplete", "<cookie>", 1, 1, 0, _udevcomplete},
 	{"udevcomplete_all", "<age_in_minutes>", 0, 1, 0, _udevcomplete_all},
 	{"udevcookies", "", 0, 0, 0, _udevcookies},
-	{"targets", "", 0, 0, 0, _targets},
+	{"udevcreatecookie", "", 0, 0, 0, _udevcreatecookie},
+	{"udevflags", "<cookie>", 1, 1, 0, _udevflags},
+	{"udevreleasecookie", "[<cookie>]", 0, 1, 0, _udevreleasecookie},
 	{"version", "", 0, 0, 0, _version},
-	{"setgeometry", "<device> <cyl> <head> <sect> <start>", 5, 5, 0, _setgeometry},
-	{"splitname", "<device> [<subsystem>]", 1, 2, 0, _splitname},
+	{"wait", "[--noflush] <device> [<event_nr>]", 0, 2, 0, _wait},
+	{"wipe_table", "<device>", 0, -1, 1, _error_device},
 	{NULL, NULL, 0, 0, 0, NULL}
 };
 
@@ -3125,7 +3126,7 @@ static void _usage(FILE *out)
 	fprintf(out, "Table_file contents may be supplied on stdin.\n");
 	fprintf(out, "Options are: devno, devname, blkdevname.\n");
 	fprintf(out, "Tree specific options are: ascii, utf, vt100; compact, inverted, notrunc;\n"
-		     "                           blkdevname, [no]device, active, open, rw and uuid.\n");
+		     "             blkdevname, [no]device, status, table, active, open, rw and uuid.\n");
 	fprintf(out, "\n");
 }
 
-- 
2.1.3


