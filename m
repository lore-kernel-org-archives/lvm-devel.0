From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  6 May 2016 14:30:29 +0000 (UTC)
Subject: master - WHATS_NEW: duplicate PVs
Message-ID: <20160506143029.0AA5060D7E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=144169b9b704a8c9693ee52bcc812c4f07d2ef8f
Commit:        144169b9b704a8c9693ee52bcc812c4f07d2ef8f
Parent:        e2d823eced26b97874399670a59c1d5b9c1fb54d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 6 09:30:01 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 6 09:30:01 2016 -0500

WHATS_NEW: duplicate PVs

---
 WHATS_NEW |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index eb442df..c8cee76 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,11 @@
 Version 2.02.153 - 
 ==================================
+  Change warning messages related to duplicate PVs.
+  A named device is always processed itself, not switched for a duplicate.
+  Add PV attr "d" and report field "duplicate" for duplicate PVs.
+  Add config setting to disallow VG changes when duplicate PVs exist.
+  Use device size and active LVs to choose the preferred duplicate PV.
+  Disable lvmetad when duplicate PVs are seen.
   Support --chunksize option also when caching LV when possible.
   Add function to check for target presence and version via 1 ioctl.
 


