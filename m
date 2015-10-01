From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  1 Oct 2015 13:03:59 +0000 (UTC)
Subject: master - man: update dmsetup and dmstats pages
Message-ID: <20151001130359.CAC7760331@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=867a36b4197e2abe6efd3b16e229590eedc566a3
Commit:        867a36b4197e2abe6efd3b16e229590eedc566a3
Parent:        a139275eca4fadca4a456fd27e8b2ba30d7d2c02
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 23 11:25:00 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 1 15:03:12 2015 +0200

man: update dmsetup and dmstats pages

Try to provide properly rendered pages no just with
plain 'man' but also for:

man -Tps
man -Thtml
man2html
---
 man/dmsetup.8.in | 1039 +++++++++++++++++++++++++++++++++---------------------
 man/dmstats.8.in |  890 ++++++++++++++++++++++++----------------------
 2 files changed, 1099 insertions(+), 830 deletions(-)

diff --git a/man/dmsetup.8.in b/man/dmsetup.8.in
index eff805a..183f4fc 100644
--- a/man/dmsetup.8.in
+++ b/man/dmsetup.8.in
@@ -1,171 +1,378 @@
 .TH DMSETUP 8 "Apr 06 2006" "Linux" "MAINTENANCE COMMANDS"
+.
 .SH NAME
+.
 dmsetup \(em low level logical volume management
+.
 .SH SYNOPSIS
+.
+.\".nh
 .ad l
 .PD 0
+.HP 9
+.B dmsetup
+.de CMD_CLEAR
+.  BR clear
+.  IR device_name
+..
+.CMD_CLEAR
+.
+.HP
+.B dmsetup
+.de CMD_CREATE
+.  ad l
+.  BR create
+.  IR device_name
+.  RB [ -u | \-\-uuid
+.  IR uuid ]
+.  RB \%[ \-\-addnodeoncreate | \-\-addnodeonresume ]
+.  RB \%[ \-n | \-\-notable | \-\-table
+.  RI \%{ table | table_file }]
+.  RB [ \-\-readahead
+.  RB \%{[ + ] \fIsectors | auto | none }]
+.  ad b
+..
+.CMD_CREATE
+.
+.HP
+.B dmsetup
+.de CMD_DEPS
+.  ad l
+.  BR deps
+.  RB [ \-o
+.  IR options ]
+.  RI [ device_name ]
+.  ad b
+..
+.CMD_DEPS
+.
+.HP
+.B dmsetup
+.de CMD_HELP
+.  BR help
+.  RB [ \-c | \-C | \-\-columns ]
+..
+.CMD_HELP
+.
+.HP
+.B dmsetup
+.de CMD_INFO
+.  BR info
+.  RI [ device_name ]
+..
+.CMD_INFO
+.
+.HP
+.B dmsetup
+.de CMD_INFOLONG
+.  ad l
+.  BR info
+.  BR \-c | \-C | \-\-columns
+.  RB [ \-\-count
+.  IR count ]
+.  RB [ \-\-interval
+.  IR seconds ]
+.  RB \%[ \-\-nameprefixes ]
+.  RB \%[ \-\-noheadings ]
+.  RB [ \-o
+.  IR fields ]
+.  RB [ \-O | \-\-sort
+.  IR sort_fields ]
+.  RB [ \-\-separator
+.  IR separator ]
+.  RI [ device_name ]
+.  ad b
+..
+.CMD_INFOLONG
+.
+.HP
+.B dmsetup
+.de CMD_LOAD
+.  ad l
+.  BR load
+.  IR device_name
+.  RB [ \-\-table
+.  RI { table | table_file }]
+.  ad b
+..
+.CMD_LOAD
+.
+.HP
+.B dmsetup
+.de CMD_LS
+.  ad l
+.  BR ls
+.  RB [ \-\-target
+.  IR target_type ]
+.  RB [ \-\-exec
+.  IR command ]
+.  RB [ \-\-tree ]
+.  RB [ \-o
+.  IR options ]
+.  ad b
+..
+.CMD_LS
+.
+.HP
+.B dmsetup
+.de CMD_MANGLE
+.  BR mangle
+.  RI [ device_name ]
+..
+.CMD_MANGLE
+.
+.HP
+.B dmsetup
+.de CMD_MESSAGE
+.  BR message
+.  IR device_name
+.  IR sector
+.  IR message
+..
+.CMD_MESSAGE
+.
+.HP
+.B dmsetup
+.de CMD_MKNODES
+.  BR mknodes
+.  RI [ device_name ]
+..
+.CMD_MKNODES
+.
+.HP
+.B dmsetup
+.de CMD_RELOAD
+.  ad l
+.  BR reload
+.  IR device_name
+.  RB [ \-\-table
+.  RI { table | table_file }]
+.  ad b
+..
+.CMD_RELOAD
+.
+.HP
+.B dmsetup
+.de CMD_REMOVE
+.  ad l
+.  BR remove
+.  RB [ \-f | \-\-force ]
+.  RB [ \-\-retry ]
+.  RB [ \-\-deferred ]
+.  IR device_name
+.  ad b
+..
+.CMD_REMOVE
+.
+.HP
+.B dmsetup
+.de CMD_REMOVE_ALL
+.  BR remove_all
+.  RB [ \-f | \-\-force ]
+.  RB [ \-\-deferred ]
+..
+.CMD_REMOVE_ALL
+.
+.HP
+.B dmsetup
+.de CMD_RENAME
+.  BR rename
+.  IR device_name
+.  IR new_name
+..
+.CMD_RENAME
+.
+.HP
+.B dmsetup
+.de CMD_RENAME_UUID
+.  BR rename
+.  IR device_name
+.  BR \-\-setuuid
+.  IR uuid
+..
+.CMD_RENAME_UUID
+.
+.HP
+.B dmsetup
+.de CMD_RESUME
+.  ad l
+.  BR resume
+.  IR device_name
+.  RB [ \-\-addnodeoncreate | \-\-addnodeonresume ]
+.  RB [ \-\-noflush ]
+.  RB [ \-\-nolockfs ]
+.  RB \%[ \-\-readahead
+.  RB \%{[ + ] \fIsectors | auto | none }]
+.  ad b
+..
+.CMD_RESUME
+.
+.HP
+.B dmsetup
+.de CMD_SETGEOMETRY
+.  ad l
+.  BR setgeometry
+.  IR device_name
+.  IR cyl
+.  IR head
+.  IR sect
+.  IR start
+.  ad b
+..
+.CMD_SETGEOMETRY
+.
+.HP
+.B dmsetup
+.de CMD_SPLITNAME
+.  BR splitname
+.  IR device_name
+.  RI [ subsystem ]
+..
+.CMD_SPLITNAME
+.
+.HP
+.B dmsetup
+.de CMD_STATS
+.  BR stats
+.  IR command
+.  RI [ options ]
+..
+.CMD_STATS
+.
+.HP
+.B dmsetup
+.de CMD_STATUS
+.  ad l
+.  BR status
+.  RB [ \-\-target
+.  IR target_type ]
+.  RB [ \-\-noflush ]
+.  RI [ device_name ]
+.  ad b
+..
+.CMD_STATUS
+.
+.HP
+.B dmsetup
+.de CMD_SUSPEND
+.  ad l
+.  BR suspend
+.  RB [ \-\-nolockfs ]
+.  RB [ \-\-noflush ]
+.  IR device_name
+.  ad b
+..
+.CMD_SUSPEND
+.
+.HP
+.B dmsetup
+.de CMD_TABLE
+.  ad l
+.  BR table
+.  RB [ \-\-target
+.  IR target_type ]
+.  RB [ \-\-showkeys ]
+.  RI [ device_name ]
+.  ad b
+..
+.CMD_TABLE
+.
+.HP
+.B dmsetup
+.de CMD_TARGETS
+.  BR targets
+..
+.CMD_TARGETS
+.
+.HP
+.B dmsetup
+.de CMD_UDEVCOMPLETE
+.  BR udevcomplete
+.  IR cookie
+..
+.CMD_UDEVCOMPLETE
+.
+.HP
+.B dmsetup
+.de CMD_UDEVCOMPLETE_ALL
+.  BR udevcomplete_all
+.  RI [ age_in_minutes ]
+..
+.CMD_UDEVCOMPLETE_ALL
+.
+.HP
+.B dmsetup
+.de CMD_UDEVCOOKIES
+.  BR udevcookie
+..
+.CMD_UDEVCOOKIES
+.
+.HP
+.B dmsetup
+.de CMD_UDEVCTEATECOOKIE
+.  BR udevcreatecookie
+..
+.CMD_UDEVCTEATECOOKIE
+.
+.HP
+.B dmsetup
+.de CMD_UDEVFLAGS
+.  BR udevflags
+.  IR cookie
+..
+.CMD_UDEVFLAGS
+.
+.HP
+.B dmsetup
+.de CMD_UDEVRELEASECOOKIE
+.  BR udevreleasecookie
+.  RI [ cookie ]
+..
+.CMD_UDEVRELEASECOOKIE
+.
+.HP
+.B dmsetup
+.de CMD_VERSION
+.  BR version
+..
+.CMD_VERSION
+.
+.HP
+.B dmsetup
+.de CMD_WAIT
+.  ad l
+.  BR wait
+.  RB [ \-\-noflush ]
+.  IR device_name
+.  RI [ event_nr ]
+.  ad b
+..
+.CMD_WAIT
+.
+.HP
+.B dmsetup
+.de CMD_WIPE_TABLE
+.  ad l
+.  BR wipe_table
+.  IR device_name
+.  RB [ \-f | \-\-force ]
+.  RB [ \-\-noflush ]
+.  RB [ \-\-nolockfs ]
+.  ad b
+..
+.CMD_WIPE_TABLE
+.PD
+.P
 .HP
-.B dmsetup clear
-.I device_name
-.HP
-.B dmsetup create
-.I device_name
-.RB [ \-\-addnodeoncreate | \-\-addnodeonresume ]
-.RB [ \-\-readahead
-.RB {[ + ] \fIsectors | auto | none }]
-.RB [ \-u
-.IR uuid ]
-.RB [ \-n | \-\-notable | \-\-table
-.RI { table | table_file }]
-.HP
-.B dmsetup deps
-.RB [ \-o
-.IR options ]
-.RI [ device_name ]
-.HP
-.B dmsetup help
-.RB [ \-c | \-C | \-\-columns ]
-.HP
-.B dmsetup info
-.RI [ device_name ]
-.HP
-.B dmsetup info
-.BR \-c | \-C | \-\-columns
-.RB [ \-\-count
-.IR count ]
-.RB [ \-\-interval
-.IR seconds ]
-.RB [ \-\-nameprefixes ]
-.RB [ \-\-noheadings ]
-.RB [ \-o
-.IR fields ]
-.RB [ \-O | \-\-sort
-.IR sort_fields ]
-.RB [ \-S | \-\-select
-.IR selection ]
-.RB [ \-\-separator
-.IR separator ]
-.RI [ device_name ]
-.HP
-.B dmsetup load
-.I device_name
-.RB [ \-\-table
-.RI { table | table_file }]
-.HP
-.B dmsetup ls
-.RB [ \-\-target
-.IR target_type ]
-.RB [ \-\-exec
-.IR command ]
-.RB [ \-\-tree ]
-.RB [ \-o
-.IR options ]
-.HP 
-.B dmsetup message
-.I device_name sector message
-.HP
-.B dmsetup mknodes
-.RI [ device_name ]
-.HP
-.B dmsetup mangle
-.RI [ device_name ]
-.HP
-.B dmsetup reload
-.I device_name
-.RB [ \-\-table
-.RI { table | table_file }]
-.HP
-.B dmsetup remove
-.RB [ \-f | \-\-force ]
-.RB [ \-\-retry ]
-.RB [ \-\-deferred ]
-.I device_name
-.HP
-.B dmsetup remove_all
-.RB [ \-f | \-\-force ]
-.RB [ \-\-deferred ]
-.HP
-.B dmsetup rename
-.I device_name new_name
-.HP
-.B dmsetup rename
-.I device_name
-.B \-\-setuuid
-.I uuid
-.HP
-.B dmsetup resume
-.I device_name
-.RB [ \-\-addnodeoncreate | \-\-addnodeonresume ]
-.RB [ \-\-readahead
-.RB {[ + ] \fIsectors | auto | none }]
-.HP
-.B dmsetup setgeometry
-.I device_name cyl head sect start
-.HP
-.B dmsetup splitname
-.I device_name
-.RI [ subsystem ]
-.HP
-.B dmsetup stats
-.I command
-.RI [ options ]
-.HP
-.B dmsetup status
-.RB [ \-\-target
-.IR target_type ]
-.RB [ \-\-noflush ]
-.RI [ device_name ]
-.HP
-.B dmsetup suspend
-.RB [ \-\-nolockfs ]
-.RB [ \-\-noflush ]
-.I device_name
-.HP
-.B dmsetup table
-.RB [ \-\-target
-.IR target_type ]
-.RB [ \-\-showkeys ]
-.RI [ device_name ]
-.HP
-.B dmsetup targets
-.HP
-.B dmsetup udevcomplete
-.I cookie
-.HP
-.B dmsetup udevcomplete_all
-.RI [ age_in_minutes ]
-.HP
-.B dmsetup udevcookies
-.HP
-.B dmsetup udevcreatecookie
-.HP
-.B dmsetup udevflags
-.I cookie
-.HP
-.B dmsetup udevreleasecookie
-.RI [ cookie ]
-.HP
-.B dmsetup version
-.HP
-.B dmsetup wait
-.RB [ \-\-noflush ]
-.I device_name
-.RI [ event_nr ]
-.HP
-.B dmsetup wipe_table
-.I device_name
-.RB [ \-f | \-\-force ]
-.RB [ \-\-noflush ]
-.RB [ \-\-nolockfs ]
-.HP
-.B devmap_name
-.I major minor
+.PD 0
+.B devmap_name \fImajor minor
 .HP
-.B devmap_name
-.I major:minor
-.ad b
+.B devmap_name \fImajor:minor
 .PD
+.ad b
+.
 .SH DESCRIPTION
+.
 dmsetup manages logical devices that use the device-mapper driver.
 Devices are created by loading a table that specifies a target for
 each sector (512 bytes) in the logical device.
@@ -173,166 +380,235 @@ each sector (512 bytes) in the logical device.
 The first argument to dmsetup is a command.
 The second argument is the logical device name or uuid.
 
-Invoking the command as \fBdevmap_name\fP is equivalent to
-.br
-\fBdmsetup info \-c \-\-noheadings \-j \fImajor\fB \-m \fIminor\fP.
+Invoking the dmsetup tool as \fBdevmap_name\fP
+(which is not normally distributed and is supported
+only for historical reasons) is equivalent to
+.BI \%dmsetup\ info\ \-c\ \-\-noheadings\ \-j \ major\  \-m \ minor \c
+\fR.
+.\" dot above here fixes -Thtml rendering for next HP option
+.
 .SH OPTIONS
-.TP
-.B \-\-addnodeoncreate
-Ensure /dev/mapper node exists after dmsetup create.
-.TP
-.B \-\-addnodeonresume
-Ensure /dev/mapper node exists after dmsetup resume (default with udev).
-.TP
-.B \-\-checks
+.
+.HP
+.BR \-\-addnodeoncreate
+.br
+Ensure \fI/dev/mapper\fP node exists after \fBdmsetup create\fP.
+.
+.HP
+.BR \-\-addnodeonresume
+.br
+Ensure \fI/dev/mapper\fP node exists after \fBdmsetup resume\fP (default with udev).
+.
+.HP
+.BR \-\-checks
+.br
 Perform additional checks on the operations requested and report
 potential problems.  Useful when debugging scripts.
 In some cases these checks may slow down operations noticeably.
-.TP
+.
+.HP
 .BR \-c | \-C | \-\-columns
+.br
 Display output in columns rather than as Field: Value lines.
-.TP
-.B \-\-count \fIcount
+.
+.HP
+.BR \-\-count
+.IR count
+.br
 Specify the number of times to repeat a report. Set this to zero
 continue until interrupted.  The default interval is one second.
-.TP
+.
+.HP
 .BR \-f | \-\-force
+.br
 Try harder to complete operation.
-.TP
+.
+.HP
 .BR \-h | \-\-help
+.br
 Outputs a summary of the commands available, optionally including
 the list of report fields (synonym with \fBhelp\fP command).
-.TP
-.B \-\-inactive
+.
+.HP
+.BR \-\-inactive
+.br
 When returning any table information from the kernel report on the
 inactive table instead of the live table.
 Requires kernel driver version 4.16.0 or above.
-.TP
-.B \-\-interval \fIseconds
+.
+.HP
+.BR \-\-interval
+.IR seconds
+.br
 Specify the interval in seconds between successive iterations for
 repeating reports. If \fB\-\-interval\fP is specified but \fB\-\-count\fP
 is not, reports will continue to repeat until interrupted.
 The default interval is one second.
-.TP
-.BR \-\-manglename \ { none | hex | auto }
+.
+.HP
+.BR \-\-manglename
+.RB { auto | hex | none }
+.br
 Mangle any character not on a whitelist using mangling_mode when
 processing device-mapper device names and UUIDs. The names and UUIDs
 are mangled on input and unmangled on output where the mangling mode
 is one of:
-\fBnone\fP (no mangling),
-\fBhex\fP (always do the mangling) and
 \fBauto\fP (only do the mangling if not mangled yet, do nothing
-if already mangled, error on mixed)
+if already mangled, error on mixed),
+\fBhex\fP (always do the mangling) and
+\fBnone\fP (no mangling).
 Default mode is \fB#DEFAULT_MANGLING#\fP.
 Character whitelist: 0-9, A-Z, a-z, #+-.:=@_. This whitelist is
 also supported by udev. Any character not on a whitelist is replaced
 with its hex value (two digits) prefixed by \\x.
 Mangling mode could be also set through
-.B DM_DEFAULT_NAME_MANGLING_MODE
+\fBDM_DEFAULT_NAME_MANGLING_MODE\fP
 environment variable.
-.TP
-.BR \-j | \-\-major\ \fImajor
+.
+.HP
+.BR \-j | \-\-major
+.IR major
+.br
 Specify the major number.
-.TP
-.BR \-m | \-\-minor\ \fIminor
+.
+.HP
+.BR \-m | \-\-minor
+.IR minor
+.br
 Specify the minor number.
-.TP
+.
+.HP
 .BR \-n | \-\-notable
+.br
 When creating a device, don't load any table.
-.TP
+.
+.HP
 .BR \-\-nameprefixes
+.br
 Add a "DM_" prefix plus the field name to the output.  Useful with
 \fB\-\-noheadings\fP to produce a list of
 field=value pairs that can be used to set environment variables
 (for example, in
 .BR udev (7)
 rules).
-.TP
+.
+.HP
 .BR \-\-noheadings
 Suppress the headings line when using columnar output.
-.TP
-.B \-\-noflush
+.
+.HP
+.BR \-\-noflush
 Do not flush outstading I/O when suspending a device, or do not
 commit thin-pool metadata when obtaining thin-pool status.
-.TP
-.B \-\-nolockfs
+.
+.HP
+.BR \-\-nolockfs
+.br
 Do not attempt to synchronize filesystem eg, when suspending a device.
-.TP
-.B \-\-noopencount
+.
+.HP
+.BR \-\-noopencount
+.br
 Tell the kernel not to supply the open reference count for the device.
-.TP
-.B \-\-noudevrules
+.
+.HP
+.BR \-\-noudevrules
+.br
 Do not allow udev to manage nodes for devices in device-mapper directory.
-.TP
-.B \-\-noudevsync
+.
+.HP
+.BR \-\-noudevsync
+.br
 Do not synchronise with udev when creating, renaming or removing devices.
-.TP
+.
+.HP
 .BR \-o | \-\-options
+.IR options
+.br
 Specify which fields to display.
-.TP
-.BR \-\-readahead \ {[ + ] \fIsectors | auto | none }
+.
+.HP
+.BR \-\-readahead
+.RB {[ + ] \fIsectors | auto | none }
+.br
 Specify read ahead size in units of sectors.
 The default value is \fBauto\fP which allows the kernel to choose
 a suitable value automatically.  The \fB+\fP prefix lets you
 specify a minimum value which will not be used if it is
 smaller than the value chosen by the kernel.
 The value \fBnone\fP is equivalent to specifying zero.
-.TP
+.
+.HP
 .BR \-r | \-\-readonly
+.br
 Set the table being loaded read-only.
-.TP
-.BR \-S | \-\-select \ \fIselection
+.
+.HP
+.BR \-S | \-\-select
+.IR selection
+.br
 Display only rows that match \fIselection\fP criteria. All rows are displayed
 with the additional "selected" column (\fB-o selected\fP) showing 1 if the row
 matches the \fIselection\fP and 0 otherwise. The selection criteria are defined
 by specifying column names and their valid values while making use of
 supported comparison operators. As a quick help and to see full list of
 column names that can be used in selection and the set of supported
-selection operators, check the output of \fBdmsetup info -c -S help\fP
+selection operators, check the output of \fBdmsetup\ info\ -c\ -S\ help\fP
 command.
-.TP
-.IR \fB\-\-table \  table
+.
+.HP
+.BR \-\-table
+.IR table
+.br
 Specify a one-line table directly on the command line.
 See below for more information on the table format.
-.TP
-.B \-\-udevcookie \fIcookie
+.
+.HP
+.BR \-\-udevcookie
+.IR cookie
+.br
 Use cookie for udev synchronisation.
 Note: Same cookie should be used for same type of operations i.e. creation of
 multiple different devices. It's not adviced to combine different
 operations on the single device.
-.TP
+.
+.HP
 .BR \-u | \-\-uuid
+.br
 Specify the \fIuuid\fP.
-.TP
+.
+.HP
 .BR \-y | \-\-yes
+.br
 Answer yes to all prompts automatically.
-.TP
-.BR \-v | \-\-verbose \ [ \-v | \-\-verbose ]
+.
+.HP
+.BR \-v | \-\-verbose
+.RB [ \-v | \-\-verbose ]
+.br
 Produce additional output.
-.TP
-.B \-\-verifyudev
+.
+.HP
+.BR \-\-verifyudev
+.br
 If udev synchronisation is enabled, verify that udev operations get performed
 correctly and try to fix up the device nodes afterwards if not.
-.TP
-.B \-\-version
+.
+.HP
+.BR \-\-version
+.br
 Display the library and kernel driver version.
 .br
+.
 .SH COMMANDS
+.
 .HP
-.B clear
-.I device_name
+.CMD_CLEAR
 .br
 Destroys the table in the inactive table slot for device_name.
+.
 .HP
-.B create
-.I device_name
-.RB [ \-u
-.IR uuid ]
-.RB [ \-\-addnodeoncreate | \-\-addnodeonresume ]
-.RB [ \-n | \-\-notable | \-\-table
-.RI { table | table_file }]
-.RB [ \-\-readahead
-.RB {[ + ] \fIsectors | auto | none }]
+.CMD_CREATE
 .br
 Creates a device with the given name.
 If \fItable\fP or \fItable_file\fP is supplied, the table is loaded and made live.
@@ -340,28 +616,26 @@ Otherwise a table is read from standard input unless \fB\-\-notable\fP is used.
 The optional \fIuuid\fP can be used in place of
 device_name in subsequent dmsetup commands.
 If successful the device will appear in table and for live
-device the node /dev/mapper/\fIdevice_name\fP is created.
+device the node \fI/dev/mapper/device_name\fP is created.
 See below for more information on the table format.
+.
 .HP
-.B deps
-.RB [ \-o
-.IR options ]
-.RI [ device_name ]
+.CMD_DEPS
 .br
 Outputs a list of devices referenced by the live table for the specified
 device. Device names on output can be customised by following \fIoptions\fP:
 \fBdevno\fP (major and minor pair, used by default),
 \fBblkdevname\fP (block device name),
 \fBdevname\fP (map name for device-mapper devices, equal to blkdevname otherwise).
+.
 .HP
-.B help
-.RB [ \-c | \-C | \-\-columns ]
+.CMD_HELP
 .br
 Outputs a summary of the commands available, optionally including
 the list of report fields.
+.
 .HP
-.B info
-.RI [ device_name ]
+.CMD_INFO
 .br
 Outputs some brief information about the device in the form:
 .RS
@@ -376,45 +650,38 @@ Outputs some brief information about the device in the form:
 .RE
 .RE
 .HP
-.B info
-.BR \-c | \-C | \-\-columns
-.RB [ \-\-count
-.IR count ]
-.RB [ \-\-interval
-.IR seconds ]
-.RB [ \-\-nameprefixes ]
-.RB [ \-\-noheadings ]
-.RB [ \-o
-.IR fields ]
-.RB [ \-O | \-\-sort
-.IR sort_fields ]
-.RB [ \-\-separator
-.IR separator ]
-.RI [ device_name ]
+.CMD_INFOLONG
 .br
 Output you can customise.
 Fields are comma-separated and chosen from the following list:
-name, major, minor, attr, open, segments, events, uuid.
-Attributes are: (L)ive, (I)nactive, (s)uspended, (r)ead-only, read-(w)rite.
+.BR name ,
+.BR major ,
+.BR minor ,
+.BR attr ,
+.BR open ,
+.BR segments ,
+.BR events ,
+.BR uuid .
+Attributes are:
+.RI ( L )ive,
+.RI ( I )nactive,
+.RI ( s )uspended,
+.RI ( r )ead-only,
+.RI read-( w )rite.
 Precede the list with '\fB+\fP' to append
 to the default selection of columns instead of replacing it.
-Precede any sort_field with '\fB-\fP' for a reverse sort on that column.
+Precede any sort field with '\fB-\fP' for a reverse sort on that column.
+.
 .HP
-.B ls
-.RB [ \-\-target
-.IR target_type ]
-.RB [ \-\-exec
-.IR command ]
-.RB [ \-\-tree ]
-.RB [ \-o
-.IR options ]
+.CMD_LS
 .br
 List device names.  Optionally only list devices that have at least
 one target of the specified type.  Optionally execute a command for
 each device.  The device name is appended to the supplied command.
-Device names on output can be customised by following options: devno (major
-and minor pair, used by default), blkdevname (block device name),
-devname (map name for device-mapper devices, equal to blkdevname otherwise).
+Device names on output can be customised by following options:
+\fBdevno\fP (major and minor pair, used by default),
+\fBblkdevname\fP (block device name),
+\fBdevname\fP (map name for device-mapper devices, equal to blkdevname otherwise).
 \fB\-\-tree\fP displays dependencies between devices as a tree.
 It accepts a comma-separate list of \fIoptions\fP.
 Some specify the information displayed against each node:
@@ -424,17 +691,16 @@ Some specify the information displayed against each node:
 Others specify how the tree is displayed:
 .BR ascii ", " utf ", " vt100 ;
 .BR compact ", " inverted ", " notrunc .
+.
 .HP
-.BR load | reload
-.I device_name
-.RB [ \-\-table
-.RI { table | table_file }]
+.BR load | \c
+.CMD_RELOAD
 .br
 Loads \fItable\fP or \fItable_file\fP into the inactive table slot for device_name.
 If neither is supplied, reads a table from standard input.
+.
 .HP
-.B mangle
-.RI [ device_name ]
+.CMD_MANGLE
 .br
 Ensure existing device-mapper \fIdevice_name\fP and UUID is in the correct mangled
 form containing only whitelisted characters (supported by udev) and do
@@ -444,25 +710,22 @@ names and not for device UUIDs because the kernel does not allow changing
 the UUID of active devices. Any incorrect UUIDs are reported only and they
 must be manually corrected by deactivating the device first and then
 reactivating it with proper mangling mode used (see also \fB\-\-manglename\fP).
+.
 .HP
-.B message 
-.I device_name sector message
+.CMD_MESSAGE
 .br
 Send message to target. If sector not needed use 0.
+.
 .HP
-.B mknodes
-.RI [ device_name ]
+.CMD_MKNODES
 .br
-Ensure that the node in /dev/mapper for device_name is correct.
-If no device_name is supplied, ensure that all nodes in /dev/mapper
+Ensure that the node in \fI/dev/mapper\fP for \fIdevice_name\fP is correct.
+If no device_name is supplied, ensure that all nodes in \fI/dev/mapper\fP
 correspond to mapped devices currently loaded by the device-mapper kernel
 driver, adding, changing or removing nodes as necessary.
+.
 .HP
-.B remove
-.RB [ \-f | \-\-force ]
-.RB [ \-\-retry ]
-.RB [ \-\-deferred ]
-.I device_name
+.CMD_REMOVE
 .br
 Removes a device.  It will no longer be visible to dmsetup.  Open devices
 cannot be removed, but adding \fB\-\-force\fP will replace the table with one
@@ -477,10 +740,9 @@ Do NOT combine
 \fB\-\-force\fP and \fB\-\-udevcookie\fP, as udev may start to process udev
 rules in the middle of error target replacement and result in nondeterministic
 result.
+.
 .HP
-.B remove_all
-.RB [ \-f | \-\-force ]
-.RB [ \-\-deferred ]
+.CMD_REMOVE_ALL
 .br
 Attempts to remove all device definitions i.e. reset the driver.  This also runs
 \fBmknodes\fP afterwards.  Use with care!  Open devices cannot be removed, but
@@ -489,42 +751,34 @@ adding \fB\-\-force\fP will replace the table with one that fails all I/O.
 will be removed when the last user closes it.  The deferred removal feature is
 supported since version 4.27.0 of the device-mapper driver available in
 upstream kernel version 3.13.
+.
 .HP
-.B rename
-.I device_name new_name
+.CMD_RENAME
 .br
 Renames a device.
+.
 .HP
-.B rename
-.I device_name
-.B \-\-setuuid
-.I uuid
+.CMD_RENAME_UUID
 .br
 Sets the uuid of a device that was created without a uuid.
 After a uuid has been set it cannot be changed.
+.
 .HP
-.B resume
-.I device_name
-.RB [ \-\-addnodeoncreate | \-\-addnodeonresume ]
-.RB [ \-\-nolockfs ]
-.RB [ \-\-noflush ]
-.RB [ \-\-readahead
-.RB {[ + ] \fIsectors | auto | none }]
+.CMD_RESUME
 .br
 Un-suspends a device.
 If an inactive table has been loaded, it becomes live.
 Postponed I/O then gets re-queued for processing.
+.
 .HP
-.B setgeometry 
-.I device_name cyl head sect start
+.CMD_SETGEOMETRY
 .br
 Sets the device geometry to C/H/S.
+.
 .HP
-.B splitname
-.I device_name
-.RI [ subsystem ]
+.CMD_SPLITNAME
 .br
-Splits given device name into subsystem constituents.
+Splits given \fIdevice name\fP into \fIsubsystem\fP constituents.
 The default subsystem is LVM.
 LVM currently generates device names by concatenating the names of the Volume
 Group, Logical Volume and any internal Layer with a hyphen as separator.
@@ -533,30 +787,22 @@ The precise encoding might change without notice in any future
 release, so we recommend you always decode using the current version of
 this command.
 .HP
-.B stats
-.I command
-.RI [ options ]
+.BR stats " " \fIcommand " [" \fIoptions ]
 .br
 Manages IO statistics regions for devices.
-See  
+See
 .BR dmstats (8)
 for more details.
 .HP
-.B status
-.RB [ \-\-target
-.IR target_type ]
-.RB [ \-\-noflush ]
-.RI [ device_name ]
+.CMD_STATS
 .br
 Outputs status information for each of the device's targets.
 With \fB\-\-target\fP, only information relating to the specified target type
 any is displayed.  With \fB\-\-noflush\fP, the thin target (from version 1.3.0)
 doesn't commit any outstanding changes to disk before reporting its statistics.
+
 .HP
-.B suspend
-.RB [ \-\-nolockfs ]
-.RB [ \-\-noflush ]
-.I device_name
+.CMD_SUSPEND
 .br
 Suspends a device.  Any I/O that has already been mapped by the device
 but has not yet completed will be flushed.  Any further I/O to that
@@ -566,12 +812,9 @@ an attempt will be made to sync it first unless \fB\-\-nolockfs\fP is specified.
 Some targets such as recent (October 2006) versions of multipath may support
 the \fB\-\-noflush\fP option.  This lets outstanding I/O that has not yet reached the
 device to remain unflushed.
+.
 .HP
-.B table
-.RB [ \-\-target
-.IR target_type ]
-.RB [ \-\-showkeys ]
-.RI [ device_name ]
+.CMD_TABLE
 .br
 Outputs the current table for the device in a format that can be fed
 back in using the create or load commands.
@@ -579,28 +822,31 @@ With \fB\-\-target\fP, only information relating to the specified target type
 is displayed.
 Encryption keys are suppressed in the table output for the crypt
 target unless the \fB\-\-showkeys\fP parameter is supplied.
+.
 .HP
-.B targets
+.CMD_TARGETS
 .br
 Displays the names and versions of the currently-loaded targets.
+.
 .HP
-.B udevcomplete
-.I cookie
+.CMD_UDEVCOMPLETE
 .br
 Wake any processes that are waiting for udev to complete processing the specified cookie.
+.
 .HP
-.B udevcomplete_all
-.RI [ age_in_minutes ]
+.CMD_UDEVCOMPLETE_ALL
 .br
 Remove all cookies older than the specified number of minutes.
 Any process waiting on a cookie will be resumed immediately.
+.
 .HP
-.B udevcookies
+.CMD_UDEVCOOKIES
 .br
 List all existing cookies. Cookies are system-wide semaphores with keys
 prefixed by two predefined bytes (0x0D4D).
+.
 .HP
-.B udevcreatecookie
+.CMD_UDEVCREATECOOKIE
 .br
 Creates a new cookie to synchronize actions with udev processing.
 The output is a cookie value. Normally we don't need to create cookies since
@@ -612,33 +858,32 @@ of the dmsetup process as \fBDM_UDEV_COOKIE\fP variable and it will be used auto
 with all subsequent commands until it is unset.
 Invoking this command will create system-wide semaphore that needs to be cleaned
 up explicitly by calling udevreleasecookie command.
+.
 .HP
-.B udevflags
-.I cookie
+.CMD_UDEVFLAGS
 .br
-Parses given cookie value and extracts any udev control flags encoded.
+Parses given \fIcookie\fP value and extracts any udev control flags encoded.
 The output is in environment key format that is suitable for use in udev
 rules. If the flag has its symbolic name assigned then the output is
-DM_UDEV_FLAG_<flag_name>='1', DM_UDEV_FLAG<flag_position>='1' otherwise.
+DM_UDEV_FLAG_<flag_name> = '1', DM_UDEV_FLAG<flag_position> = '1' otherwise.
 Subsystem udev flags don't have symbolic names assigned and these ones are
-always reported as DM_SUBSYSTEM_UDEV_FLAG<flag_position>='1'. There are
+always reported as DM_SUBSYSTEM_UDEV_FLAG<flag_position> = '1'. There are
 16 udev flags altogether.
+.
 .HP
-.B udevreleasecookie
-.RI [ cookie ]
+.CMD_UDEVRELEASECOOKIE
 .br
 Waits for all pending udev processing bound to given cookie value and clean up
 the cookie with underlying semaphore. If the cookie is not given directly,
 the command will try to use a value defined by \fBDM_UDEV_COOKIE\fP environment variable.
+.
 .HP
-.B version
+.CMD_VERSION
 .br
 Outputs version information.
+.
 .HP
-.B wait
-.RB [ \-\-noflush ]
-.I device_name
-.RI [ event_nr ]
+.CMD_WAIT
 .br
 Sleeps until the event counter for device_name exceeds event_nr.
 Use \fB\-v\fP to see the event number returned.
@@ -646,39 +891,30 @@ To wait until the next event is triggered, use \fBinfo\fP to find
 the last event number.
 With \fB\-\-noflush\fP, the thin target (from version 1.3.0) doesn't commit
 any outstanding changes to disk before reporting its statistics.
+.
 .HP
-.B wipe_table
-.I device_name
-.RB [ \-f | \-\-force ]
-.RB [ \-\-noflush ]
-.RB [ \-\-nolockfs ]
+.CMD_WIPE_TABLE
 .br
 Wait for any I/O in-flight through the device to complete, then
 replace the table with a new table that fails any new I/O
 sent to the device.  If successful, this should release any devices
 held open by the device's table(s).
+.
 .SH TABLE FORMAT
+.
 Each line of the table specifies a single target and is of the form:
-.P
+.sp
 .I logical_start_sector num_sectors
 .B target_type
 .I target_args
-.P
-Simple target types and \fItarget_args\fP include:
-.HP
-.PD 0
-.B linear
-.I destination_device
-.I start_sector
-.br
+.sp
+Simple target types and target args include:
+.
+.TP
+.B linear \fIdestination_device start_sector
 The traditional linear mapping.
-.HP
-.B striped
-.I num_stripes
-.I chunk_size
-.RI [ destination
-.IR start_sector ]...
-.br
+.TP
+.B striped \fInum_stripes chunk_size \fR[\fIdestination start_sector\fR]...
 Creates a striped area.
 .br
 e.g. striped 2 32 /dev/hda1 0 /dev/hdb1 0
@@ -692,93 +928,78 @@ will map the first chunk (16k) as follows:
  etc.
 .RE
 .RE
-.HP
+.TP
 .B error
-.br
 Errors any I/O that goes to this area.  Useful for testing or
 for creating devices with holes in them.
-.HP
+.TP
 .B zero
-.br
 Returns blocks of zeroes on reads.  Any data written is discarded silently.
-This is a block-device equivalent of the /dev/zero character-device data sink
-described in \fBnull\fP(4).
-.PD
-.HP
+This is a block-device equivalent of the \fI/dev/zero\fP
+character-device data sink described in \fBnull\fP(4).
+.P
 More complex targets include:
-.HP
-.PD 0
+.TP
 .B cache
-.br
 Improves performance of a block device (eg, a spindle) by dynamically
 migrating some of its data to a faster smaller device (eg, an SSD).
-.HP
+.TP
 .B crypt
-.br
 Transparent encryption of block devices using the kernel crypto API.
-.HP
+.TP
 .B delay
-.br
 Delays reads and/or writes to different devices.  Useful for testing.
-.HP
+.TP
 .B flakey
-.br
 Creates a similar mapping to the linear target but
 exhibits unreliable behaviour periodically.
 Useful for simulating failing devices when testing.
-.HP
+.TP
 .B mirror
-.br
 Mirrors data across two or more devices.
-.HP
+.TP
 .B multipath
-.br
 Mediates access through multiple paths to the same device.
-.HP
+.TP
 .B raid
-.br
 Offers an interface to the kernel's software raid driver, md.
-.HP
+.TP
 .B snapshot
-.br
 Supports snapshots of devices.
-.HP
-.BR thin ,\  thin-pool
-.br
+.TP
+.BR thin ", " thin-pool
 Supports thin provisioning of devices and also provides a better snapshot support.
-.PD
 .P
 To find out more about the various targets and their table formats and status
 lines, please read the files in the Documentation/device-mapper directory in
 the kernel source tree.
 (Your distribution might include a copy of this information in the
 documentation directory for the device-mapper package.)
-
+.
 .SH EXAMPLES
-
+.
 # A table to join two disks together
 .br
-.br
 0 1028160 linear /dev/hda 0
 .br
 1028160 3903762 linear /dev/hdb 0
-
-
+.br
 # A table to stripe across the two disks,
 .br
 # and add the spare space from
 .br
 # hdb to the back of the volume
-
+.br
 0 2056320 striped 2 32 /dev/hda 0 /dev/hdb 0
 .br
 2056320 2875602 linear /dev/hdb 1028160
-
+.
 .SH ENVIRONMENT VARIABLES
+.
 .TP
 .B DM_DEV_DIR
 The device directory name.
-Defaults to "/dev" and must be an absolute path.
+Defaults to "\fI/dev\fP" and must be an absolute path.
 .TP
 .B DM_UDEV_COOKIE
 A cookie to use for all relevant commands to synchronize with udev processing.
@@ -787,15 +1008,17 @@ It is an alternative to using \fB\-\-udevcookie\fP option.
 .B DM_DEFAULT_NAME_MANGLING_MODE
 A default mangling mode. Defaults to "\fB#DEFAULT_MANGLING#\fP"
 and it is an alternative to using \fB\-\-manglename\fP option.
-
+.
 .SH AUTHORS
-Original version: Joe Thornber (thornber at redhat.com)
-
+.
+Original version: Joe Thornber <thornber@redhat.com>
+.
 .SH SEE ALSO
+.
 .BR dmstats (8),
 .BR udev (7),
 .BR udevadm (8)
-
-LVM2 resource page https://www.sourceware.org/lvm2/
+.P
+LVM2 resource page: https://www.sourceware.org/lvm2/
 .br
 Device-mapper resource page: http://sources.redhat.com/dm/
diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index 985f3fd..9776aa7 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -1,278 +1,420 @@
 .TH DMSTATS 8 "Jul 25 2015" "Linux" "MAINTENANCE COMMANDS"
+
+.de OPT_PROGRAMS
+.  RB \%[ \-\-allprograms | \-\-programid
+.  IR id ]
+..
+.
+.de OPT_REGIONS
+.  RB \%[ \-\-allregions | \-\-regionid
+.  IR id ]
+..
+.
+.\" Print units suffix, use with arg to print human
+.\" man2html can't handle too many changes per command
+.de UNITS
+.  BR b | B | s | S | k | K | m | M | \c
+.  BR g | G | t | T | p | P | e | E ]
+..
+.
+.\" Print help text for units, use with arg to print human
+.de HELP_UNITS
+.  RB ( b )ytes,
+.  RB ( s )ectors,
+.  RB ( k )ilobytes,
+.  RB ( m )egabytes,
+.  RB ( g )igabytes,
+.  RB ( t )erabytes,
+.  RB ( p )etabytes,
+.  RB ( e )xabytes.
+.  nop Capitalise to use multiples of 1000 (S.I.) instead of 1024.
+..
+.
 .SH NAME
+.
 dmstats \(em device-mapper statistics management
+.
 .SH SYNOPSIS
-.ad l
-.B dmsetup stats
+.
+.B dmsetup
+.B stats
 .I command
 .RB [ options ]
-.HP
+.sp
+.
 .PD 0
+.HP
 .B dmstats
-.I command
-.RI [ device_name | \fB\-\-uuid
-.IR uuid | \fB\-\-major
-.I major
-.B \-\-minor
-.IR minor ]
-.HP
-.B dmstats clear
-.I device_name
-.RB [ \-\-allregions | \-\-regionid
-.IR id ]
-.HP
-.B dmstats create
-.I device_name
-.RB [ \-\-alldevices ]
-.RB [ \-\-areas
-.IR nr_areas | \fB\-\-areasize
-.IR area_size ]
-.RB [ \-\-bounds
-.IR histogram_boundaries ]
-.RB [ \-\-precise ]
-.RB [ \-\-start
-.I  start_sector
-.B  \-\-length
-.IR length | \fB\-\-segments ]
-.RB [ \-\-auxdata
-.IR data ]
-.RB [ \-\-programid
-.IR id ]
-.HP
-.B dmstats delete
-.I device_name
-.RB [ \-\-alldevices ]
-.RB [ \-\-allregions | \-\-regionid
-.IR id ]
-.RB [ \-\-allprograms | \-\-programid
-.IR id ]
-.HP
-.B dmstats help
-.RB [ \-c | \-C | \-\-columns ]
-.HP
-.B dmstats list
-.RI [ device_name ]
-.RB [ \-\-allprograms | \-\-programid
-.IR id ]
-.RB [ \-\-histogram ]
-.RB [ \-\-units
-.IR units ]
-.RB [ \-\-nosuffix ]
-.RB [ \-\-notimesuffix ]
-.RB [ \-v | \-\-verbose \ [ \-v | \-\-verbose ]]
-.HP
-.B dmstats print
-.RI [ device_name ]
-.RB [ \-\-clear ]
-.RB [ \-\-allprograms | \-\-programid
-.IR id ]
-.RB [ \-\-allregions | \-\-regionid
-.IR id ]
+.de CMD_COMMAND
+.  ad l
+.  IR command
+.  RI [ device_name
+.  RB | \-\-uuid
+.  IR uuid | \fB\-\-major
+.  IR major
+.  BR \-\-minor
+.  IR minor ]
+.  ad b
+..
+.CMD_COMMAND
+.
 .HP
-.B dmstats report
-.RI [ device_name ]
-.RB [ \-\-interval
-.IR seconds ]
-.RB [ \-\-count
-.IR count ]
-.RB [ \-\-units
-.IR units ]
-.RB [ \-\-histogram ]
-.RB [ \-\-allprograms ]
-.RB [ \-\-programid
-.IR id ]
-.RB [ \-\-regionid
-.IR id ]
-.RB [ \-O | \-\-sort
-.IR sort_fields ]
-.RB [ \-S | \-\-select
-.IR Selection ]
-.RB [ \-\-units
-.IR units ]
-.RB [ \-\-nosuffix ]
-.RB [ \-\-notimesuffix ]
-.PD
+.B dmstats
+.de CMD_CLEAR
+.  ad l
+.  BR clear
+.  IR device_name
+.  OPT_PROGRAMS
+.  OPT_REGIONS
+.  ad b
+..
+.CMD_CLEAR
+.
+.HP
+.B dmstats
+.de CMD_CREATE
+.  ad l
+.  BR create
+.  IR device_name
+.  RB [ \-\-alldevices ]
+.  RB [ \-\-areas
+.  IR nr_areas | \fB\-\-areasize
+.  IR area_size ]
+.  RB [ \-\-bounds
+.  IR \%histogram_boundaries ]
+.  RB [ \-\-precise ]
+.  RB [ \-\-start
+.  IR start_sector
+.  BR \-\-length
+.  IR length | \fB\-\-segments ]
+.  RB \%[ \-\-auxdata
+.  IR data ]
+.  RB [ \-\-programid
+.  IR id ]
+.  ad b
+..
+.CMD_CREATE
+.
+.HP
+.B dmstats
+.de CMD_DELETE
+.  ad l
+.  BR delete
+.  RI [ device_name ]
+.  RB [ \-\-alldevices ]
+.  OPT_PROGRAMS
+.  OPT_REGIONS
+.  ad b
+..
+.CMD_DELETE
+.
 .HP
+.B dmstats
+.de CMD_HELP
+.  ad l
+.  BR help
+.  RB [ \-c | \-C | \-\-columns ]
+.  ad b
+..
+.CMD_HELP
+.
+.HP
+.B dmstats
+.de CMD_LIST
+.  ad l
+.  BR list
+.  RI [ device_name ]
+.  RB [ \-\-histogram ]
+.  OPT_PROGRAMS
+.  RB [ \-\-units
+.  IR units ]
+.  RB \%[ \-\-nosuffix ]
+.  RB [ \-\-notimesuffix ]
+.  RB \%[ \-v | \-\-verbose [ \-v | \-\-verbose ]]
+.  ad b
+..
+.CMD_LIST
+.
+.HP
+.B dmstats
+.de CMD_PRINT
+.  ad l
+.  BR print
+.  RI [ device_name ]
+.  RB [ \-\-clear ]
+.  OPT_PROGRAMS
+.  OPT_REGIONS
+.  ad b
+..
+.CMD_PRINT
+.
+.HP
+.B dmstats
+.de CMD_REPORT
+.  ad l
+.  BR report
+.  RI [ device_name ]
+.  RB [ \-\-interval
+.  IR seconds ]
+.  RB [ \-\-count
+.  IR count ]
+.  RB [ \-\-units
+.  IR units ]
+.  RB [ \-\-histogram ]
+.  OPT_PROGRAMS
+.  OPT_REGIONS
+.  RB [ \-O | \-\-sort
+.  IR sort_fields ]
+.  RB [ \-S | \-\-select
+.  IR selection ]
+.  RB [ \-\-units
+.  IR units ]
+.  RB [ \-\-nosuffix ]
+.  RB \%[ \-\-notimesuffix ]
+.  ad b
+..
+.CMD_REPORT
+.
+.PD
 .ad b
+.
 .SH DESCRIPTION
+.
 The dmstats program manages IO statistics regions for devices that use
 the device-mapper driver. Statistics regions may be created, deleted,
 listed and reported on using the tool.
 
-The first argument to dmstats is a command.
+The first argument to dmstats is a \fIcommand\fP.
 
-The second argument is the device name, uuid, or major and minor
-numbers.
+The second argument is the \fIdevice name\fP,
+\fIuuid\fP or \fImajor\fP and \fIminor\fP numbers.
 
 Further options permit the selection of regions, output format
 control, and reporting behaviour.
 
-When the program is run using the 'dmstats' alias, the command
+When the program is run using the '\fBdmstats\fP' alias, the command
 \fBmust\fP be the first argument and any switches and options should be
 specified following the command itself. This limitation is not present
-when run as 'dmsetup stats'.
+when run as '\fBdmsetup stats\fP'.
 
 When no device argument is given dmstats will by default operate on all
 device-mapper devices present. The \fBcreate\fP and \fBdelete\fP
-commands require the use of \fB--alldevices\fP when used in this way.
-
+commands require the use of \fB\-\-alldevices\fP when used in this way.
+.
 .SH OPTIONS
-.TP
-.B \-\-alldevices
+.
+.HP
+.BR \-\-alldevices
+.br
 If no device arguments are given allow operation on all devices when
 creating or deleting regions.
-.TP
-.B \-\-allprograms
+.
+.HP
+.BR \-\-allprograms
+.br
 Include regions from all program IDs for list and report operations.
-.TP
-.B \-\-allregions
+.br
+.HP
+.BR \-\-allregions
+.br
 Include all present regions for commands that normally accept a single
 region identifier.
-.TP
-.B \-\-areas \fInr_areas
+.
+.HP
+.BR \-\-areas
+.IR nr_areas
+.br
 Specify the number of statistics areas to create within a new region.
-.TP
-.B \-\-areasize \fIarea_size
+.
+.HP
+.BR \-\-areasize
+.IR area_size \c
+.RB [ \c
+.UNITS
+.br
 Specify the size of areas into which a new region should be divided. An
-optional suffix selects units of bBsSkKmMgGtTpPeE: (b)ytes,
-(s)ectors, (k)ilobytes, (m)egabytes, (g)igabytes, (t)erabytes,
-(p)etabytes, (e)xabytes.  Capitalise to use multiples of 1000 (S.I.)
-instead of 1024.
-.TP
-.B \-\-auxdata \fIaux_data
+optional suffix selects units of:
+.HELP_UNITS
+.
+.HP
+.BR \-\-auxdata
+.IR aux_data
+.br
 Specify auxilliary data (a string) to be stored with a new region.
-.TP
-.B \-\-clear
+.
+.HP
+.BR \-\-clear
+.br
 When printing statistics counters, also atomically reset them to zero.
-.TP
-.B \-\-count \fIcount
+.
+.HP
+.BR \-\-count
+.IR count
+.br
 Specify the iteration count for repeating reports. If the count
 argument is zero reports will continue to repeat until interrupted.
-.TP
-.B \-\-bounds \fIhistogram_boundaries
+.
+.HP
+.BR \-\-bounds
+.IR histogram_boundaries \c
+.RB [ ns | us | ms | s ]
+.br
 Specify the boundaries of a latency histogram to be tracked for the
 region as a comma separated list of latency values. Latency values are
-given in nanoseconds. An optional unit suffix of ns, us, ms, or s may be
-given after each value to specify units of nanoseconds, microseconds,
-miliseconds or seconds respectively.
-.TP
-.B \-\-histogram
+given in nanoseconds. An optional unit suffix of
+.BR ns ,
+.BR us ,
+.BR ms ,
+or \fBs\fP may be given after each value to specify units of
+nanoseconds, microseconds, miliseconds or seconds respectively.
+.
+.HP
+.BR \-\-histogram
+.br
 When used with the \fBreport\fP and \fBlist\fP commands select default
 fields that emphasize latency histogram data.
-.TP
-.B \-\-interval \fIseconds
+.
+.HP
+.BR \-\-interval
+.IR seconds
+.br
 Specify the interval in seconds between successive iterations for
-repeating reports. If \-\-interval is specified but \-\-count is not,
+repeating reports. If \fB\-\-interval\fP is specified but
+\fB\-\-count\fP is not,
 reports will continue to repeat until interrupted.
-.TP
-.B \-\-length \fIlength
+.
+.HP
+.BR \-\-length
+.IR length \c
+.RB [ \c
+.UNITS
+.br
 Specify the length of a new statistics region in sectors. An optional
-suffix selects units of bBsSkKmMgGtTpPeE: (b)ytes, (s)ectors,
-(k)ilobytes, (m)egabytes, (g)igabytes, (t)erabytes, (p)etabytes,
-(e)xabytes.  Capitalise to use multiples of 1000 (S.I.) instead of 1024.
-.TP
-.BR \-j | \-\-major\ \fImajor
+suffix selects units of:
+.HELP_UNITS
+.
+.HP
+.BR \-j | \-\-major
+.IR major
+.br
 Specify the major number.
-.TP
-.BR \-m | \-\-minor\ \fIminor
+.
+.HP
+.BR \-m | \-\-minor
+.IR minor
+.br
 Specify the minor number.
-.TP
-.B \-\-nosuffix
+.
+.HP
+.BR \-\-nosuffix
+.br
 Suppress the suffix on output sizes.  Use with \fB\-\-units\fP
 (except h and H) if processing the output.
-.TP
-.B \-\-notimesuffix
+.
+.HP
+.BR \-\-notimesuffix
+.br
 Suppress the suffix on output time values. Histogram boundary values
 will be reported in units of nanoseconds.
-.TP
+.
+.HP
 .BR \-o | \-\-options
+.br
 Specify which report fields to display.
-.TP
-.BR \-O | \-\-sort\ \fIsort_fields
+.
+.HP
+.BR \-O | \-\-sort
+.IR sort_fields
+.br
 Sort output according to the list of fields given. Precede any
-sort_field with - for a reverse sort on that column.
-.TP
+sort field with '\fB-\fP' for a reverse sort on that column.
+.
+.HP
 .BR \-\-precise
+.br
 Attempt to use nanosecond precision counters when creating new
 statistics regions.
-.TP
-.B \-\-programid \fIid
+.
+.HP
+.BR \-\-programid
+.IR id
+.br
 Specify a program ID string. When creating new statistics regions this
 string is stored with the region. Subsequent operations may supply a
 program ID in order to select only regions with a matching value. The
 default program ID for dmstats-managed regions is "dmstats".
-.TP
-.B \-\-regionid \fIid
+.
+.HP
+.BR \-\-regionid
+.IR id
+.br
 Specify the region to operate on.
-.TP
+.
+.HP
 .BR \-\-relative
+.br
 If displaying the histogram report show relative (percentage) values
 instead of absolute counts.
-.TP
-.BR \-S | \-\-select \ \fIselection
-Display only rows that match selection criteria. All rows with the
-additional "selected" column (-o selected) showing 1 if the row matches
-the selection and 0 otherwise. The selection criteria are defined by
+.
+.HP
+.BR \-S | \-\-select
+.IR selection
+.br
+Display only rows that match \fIselection\fP criteria. All rows with the
+additional "selected" column (\fB\-o selected\fP) showing 1 if the row matches
+the \fIselection\fP and 0 otherwise. The selection criteria are defined by
 specifying column names and their valid values while making use of
 supported comparison operators.
-.TP
-.B \-\-start \fIstart
+.
+.HP
+.BR \-\-start
+.IR start \c
+.RB [ \c
+.UNITS
+.br
 Specify the start offset of a new statistics region in sectors. An
-optional suffix selects units of bBsSkKmMgGtTpPeE: (b)ytes,
-(s)ectors, (k)ilobytes, (m)egabytes, (g)igabytes, (t)erabytes,
-(p)etabytes, (e)xabytes.  Capitalise to use multiples of 1000 (S.I.)
-instead of 1024.
-.TP
-.B \-\-segments
+optional suffix selects units of:
+.HELP_UNITS
+.
+.HP
+.BR \-\-segments
+.br
 Create a new statistics region for each target contained in the target
 device. This causes a separate region to be allocated for each segment
 of the device.
-.TP
-.BR \-\-units \ hHbBsSkKmMgGtTpPeE
-Set the display units for report output. All sizes are output in these
-units: (h)uman-readable, (b)ytes, (s)ectors, (k)ilobytes, (m)egabytes,
-(g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.  Capitalise to use
-multiples of 1000 (S.I.) instead of 1024.  Can also specify custom units
-e.g. \fB\-\-units 3M\fP
-.TP
+.
+.HP
+.BR \-\-units
+.RI [ units ] \c
+.RB [ h | H | \c
+.UNITS
+.br
+Set the display units for report output.
+All sizes are output in these units:
+.RB ( h )uman-readable,
+.HELP_UNITS
+Can also specify custom units e.g. \fB\-\-units\ 3M\fP.
+.
+.HP
 .BR \-u | \-\-uuid
+.br
 Specify the uuid.
-.TP
-.BR \-v | \-\-verbose \ [ \-v | \-\-verbose ]
-Produce additional output.
+.
+.HP
+.BR \-v | \-\-verbose " [" \-v | \-\-verbose ]
 .br
+Produce additional output.
+.
 .SH COMMANDS
-.TP
-.B clear
-.I device_name
-.RB [ \-\-allregions | \-\-regionid
-.IR id ]
-.RB [ \-\-allprograms
-.RB |
-.B \-\-programid
-.IR id ]
+.
+.HP
+.CMD_CLEAR
 .br
 Instructs the kernel to clear statistics counters for the speficied
 regions (with the exception of in-flight IO counters).
-.br
-.TP
-.B create
-.I device_name
-.RB [ \-\-areas
-.IR nr_areas ]
-.RB [ \-\-areasize
-.IR area_size ]
-.RB [ --bounds
-.IR histogram_boundaries ]
-.RB [ \-\-precise ]
-.RB [ \-\-start
-.I  start_sector
-.B  \-\-length
-.IR length | \fB\-\-segments ]
-.RB [ \-\-auxdata
-.IR data ]
-.RB [ \-\-programid
-.IR id ]
+.
+.HP
+.CMD_CREATE
 .br
 Creates one or more new statistics regions on the specified device(s).
 
@@ -286,7 +428,7 @@ device-mapper device's table.
 If the \fB\-\-precise\fP option is used the command will attempt to
 create a region using nanosecond precision counters.
 
-If \fB--bounds\fP is given a latency histogram will be tracked for
+If \fB\-\-bounds\fP is given a latency histogram will be tracked for
 the new region. The boundaries of the histogram bins are given as a
 comma separated list of latency values. There is an implicit lower bound
 of zero on the first bin and an implicit upper bound of infinity (or the
@@ -311,17 +453,9 @@ By default dmstats creates regions with a \fBprogram_id\fP of
 
 On success the \fBregion_id\fP of the newly created region is printed to
 stdout.
-.br
-.TP
-.B delete
-.RI [ device_name ]
-.RB [ \-\-alldevices ]
-.RB [ \-\-allregions
-|
-.B \-\-regionid
-.IR id ]
-.RB [ \-\-allprograms | \-\-programid
-.IR id ]
+.
+.HP
+.CMD_DELETE
 .br
 Delete the specified statistics region. All counters and resources used
 by the region are released and the region will not appear in the output
@@ -330,24 +464,17 @@ of subsequent list, print, or report operations.
 All regions registered on a device may be removed using
 \fB\-\-allregions\fP.
 
-To remove all regions on all devices both \fB--allregions\fP and
+To remove all regions on all devices both \fB\-\-allregions\fP and
 \fB\-\-alldevices\fP must be used.
-.br
-.TP
-.B help
-.RB [ \-c | \-C | \-\-columns ]
+.
+.HP
+.CMD_HELP
 .br
 Outputs a summary of the commands available, optionally including
 the list of report fields.
-.br
-.TP
-.B list
-.RI [ device_name ]
-.RB [ \-\-histogram ]
-.RB [ \-\-allprograms ]
-.RB [ \-\-programid
-.IR id ]
-.RB [ \-v | \-\-verbose \ [ \-v | \-\-verbose ]]
+.
+.HP
+.CMD_LIST
 .br
 List the statistics regions registered on the device. If the
 \fB\-\-allprograms\fP switch is given all regions will be listed
@@ -358,37 +485,15 @@ a row of information for each area contained in each region displayed.
 
 If \fB\-\-histogram\fP is given the report will include the bin count
 and latency boundary values for any configured histograms.
-.br
-.TP
-.B print
-.RB [ \-\-allregions | \-\-regionid
-.IR id ]
-.RB [ \-\-allprograms | \-\-programid
-.IR id ]
-.RB [ \-\-clear ]
+.
+.HP
+.CMD_PRINT
 .br
 Print raw statistics counters for the specified region or for all
 present regions.
-.br
-.TP
-.B report
-.RB [ \-\-allprograms ]
-.RB [ \-\-interval
-.IR seconds ]
-.RB [ \-\-count
-.IR count ]
-.RB [ \-\-units
-.IR unit ]
-.RB [ \-\-regionid
-.IR id ]
-.RB [ \-\-programid
-.IR id ]
-.RB [ \-O | \-\-sort
-.IR sort_fields ]
-.RB [ \-S | \-\-select
-.IR selection ]
-.RB [ \-\-units
-.IR units ]
+.
+.HP
+.CMD_REPORT
 .br
 Start a report for the specified region or for all present regions. If
 the count argument is specified, the report will repeat at a fixed
@@ -398,14 +503,14 @@ one second.
 If the \fB\-\-allprograms\fP switch is given, all regions will be
 listed, regardless of region program ID values.
 
-If \fB\-\-histogram\fP is given the report will include the histogram
+If the \fB\-\-histogram\fP is given the report will include the histogram
 values and latency boundaries.
 
-If \fB\-\-relative\fP is used the default histogram field displays
+If the \fB\-\-relative\fP is used the default histogram field displays
 bin values as a percentage of the total number of I/Os.
-
-.br
+.
 .SH REGIONS AND AREAS
+.
 The device-mapper statistics facility allows separate performance
 counters to be maintained for arbitrary regions of devices. A region may
 span any range: from a single sector to the whole device. A region may
@@ -421,113 +526,96 @@ areas, or into areas of the given size by specifying one of
 \fB\-\-areas\fP or \fB\-\-areasize\fP when creating a region with the
 \fBcreate\fP command. Depending on the size of the areas and the device
 region the final area within the region may be smaller than requested.
-
-.SS Region identifiers
+.P
+.B Region identifiers
+.P
 Each region is assigned an identifier when it is created that is used to
 reference the region in subsequent operations. Region identifiers are
 unique within a given device (including across different \fBprogram_id\fP
 values).
-.br
+
 Depending on the sequence of create and delete operations, gaps may
 exist in the sequence of \fBregion_id\fP values for a particular device.
-
+.
 .SH REPORT FIELDS
+.
 The dmstats report provides several types of field that may be added to
 the default field set, or used to create custom reports.
-.br
+
 All performance counters and metrics are calculated per-area.
-.br
+.
 .SS Derived metrics
+.
 A number of metrics fields are included that provide high level
 performance indicators. These are based on the fields provided by the
 conventional Linux iostat program and are derived from the basic counter
 values provided by the kernel for each area.
-.br
-.HP
+.TP
 .B reads_merged_per_sec
-.br
 Reads merged per second.
-.HP
+.TP
 .B writes_merged_per_sec
-.br
 Writes merged per second.
-.HP
+.TP
 .B reads_per_sec
-.br
 Reads completed per second.
-.HP
+.TP
 .B writes_per_sec
-.br
 Writes completed per second.
-.HP
+.TP
 .B read_size_per_sec
-.br
 Size of data read per second.
-.HP
+.TP
 .B write_size_per_sec
-.br
 Size of data written per second.
-.HP
+.TP
 .B avg_request_size
-.br
 Average request size.
-.HP
+.TP
 .B queue_size
-.br
 Average queue size.
-.HP
+.TP
 .B await
-.br
 The average wait time for read and write operations.
-.HP
+.TP
 .B r_await
-.br
 The average wait time for read operations.
-.HP
+.TP
 .B w_await
-.br
 The average wait time for write operations.
-.HP
+.TP
 .B throughput
-.br
 The device throughput in operations per second.
-.HP
+.TP
 .B service_time
-.br
-The  average  service  time  (in milliseconds) for operations issued
+The average service time (in milliseconds) for operations issued
 to the device.
-.HP
+.TP
 .B util
-.br
 Percentage of CPU time during which I/O requests were issued to the
 device (bandwidth utilization for the device). Device saturation occurs
 when this value is close to 100%.
-.br
+.
 .SS Region and area meta fields
+.
 Meta fields provide information about the region or area that the
 statistics values relate to. This includes the region and area
 identifier, start, length, and counts, as well as the program ID and
 auxiliary data values.
-.br
-.HP
+.TP
 .B region_id
-.br
 Region identifier. This is a non-negative integer returned by the kernel
 when a statistics region is created.
-.HP
+.TP
 .B region_start
-.br
-.br
 The region start location. Display units are selected by the
-\fB--units\fP option.
-.HP
+\fB\-\-units\fP option.
+.TP
 .B region_len
-.br
 The length of the region. Display units are selected by the
-\fB--units\fP option.
-.HP
+\fB\-\-units\fP option.
+.TP
 .B area_id
-.br
 Area identifier. Area identifiers are assigned by the device-mapper
 statistics library and uniquely identify each area within a region. Each
 ID corresponds to a distinct set of performance counters for that area
@@ -535,206 +623,170 @@ of the statistics region. Area identifiers are always monotonically
 increasing within a region so that higher ID values correspond to
 greater sector addresses within the area and no gaps in the sequence of
 identifiers exist.
-.HP
+.TP
 .B area_start
-.br
 The area start location. Display units are selected by the
-\fB--units\fP option.
-.HP
+\fB\-\-units\fP option.
+.TP
 .B area_len
-.br
 The length of the area. Display units are selected by the
-\fB--units\fP option.
-.HP
+\fB\-\-units\fP option.
+.TP
 .B area_count
-.br
 The number of areas in this region.
-.HP
+.TP
 .B program_id
-.br
 The program ID value associated with this region.
-.HP
+.TP
 .B aux_data
-.br
 The auxiliary data value associated with this region.
-.br
-.HP
+.TP
 .B interval_ns
-.br
 The estimated interval over which the current counter values have
 accumulated. The value is reported as an interger expressed in units
 of nanoseconds.
-.br
-.HP
+.TP
 .B interval
-.br
 The estimated interval over which the current counter values have
 accumulated. The value is reported as a real number in units of
 seconds.
-.br
+.
 .SS Basic counters
+.
 Basic counters provide access to the raw counter data from the kernel,
 allowing further processing to be carried out by another program.
-
+.P
 The kernel provides thirteen separate counters for each statistics
 area. The first eleven of these match the counters provided in
 /proc/diskstats or /sys/block/*/*/stat. The final pair provide separate
 counters for read and write time.
-.P
-.HP
+.TP
 .B read_count
-.br
 Count of reads completed this interval.
-.HP
+.TP
 .B reads_merged_count
-.br
 Count of reads merged this interval.
-.HP
+.TP
 .B read_sector_count
-.br
 Count of 512 byte sectors read this interval.
-.HP
+.TP
 .B read_time
-.br
 Accumulated duration of all read requests (ns).
-.HP
+.TP
 .B write_count
-.br
 Count of writes completed this interval.
-.HP
+.TP
 .B writes_merged_count
-.br
 Count of writes merged this interval.
-.HP
+.TP
 .B write_sector_count
-.br
 Count of 512 byte sectors written this interval.
-.HP
+.TP
 .B write_nsecs
-.br
 Accumulated duration of all write requests (ns).
-.HP
+.TP
 .B in_progress_count
-.br
 Count of requests currently in progress.
-.HP
+.TP
 .B io_ticks
-.br
 Nanoseconds spent servicing requests.
-.HP
+.TP
 .B queue_ticks
-.br
 This field is incremented at each I/O start, I/O completion, I/O merge,
 or read of these stats by the number of I/Os in progress multiplied by
 the number of milliseconds spent doing I/O since the last update of this
 field.  This can provide an easy measure of both I/O completion time and
 the backlog that may be accumulating.
-.HP
+.TP
 .B read_ticks
-.br
 Nanoseconds spent servicing reads.
-.HP
+.TP
 .B write_ticks
-.br
 Nanoseconds spent servicing writes.
-.br
+.
 .SS Histogram fields
+.
 Histograms measure the frequency distribution of user specified I/O
 latency intervals. Histogram bin boundaries are specified when a region
 is created.
-
+.P
 A brief representation of the histogram values and latency intervals can
 be included in the report using these fields.
-.P
-.HP
+.TP
 .B hist_count
-.br
 A list of the histogram counts for the current statistics area in order
 of ascending latency value. Each value represents the number of I/Os
 with latency times falling into that bin's time range during the sample
 period.
-.HP
+.TP
 .B hist_count_bounds
-.br
 A list of the histogram counts for the current statistics area in order
 of ascending latency value including bin boundaries: each count is
 prefixed by the lower bound of the corresponding histogram bin.
-.HP
+.TP
 .B hist_count_ranges
-.br
 A list of the histogram counts for the current statistics area in order
 of ascending latency value including bin boundaries: each count is
 prefixed by both the lower and upper bounds of the corresponding
 histogram bin.
-.HP
+.TP
 .B hist_percent
-.br
 A list of the relative histogram values for the current statistics area
 in order of ascending latency value, expressed as a percentage. Each
 value represents the proportion of I/Os with latency times falling into
 that bin's time range during the sample period.
-.HP
+.TP
 .B hist_percent_bounds
-.br
 A list of the relative histogram values for the current statistics area
 in order of ascending latency value, expressed as a percentage and
 including bin boundaries. Each value represents the proportion of I/Os
 with latency times falling into that bin's time range during the sample
 period and is prefixed with the corresponding bin's lower bound.
-.HP
+.TP
 .B hist_percent_ranges
-.br
 A list of the relative histogram values for the current statistics area
 in order of ascending latency value, expressed as a percentage and
 including bin boundaries. Each value represents the proportion of I/Os
 with latency times falling into that bin's time range during the sample
 period and is prefixed with the corresponding bin's lower and upper
 bounds.
-.HP
+.TP
 .B hist_bounds
-.br
 A list of the histogram boundary values for the current statistics area
 in order of ascending latency value.  The values are expressed in whole
 units of seconds, miliseconds, microseconds or nanoseconds with a suffix
 indicating the unit.
-.HP
+.TP
 .B hist_ranges
-.br
 A list of the histogram bin ranges for the current statistics area in
 order of ascending latency value.  The values are expressed as
 "LOWER-UPPER" in whole units of seconds, miliseconds, microseconds or
 nanoseconds with a suffix indicating the unit.
-.HP
+.TP
 .B hist_bins
-.br
 The number of latency histogram bins configured for the area.
-.br
-.br
-.P
+.
 .SH EXAMPLES
+.
 Create a whole-device region with one area on vg00/lvol1
 .br
-.br
-# dmstats create vg00/lvol1
+#
+.B dmstats create vg00/lvol1
 .br
 vg00/lvol1: Created new region with 1 area(s) as region ID 0
-.br
-.br
-
-
+.P
 Create a 32M region 1G into device d0
 .br
-.br
-# dmstats create --start 1G --length 32M d0
+#
+.B dmstats create \-\-start 1G \-\-length 32M d0
 .br
 d0: Created new region with 1 area(s) as region ID 0
-.br
-
-
+.P
 Create a whole-device region with 8 areas on every device
 .br
 .br
-# dmstats create --areas 8
+#
+.B dmstats create \-\-areas 8
 .br
 vg00-lvol1: Created new region with 8 area(s) as region ID 0
 .br
@@ -747,37 +799,33 @@ vg01-lvol0: Created new region with 8 area(s) as region ID 2
 vg01-lvol1: Created new region with 8 area(s) as region ID 0
 .br
 vg00-lvol2: Created new region with 8 area(s) as region ID 1
-.br
-.br
-
+.P
 Delete all regions on all devices
 .br
 .br
-# dmstats delete --alldevices --allregions
-.br
-.br
-
+#
+.B dmstats delete \-\-alldevices \-\-allregions
+.P
 Create a whole-device region with areas 10GiB in size on vg00/lvol1
 using dmsetup
 .br
 .br
-# dmsetup stats create --areasize 10G vg00/lvol1
+#
+.B dmsetup stats create \-\-areasize 10G vg00/lvol1
 .br
 vg00-lvol1: Created new region with 5 area(s) as region ID 1
-.br
-.br
-
+.P
 Create a 1GiB region with 16 areas at the start of vg00/lvol1
 .br
-# dmstats create --start 0 --len 1G --areas=16 vg00/lvol1
+#
+.B dmstats create \-\-start 0 \-\-len 1G \-\-areas=16 vg00/lvol1
 .br
 vg00-lvol1: Created new region with 16 area(s) as region ID 0
-.br
-.br
-
+.P
 List the statistics regions registered on vg00/lvol1
 .br
-# dmstats list vg00/lvol1
+#
+.B dmstats list vg00/lvol1
 .br
 Name             RgID  RStart RSize  #Areas ASize  ProgID
 .br
@@ -786,15 +834,15 @@ vg00-lvol1           0      0 61.00g      1 61.00g dmstats
 vg00-lvol1           1 61.00g 19.20g      1 19.20g dmstats
 .br
 vg00-lvol1           2 80.20g  2.14g      1  2.14g dmstats
-.br
-.br
-
+.P
 Display five statistics reports for vg00/lvol1 at an interval of one second
 .br
 .br
-# dmstats report --interval 1 --count 5 vg00/lvol1
+#
+.B dmstats report \-\-interval 1 \-\-count 5 vg00/lvol1
 .br
-# dmstats report
+#
+.B dmstats report
 .br
 Name             RgID  ArID  AStart ASize  RRqM/s   WRqM/s   R/s   W/s    RSz/s WSz/s   AvRqSz  QSize Util%      AWait RdAWa WrAWa
 .br
@@ -803,41 +851,39 @@ vg_hex-lv_home       0     0      0 61.00g     0.00     0.00  0.00 218.00     0
 vg_hex-lv_home       1     0 61.00g 19.20g     0.00     0.00  0.00   5.00     0 548.00k 109.50k  0.14      11.00 27.40  0.00 27.40
 .br
 vg_hex-lv_home       2     0 80.20g  2.14g     0.00     0.00  0.00  14.00     0   1.15m  84.00k  0.39      18.70 27.71  0.00 27.71
-.br
-.br
-
+.P
 Create one region for reach target contained in device vg00/lvol1
 .br
 .br
-# dmstats create --segments vg00/lvol1
+#
+.B dmstats create \-\-segments vg00/lvol1
 .br
 vg00-lvol1: Created new region with 1 area(s) as region ID 0
 .br
 vg00-lvol1: Created new region with 1 area(s) as region ID 1
 .br
 vg00-lvol1: Created new region with 1 area(s) as region ID 2
-.br
-.br
-
+.P
 Print raw counters for region 4 on device d0
 .br
-.br
-# dmstats print --regionid 4 d0
+#
+.B dmstats print \-\-regionid 4 d0
 .br
 2097152+65536 0 0 0 0 29 0 264 701 0 41 701 0 41
-.br
-.br
+.
 .SH AUTHORS
+.
 Bryn M. Reeves <bmr@redhat.com>
-
+.
 .SH SEE ALSO
+.
 .BR dmsetup (8)
 
-LVM2 resource page https://www.sourceware.org/lvm2/
+LVM2 resource page: https://www.sourceware.org/lvm2/
 .br
 Device-mapper resource page: http://sources.redhat.com/dm/
 .br
 
 Device-mapper statistics kernel documentation
 .br
-Documentation/device-mapper/statistics.txt
+.I Documentation/device-mapper/statistics.txt


