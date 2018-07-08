From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 8 Jul 2018 18:36:53 -0400
Subject: 2018-06-01-stable - WHATS_NEW: update
Message-ID: <201807082236.w68MarQV017281@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6fcb2ba440ebd40cdbe295b01dbbdea59ce9f895
Commit:        6fcb2ba440ebd40cdbe295b01dbbdea59ce9f895
Parent:        b8a7f6ba3de6aed38c2969693b6064a943ea8799
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 9 00:36:11 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 00:36:11 2018 +0200

WHATS_NEW: update

---
 WHATS_NEW |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 99dc056..5c5aac6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.180 - 
 =================================
+  Never send any discard ioctl with test mode.
+  Fix thin-pool alloc which needs same PV for data and metadata.
   Extend list of non-memlocked areas with newly linked libs.
   Enhance vgcfgrestore to check for active LVs in restored VG.
   lvconvert: provide possible layouts between linear and striped/raid


