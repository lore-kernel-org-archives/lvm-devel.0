From: David Teigland <teigland@sourceware.org>
Date: Mon, 6 Mar 2017 13:20:53 -0500
Subject: master - man/help: improve stripes option wording
Message-ID: <201703061820.v26IKrtR030590@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0b019c5406c27edfd00b502a95cb57e198c949a8
Commit:        0b019c5406c27edfd00b502a95cb57e198c949a8
Parent:        ef97360866d8a9221eb8d9b2d0e2f7e366bbd8ef
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Mar 6 12:01:11 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Mar 6 12:20:33 2017 -0600

man/help: improve stripes option wording

---
 tools/args.h |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 7c44256..7bb177d 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -974,15 +974,15 @@ arg(stripes_ARG, 'i', "stripes", number_VAL, 0, 0,
     "Specifies the number of stripes in a striped LV. This is the number of\n"
     "PVs (devices) that a striped LV is spread across. Data that\n"
     "appears sequential in the LV is spread across multiple devices in units of\n"
-    "the stripe size (see --stripesize). This does not apply to\n"
-    "existing allocated space, only newly allocated space can be striped.\n"
+    "the stripe size (see --stripesize). This does not change existing\n"
+    "allocated space, but only applies to space being allocated by the command.\n"
     "When creating a RAID 4/5/6 LV, this number does not include the extra\n"
     "devices that are required for parity. The largest number depends on\n"
-    "the RAID type (raid0: 64, raid10: 32, raid4/5: 63, raid6: 62.)\n"
-    "When unspecified, the default depends on the RAID type\n"
+    "the RAID type (raid0: 64, raid10: 32, raid4/5: 63, raid6: 62), and\n"
+    "when unspecified, the default depends on the RAID type\n"
     "(raid0: 2, raid10: 4, raid4/5: 3, raid6: 5.)\n"
-    "When unspecified, to stripe across all PVs of the VG,\n"
-    "set lvm.conf allocation/raid_stripe_all_devices=1.\n")
+    "To stripe a new raid LV across all PVs by default,\n"
+    "see lvm.conf allocation/raid_stripe_all_devices.\n")
 
 arg(stripesize_ARG, 'I', "stripesize", sizekb_VAL, 0, 0,
     "The amount of data that is written to one device before\n"


