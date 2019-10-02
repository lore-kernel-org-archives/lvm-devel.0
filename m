From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 2 Oct 2019 11:15:49 -0400
Subject: stable-2.02 - WHATS_NEW: new lvextend-raid.sh test
Message-ID: <201910021515.x92FFnES004079@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=45ee63ede955d3188119d039faca26a159038f67
Commit:        45ee63ede955d3188119d039faca26a159038f67
Parent:        8632aa5fd371b9a2dc1996a65135b35e9c006036
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Oct 2 17:06:22 2019 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Oct 2 17:06:22 2019 +0200

WHATS_NEW: new lvextend-raid.sh test

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 80ba83d..a157986 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.187 - 
 ===================================
+  Add lvextend-raid.sh to check on RaidLV extensions synchronization.
   Fix lvmetad shutdown and avoid lenghty timeouts when rebooting system.
   Prevent creating VGs with PVs with different logical block sizes.
   Pvmove runs in exlusively activating mode for exclusively active LVs.


