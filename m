From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 25 Sep 2019 02:36:06 -0400
Subject: master - build: make generate
Message-ID: <201909250636.x8P6a6Ma012138@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dc3f0e067d2f402853551142bc917dc9c070d499
Commit:        dc3f0e067d2f402853551142bc917dc9c070d499
Parent:        9a8e6ad014c7dd6785ad6859551d68a264bad1f8
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Sep 25 08:27:49 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Sep 25 08:27:49 2019 +0200

build: make generate

---
 man/lvchange.8_pregen  |    4 +++-
 man/lvconvert.8_pregen |   39 +++++++++++++++++++++++++++++++++++++++
 man/pvscan.8_pregen    |   13 +++++++++++++
 3 files changed, 55 insertions(+), 1 deletions(-)

diff --git a/man/lvchange.8_pregen b/man/lvchange.8_pregen
index 110dd91..51172f2 100644
--- a/man/lvchange.8_pregen
+++ b/man/lvchange.8_pregen
@@ -360,7 +360,9 @@ required, after which the others are optional.
 .br
 -
 
-Resyncronize a mirror or raid LV.
+Resyncronize a mirror or raid LV. 
+.br
+Use to reset 'R' attribute on a not initially synchronized LV.
 .br
 .P
 \fBlvchange\fP \fB--resync\fP \fIVG\fP|\fILV\fP\fI_mirror_raid\fP|\fITag\fP|\fISelect\fP ...
diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index 846ea2d..b676e72 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -1807,6 +1807,45 @@ Attach a cache pool to an LV (infers --type cache).
 .br
 -
 
+Attach a cache to an LV, converts the LV to type cache.
+.br
+.P
+\fBlvconvert\fP \fB-H\fP|\fB--cache\fP \fB--cachevol\fP \fILV\fP \fILV\fP\fI_linear_striped_thinpool_raid\fP
+.br
+.RS 4
+.ad l
+[ \fB-Z\fP|\fB--zero\fP \fBy\fP|\fBn\fP ]
+.ad b
+.br
+.ad l
+[ \fB-c\fP|\fB--chunksize\fP \fISize\fP[k|UNIT] ]
+.ad b
+.br
+.ad l
+[    \fB--cachemetadataformat\fP \fBauto\fP|\fB1\fP|\fB2\fP ]
+.ad b
+.br
+.ad l
+[    \fB--cachemode\fP \fBwritethrough\fP|\fBwriteback\fP|\fBpassthrough\fP ]
+.ad b
+.br
+.ad l
+[    \fB--cachepolicy\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--cachesettings\fP \fIString\fP ]
+.ad b
+.br
+.ad l
+[    \fB--poolmetadatasize\fP \fISize\fP[m|UNIT] ]
+.ad b
+.br
+[ COMMON_OPTIONS ]
+.RE
+.br
+-
+
 Convert LV to type vdopool.
 .br
 .P
diff --git a/man/pvscan.8_pregen b/man/pvscan.8_pregen
index ed5ba92..94c4268 100644
--- a/man/pvscan.8_pregen
+++ b/man/pvscan.8_pregen
@@ -115,6 +115,10 @@ Autoactivate a VG when all PVs are online.
 [    \fB--minor\fP \fINumber\fP ]
 .ad b
 .br
+.ad l
+[    \fB--noudevsync\fP ]
+.ad b
+.br
 [ COMMON_OPTIONS ]
 .RE
 .br
@@ -289,6 +293,15 @@ Disable locking.
 .ad b
 .HP
 .ad l
+\fB--noudevsync\fP
+.br
+Disables udev synchronisation. The process will not wait for notification
+from udev. It will continue irrespective of any possible udev processing
+in the background. Only use this if udev is not running or has rules that
+ignore the devices LVM creates.
+.ad b
+.HP
+.ad l
 \fB-n\fP|\fB--novolumegroup\fP
 .br
 Only show PVs not belonging to any VG.


