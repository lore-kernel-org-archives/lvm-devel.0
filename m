From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 15 Mar 2017 20:51:00 -0400
Subject: master - man: reinstate lvmchange man page for now
Message-ID: <201703160051.v2G0p0u2022835@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6d6ab310e5a848737a50e1a2c8e3659912e337c7
Commit:        6d6ab310e5a848737a50e1a2c8e3659912e337c7
Parent:        07ded8059cbd36a8104491dc81907325f3413919
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Mar 16 00:46:35 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Mar 16 00:46:35 2017 +0000

man: reinstate lvmchange man page for now

---
 man/lvm.8_main       |    5 +----
 man/lvmchange.8_main |   10 ++++++++++
 2 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/man/lvm.8_main b/man/lvm.8_main
index 1f3247a..1166375 100644
--- a/man/lvm.8_main
+++ b/man/lvm.8_main
@@ -205,9 +205,6 @@ Display attributes of a Logical Volume.
 .B lvextend
 Extend the size of a Logical Volume.
 .TP
-.B lvmchange
-Change attributes of the Logical Volume Manager.
-.TP
 .B lvmconfig
 Display the configuration information after
 loading \fBlvm.conf\fP(5) and any other configuration files.
@@ -239,7 +236,7 @@ Scan (all disks) for Logical Volumes.
 .P
 The following commands are not implemented in LVM2 but might be
 in the future:
-.BR lvmsadc ", " lvmsar ", " pvdata .
+.BR lvmchange ", " lvmsadc ", " lvmsar ", " pvdata .
 .
 .SH VALID NAMES
 .
diff --git a/man/lvmchange.8_main b/man/lvmchange.8_main
new file mode 100644
index 0000000..dc6b3bd
--- /dev/null
+++ b/man/lvmchange.8_main
@@ -0,0 +1,10 @@
+.TH LVMCHANGE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
+.SH NAME
+lvmchange \(em change attributes of the logical volume manager
+.SH SYNOPSIS
+.B lvmchange
+.SH DESCRIPTION
+lvmchange is not currently supported under LVM2, although
+\fBdmsetup\fP(8) has a \fBremove_all\fP command.
+.SH SEE ALSO
+.BR dmsetup (8)


