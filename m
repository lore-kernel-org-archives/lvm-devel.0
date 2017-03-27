From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 27 Mar 2017 18:27:31 -0400
Subject: master - man: fix / typo
Message-ID: <201703272227.v2RMRVqU032097@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=19a72e601f64b21f0587f006f85da058737f077d
Commit:        19a72e601f64b21f0587f006f85da058737f077d
Parent:        7f312618447b0dc34901e77c45f468a738808d9b
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Mar 28 00:27:04 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Mar 28 00:27:04 2017 +0200

man: fix / typo

---
 man/lvmraid.7_main |    3 ++-
 tools/args.h       |    4 ++--
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/man/lvmraid.7_main b/man/lvmraid.7_main
index 3cbc84b..398a25d 100644
--- a/man/lvmraid.7_main
+++ b/man/lvmraid.7_main
@@ -8,7 +8,8 @@ lvmraid \(em LVM RAID
 LVM RAID is a way to create logical volumes (LVs) that use multiple physical
 devices to improve performance or tolerate device failure.  How blocks of
 data in an LV are placed onto physical devices is determined by the RAID
-level.  RAID levels are commonly referred to by number, e.g. raid1, raid5.
+level.  RAID levels are commonly referred by a level specific number
+suffixed to the string 'raid', e.g. raid1, raid5 or raid6.
 Selecting a RAID level involves tradeoffs among physical device
 requirements, fault tolerance, and performance.  A description of the RAID
 levels can be found at
diff --git a/tools/args.h b/tools/args.h
index b81e2c9..8d6b44d 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -837,7 +837,7 @@ arg(activate_ARG, 'a', "activate", activation_VAL, 0, 0,
     "\\fBn\\fP makes the LV inactive, or unavailable, only when possible.\n"
     "In some cases, creating an LV requires it to be active.\n"
     "For example, COW snapshots of an active origin LV can only\n"
-    "be created in the active state (this does not apply to thin snapshots.)\n"
+    "be created in the active state (this does not apply to thin snapshots).\n"
     "The --zero option normally requires the LV to be active.\n"
     "If autoactivation \\fBay\\fP is used, the LV is only activated\n"
     "if it matches an item in lvm.conf activation/auto_activation_volume_list.\n"
@@ -995,7 +995,7 @@ arg(stripes_ARG, 'i', "stripes", number_VAL, 0, 0,
     "devices that are required for parity. The largest number depends on\n"
     "the RAID type (raid0: 64, raid10: 32, raid4/5: 63, raid6: 62), and\n"
     "when unspecified, the default depends on the RAID type\n"
-    "(raid0: 2, raid10: 4, raid4/5: 3, raid6: 5.)\n"
+    "(raid0: 2, raid10: 2, raid4/5: 3, raid6: 5.)\n"
     "To stripe a new raid LV across all PVs by default,\n"
     "see lvm.conf allocation/raid_stripe_all_devices.\n")
 


