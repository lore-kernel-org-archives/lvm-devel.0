From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 12 Mar 2018 17:31:47 -0400
Subject: master - dev_manager: always activate RAID SubLVs readwrite
Message-ID: <201803122131.w2CLVlFn003047@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0646fd465eef51f3cfbd2219a0992af27d61ae14
Commit:        0646fd465eef51f3cfbd2219a0992af27d61ae14
Parent:        dd88a0f05cb27d54aa74960bbe9370fa37197cdc
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Mar 12 22:21:13 2018 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Mar 12 22:29:54 2018 +0100

dev_manager: always activate RAID SubLVs readwrite

RaidLVs on read_only_volume_list have their SubLVs
activated readonly thus disabling metadata updates
or image resynchronization/recovery.  Bug also causes
automatic repairs to fail.

Fix by always activating the RAID SubLVs readwrite.

Resolves: rhbz1208269
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |    3 +++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 40f81f5..177a2fe 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Activate RAID SubLVs on read_only_volume_list readwrite
   Offer convenience type raid5_n converting to raid10
   Automatically avoid reading invalid snapshots during device scan.
   Ensure COW device is writable even for read-only thick snapshots.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 6b042fb..f4d602f 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -80,6 +80,9 @@ int read_only_lv(const struct logical_volume *lv, const struct lv_activate_opts
 	if (layer && lv_is_cow(lv))
 		return 0; /* Keep snapshot's COW volume writable */
 
+	if (lv_is_raid_image(lv) || lv_is_raid_metadata(lv))
+		return 0; /* Keep RAID SubLvs writable */
+
 	return (laopts->read_only || !(lv->status & LVM_WRITE));
 }
 


