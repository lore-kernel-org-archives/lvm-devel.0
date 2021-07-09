From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri,  9 Jul 2021 18:51:42 +0000 (GMT)
Subject: main - man: vdoimport page
Message-ID: <20210709185142.5ED4D3858003@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=70c32d1e74b92f6055bcb688ed0e3bc8630f5489
Commit:        70c32d1e74b92f6055bcb688ed0e3bc8630f5489
Parent:        ed48cb26a31e8e5a12d82d96d8bec6bfc4d5b218
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 9 20:50:40 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 9 20:50:40 2021 +0200

man: vdoimport page

---
 man/vdoimport.8_main | 92 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 92 insertions(+)

diff --git a/man/vdoimport.8_main b/man/vdoimport.8_main
new file mode 100644
index 000000000..1f329099c
--- /dev/null
+++ b/man/vdoimport.8_main
@@ -0,0 +1,92 @@
+.TH "FSADM" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
+.
+.SH "NAME"
+.
+vdoimport \(em utility to import VDO volumes into a new volume group.
+.
+.SH SYNOPSIS
+.
+.PD 0
+.ad l
+.TP 10
+.B vdoimport
+.RI [ options ]
+.IR device
+.
+.PD
+.
+.SH DESCRIPTION
+.
+vdoimport utility imports VDO volumes created and managed by
+.BR vdo (8)
+manager into
+.BR lvm2 (8)
+managed VDO LV. This is realized by moving VDO superblock by 2MiB
+and creating lvm2 metadata at the front of this device. The operation is not reversible,
+thus after conversion to lvm2 the access to VDO data is only possible with
+.BR lvm2 (8)
+commands,
+.BR vdo (8)
+manager no longer control such volume.
+.
+.SH OPTIONS
+.
+.TP
+.BR -f | --force
+Bypass some sanity checks.
+.
+.TP
+.BR -h | --help
+Display the help text.
+.
+.TP
+.BR -n | --name
+Specifies the name of converted VDO LV. When the name is not specified,
+some automatic name is selected. In case the converted VDO volume is
+already using LV a backend device, the name of this LV is used for VDO LV.
+In this case also the of volume group must stay same.
+.
+.TP
+.BR -v | --verbose
+Be more verbose.
+.
+.TP
+.BR -y | --yes
+Answer "yes" at any prompts.
+.
+.TP
+.BR --dry-run
+Print commands without running them.
+.
+.
+.SH DIAGNOSTICS
+.
+On successful completion, the status code is 0.
+A status code of 1 is used for failure.
+.
+.SH EXAMPLES
+.
+Convert VDO volume created by vdo manager into logical volume LV1 with within volume group VG1.
+.P
+#
+.B vdoimport --name VG1/LV1 /dev/mapper/vdo-volume
+.
+.SH ENVIRONMENT VARIABLES
+.
+.TP
+.B TMPDIR
+The temporary directory name for mount points. Defaults to "\fI/tmp\fP".
+.TP
+.B DM_DEV_DIR
+The device directory name.
+Defaults to "\fI/dev\fP" and must be an absolute path.
+.
+.SH SEE ALSO
+.
+.nh
+.ad l
+.BR lvm (8),
+.BR lvm.conf (5),
+.P
+.BR vdo (8),
+.BR vdo2lvm (8),


