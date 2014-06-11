From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 11 Jun 2014 09:11:45 +0000 (UTC)
Subject: master - man: dmsetup manglename
Message-ID: <20140611091145.17D4460EE7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f845afe7cfc98ac1cde86e25d60c6eeeb530eebe
Commit:        f845afe7cfc98ac1cde86e25d60c6eeeb530eebe
Parent:        4db71422a243ac915ec835a46031f8458f0a8648
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 11 10:52:16 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 11 11:11:10 2014 +0200

man: dmsetup manglename

More updates to manglename option.
Add reference to LVM2 resource page, since for a long time,
this is the right places for sources for libdevmapper....
---
 man/dmsetup.8.in |   25 +++++++++++++++----------
 1 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/man/dmsetup.8.in b/man/dmsetup.8.in
index b257c89..10c63ab 100644
--- a/man/dmsetup.8.in
+++ b/man/dmsetup.8.in
@@ -192,13 +192,16 @@ When returning any table information from the kernel report on the
 inactive table instead of the live table.
 Requires kernel driver version 4.16.0 or above.
 .TP
-.IR \fB\-\-manglename \ < mangling_mode >
+.IR \fB\-\-manglename \ { none | hex | auto }
 Mangle any character not on a whitelist using mangling_mode when
 processing device-mapper device names and UUIDs. The names and UUIDs
-are mangled on input and unmangled on output where the mangling_mode
-is one of: none (no mangling), hex (always do the mangling) and auto
-(only do the mangling if not mangled yet, do nothing if already
-mangled, error on mixed; this is used by default).
+are mangled on input and unmangled on output where the mangling mode
+is one of:
+\fInone\fP (no mangling),
+\fIhex\fP (always do the mangling) and
+\fIauto\fP (only do the mangling if not mangled yet, do nothing
+if already mangled, error on mixed)
+Default mode is \fI#DEFAULT_MANGLING#\fP.
 Character whitelist: 0-9, A-Z, a-z, #+-.:=@_. This whitelist is
 also supported by udev. Any character not on a whitelist is replaced
 with its hex value (two digits) prefixed by \\x.
@@ -386,7 +389,7 @@ If neither is supplied, reads a table from standard input.
 .br
 Wait for any I/O in-flight through the device to complete, then
 replace the table with a new table that fails any new I/O
-sent to the device.  If successful, this should release any devices 
+sent to the device.  If successful, this should release any devices
 held open by the device's table(s).
 .br
 .HP
@@ -612,7 +615,7 @@ Each line of the table specifies a single target and is of the form:
 .B target_type
 .RI < target_args >
 .P
-Simple target types and <target_args> include: 
+Simple target types and <target_args> include:
 .HP
 .B linear
 .I destination_device start_sector
@@ -683,8 +686,8 @@ Supports snapshots of devices.
 .P
 To find out more about the various targets and their table formats and status
 lines, please read the files in the Documentation/device-mapper directory in
-the kernel source tree.  
-(Your distribution might include a copy of this information in the 
+the kernel source tree.
+(Your distribution might include a copy of this information in the
 documentation directory for the device-mapper package.)
 
 .SH EXAMPLES
@@ -718,11 +721,13 @@ A cookie to use for all relevant commands to synchronize with udev processing.
 It is an alternative to using \fB\-\-udevcookie\fP option.
 .TP
 .B DM_DEFAULT_NAME_MANGLING_MODE
-A default mangling mode. Defaults to "#DEFAULT_MANGLING#"
+A default mangling mode. Defaults to "\fI#DEFAULT_MANGLING#\fP"
 and it is an alternative to using \fB\-\-manglename\fP option.
 
 .SH AUTHORS
 Original version: Joe Thornber (thornber at redhat.com)
 
 .SH SEE ALSO
+LVM2 resource page https://www.sourceware.org/lvm2/
+.br
 Device-mapper resource page: http://sources.redhat.com/dm/


