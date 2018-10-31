From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 31 Oct 2018 03:51:12 -0400
Subject: 2018-06-01-stable - Update WHATS_NEW
Message-ID: <201810310751.w9V7pC0M003668@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=efa281685a4e2861973d131ccc31313ba31a97ef
Commit:        efa281685a4e2861973d131ccc31313ba31a97ef
Parent:        ab27d5dc2a5c3bf23ab8fed438f1542015dc723d
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Oct 29 18:36:59 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Oct 30 10:00:24 2018 +0100

Update WHATS_NEW

---
 WHATS_NEW |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a6bd6a3..79a8716 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.182 - 
 ==============================
+  Fix possible write race between last metadata block and the first extent.
+  Fix filtering of md 1.0 devices so they are not seen as duplicate PVs.
   Fix lvconvert striped/raid0/raid0_meta -> raid6 regression.
   Add After=rbdmap.service to {lvm2-activation-net,blk-availability}.service.
   Fix pvs with lvmetad to avoid too many open files from filter reads.


