From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 21 Mar 2017 13:19:13 -0400
Subject: master - WHATS_NEW: adjust to misordered raid parameters
Message-ID: <201703211719.v2LHJDGn029763@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1810162b510e25d4f07d07f83ba17a8ebc230c9c
Commit:        1810162b510e25d4f07d07f83ba17a8ebc230c9c
Parent:        1e4462dbfbd2bbe3590936df24b3ccd83110b158
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Mar 21 18:18:58 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Mar 21 18:18:58 2017 +0100

WHATS_NEW: adjust to misordered raid parameters

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index daca9e0..99a0bda 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Adjust to misordered raid parameters
   Conditionally reject raid convert to striped/raid0* after reshape
   Ensure raid6 upconversion restrictions
   Adjust mirror+raid DSOs to aforementioned lvconvert --repair


