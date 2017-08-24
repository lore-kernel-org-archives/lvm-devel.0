From: David Teigland <teigland@sourceware.org>
Date: Thu, 24 Aug 2017 11:25:50 -0400
Subject: master - man lvmthin: change fsck references
Message-ID: <201708241525.v7OFPoki015313@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=043ff47b0579bffaa63cb023d8850b0e749eb9ce
Commit:        043ff47b0579bffaa63cb023d8850b0e749eb9ce
Parent:        e71c3ff18719f240e92bb641b9b9a01b2619cc93
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 24 10:25:01 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Aug 24 10:25:01 2017 -0500

man lvmthin: change fsck references

to more generic terms like repair.
---
 man/lvmthin.7_main |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/man/lvmthin.7_main b/man/lvmthin.7_main
index 1ebeb65..251ba12 100644
--- a/man/lvmthin.7_main
+++ b/man/lvmthin.7_main
@@ -397,7 +397,7 @@ the pmspare LV.
 
 If thin pool metadata is damaged, it may be repairable.
 Checking and repairing thin pool metadata is analagous to
-running fsck on a file system.
+running fsck/repair on a file system.
 
 When a thin pool LV is activated, lvm runs the thin_check command
 to check the correctness of the metadata on the pool metadata LV.
@@ -774,7 +774,7 @@ While waiting to be extended, the thin pool will queue writes for up to 60
 seconds (the default).  If data space has not been extended after this
 time, the queued writes will return an error to the caller, e.g. the file
 system.  This can result in file system corruption for non-journaled file
-systems that may require fsck.  When a thin pool returns errors for writes
+systems that may require repair.  When a thin pool returns errors for writes
 to a thin LV, any file system is subject to losing unsynced user data.
 
 The 60 second timeout can be changed or disabled with the dm-thin-pool
@@ -789,7 +789,7 @@ deadlocks.  (The timeout applies to all thin pools on the system.)
 
 Writes to thin LVs immediately return an error, and no writes are queued.
 In the case of a file system, this can result in corruption that may
-require fsck (the specific consequences depend on the thin LV user.)
+require fs repair (the specific consequences depend on the thin LV user.)
 
 .I data percent
 
@@ -858,7 +858,7 @@ repair.
 .br
    See "Manually manage free metadata space of a thin pool LV".
 
-4. Check and repair file system with fsck.
+4. Check and repair file system.
 
 
 .SS Automatic extend settings


