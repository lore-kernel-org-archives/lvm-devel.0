From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 21 Jan 2015 20:40:56 +0000 (UTC)
Subject: master - lvmthin: update data space exhaustion
Message-ID: <20150121204056.35C7260772@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e0dc3d5efb6da6d45994f88e9d89e6657a183aac
Commit:        e0dc3d5efb6da6d45994f88e9d89e6657a183aac
Parent:        bea003e94ceec717c2c5b847a9a28ea3f8f42dad
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jan 21 11:08:12 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jan 21 14:31:36 2015 -0600

lvmthin: update data space exhaustion

---
 man/lvmthin.7.in |   56 ++++++++++++++++++++++++++++-------------------------
 1 files changed, 30 insertions(+), 26 deletions(-)

diff --git a/man/lvmthin.7.in b/man/lvmthin.7.in
index 86456a5..908701a 100644
--- a/man/lvmthin.7.in
+++ b/man/lvmthin.7.in
@@ -716,14 +716,16 @@ For a 1G pool, using 700M will trigger a resize to 1.2G. When the usage exceeds
 \&
 
 When properly managed, thin pool data space should be extended before it
-is exhausted (see previous section).  But, if thin pool data space is
-exhausted, the thin pool behavior is configurable with the --errorwhenfull
-y|n option to lvcreate or lvchange.  The errorwhenfull setting applies
-only to writes; reading thin LVs can continue even when data space is
-exhausted.
+is exhausted (see the section "Automatically extend thin pool LV").  If
+thin pool data space is already exhausted, it can still be extended (see
+the section "Manually manage free data space of thin pool LV".)
 
-Command to change the handling of data space exhaustion of an existing
-thin pool LV:
+The behavior of a full thin pool with no remaining data space is
+configurable with the --errorwhenfull y|n option to lvcreate or lvchange.
+The errorwhenfull setting applies only to writes; reading thin LVs can
+continue even when data space is exhausted.
+
+Command to change the handling of no data space of a thin pool:
 
 .B lvchange --errorwhenfull {y|n} VG/ThinPoolLV
 
@@ -737,24 +739,25 @@ is extended, the queued writes will be processed, and the thin pool will
 return to normal operation.
 
 While waiting to be extended, the thin pool will queue writes for up to 60
-seconds.  If data space has not been extended after this time, the queued
-writes will return an error to the caller, e.g. the file system.  This can
-result in file system corruption that may require fsck to repair.
+seconds (the default).  If data space has not been extended after this
+time, the queued writes will return an error to the caller, e.g. the file
+system.  This can result in file system corruption that may require fsck.
 
 The 60 second timeout can be changed or disabled with the dm\-thin\-pool
 kernel module option
 .B no_space_timeout.
 This option sets the number of seconds that thin pools will queue writes.
-If set to 0, writes will not time out.  Disabling timeouts may result in
-the system exhausting memory if too many writes are queued.
+If set to 0, writes will not time out.  Disabling timeouts can result in
+the system running out of resources, memory exhaustion, hung tasks, and
+deadlocks.  (The timeout applies to all thin pools on the system.)
 
 .B errorwhenfull y
 
 Writes to thin LVs immediately return an error, and no writes are queued.
 In the case of a file system, this can result in corruption that may
-require fsck to repair (the specific consequences depend on the thin LV
-user.)
+require fsck (the specific consequences depend on the thin LV user.)
 
+.B display data percent
 
 When data space is exhausted, the lvs command displays 100 under Data% for
 the thin pool LV:
@@ -765,24 +768,25 @@ the thin pool LV:
   pool0  vg           twi-a-tz-- 512.00m              100.00
 .fi
 
-A thin pool can run out of data blocks for any of the following reasons:
+.B causes
+
+A thin pool may run out of data space for any of the following reasons:
 
-1. Automatic extension of the thin pool is disabled, and the thin pool is
-not manually extended.  (Disabling automatic extension is not
-recommended.)
+.IP \[bu] 2
+Automatic extension of the thin pool is disabled, and the thin pool is not
+manually extended.  (Disabling automatic extension is not recommended.)
 
-2. The dmeventd daemon is not running and the thin pool is not manually
+.IP \[bu]
+The dmeventd daemon is not running and the thin pool is not manually
 extended.  (Disabling dmeventd is not recommended.)
 
-3. Automatic extension of the thin pool is too slow given the rate of
-writes to thin LVs in the pool.  (This can be addressed by tuning the
+.IP \[bu]
+Automatic extension of the thin pool is too slow given the rate of writes
+to thin LVs in the pool.  (This can be addressed by tuning the
 thin_pool_autoextend_threshold and thin_pool_autoextend_percent.)
 
-4. The VG does not have enough free blocks to extend the thin pool.
-
-The response to data space exhaustion is to extend the thin pool.  This is
-described in the section "Manually manage free data space of thin pool
-LV".
+.IP \[bu]
+The VG does not have enough free blocks to extend the thin pool.
 
 
 .SS Metadata space exhaustion


