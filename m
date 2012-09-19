From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 19 Sep 2012 11:50:09 +0000 (UTC)
Subject: master - lvs: add partial attribute
Message-ID: <20120919115009.2F9261696@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=290ae4791ef5eedaae2bc1cfa3645ac8073faf54
Commit:        290ae4791ef5eedaae2bc1cfa3645ac8073faf54
Parent:        b737ff01e4038d45798521448dc4ae4864d1b29a
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Sep 19 12:49:40 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Sep 19 12:49:40 2012 +0100

lvs: add partial attribute

---
 WHATS_NEW         |    1 +
 lib/metadata/lv.c |    7 ++++++-
 man/lvs.8.in      |    3 +++
 3 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 996f1a2..448f306 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98 -
 =================================
+  Add (p)artial attribute to lvs.
   Don't try to issue discards to a missing PV to avoid segfault.
   Prevent lvremove from removing LVs that have any part missing.
   Clear LV_NOSYNCED flag when a RAID1 LV is converted to a linear LV.
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 003e18d..33e3270 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -377,7 +377,7 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	struct lv_segment *seg;
 	char *repstr;
 
-	if (!(repstr = dm_pool_zalloc(mem, 9))) {
+	if (!(repstr = dm_pool_zalloc(mem, 10))) {
 		log_error("dm_pool_alloc failed");
 		return 0;
 	}
@@ -496,6 +496,11 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	else
 		repstr[7] = '-';
 
+	if (lv->status & PARTIAL_LV)
+		repstr[8] = 'p';
+	else
+		repstr[8] = '-';
+
 out:
 	return repstr;
 }
diff --git a/man/lvs.8.in b/man/lvs.8.in
index 97e1879..f31256c 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -157,6 +157,9 @@ Snapshots using the original device-mapper driver appear as (s); whereas
 snapshots of thin volumes using the new thin provisioning driver appear as (t).
 .IP 8 3
 Newly-allocated data blocks are overwritten with blocks of (z)eroes before use.
+.IP 9 3
+(p)artial: One or more of the Physical Volumes this Logical Volume uses is
+missing from the system.
 .RE
 .TP
 .BR \-O ", " \-\-sort


