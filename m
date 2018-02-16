From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 16 Feb 2018 11:11:09 -0500
Subject: master - doc: Fixing VDO document
Message-ID: <201802161611.w1GGB9pR017215@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1671b83585a6ee49448376c20834a9e89936a7f3
Commit:        1671b83585a6ee49448376c20834a9e89936a7f3
Parent:        f5401fbd34371dfed74f981eb1d4c5b4b3220cc2
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Feb 16 17:09:40 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Feb 16 17:10:54 2018 +0100

doc: Fixing VDO document

---
 doc/vdo.md |   59 +++++++++++++++++++++++++++++++++++++++--------------------
 1 files changed, 39 insertions(+), 20 deletions(-)

diff --git a/doc/vdo.md b/doc/vdo.md
index a85518b..5c5a33c 100644
--- a/doc/vdo.md
+++ b/doc/vdo.md
@@ -22,17 +22,25 @@ Usual limitations apply:
 - Never layer LUKS over another LUKS - it makes no sense.
 - LUKS is better over the raids, than under.
 
+Devices which are not best suitable as backing device:
+
+- thin volumes - at the moment it is not possible to take snapshot of active VDO volume on top of thin volume.
+
 ### Using VDO as a PV:
 
-1. under tpool
+1. under tdata
     - The best fit - it will deduplicate additional redundancies among all
       snapshots and will reduce the footprint.
     - Risks: Resize! dmevent will not be able to handle resizing of tpool ATM.
 2. under corig
-    - Cache fits better under VDO device - it will reduce amount of data, and
-      deduplicate, so there should be more hits.
     - This is useful to keep the most frequently used data in cache
-      uncompressed (if that happens to be a bottleneck.)
+      uncompressed or without deduplication if that happens to be a bottleneck.
+    - Cache may fit better under VDO device, depending on compressibility and
+      amount of duplicates, as
+        - compression will reduce amount of data, thus effectively increasing
+          size of cache,
+        - and deduplication may emphasize hotspots.
+    - Performance testing of your particular workload is strongly recommended.
 3. under (multiple) linear LVs - e.g. used for VMs.
 
 ### And where VDO does not fit:
@@ -50,36 +58,47 @@ Usual limitations apply:
 
 - under snapshot CoW device - when there are multiple of those it could deduplicate
 
+## Development
+
 ### Things to decide
 
-- under integrity devices - it should work - mostly for data
-    - hash is not compressible and unique - it makes sense to have separate imeta and idata volumes for integrity devices
+- under integrity devices
+    - VDO should work well for data blocks,
+    - but hashes are mostly unique and not compressible - were it possible it
+      would make sense to have separate imeta and idata volumes for integrity
+      devices.
 
 ### Future Integration of VDO into LVM:
 
 One issue is using both LUKS and RAID under VDO. We have two options:
 
 - use mdadm x LUKS x VDO+LV
-- use LV RAID x LUKS x VDO+LV - still requiring recursive LVs.
+- use LV RAID x LUKS x VDO+LV
+
+In both cases dmeventd will not be able to resize the volume at the moment.
 
-Another issue is duality of VDO - it is a top level LV but it can be seen as a "pool" for multiple devices.
+Another issue is duality of VDO - it can be used as a top level LV (with a
+filesystem on top) but it can be used as "pool" for multiple devices too.
 
-- This is one usecase which could not be handled by LVM at the moment.
-- Size of the VDO is its physical size and virtual size - just like tpool.
-      - same problems with virtual vs physical size - it can get full, without exposing it fo a FS
+This will be solved in similar way thin pools allow multiple volumes.
 
-Another possible RFE is to split data and metadata:
+Also VDO, has two sizes - its physical size and virtual size - and when
+overprovisioning, just like tpool, we face same problems - VDO can get full,
+without exposing it to a FS. dmeventd monitoring will be needed.
 
-- e.g. keep data on HDD and metadata on SSD
+Another possible RFE is to split data and metadata - keep data on HDD and metadata on SSD.
 
 ## Issues / Testing
 
 - fstrim/discard pass down - does it work with VDO?
-- VDO can run in synchronous vs. asynchronous mode
-    - synchronous for devices where write is safe after it is confirmed. Some devices are lying.
-    - asynchronous for devices requiring flush
-- multiple devices under VDO - need to find common options
-- pvmove - changing characteristics of underlying device
-- autoactivation during boot
-    - Q: can we use VDO for RootFS?
+- VDO can run in synchronous vs. asynchronous mode:
+    - synchronous for devices where write is safe after it is confirmed. Some
+      devices are lying.
+    - asynchronous for devices requiring flush.
+- Multiple devices under VDO - need to find and expose common properties, or
+  not allow grouping them together. (This is same for all volumes with more
+  physical devices below.)
+- pvmove changing characteristics of underlying device.
+- autoactivation during boot?
+    - Q: can we use VDO for RootFS? Dracut!
 


