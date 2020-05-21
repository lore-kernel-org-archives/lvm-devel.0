From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 21 May 2020 13:09:36 +0000 (GMT)
Subject: master - build: make generate
Message-ID: <20200521130936.1048939724B2@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=70a45c44e89534b6d5f9adeb04620f43453c67bf
Commit:        70a45c44e89534b6d5f9adeb04620f43453c67bf
Parent:        d3b515cea54bae28c438eeef77cd3625d9b2a00c
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu May 21 15:02:31 2020 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu May 21 15:02:31 2020 +0200

build: make generate

---
 man/lvconvert.8_pregen | 63 ++++++++++++++++++++++++++++++++++++++++++++++++++
 man/lvcreate.8_pregen  | 53 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 116 insertions(+)

diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index b676e724d..74409848c 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -162,6 +162,18 @@ lvconvert - Change logical volume layout
  \fB-q\fP|\fB--quiet\fP
 .ad b
 .br
+.ad l
+    \fB--raidintegrity\fP \fBy\fP|\fBn\fP
+.ad b
+.br
+.ad l
+    \fB--raidintegrityblocksize\fP \fINumber\fP
+.ad b
+.br
+.ad l
+    \fB--raidintegritymode\fP \fIString\fP
+.ad b
+.br
 .ad l
  \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP
 .ad b
@@ -982,6 +994,28 @@ Poll LV to continue conversion.
 .br
 -
 
+Add or remove data integrity checksums to raid images.
+.br
+.P
+\fBlvconvert\fP \fB--raidintegrity\fP \fBy\fP|\fBn\fP \fILV\fP\fI_raid\fP
+.br
+.RS 4
+.ad l
+[    \fB--raidintegritymode\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--raidintegrityblocksize\fP \fINumber\fP ]
+.ad b
+.br
+[ COMMON_OPTIONS ]
+.RE
+.br
+.RS 4
+[ \fIPV\fP ... ]
+.RE
+-
+
 Common options for command:
 .
 .RS 4
@@ -1405,6 +1439,35 @@ Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
+\fB--raidintegrity\fP \fBy\fP|\fBn\fP
+.br
+Enable or disable data integrity checksums for raid images.
+.ad b
+.HP
+.ad l
+\fB--raidintegrityblocksize\fP \fINumber\fP
+.br
+The block size to use for dm-integrity on raid images.
+The integrity block size should usually match the device
+logical block size, or the file system block size.
+It may be less than the file system block size, but not
+less than the device logical block size.
+Possible values: 512, 1024, 2048, 4096.
+.ad b
+.HP
+.ad l
+\fB--raidintegritymode\fP \fIString\fP
+.br
+Use a journal (default) or bitmap for keeping integrity checksums consistent
+in case of a crash. The bitmap areas are recalculated after a crash, so corruption
+in those areas would not be detected. A journal does not have this problem.
+The journal mode doubles writes to storage, but can improve performance for
+scattered writes packed into a single journal write.
+bitmap mode can in theory achieve full write throughput of the device,
+but would not benefit from the potential scattered write optimization.
+.ad b
+.HP
+.ad l
 \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP
 .br
 Sets read ahead sector count of an LV.
diff --git a/man/lvcreate.8_pregen b/man/lvcreate.8_pregen
index a80f9f571..be8e78389 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -186,6 +186,18 @@ lvcreate - Create a logical volume
  \fB-q\fP|\fB--quiet\fP
 .ad b
 .br
+.ad l
+    \fB--raidintegrity\fP \fBy\fP|\fBn\fP
+.ad b
+.br
+.ad l
+    \fB--raidintegrityblocksize\fP \fINumber\fP
+.ad b
+.br
+.ad l
+    \fB--raidintegritymode\fP \fIString\fP
+.ad b
+.br
 .ad l
  \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP
 .ad b
@@ -425,6 +437,18 @@ Create a raid LV (a specific raid level must be used, e.g. raid1).
 [    \fB--[raid]maxrecoveryrate\fP \fISize\fP[k|UNIT] ]
 .ad b
 .br
+.ad l
+[    \fB--raidintegrity\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[    \fB--raidintegritymode\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--raidintegrityblocksize\fP \fINumber\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -1420,6 +1444,35 @@ Repeat once to also suppress any prompts with answer 'no'.
 .ad b
 .HP
 .ad l
+\fB--raidintegrity\fP \fBy\fP|\fBn\fP
+.br
+Enable or disable data integrity checksums for raid images.
+.ad b
+.HP
+.ad l
+\fB--raidintegrityblocksize\fP \fINumber\fP
+.br
+The block size to use for dm-integrity on raid images.
+The integrity block size should usually match the device
+logical block size, or the file system block size.
+It may be less than the file system block size, but not
+less than the device logical block size.
+Possible values: 512, 1024, 2048, 4096.
+.ad b
+.HP
+.ad l
+\fB--raidintegritymode\fP \fIString\fP
+.br
+Use a journal (default) or bitmap for keeping integrity checksums consistent
+in case of a crash. The bitmap areas are recalculated after a crash, so corruption
+in those areas would not be detected. A journal does not have this problem.
+The journal mode doubles writes to storage, but can improve performance for
+scattered writes packed into a single journal write.
+bitmap mode can in theory achieve full write throughput of the device,
+but would not benefit from the potential scattered write optimization.
+.ad b
+.HP
+.ad l
 \fB-r\fP|\fB--readahead\fP \fBauto\fP|\fBnone\fP|\fINumber\fP
 .br
 Sets read ahead sector count of an LV.


