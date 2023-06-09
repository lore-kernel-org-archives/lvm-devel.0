From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri,  9 Jun 2023 16:01:56 +0000 (GMT)
Subject: main - vdo: man updates for lvm_import_vdo
Message-ID: <20230609160156.E36833858C41@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=17ee5df8576acf628d88fd6840ce55aa1388d6d1
Commit:        17ee5df8576acf628d88fd6840ce55aa1388d6d1
Parent:        be6c34212b05d8c59c0ba68e26c56cddf61c9f04
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 9 13:24:19 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 9 18:01:16 2023 +0200

vdo: man updates for lvm_import_vdo

---
 man/lvm_import_vdo.8_main | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/man/lvm_import_vdo.8_main b/man/lvm_import_vdo.8_main
index 23755a3aa..20be6847d 100644
--- a/man/lvm_import_vdo.8_main
+++ b/man/lvm_import_vdo.8_main
@@ -61,6 +61,20 @@ Answer "yes" at any prompts.
 .BR --dry-run
 Print verbosely commands without running them.
 .
+.TP
+.BR --no-snapshot
+With this option conversion tool will not use snapshot (COW storage) for conversion
+in your $TMPDIR filesystem and it will directly manipulate with VDO device in-place.
+Warning: the snapshot usage makes the whole conversion transactional and 
+the snapshot can be just simply merged once the whole conversion
+has successfully proceeded. In the case of error the snapshot is just removed.
+Without the use of snapshot there is higher risk of problems with recoverability in
+case some unexpected error occurs.
+.
+.TP
+.BR --vdo-config
+Configuration file for VDO manager. Can be used to specify configuration for vdo manager.
+.
 .
 .SH DIAGNOSTICS
 .
@@ -83,6 +97,15 @@ The temporary directory name for mount points. Defaults to "\fI/tmp\fP".
 .B DM_DEV_DIR
 The device directory name.
 Defaults to "\fI/dev\fP" and must be an absolute path.
+.TP
+.B DM_UUID_PREFIX
+Specify uuid prefix for snapshot volume used during vdo conversion.
+.TP
+.B LVM_BINARY
+Allow to overide command called from lvm. Defaults to "\fIlvm\fP".
+.TP
+.B VDO_BINARY
+Allow to overide command called from vdo. Defaults to "\fIvdo\fP".
 .
 .SH SEE ALSO
 .

