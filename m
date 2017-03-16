From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 16 Mar 2017 18:11:51 -0400
Subject: master - man: lvmraid(7) clarifications
Message-ID: <201703162211.v2GMBpqM023378@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ad4158bac72418ddd044110ab3663757cea6a649
Commit:        ad4158bac72418ddd044110ab3663757cea6a649
Parent:        4a3e30d1026d9bde85cda325b1c0a704e980b7db
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 16 23:10:57 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 16 23:10:57 2017 +0100

man: lvmraid(7) clarifications

---
 man/lvmraid.7_main |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/man/lvmraid.7_main b/man/lvmraid.7_main
index d738cf8..8ac59c6 100644
--- a/man/lvmraid.7_main
+++ b/man/lvmraid.7_main
@@ -273,16 +273,16 @@ written.
 The RAID implementation keeps track of which parts of a RAID LV are
 synchronized.  This uses a bitmap saved in the RAID metadata.  The bitmap
 can exclude large parts of the LV from synchronization to reduce the
-amount of work.  Without this, the entire LV would need to be synchronized
-every time it was activated.  When a RAID LV is first created and
-activated the first synchronization is called initialization.
+amount of work after a crash.  Without this, the entire LV would need
+to be synchronized every time it was activated.  When a RAID LV is
+first created and activated the first synchronization is called initialization.
 
 Automatic synchronization happens when a RAID LV is activated, but it is
 usually partial because the bitmaps reduce the areas that are checked.
-A full sync may become necessary when devices in the RAID LV are changed.
+A full sync becomes necessary when devices in the RAID LV are replaced.
 
 The synchronization status of a RAID LV is reported by the
-following command, where "image synced" means sync is complete:
+following command, where "Cpy%Sync" = "100%" means sync is complete:
 
 .B lvs -a -o name,sync_percent
 
@@ -824,8 +824,8 @@ synchronous.
 
 RAID takeover is converting a RAID LV from one RAID level to another, e.g.
 raid5 to raid6.  Changing the RAID level is usually done to increase or
-decrease resilience to device failures.  This is done using lvconvert and
-specifying the new RAID level as the LV type:
+decrease resilience to device failures or to restripe LVs.  This is done
+using lvconvert and specifying the new RAID level as the LV type:
 
 .B lvconvert --type
 .I RaidLevel


