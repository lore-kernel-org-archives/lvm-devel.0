From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 18:10:28 +0000 (UTC)
Subject: master - man lvm: remove options
Message-ID: <20170213181028.A633A6039D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4d2c3502e79e34a5cf0fdb65c2a4df23aa1b2ecb
Commit:        4d2c3502e79e34a5cf0fdb65c2a4df23aa1b2ecb
Parent:        5c779b323132bfd2ddc5cf639a6fcd3e9b10a309
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jan 12 16:08:53 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 08:20:10 2017 -0600

man lvm: remove options

all options are now included in commands
---
 man/lvm.8.in |  258 +---------------------------------------------------------
 1 files changed, 3 insertions(+), 255 deletions(-)

diff --git a/man/lvm.8.in b/man/lvm.8.in
index cad724b..0a64e4f 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -45,6 +45,9 @@ A file containing a simple script with one command per line
 can also be given on the command line.  The script can also be
 executed directly if the first line is #! followed by the absolute
 path of \fBlvm\fP.
+.P
+Additional hyphens within option names are ignored.  For example,
+\fB\-\-readonly\fP and \fB\-\-read\-only\fP are both accepted.
 .
 .SH BUILT-IN COMMANDS
 .
@@ -238,261 +241,6 @@ The following commands are not implemented in LVM2 but might be
 in the future:
 .BR lvmsadc ", " lvmsar ", " pvdata .
 .
-.SH OPTIONS
-.
-The following options are available for many of the commands.
-They are implemented generically and documented here rather
-than repeated on individual manual pages.
-.P
-Additional hyphens within option names are ignored.  For example,
-\fB\-\-readonly\fP and \fB\-\-read\-only\fP are both accepted.
-.
-.HP
-.BR \-h | \-? | \-\-help
-.br
-Display the help text.
-.
-.HP
-.BR \-\-version
-.br
-Display version information.
-.
-.HP
-.BR \-v | \-\-verbose
-.br
-Set verbose level. Repeat from 1 to 3 times to increase the detail
-of messages sent to stdout and stderr.  Overrides config file setting.
-.
-.HP
-.BR \-d | \-\-debug
-.br
-Set debug level. Repeat from 1 to 6 times to increase the detail of
-messages sent to the log file and/or syslog (if configured).
-Overrides config file setting.
-.
-.HP
-.BR \-q | \-\-quiet
-.br
-Suppress output and log messages.
-Overrides \fB\-d\fP and \fB\-v\fP.
-Repeat once to also suppress any prompts with answer 'no'.
-.
-.HP
-.BR \-\-yes
-.br
-Don't prompt for confirmation interactively but instead always assume the
-answer is 'yes'.  Take great care if you use this!
-.
-.HP
-.BR \-t | \-\-test
-.br
-Run in test mode. Commands will not update metadata.
-This is implemented by disabling all metadata writing but nevertheless
-returning success to the calling function.  This may lead to unusual
-error messages in multi-stage operations if a tool relies on reading
-back metadata it believes has changed but hasn't.
-.
-.HP
-.BR \-\-driverloaded
-.RB { y | n }
-.br
-Whether or not the device-mapper kernel driver is loaded.
-If you set this to \fBn\fP, no attempt will be made to contact the driver.
-.
-.HP
-.BR \-A | \-\-autobackup
-.RB { y | n }
-.br
-Whether or not to metadata should be backed up automatically after a change.
-You are strongly advised not to disable this!
-See \fBvgcfgbackup\fP(8).
-.
-.HP
-.BR \-P | \-\-partial
-.br
-When set, the tools will do their best to provide access to Volume Groups
-that are only partially available (one or more Physical Volumes belonging
-to the Volume Group are missing from the system).  Where part of a logical
-volume is missing, \fI\%/dev/ioerror\fP will be substituted, and you could use
-\fBdmsetup\fP(8) to set this up to return I/O errors when accessed,
-or create it as a large block device of nulls.  Metadata may not be
-changed with this option. To insert a replacement Physical Volume
-of the same or large size use \fBpvcreate \-u\fP to set the uuid to
-match the original followed by \fBvgcfgrestore\fP(8).
-.
-.HP
-.BR \-S | \-\-select
-.IR Selection
-.br
-For reporting commands, display only rows that match \fISelection\fP criteria.
-All rows are displayed with the additional "selected" column (\fB-o selected\fP)
-showing 1 if the row matches the \fISelection\fP and 0 otherwise. For non-reporting
-commands which process LVM entities, the selection can be used to match items
-to process. See \fBSelection\fP section in \fBlvmreport\fP(7)  man page for more
-information about the way the selection criteria are constructed.
-.
-.HP
-.BR \-M | \-\-metadatatype
-.IR Type
-.br
-Specifies which \fItype\fP of on-disk metadata to use, such as \fBlvm1\fP
-or \fBlvm2\fP, which can be abbreviated to \fB1\fP or \fB2\fP respectively.
-The default (\fBlvm2\fP) can be changed by setting \fBformat\fP
-in the \fBglobal\fP section of the config file \fBlvm.conf\fP(5).
-.
-.HP
-.BR \-\-ignorelockingfailure
-.br
-This lets you proceed with read-only metadata operations such as
-\fBlvchange \-ay\fP and \fBvgchange \-ay\fP even if the locking module fails.
-One use for this is in a system init script if the lock directory
-is mounted read-only when the script runs.
-.
-.HP
-.BR \-\-ignoreskippedcluster
-.br
-Use to avoid exiting with an non-zero status code if the command is run
-without clustered locking and some clustered Volume Groups have to be
-skipped over.
-.
-.HP
-.BR \-\-readonly
-.br
-Run the command in a special read-only mode which will read on-disk
-metadata without needing to take any locks.  This can be used to peek
-inside metadata used by a virtual machine image while the virtual
-machine is running.
-It can also be used to peek inside the metadata of clustered Volume
-Groups when clustered locking is not configured or running.  No attempt
-will be made to communicate with the device-mapper kernel driver, so
-this option is unable to report whether or not Logical Volumes are
-actually in use.
-.
-.HP
-.BR \-\-foreign
-.br
-Cause the command to access foreign VGs, that would otherwise be skipped.
-It can be used to report or display a VG that is owned by another host.
-This option can cause a command to perform poorly because lvmetad caching
-is not used and metadata is read from disks.
-.
-.HP
-.BR \-\-shared
-.br
-Cause the command to access shared VGs, that would otherwise be skipped
-when lvmlockd is not being used.  It can be used to report or display a
-lockd VG without locking. Applicable only if LVM is compiled with lockd
-support.
-.
-.HP
-.BR \-\-addtag
-.IR Tag
-.br
-Add the tag \fITag\fP to a PV, VG or LV.
-Supply this argument multiple times to add more than one tag at once.
-A tag is a word that can be used to group LVM2 objects of the same type
-together.
-Tags can be given on the command line in place of PV, VG or LV
-arguments.  Tags should be prefixed with @ to avoid ambiguity.
-Each tag is expanded by replacing it with all objects possessing
-that tag which are of the type expected by its position on the command line.
-PVs can only possess tags while they are part of a Volume Group:
-PV tags are discarded if the PV is removed from the VG.
-As an example, you could tag some LVs as \fBdatabase\fP and others
-as \fBuserdata\fP and then activate the database ones
-with \fBlvchange \-ay @database\fP.
-Objects can possess multiple tags simultaneously.
-Only the new LVM2 metadata format supports tagging: objects using the
-LVM1 metadata format cannot be tagged because the on-disk format does not
-support it.
-Characters allowed in tags are:
-.BR A - Z
-.BR a - z
-.BR 0 - 9
-.BR "_ + . -"
-and as of version 2.02.78 the following characters are also accepted:
-.BR "/ = ! : # &" .
-.
-.HP
-.BR \-\-deltag
-.IR Tag
-.br
-Delete the tag \fITag\fP from a PV, VG or LV, if it's present.
-Supply this argument multiple times to remove more than one tag at once.
-.
-.HP
-.BR \-\-alloc
-.RB { anywhere | contiguous | cling | inherit | normal }
-.br
-Selects the allocation policy when a command needs to allocate
-Physical Extents from the Volume Group.
-Each Volume Group and Logical Volume has an allocation policy defined.
-The default for a Volume Group is \fBnormal\fP which applies
-common-sense rules such as not placing parallel stripes on the same
-Physical Volume.  The default for a Logical Volume is \fBinherit\fP
-which applies the same policy as for the Volume Group.  These policies can
-be changed using \fBlvchange\fP(8) and \fBvgchange\fP(8) or overridden
-on the command line of any command that performs allocation.
-The \fBcontiguous\fP policy requires that new Physical Extents be placed adjacent
-to existing Physical Extents.
-The \fBcling\fP policy places new Physical Extents on the same Physical
-Volume as existing Physical Extents in the same stripe of the Logical Volume.
-If there are sufficient free Physical Extents to satisfy
-an allocation request but \fBnormal\fP doesn't use them,
-\fBanywhere\fP will - even if that reduces performance by
-placing two stripes on the same Physical Volume.
-.
-.HP
-.BR \-\-commandprofile
-.IR ProfileName
-.br
-Selects the command configuration profile to use when processing an LVM command.
-See also \fBlvm.conf\fP(5) for more information about \fBcommand profile config\fP and
-the way it fits with other LVM configuration methods. Using \fB\-\-commandprofile\fP
-option overrides any command profile specified via \fBLVM_COMMAND_PROFILE\fP
-environment variable.
-.
-.HP
-.BR \-\-metadataprofile
-.IR ProfileName
-.br
-Selects the metadata configuration profile to use when processing an LVM command.
-When using metadata profile during Volume Group or Logical Volume creation,
-the metadata profile name is saved in metadata. When such Volume Group or Logical
-Volume is processed next time, the metadata profile is automatically applied
-and the use of \fB\-\-metadataprofile\fP option is not necessary. See also
-\fBlvm.conf\fP(5) for more information about \fBmetadata profile config\fP and the
-way it fits with other LVM configuration methods.
-.
-.HP
-.BR \-\-profile
-.IR ProfileName
-.br
-A short form of \fB\-\-metadataprofile\fP for \fBvgcreate\fP, \fBlvcreate\fP,
-\fBvgchange\fP and \fBlvchange\fP command and a short form of \fB\-\-commandprofile\fP
-for any other command (with the exception of \fBlvmconfig\fP command where the
-\fB\-\-profile\fP has special meaning, see \fBlvmconfig\fP(8) for more information).
-.
-.HP
-.BR \-\-reportformat
-.IR {basic|json}
-.br
-Overrides current output format for reports which is defined globally by
-\fBreport/output_format\fP configuration setting in \fBlvm.conf\fP(5).
-The \fBbasic\fP format is the original format with columns and rows and
-if there is more than one report per command, each report is prefixed
-with report's name for identification. The \fBjson\fP stands for report
-output in JSON format.
-.HP
-.BR \-\-config
-.IR ConfigurationString
-.br
-Uses the ConfigurationString as direct string representation of the configuration
-to override the existing configuration. The ConfigurationString is of exactly
-the same format as used in any LVM configuration file. See \fBlvm.conf\fP(5)
-for more information about \fBdirect config override on command line\fP and the
-way it fits with other LVM configuration methods.
-.
 .SH VALID NAMES
 .
 The valid characters for VG and LV names are:


