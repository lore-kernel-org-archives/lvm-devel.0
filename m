From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 18 Apr 2014 01:48:03 +0000 (UTC)
Subject: master - reports: Use X for unknown LV attr when no dm.
Message-ID: <20140418014803.B6A8360317@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=177ece01a9b67c60818049084555a877f9e236e0
Commit:        177ece01a9b67c60818049084555a877f9e236e0
Parent:        e8a3ba18659404b4ebded504a37623eeae8cc830
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Apr 18 02:23:39 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Apr 18 02:23:39 2014 +0100

reports: Use X for unknown LV attr when no dm.

It's safer not to tell people an LV is inactive when we aren't sure.
---
 WHATS_NEW             |    2 ++
 lib/display/display.c |    2 +-
 lib/metadata/lv.c     |    9 +++++++--
 man/lvs.8.in          |    8 +++++---
 4 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 53db07b..62f0959 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.107 - 
 ==================================
+  Use X for LV attributes that are unknown when activation disabled.
+  Only output lvdisplay 'LV Status' field when activation is enabled.
   Use lvmetad_used() in pvscan instead of config_tree.
   Configure --enable-udev-systemd-background-jobs if not disabled explicitly.
   Add lvmdump -s to collect system info and context (currently systemd only).
diff --git a/lib/display/display.c b/lib/display/display.c
index 810097a..3bcf439 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -640,7 +640,7 @@ int lvdisplay_full(struct cmd_context *cmd,
 
 	if (inkernel && info.suspended)
 		log_print("LV Status              suspended");
-	else
+	else if (activation())
 		log_print("LV Status              %savailable",
 			  inkernel ? "" : "NOT ");
 
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 4549f03..8445d16 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -612,7 +612,10 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 
 	repstr[3] = (lv->status & FIXED_MINOR) ? 'm' : '-';
 
-	if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) && info.exists) {
+	if (!activation()) {
+		repstr[4] = 'X';		/* Unknown */
+		repstr[5] = 'X';		/* Unknown */
+	} else if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) && info.exists) {
 		if (info.suspended)
 			repstr[4] = 's';	/* Suspended */
 		else if (info.live_table)
@@ -681,7 +684,9 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 		repstr[8] = 'p';
 	else if (lv_is_raid_type(lv)) {
 		uint64_t n;
-		if (!_lv_raid_healthy(lv))
+		if (!activation())
+			repstr[8] = 'X';	/* Unknown */
+		else if (!_lv_raid_healthy(lv))
 			repstr[8] = 'r';  /* RAID needs 'r'efresh */
 		else if (lv->status & RAID) {
 			if (lv_raid_mismatch_count(lv, &n) && n)
diff --git a/man/lvs.8.in b/man/lvs.8.in
index 95eb25a..7297ee9 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -154,9 +154,10 @@ fixed (m)inor
 .IP 5 3
 State: (a)ctive, (s)uspended, (I)nvalid snapshot, invalid (S)uspended snapshot,
 snapshot (m)erge failed, suspended snapshot (M)erge failed,
-mapped (d)evice present without tables, mapped device present with (i)nactive table
+mapped (d)evice present without tables, mapped device present with (i)nactive table,
+(X) unknown
 .IP 6 3
-device (o)pen
+device (o)pen, (X) unknown
 .IP 7 3
 Target type: (m)irror, (r)aid, (s)napshot, (t)hin, (u)nknown, (v)irtual.
 This groups logical volumes related to the same kernel target together.  So,
@@ -168,7 +169,8 @@ snapshots of thin volumes using the new thin provisioning driver appear as (t).
 .IP 8 3
 Newly-allocated data blocks are overwritten with blocks of (z)eroes before use.
 .IP 9 3
-Volume Health: (p)artial, (r)efresh needed, (m)ismatches exist, (w)ritemostly.
+Volume Health: (p)artial, (r)efresh needed, (m)ismatches exist, (w)ritemostly,
+(X) unknown.
 (p)artial signifies that one or more of the Physical Volumes this Logical
 Volume uses is missing from the system.  (r)efresh signifies that one or
 more of the Physical Volumes this RAID Logical Volume uses had suffered a


