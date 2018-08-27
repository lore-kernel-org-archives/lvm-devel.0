From: David Teigland <teigland@sourceware.org>
Date: Mon, 27 Aug 2018 15:42:01 -0400
Subject: 2018-06-01-stable - WHATS_NEW: recent fixes
Message-ID: <201808271942.w7RJg1Ru025439@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ed749cdb5b6ccfe8d47c8f765bd71d3e6f6d8622
Commit:        ed749cdb5b6ccfe8d47c8f765bd71d3e6f6d8622
Parent:        5502f72e41dceb85d11ec562819ad6c5db6758ae
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Aug 27 14:41:29 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Aug 27 14:41:29 2018 -0500

WHATS_NEW: recent fixes

---
 WHATS_NEW |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1a00b78..b4af84b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,10 +1,12 @@
 Version 2.02.182 - 
 ==============================
+  Fix pvs with lvmetad to avoid too many open files from filter reads.
+  Fix pvscan --cache to avoid too many open files from filter reads.
+  Reduce max concurrent aios to avoid EMFILE with many devices.
   Fix lvconvert conversion attempts to linear.
   Fix lvconvert raid0/raid0_meta -> striped regression.
   Fix lvconvert --splitmirror for mirror type (2.02.178).
   Do not pair cache policy and cache metadata format.
-  Reduce max concurrent aios to avoid EMFILE with many devices.
 
 Version 2.02.181 - 01 August 2018
 =================================


