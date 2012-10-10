From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 10 Oct 2012 15:18:36 +0000 (UTC)
Subject: master - man: dmsetup mangle also processes UUIDs now
Message-ID: <20121010151836.6EBE333A1@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a5306421ddd014598a2d94248ff9eb75df2ea2b0
Commit:        a5306421ddd014598a2d94248ff9eb75df2ea2b0
Parent:        470d1a2f5459bbbf82effb70b83a86329a170f85
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Oct 10 17:04:56 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Oct 10 17:16:15 2012 +0200

 man: dmsetup mangle also processes UUIDs now

---
 man/dmsetup.8.in |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/man/dmsetup.8.in b/man/dmsetup.8.in
index 90c715f..a4eac1e 100644
--- a/man/dmsetup.8.in
+++ b/man/dmsetup.8.in
@@ -193,9 +193,9 @@ Requires kernel driver version 4.16.0 or above.
 .TP
 .IR \fB\-\-manglename \ < mangling_mode >
 Mangle any character not on a whitelist using mangling_mode when
-processing device-mapper device names. The names are mangled on
-input and unmangled on output where the mangling_mode is one of:
-none (no mangling), hex (always do the mangling) and auto
+processing device-mapper device names and UUIDs. The names and UUIDs
+are mangled on input and unmangled on output where the mangling_mode
+is one of: none (no mangling), hex (always do the mangling) and auto
 (only do the mangling if not mangled yet, do nothing if already
 mangled, error on mixed; this is used by default).
 Character whitelist: 0-9, A-Z, a-z, #+-.:=@_. This whitelist is
@@ -401,10 +401,14 @@ driver, adding, changing or removing nodes as necessary.
 .B mangle
 .RI [ device_name ]
 .br
-Ensure existing device-mapper device name is in the correct mangled
+Ensure existing device-mapper device name and UUID is in the correct mangled
 form containing only whitelisted characters (supported by udev) and do
 a rename if necessary. Any character not on the whitelist will be mangled
-based on the --manglename settting.
+based on the --manglename setting. Automatic rename works only for device
+names and not for device UUIDs because the kernel does not allow changing
+the UUID of active devices. Any incorrect UUIDs are reported only and they
+must be manually corrected by deactivating the device first and then
+reactivating it with proper mangling mode used (see also --manglename).
 .br
 .HP
 .B remove


