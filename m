From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 26 Aug 2013 13:53:07 +0000 (UTC)
Subject: master - WHATS_NEW: for 4d3b5724e0b51782000a45027de00e0fed1c9833
Message-ID: <20130826135307.07CF460EAA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d34ab5e0d39543db4f17994432a49a77709b3487
Commit:        d34ab5e0d39543db4f17994432a49a77709b3487
Parent:        4d3b5724e0b51782000a45027de00e0fed1c9833
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Aug 26 15:52:15 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Aug 26 15:52:15 2013 +0200

WHATS_NEW: for 4d3b5724e0b51782000a45027de00e0fed1c9833

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index bf13023..c0744f6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.101 - 
 ===================================
+  Inform lvmetad about any lost PV label to make it in sync with system state.
   Support most of lvchange operations on stacked thin pool meta/data LVs.
   Add ability to pvmove RAID, mirror, and thin volumes.
   Make lvm2-activation-generator silent unless it's in error state.


