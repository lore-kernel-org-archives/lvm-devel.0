From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 19 Nov 2012 15:21:38 +0000 (UTC)
Subject: master - Document use_lvmetad and global_filter in lvm.conf.5.
Message-ID: <20121119152138.71DF51F39@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c907ee0351b226eb9e89929afcfc008985f32f97
Commit:        c907ee0351b226eb9e89929afcfc008985f32f97
Parent:        a7893ae8580d344f3f55ddb08892991edf17408f
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Nov 19 16:19:58 2012 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Nov 19 16:20:54 2012 +0100

Document use_lvmetad and global_filter in lvm.conf.5.

---
 man/lvm.conf.5.in |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/man/lvm.conf.5.in b/man/lvm.conf.5.in
index 79044fc..718cf4d 100644
--- a/man/lvm.conf.5.in
+++ b/man/lvm.conf.5.in
@@ -104,6 +104,12 @@ otherwise it is accepted.  As an example, to ignore /dev/cdrom you could use:
 .br
 \fBdevices { filter=["r|cdrom|"] }\fP
 .IP
+\fBglobal_filter\fP \(em Since "filter" is often overriden from command line, it
+is not suitable for system-wide device filtering (udev rules, lvmetad). To hide
+devices from LVM-specific udev processing and/or from lvmetad, you need to set
+global_filter. The syntax is the same as for normal "filter" above. Devices that
+fail the global_filter are not even opened by LVM.
+.IP
 \fBcache_dir\fP \(em Persistent filter cache file directory.
 Defaults to "#DEFAULT_CACHE_DIR#".
 .IP
@@ -354,6 +360,18 @@ if \fBlocking_type\fP is set to 1.  The default is \fB/var/lock/lvm\fP.
 library to load if \fBlocking_type\fP is set to 2.
 The default is \fBliblvm2clusterlock.so\fP.  If you need to write
 such a library, look at the lib/locking source code directory.
+.IP
+\fBuse_lvmetad\fP \(em Whether to use (trust) a running instance of lvmetad. If
+this is set to 0, all commands fall back to the usual scanning mechanisms. When
+set to 1 \fBand\fP when lvmetad is running (it is not auto-started), the volume
+group metadata and PV state flags are obtained from the lvmetad instance and no
+scanning is done by the individual commands. In a setup with lvmetad, lvmetad
+udev rules \fBmust\fP be set up for LVM to work correctly. Without proper udev
+rules, all changes in block device configuration will be \fBignored\fP until a
+manual 'pvscan --cache' is performed.
+.br
+If lvmetad has been running while use_lvmetad was 0, it \fBMUST\fP be stopped before
+changing use_lvmetad to 1 and started again afterwards.
 .TP
 \fBtags\fP \(em Host tag settings
 .IP


