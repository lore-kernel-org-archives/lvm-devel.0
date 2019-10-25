From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Oct 2019 18:55:53 -0400
Subject: stable-2.02 - WHATS_NEW
Message-ID: <201910252255.x9PMtro3012097@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5ee3d6dbdffc47467727d8c89fc91d84aa97189a
Commit:        5ee3d6dbdffc47467727d8c89fc91d84aa97189a
Parent:        9a8bff003bb5cc64f785db7190c323cf6a714789
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 26 00:48:00 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Oct 26 00:48:00 2019 +0200

WHATS_NEW

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a157986..4669443 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.187 - 
 ===================================
+  Fix activation order when removing merged snapshot.
   Add lvextend-raid.sh to check on RaidLV extensions synchronization.
   Fix lvmetad shutdown and avoid lenghty timeouts when rebooting system.
   Prevent creating VGs with PVs with different logical block sizes.


