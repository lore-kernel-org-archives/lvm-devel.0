From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Feb 2021 12:01:29 +0000 (GMT)
Subject: stable-2.02 - WHATS_NEW: updates
Message-ID: <20210217120129.EB4D13896839@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=87e0b1a36faa54c6fc27837cac3be01a1553eaf9
Commit:        87e0b1a36faa54c6fc27837cac3be01a1553eaf9
Parent:        99d8b91422243f227c9324bdee2cd7d3d879ddbc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 17 12:34:25 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 17 12:59:36 2021 +0100

WHATS_NEW: updates

---
 WHATS_NEW | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index dafa4169a..7a9491a8b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,9 @@
 Version 2.02.188 - 
 ==================================
+  Avoid removing LVs on error path of lvconvert during creation volumes.
+  Fix crashing lvdisplay when thin volume was waiting for merge.
+  Support option --errorwhenfull when converting volume to thin-pool.
+  Improve thin-performance profile support conversion to thin-pool.
   Support resize of cached volumes.
   Allocation prints better error when metadata cannot fit on a single PV.
   Pvmove can better resolve full thin-pool tree move.


