From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 25 Jan 2018 05:16:20 -0500
Subject: master - doc: Add VDO stacking document
Message-ID: <201801251016.w0PAGKDR010894@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=edb209776f9fec2ce2c0630560e238056c47c978
Commit:        edb209776f9fec2ce2c0630560e238056c47c978
Parent:        a1cfef9f26a47bf414240b8c87865caf6ac15092
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Jan 25 11:12:38 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Jan 25 11:15:23 2018 +0100

doc: Add VDO stacking document

---
 doc/vdo.md |   85 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 85 insertions(+), 0 deletions(-)

diff --git a/doc/vdo.md b/doc/vdo.md
new file mode 100644
index 0000000..a85518b
--- /dev/null
+++ b/doc/vdo.md
@@ -0,0 +1,85 @@
+# VDO - Compression and deduplication.
+
+Currently device stacking looks like this:
+
+    Physical x [multipath] x [partition] x [mdadm] x [LUKS] x [LVS] x [LUKS] x [FS|Database|...]
+
+Adding VDO:
+
+    Physical x [multipath] x [partition] x [mdadm] x [LUKS] x [LVS] x [LUKS] x VDO x [LVS] x [FS|Database|...]
+
+## Where VDO fits (and where it does not):
+
+### Backing devices for VDO volumes:
+
+1. Physical x [multipath] x [partition] x [mdadm],
+2. LUKS over (1) - full disk encryption.
+3. LVs (raids|mirror|stripe|linear) x [cache] over (1).
+4. LUKS over (3) - especially when using raids.
+
+Usual limitations apply:
+
+- Never layer LUKS over another LUKS - it makes no sense.
+- LUKS is better over the raids, than under.
+
+### Using VDO as a PV:
+
+1. under tpool
+    - The best fit - it will deduplicate additional redundancies among all
+      snapshots and will reduce the footprint.
+    - Risks: Resize! dmevent will not be able to handle resizing of tpool ATM.
+2. under corig
+    - Cache fits better under VDO device - it will reduce amount of data, and
+      deduplicate, so there should be more hits.
+    - This is useful to keep the most frequently used data in cache
+      uncompressed (if that happens to be a bottleneck.)
+3. under (multiple) linear LVs - e.g. used for VMs.
+
+### And where VDO does not fit:
+
+- *never* use VDO under LUKS volumes
+    - these are random data and do not compress nor deduplicate well,
+- *never* use VDO under cmeta and tmeta LVs
+    - these are random data and do not compress nor deduplicate well,
+- under raids
+    - raid{4,5,6} scrambles data, so they do not deduplicate well,
+    - raid{1,4,5,6,10} also causes amount of data grow, so more (duplicit in
+      case of raid{1,10}) work has to be done in order to find less duplicates.
+
+### And where it could be useful:
+
+- under snapshot CoW device - when there are multiple of those it could deduplicate
+
+### Things to decide
+
+- under integrity devices - it should work - mostly for data
+    - hash is not compressible and unique - it makes sense to have separate imeta and idata volumes for integrity devices
+
+### Future Integration of VDO into LVM:
+
+One issue is using both LUKS and RAID under VDO. We have two options:
+
+- use mdadm x LUKS x VDO+LV
+- use LV RAID x LUKS x VDO+LV - still requiring recursive LVs.
+
+Another issue is duality of VDO - it is a top level LV but it can be seen as a "pool" for multiple devices.
+
+- This is one usecase which could not be handled by LVM at the moment.
+- Size of the VDO is its physical size and virtual size - just like tpool.
+      - same problems with virtual vs physical size - it can get full, without exposing it fo a FS
+
+Another possible RFE is to split data and metadata:
+
+- e.g. keep data on HDD and metadata on SSD
+
+## Issues / Testing
+
+- fstrim/discard pass down - does it work with VDO?
+- VDO can run in synchronous vs. asynchronous mode
+    - synchronous for devices where write is safe after it is confirmed. Some devices are lying.
+    - asynchronous for devices requiring flush
+- multiple devices under VDO - need to find common options
+- pvmove - changing characteristics of underlying device
+- autoactivation during boot
+    - Q: can we use VDO for RootFS?
+


