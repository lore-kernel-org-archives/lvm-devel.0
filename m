From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 12 Nov 2011 22:48:45 -0000
Subject: LVM2 ./WHATS_NEW_DM man/dmsetup.8.in
Message-ID: <20111112224845.28164.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-12 22:48:45

Modified files:
	.              : WHATS_NEW_DM 
	man            : dmsetup.8.in 

Log message:
	Update dmsetup man page
	
	Use standard manpage style.
	Keep options and commands in alphabetic order.
	Added at least a very simply info about some other targets.
	TODO: documenting targest needs far more work...

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.521&r2=1.522
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmsetup.8.in.diff?cvsroot=lvm2&r1=1.44&r2=1.45

--- LVM2/WHATS_NEW_DM	2011/11/08 17:32:10	1.521
+++ LVM2/WHATS_NEW_DM	2011/11/12 22:48:44	1.522
@@ -1,5 +1,6 @@
 Version 1.02.68 -
 ==================================
+  Improve man page style for dmsetup.
   Fix _get_proc_number to be tolerant of malformed /proc/misc entries.
   Add ExecReload to dm-event.service for systemd to reload dmeventd properly.
   Add dm_config_tree_find_str_allow_empty.
--- LVM2/man/dmsetup.8.in	2011/09/23 09:51:37	1.44
+++ LVM2/man/dmsetup.8.in	2011/11/12 22:48:44	1.45
@@ -3,244 +3,303 @@
 dmsetup \- low level logical volume management
 .SH SYNOPSIS
 .ad l
-.B dmsetup help
-.I [-c|-C|--columns]
+.B dmsetup clear
+.I device_name
 .br
-.B dmsetup create 
-.I device_name [-u uuid] [--notable | --table <table> | table_file]
-.I [{ --addnodeonresume | --addnodeoncreate }]
+.B dmsetup create
+.I device_name
+.RB [ \-u
+.IR uuid ]
+.RB [ \-\-notable | \-\-table
+.RI < table >|
+.RS
+.IR table_file ]
+.RB [{ \-\-addnodeoncreate | \-\-addnodeonresume }]
+.RE
 .br
-.B dmsetup remove
-.I [-f|--force] [--retry] device_name
+.B dmsetup deps
+.RI [ device_name ]
 .br
-.B dmsetup remove_all
-.I [-f|--force]
+.B dmsetup help
+.RB [ \-c | \-C | \-\-columns ]
 .br
-.B dmsetup suspend
-.I [--nolockfs] [--noflush] device_name
+.B dmsetup info
+.RI [ device_name ]
 .br
-.B dmsetup resume
-.I device_name [{ --addnodeonresume | --addnodeoncreate }]
+.B dmsetup info
+.BR \-c | \-C | \-\-columns
+.RB [ \-\-noheadings ]
+.RB [ \-\-separator
+.IR separator ]
+.RS
+.RB [ \-o
+.IR fields ]
+.RB [ \-O | \-\-sort
+.IR sort_fields ]
+.RI [ device_name ]
+.RE
 .br
 .B dmsetup load
-.I device_name [--table <table> | table_file]
-.br
-.B dmsetup clear
 .I device_name
+.RB [ \-\-table
+.RI < table >| table_file ]
 .br
-.B dmsetup reload
-.I device_name [--table <table> | table_file]
-.br
-.B dmsetup rename
-.I device_name new_name
-.br
-.B dmsetup rename
-.I device_name --setuuid uuid
+.B dmsetup ls
+.RB [ \-\-target
+.IR target_type ]
+.RB [ \-\-exec
+.IR command ]
+.RB [ \-\-tree
+.RS
+.RB [ \-o
+.IR options ]]
+.RE
 .br
 .B dmsetup message
 .I device_name sector message
 .br
-.B dmsetup ls
-.I [--target target_type] [--exec command] [--tree [-o options]]
+.B dmsetup mknodes
+.RI [ device_name ]
 .br
-.B dmsetup info 
-.I [device_name]
+.B dmsetup reload
+.I device_name
+.RB [ \-\-table
+.RI < table >| table_file ]
 .br
-.B dmsetup info -c|-C|--columns
-.I [--noheadings] [--separator separator] [-o fields] [-O|--sort sort_fields]
-.I [device_name]
+.B dmsetup remove
+.RB [ \-f | \-\-force ]
+.RB [ \-\-retry ]
+.I device_name
 .br
-.B dmsetup deps
-.I [device_name]
+.B dmsetup remove_all
+.RB [ \-f | \-\-force ]
 .br
-.B dmsetup status
-.I [--target target_type]
-.I [device_name]
+.B dmsetup rename
+.I device_name new_name
 .br
-.B dmsetup table
-.I [--target target_type] [--showkeys]
-.I [device_name]
+.B dmsetup rename
+.I device_name
+.B \-\-setuuid
+.I uuid
 .br
-.B dmsetup wait
+.B dmsetup resume
 .I device_name
-.I [event_nr]
+.RB [{ \-\-addnodeoncreate | \-\-addnodeonresume }]
 .br
-.B dmsetup mknodes
-.I [device_name]
+.B dmsetup setgeometry
+.I device_name cyl head sect start
 .br
-.B dmsetup udevcreatecookie
+.B dmsetup splitname
+.I device_name
+.RI [ subsystem ]
 .br
-.B dmsetup udevreleasecookie
-.I [cookie]
+.B dmsetup status
+.RB [ \-\-target
+.IR target_type ]
+.RI [ device_name ]
 .br
-.B dmsetup udevflags
-.I cookie
+.B dmsetup suspend
+.RB [ \-\-nolockfs ]
+.RB [ \-\-noflush ]
+.I device_name
+.br
+.B dmsetup table
+.RB [ \-\-target
+.IR target_type ]
+.RB [ \-\-showkeys ]
+.RI [ device_name ]
+.br
+.B dmsetup targets
 .br
 .B dmsetup udevcomplete
 .I cookie
 .br
 .B dmsetup udevcomplete_all
-.I [age_in_minutes]
+.RI [ age_in_minutes ]
 .br
 .B dmsetup udevcookies
 .br
-.B dmsetup targets
+.B dmsetup udevcreatecookie
 .br
-.B dmsetup version
+.B dmsetup udevflags
+.I cookie
 .br
-.B dmsetup setgeometry
-.I device_name cyl head sect start
+.B dmsetup udevreleasecookie
+.RI [ cookie ]
 .br
-.B dmsetup splitname
+.B dmsetup version
+.br
+.B dmsetup wait
 .I device_name
-.I [subsystem]
+.RI [ event_nr ]
 .br
 
 .B devmap_name
 .I major minor
 .br
-.B devmap_name 
+.B devmap_name
 .I major:minor
 .ad b
 .SH DESCRIPTION
-dmsetup manages logical devices that use the device-mapper driver.  
+dmsetup manages logical devices that use the device-mapper driver.
 Devices are created by loading a table that specifies a target for
 each sector (512 bytes) in the logical device.
 
-The first argument to dmsetup is a command. 
+The first argument to dmsetup is a command.
 The second argument is the logical device name or uuid.
 
 Invoking the command as \fBdevmap_name\fP is equivalent to
 .br
-\fBdmsetup info -c --noheadings -j \fImajor\fB -m \fIminor\fP.
+\fBdmsetup info \-c \-\-noheadings \-j \fImajor\fB \-m \fIminor\fP.
 .SH OPTIONS
-.IP \fB--checks
+.TP
+.B \-\-addnodeoncreate
+Ensure /dev/mapper node exists after dmsetup create.
+.TP
+.B \-\-addnodeonresume
+Ensure /dev/mapper node exists after dmsetup resume (default with udev).
+.TP
+.B \-\-checks
 Perform additional checks on the operations requested and report
 potential problems.  Useful when debugging scripts.
 In some cases these checks may slow down operations noticeably.
-.IP \fB-c|-C|--columns
-.br
+.TP
+.BR \-c | \-C | \-\-columns
 Display output in columns rather than as Field: Value lines.
-.IP \fB-h|--help
-.br
+.TP
+.BR \-h | \-\-help
 Outputs a summary of the commands available, optionally including
 the list of report fields (synonym with \fBhelp\fP command).
-.IP \fB--inactive
-.br
-When returning any table information from the kernel report on the 
+.TP
+.B \-\-inactive
+When returning any table information from the kernel report on the
 inactive table instead of the live table.
 Requires kernel driver version 4.16.0 or above.
-.IP \fB-j|--major\ \fImajor
-.br
+.TP
+.BR \-j | \-\-major\ \fImajor
 Specify the major number.
-.IP \fB-m|--minor\ \fIminor
-.br
+.TP
+.BR \-m | \-\-minor\ \fIminor
 Specify the minor number.
-.IP \fB-n|--noheadings
-.br
+.TP
+.BR \-n | \-\-noheadings
 Suppress the headings line when using columnar output.
-.IP \fB--noopencount
-.br
+.TP
+.B \-\-noopencount
 Tell the kernel not to supply the open reference count for the device.
-.IP \fB--notable
-.br
+.TP
+.B \-\-notable
 When creating a device, don't load any table.
-.IP \fB--addnodeonresume
-.br
-Ensure /dev/mapper node exists after dmsetup resume (default with udev).
-.IP \fB--addnodeoncreate
-.br
-Ensure /dev/mapper node exists after dmsetup create.
-.IP \fB--udevcookie\ \fIcookie
-.br
-Use cookie for udev synchronisation.
-.IP \fB--noudevrules
+.TP
+.B \-\-noudevrules
 Do not allow udev to manage nodes for devices in device-mapper directory.
-.br
-.IP \fB--noudevsync
+.TP
+.B \-\-noudevsync
 Do not synchronise with udev when creating, renaming or removing devices.
-.br
-.IP \fB-o|--options
-.br
+.TP
+.BR \-o | \-\-options
 Specify which fields to display.
-.IP \fB-r|--readonly
-.br
-Set the table being loaded read-only.
-.IP \fB--readahead\ [+]<sectors>|auto|none
-.br    
+.TP
+.IR \fB\-\-readahead \ [ \+ ]< sectors >| auto | none
 Specify read ahead size in units of sectors.
 The default value is "auto" which allows the kernel to choose
 a suitable value automatically.  The + prefix lets you
 specify a minimum value which will not be used if it is
 smaller than the value chosen by the kernel.
 "None" is equivalent to specifying zero.
-.IP \fB--table\ <table>
-.br
+.TP
+.BR \-r | \-\-readonly
+Set the table being loaded read-only.
+.TP
+.IR \fB\-\-table \ < table >
 Specify a one-line table directly on the command line.
-.IP \fB-u|--uuid
-.br
+.TP
+.B \-\-udevcookie \fIcookie
+Use cookie for udev synchronisation.
+.TP
+.BR \-u | \-\-uuid
 Specify the uuid.
-.IP \fB-y|--yes
-.br
+.TP
+.BR \-y | \-\-yes
 Answer yes to all prompts automatically.
-.IP \fB-v|--verbose\ [-v|--verbose]
-.br
+.TP
+.BR \-v | \-\-verbose \ [ \-v | \-\-verbose ]
 Produce additional output.
-.IP \fB--verifyudev
+.TP
+.B \-\-verifyudev
 If udev synchronisation is enabled, verify that udev operations get performed
 correctly and try to fix up the device nodes afterwards if not.
-.br
-.IP \fB--version
-.br
+.TP
+.B \-\-version
 Display the library and kernel driver version.
+.br
 .SH COMMANDS
-.IP \fBclear
+.TP
+.B clear
 .I device_name
 .br
 Destroys the table in the inactive table slot for device_name.
-.IP \fBcreate
-.I device_name [-u uuid] [--notable | --table <table> | table_file]
+.br
+.TP
+.B create
+.I device_name
+.RB [ \-u
+.IR uuid ]
+.RB [ \-\-notable | \-\-table
+.RI < \fItable >| table_file ]
+.RB [{ \-\-addnodeoncreate | \-\-addnodeonresume }]
 .br
 Creates a device with the given name.
 If table_file or <table> is supplied, the table is loaded and made live.
-Otherwise a table is read from standard input unless --notable is used.
+Otherwise a table is read from standard input unless \-\-notable is used.
 The optional uuid can be used in place of
-device_name in subsequent dmsetup commands.  
+device_name in subsequent dmsetup commands.
 If successful a device will appear as
-/dev/device-mapper/<device-name>.  
+/dev/mapper/<device-name>.
 See below for information on the table format.
-.IP \fBdeps
-.I [device_name]
+.br
+.TP
+.B deps
+.RI [ device_name ]
 .br
 Outputs a list of (major, minor) pairs for devices referenced by the
 live table for the specified device.
-.IP \fBhelp
-.I [-c|-C|--columns]
+.br
+.TP
+.B help
+.RB [ \-c | \-C | \-\-columns ]
 .br
 Outputs a summary of the commands available, optionally including
 the list of report fields.
-.IP \fBinfo
-.I [device_name]
-.br
-Outputs some brief information about the device in the form:
-.br
-    State: SUSPENDED|ACTIVE, READ-ONLY
-.br
-    Tables present: LIVE and/or INACTIVE
-.br
-    Open reference count
 .br
-    Last event sequence number (used by \fBwait\fP)
-.br
-    Major and minor device number
+.TP
+.B info
+.RI [ device_name ]
 .br
-    Number of targets in the live table
+Outputs some brief information about the device in the form:
+.RS
+.RS
+ State: SUSPENDED|ACTIVE, READ-ONLY
+ Tables present: LIVE and/or INACTIVE
+ Open reference count
+ Last event sequence number (used by \fBwait\fP)
+ Major and minor device number
+ Number of targets in the live table
+ UUID
+.RE
+.RE
 .br
-    UUID
-.IP \fBinfo
-.I -c|-C|--columns
-.I [--noheadings] [--separator separator] [-o fields] [-O|--sort sort_fields]
-.I [device_name]
+.TP
+.B info
+.BR \-c | \-C | \-\-columns
+.RB [ \-\-noheadings ]
+.RB [ \-\-separator
+.IR separator ]
+.RB [ \-o
+.IR fields ]
+.RB [ \-O | \-\-sort
+.IR sort_fields ]
+.RI [ device_name ]
 .br
 Output you can customise.
 Fields are comma-separated and chosen from the following list:
@@ -249,10 +308,16 @@
 Precede the list with '+' to append
 to the default selection of columns instead of replacing it.
 Precede any sort_field with - for a reverse sort on that column.
-.IP \fBls
-.I [--target target_type]
-.I [--exec command]
-.I [--tree [-o options]]
+.br
+.TP
+.B ls
+.RB [ \-\-target
+.IR target_type ]
+.RB [ \-\-exec
+.IR command ]
+.RB [ \-\-tree
+.RB [ \-o
+.IR options ]]
 .br
 List device names.  Optionally only list devices that have at least
 one target of the specified type.  Optionally execute a command for
@@ -263,125 +328,177 @@
 device/nodevice; active, open, rw, uuid.
 Others specify how the tree is displayed:
 ascii, utf, vt100; compact, inverted, notrunc.
-.IP \fBload|reload
-.I device_name [--table <table> | table_file]
+.br
+.HP
+.BR load | reload
+.I device_name
+.RB [ \-\-table
+.RI < table >| table_file ]
 .br
 Loads <table> or table_file into the inactive table slot for device_name.
 If neither is supplied, reads a table from standard input.
-.IP \fBmessage
+.br
+.HP
+.B message
 .I device_name sector message
 .br
 Send message to target. If sector not needed use 0.
-.IP \fBmknodes
-.I [device_name]
+.br
+.HP
+.B mknodes
+.RI [ device_name ]
 .br
 Ensure that the node in /dev/mapper for device_name is correct.
-If no device_name is supplied, ensure that all nodes in /dev/mapper 
+If no device_name is supplied, ensure that all nodes in /dev/mapper
 correspond to mapped devices currently loaded by the device-mapper kernel
 driver, adding, changing or removing nodes as necessary.
-.IP \fBremove
-.I [-f|--force] [--retry] device_name
+.br
+.HP
+.B remove
+.RB [ \-f | \-\-force ]
+.RB [ \-\-retry ]
+.I device_name
 .br
 Removes a device.  It will no longer be visible to dmsetup.
 Open devices cannot be removed except with older kernels
 that contain a version of device-mapper prior to 4.8.0.
-In this case the device will be deleted when its open_count 
+In this case the device will be deleted when its open_count
 drops to zero.  From version 4.8.0 onwards, if a device can't
 be removed because an uninterruptible process is waiting for
-I/O to return from it, adding --force will replace the table 
-with one that fails all I/O, which might allow the 
+I/O to return from it, adding \-\-force will replace the table
+with one that fails all I/O, which might allow the
 process to be killed. If an attempt to remove a device fails,
 perhaps because a process run from a quick udev rule
-temporarily opened the device, the --retry option will cause
+temporarily opened the device, the \-\-retry option will cause
 the operation to be retried for a few seconds before failing.
-.IP \fBremove_all
-.I [-f|--force]
+.br
+.HP
+.B remove_all
+.RB [ \-f | \-\-force ]
 .br
 Attempts to remove all device definitions i.e. reset the driver.
 Use with care!  From version 4.8.0 onwards, if devices can't
 be removed because uninterruptible processes are waiting for
-I/O to return from them, adding --force will replace the table 
-with one that fails all I/O, which might allow the 
+I/O to return from them, adding \-\-force will replace the table
+with one that fails all I/O, which might allow the
 process to be killed.  This also runs \fBmknodes\fP afterwards.
-.IP \fBrename
+.br
+.HP
+.B rename
 .I device_name new_name
 .br
 Renames a device.
-.IP \fBrename
-.I device_name --setuuid uuid
+.br
+.HP
+.B rename
+.I device_name
+.B \-\-setuuid
+.I uuid
 .br
 Sets the uuid of a device that was created without a uuid.
 After a uuid has been set it cannot be changed.
-.IP \fBresume
-.I device_name [{ --addnodeonresume | --addnodeoncreate }]
 .br
-Un-suspends a device.  
+.TP
+.B resume
+.I device_name
+.RB [{ \-\-addnodeoncreate | \-\-addnodeonresume }]
+.br
+Un-suspends a device.
 If an inactive table has been loaded, it becomes live.
 Postponed I/O then gets re-queued for processing.
-.IP \fBsetgeometry
-.I device_name cyl head sect start
+.br
+.TP
+.B setgeometry \fIdevice_name cyl head sect start
 .br
 Sets the device geometry to C/H/S.
-.IP \fBsplitname
+.br
+.HP
+.B splitname
 .I device_name
-.I [subsystem]
+.RI [ subsystem ]
 .br
 Splits given device name into subsystem constituents.
 Default subsystem is LVM.
-.IP \fBstatus
-.I [--target target_type]
-.I [device_name]
+.br
+.TP
+.B status
+.RB [ \-\-target
+.IR target_type ]
+.RI [ device_name ]
 .br
 Outputs status information for each of the device's targets.
-With --target, only information relating to the specified target type
+With \-\-target, only information relating to the specified target type
 is displayed.
-.IP \fBsuspend
-.I [--nolockfs] [--noflush]
+.br
+.HP
+.B suspend
+.RB [ \-\-nolockfs ]
+.RB [ \-\-noflush ]
 .I device_name
 .br
 Suspends a device.  Any I/O that has already been mapped by the device
 but has not yet completed will be flushed.  Any further I/O to that
 device will be postponed for as long as the device is suspended.
-If there's a filesystem on the device which supports the operation, 
-an attempt will be made to sync it first unless --nolockfs is specified.
+If there's a filesystem on the device which supports the operation,
+an attempt will be made to sync it first unless \-\-nolockfs is specified.
 Some targets such as recent (October 2006) versions of multipath may support
-the --noflush option.  This lets outstanding I/O that has not yet reached the
+the \-\-noflush option.  This lets outstanding I/O that has not yet reached the
 device to remain unflushed.
-.IP \fBtable
-.I [--target target_type] [--showkeys]
-.I [device_name]
+.br
+.TP
+.B table
+.RB [ \-\-target
+.IR target_type ]
+.RB [ \-\-showkeys ]
+.RI [ device_name ]
 .br
 Outputs the current table for the device in a format that can be fed
 back in using the create or load commands.
-With --target, only information relating to the specified target type
+With \-\-target, only information relating to the specified target type
 is displayed.
 Encryption keys are suppressed in the table output for the crypt
-target unless the --showkeys parameter is supplied.
-.IP \fBtargets
+target unless the \-\-showkeys parameter is supplied.
+.br
+.TP
+.B targets
 .br
 Displays the names and versions of the currently-loaded targets.
 .br
-.IP \fBudevcreatecookie
+.HP
+.B udevcomplete
+.I cookie
+.br
+Wake any processes that are waiting for udev to complete processing the specified cookie.
+.br
+.HP
+.B udevcomplete_all
+.RI [ age_in_minutes ]
+.br
+Remove all cookies older than the specified number of minutes.
+Any process waiting on a cookie will be resumed immediately.
+.br
+.HP
+.B udevcookies
+.br
+List all existing cookies. Cookies are system-wide semaphores with keys
+prefixed by two predefined bytes (0x0D4D).
+.br
+.TP
+.B udevcreatecookie
 .br
 Creates a new cookie to synchronize actions with udev processing.
 The output is a cookie value. Normally we don't need to create cookies since
 dmsetup creates and destroys them for each action automatically. However, we can
 generate one explicitly to group several actions together and use only one
 cookie instead. We can define a cookie to use for each relevant command by using
---udevcookie option. Alternatively, we can export this value into the environment
+\-\-udevcookie option. Alternatively, we can export this value into the environment
 of the dmsetup process as DM_UDEV_COOKIE variable and it will be used automatically
 with all subsequent commands until it is unset.
 Invoking this command will create system-wide semaphore that needs to be cleaned
 up explicitly by calling udevreleasecookie command.
 .br
-.IP \fBudevreleasecookie
-.I [cookie]
-.br
-Waits for all pending udev processing bound to given cookie value and clean up
-the cookie with underlying semaphore. If the cookie is not given directly,
-the command will try to use a value defined by DM_UDEV_COOKIE environment variable.
-.br
-.IP \fBudevflags
+.HP
+.B udevflags
 .I cookie
 .br
 Parses given cookie value and extracts any udev control flags encoded.
@@ -392,68 +509,145 @@
 always reported as DM_SUBSYSTEM_UDEV_FLAG<flag_position>='1'. There are
 16 udev flags altogether.
 .br
-.IP \fBudevcomplete
-.I cookie
-.br
-Wake any processes that are waiting for udev to complete processing the specified cookie.
-.br
-.IP \fBudevcomplete_all 
-.I[age_in_minutes]
-Remove all cookies older than the specified number of minutes. 
-Any process waiting on a cookie will be resumed immediately.
+.HP
+.B udevreleasecookie
+.RI [ cookie ]
 .br
-.IP \fBudevcookies
-List all existing cookies. Cookies are system-wide semaphores with keys
-prefixed by two predefined bytes (0x0D4D).
+Waits for all pending udev processing bound to given cookie value and clean up
+the cookie with underlying semaphore. If the cookie is not given directly,
+the command will try to use a value defined by DM_UDEV_COOKIE environment variable.
 .br
-.IP \fBversion
+.TP
+.B version
 .br
 Outputs version information.
-.IP \fBwait
+
+.TP
+.B wait
 .I device_name
-.I [event_nr]
+.RI [ event_nr ]
 .br
 Sleeps until the event counter for device_name exceeds event_nr.
-Use -v to see the event number returned.
+Use \-v to see the event number returned.
 To wait until the next event is triggered, use \fBinfo\fP to find
-the last event number.  
+the last event number.
 .SH TABLE FORMAT
 Each line of the table specifies a single target and is of the form:
-.br
-    logical_start_sector num_sectors target_type target_args
-.br
-.br
-
-There are currently three simple target types available together 
-with more complex optional ones that implement snapshots and mirrors.
-
-.IP \fBlinear
+.P
+.I logical_start_sector num_sectors
+.B target_type
+.RI < target_args >
+.P
+There are currently three simple target types available (linear,
+striped, error) together with more complex optional ones that implement
+e.g. snapshots and mirrors.
+.HP
+.B linear
 .I destination_device start_sector
 .br
 The traditional linear mapping.
-
-.IP \fBstriped
-.I num_stripes chunk_size [destination start_sector]+
+.HP
+.B striped
+.I num_stripes chunk_size
+.RI [ destination
+.IR start_sector ]+
 .br
 Creates a striped area.
 .br
 e.g. striped 2 32 /dev/hda1 0 /dev/hdb1 0
 will map the first chunk (16k) as follows:
+.RS
+.RS
+ LV chunk 1 -> hda1, chunk 1
+ LV chunk 2 -> hdb1, chunk 1
+ LV chunk 3 -> hda1, chunk 2
+ LV chunk 4 -> hdb1, chunk 2
+ etc.
+.RE
+.RE
+.TP
+.B error
 .br
-    LV chunk 1 -> hda1, chunk 1
+Errors any I/O that goes to this area.  Useful for testing or
+for creating devices with holes in them.
+.TP
+.B crypt
+.I cipher key iv_offset destination offset
+.RI [ num_params
+.RI < params >]
 .br
-    LV chunk 2 -> hdb1, chunk 1
+Target for transparent encryption of block devices
+using the kernel crypto API.
+.TP
+.B delay
+.I read_device read_offset read_delay
+.RI [ write_device
+.I write_offset
+.IR write_delay ]
 .br
-    LV chunk 3 -> hda1, chunk 2
+Creates mapping that "delays" reads and/or writes
+to different devices.
+.TP
+.B flakey
+.I destination_device start_sector up_interval
+.I down_interval
+.RI [ num_features
+.RI [< feature_arguments >]]
+.br
+Creates the same mapping as the linear target except
+that it exhibits unreliable behaviour periodically.
+Useful for simulating failing devices for testing
+purposes.
+.TP
+.B mirror
+.I log_type num_logargs
+.RI < logargs >
+.I num_devices
+.RI < device
+.IR offset >+
+.br
+Creates mirror mapping target for mirrored logical devices.
+.HP
+.B multipath
+.I num_features
+.RI < features >
+.I num_handle_args
+.RI < handle_args >
+.I num_path_groups
+.I path_group
+.RI < path_group_args1\.\.N >
 .br
-    LV chunk 4 -> hdb1, chunk 2
+Creates multipath mapping.
+.TP
+.BR raid1 | raid4 | raid5_ { la | ra | ls | rs }| raid6_ { zr | mr | nc }
+.I num_raid_params
+.RI < raid_params >
+.I num_raid_devs
+.RI < metadata_device
+.IR device >+
+.br
+Creates RAID "bridge" mapping between DM and MD.
+It allows the MD RAID drivers to be
+accessed using a device-mapper interface.
+.HP
+.B snapshot
+.I origin_device cow_device persistant chunksize
+.br
+.HP
+.B snapshot-merge
+.I origin_device cow_device persistant chunksize
+.br
+.HP
+.B snapshot-origin
+.I origin_device
 .br
-    etc.
-
-.IP \fBerror
+Supports device snapshots.
+.TP
+.B zero
 .br
-Errors any I/O that goes to this area.  Useful for testing or
-for creating devices with holes in them.
+Returns always zeroed data on reads and silently drops writes.
+This is similar behavior to /dev/zero, but as a block-device instead
+of a character device.
 
 .SH EXAMPLES
 
@@ -465,7 +659,7 @@
 1028160 3903762 linear /dev/hdb 0
 
 
-# A table to stripe across the two disks, 
+# A table to stripe across the two disks,
 .br
 # and add the spare space from
 .br
@@ -477,13 +671,13 @@
 
 .SH ENVIRONMENT VARIABLES
 .TP
-\fBDM_DEV_DIR\fP
+.B DM_DEV_DIR
 The device directory name.
 Defaults to "/dev" and must be an absolute path.
 .TP
-\fBDM_UDEV_COOKIE\fP
+.B DM_UDEV_COOKIE
 A cookie to use for all relevant commands to synchronize with udev processing.
-It is an alternative to using --udevcookie option.
+It is an alternative to using \-\-udevcookie option.
 
 .SH AUTHORS
 Original version: Joe Thornber (thornber at sistina.com)


