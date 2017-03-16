From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 15 Mar 2017 22:11:02 -0400
Subject: master - man: Include lvmchange/lvmsar/lvmsadc content in lvm.8
Message-ID: <201703160211.v2G2B29s000932@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8ef93c756eecc2036f0c945c80972902f27970ca
Commit:        8ef93c756eecc2036f0c945c80972902f27970ca
Parent:        b0430b975ba96e6309e6c0dcd675b3ada32ffc70
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Mar 16 02:09:51 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Mar 16 02:09:51 2017 +0000

man: Include lvmchange/lvmsar/lvmsadc content in lvm.8

Remove separate lvmchange man page as the external command has also been
removed.
---
 man/Makefile.in      |    2 +-
 man/lvm.8_main       |    3 +++
 man/lvmchange.8_main |   10 ----------
 3 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index ae1739e..1e521fd 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -39,7 +39,7 @@ MAN8=lvm.8 lvmconf.8 lvmdump.8 lvm-config.8 lvm-dumpconfig.8 lvm-fullreport.8 \
      vgck.8 vgcreate.8 vgconvert.8 vgdisplay.8 vgexport.8 vgextend.8 \
      vgimport.8 vgimportclone.8 vgmerge.8 vgmknodes.8 vgreduce.8 vgremove.8 \
      vgrename.8 vgs.8 vgscan.8 vgsplit.8 \
-     lvmsar.8 lvmsadc.8 lvmdiskscan.8 lvmchange.8
+     lvmsar.8 lvmsadc.8 lvmdiskscan.8
 MAN8DM=dmsetup.8 dmstats.8 dmfilemapd.8
 MAN8CLUSTER=
 MAN8SYSTEMD_GENERATORS=lvm2-activation-generator.8
diff --git a/man/lvm.8_main b/man/lvm.8_main
index 32b87c4..dd60da0 100644
--- a/man/lvm.8_main
+++ b/man/lvm.8_main
@@ -233,6 +233,8 @@ Scan (all disks) for Logical Volumes.
 .P
 The following LVM1 commands are not implemented in LVM2:
 .BR lvmchange ", " lvmsadc ", " lvmsar ", " pvdata .
+For performance metrics, use \fBdmstats\fP(8) or to manipulate the kernel
+device-mapper driver used by LVM2 directly, use \fBdmsetup\fP(8).
 .
 .SH VALID NAMES
 .
@@ -543,4 +545,5 @@ directly.
 .BR lvmcache (7)
 
 .BR dmsetup (8),
+.BR dmstats (8),
 .BR readline (3)
diff --git a/man/lvmchange.8_main b/man/lvmchange.8_main
deleted file mode 100644
index dc6b3bd..0000000
--- a/man/lvmchange.8_main
+++ /dev/null
@@ -1,10 +0,0 @@
-.TH LVMCHANGE 8 "LVM TOOLS #VERSION#" "Sistina Software UK" \" -*- nroff -*-
-.SH NAME
-lvmchange \(em change attributes of the logical volume manager
-.SH SYNOPSIS
-.B lvmchange
-.SH DESCRIPTION
-lvmchange is not currently supported under LVM2, although
-\fBdmsetup\fP(8) has a \fBremove_all\fP command.
-.SH SEE ALSO
-.BR dmsetup (8)


