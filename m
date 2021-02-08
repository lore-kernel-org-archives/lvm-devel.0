From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Feb 2021 22:45:14 +0000 (GMT)
Subject: main - WHATS_NEW: updates
Message-ID: <20210208224514.3137C389681C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d280999b62c61b9769eb5c3a01a19fa54461259d
Commit:        d280999b62c61b9769eb5c3a01a19fa54461259d
Parent:        d422aa79249a069317ef71e872da42d6e2e6c344
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 8 23:16:54 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 8 23:43:38 2021 +0100

WHATS_NEW: updates

---
 WHATS_NEW | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index 42ea4f550..bf2c5806c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.03.12 - 
 ===================================
+  Support resize of cached volumes.
+  Disable autoactivation with global/event_activation=0.
   Check if lvcreate passes read_only_volume_list with tags and skips zeroing.
   Allocation prints better error when metadata cannot fit on a single PV.
   Pvmove can better resolve full thin-pool tree move.


