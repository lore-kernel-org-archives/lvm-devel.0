From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 28 Aug 2013 12:59:29 +0000 (UTC)
Subject: master - man: lvmdump: add doc for -l and -u
Message-ID: <20130828125929.309A461019@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c9258e7f2eebd4fd188d95bcfb9a280d857d186f
Commit:        c9258e7f2eebd4fd188d95bcfb9a280d857d186f
Parent:        8b3664dc8dcfb5bf86be03f20e62617e0c49f5ec
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Aug 28 14:57:34 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Aug 28 14:59:15 2013 +0200

man: lvmdump: add doc for -l and -u

---
 man/lvmdump.8.in |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/man/lvmdump.8.in b/man/lvmdump.8.in
index 3d53420..306ae39 100644
--- a/man/lvmdump.8.in
+++ b/man/lvmdump.8.in
@@ -35,6 +35,10 @@ The content of the tarball is as follows:
 - if enabled with \-a, debug output of vgscan, pvscan and list of all available volume groups, physical volumes and logical volumes will be included
 .br
 - if enabled with \-c, cluster status info
+.br
+- if enabled with \-l, lvmetad state if running
+.br
+- if enabled with \-u, udev info and context
 .SH OPTIONS
 .TP
 .B \-a
@@ -54,11 +58,24 @@ produce the raw dump tree, rooted in \fIdirectory\fP.
 .B \-h
 Print help message
 .TP
+.B \-l
+Include \fBlvmetad\fP(8) daemon dump if it is running. The dump contains
+cached information that is currently stored in lvmetad: VG metadata,
+PV metadata and various mappings in between these metadata for quick
+access.
+.TP
 .B \-m
 Gather LVM metadata from the PVs
 This option generates a 1:1 dump of the metadata area from all PVs visible
 to the system, which can cause the dump to increase in size considerably.
 However, the metadata dump may represent a valuable diagnostic resource.
+.TP
+.B \-u
+Gather udev info and context: /etc/udev/udev.conf file, udev daemon version
+(output of 'udevadm info --version' command), udev rules currently used in the system
+(content of /lib/udev/rules.d and /etc/udev/rules.d directory),
+list of files in /lib/udev directory and dump of current udev
+database content (the output of 'udevadm info --export-db' command).
 .SH ENVIRONMENT VARIABLES
 .TP
 \fBLVM_BINARY\fP


