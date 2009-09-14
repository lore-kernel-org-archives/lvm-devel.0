From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 14 Sep 2009 15:14:48 -0400
Subject: [PATCH 1/3] Update lvm and vgs man pages to clarify 'partial' is a VG missing PVs.
In-Reply-To: <1252955690-25500-1-git-send-email-dwysocha@redhat.com>
References: <1252955690-25500-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1252955690-25500-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 man/lvm.8.in |    3 ++-
 man/vgs.8.in |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/man/lvm.8.in b/man/lvm.8.in
index 247b241..2c4c0ce 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -182,7 +182,8 @@ See
 .TP
 \fB-P | --partial\fP
 When set, the tools will do their best to provide access to volume groups
-that are only partially available.  Where part of a logical volume is 
+that are only partially available (one or more physical volumes are
+missing from the system).  Where part of a logical volume is
 missing, \fB/dev/ioerror\fP will be substituted, and you could use
 \fBdmsetup (8)\fP to set this up to return I/O errors when accessed,
 or create it as a large block device of nulls.  Metadata may not be
diff --git a/man/vgs.8.in b/man/vgs.8.in
index c05a05a..2cb66cd 100644
--- a/man/vgs.8.in
+++ b/man/vgs.8.in
@@ -60,7 +60,7 @@ Resi(z)eable
 .IP 3 3
 E(x)ported
 .IP 4 3
-(p)artial
+(p)artial: one or more physical volumes are missing from the system
 .IP 5 3
 Allocation policy: (c)ontiguous, c(l)ing, (n)ormal, (a)nywhere, (i)nherited
 .IP 6 3
-- 
1.6.0.6


