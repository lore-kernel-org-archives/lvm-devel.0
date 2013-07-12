From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 12 Jul 2013 19:39:06 +0000 (UTC)
Subject: master - lvs: add 's(k)ip activatoin' lv_attr field
Message-ID: <20130712193906.D1C3660DEE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=283c93a85878cfb67e1c9f0045065dbc0d63bca6
Commit:        283c93a85878cfb67e1c9f0045065dbc0d63bca6
Parent:        ab789c1bcfce3e9ad5032ad85b2f8a3171a6dbfb
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 11 14:05:05 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jul 12 20:54:17 2013 +0200

lvs: add 's(k)ip activatoin' lv_attr field

A new 10-th bit in lvs lv_attr field to indicate whether an LV
has the ACTIVATION_SKIP flag attached (stored in metadata).
---
 lib/metadata/lv.c |    7 ++++++-
 man/lvs.8.in      |    2 ++
 2 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 0742562..4d3a259 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -530,7 +530,7 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	struct lv_segment *seg;
 	char *repstr;
 
-	if (!(repstr = dm_pool_zalloc(mem, 10))) {
+	if (!(repstr = dm_pool_zalloc(mem, 11))) {
 		log_error("dm_pool_alloc failed");
 		return 0;
 	}
@@ -664,6 +664,11 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 			repstr[8] = 'w';  /* sub-LV has 'w'ritemostly */
 	}
 
+	if (lv->status & LV_ACTIVATION_SKIP)
+		repstr[9] = 'k';
+	else
+		repstr[9] = '-';
+
 out:
 	return repstr;
 }
diff --git a/man/lvs.8.in b/man/lvs.8.in
index 013740f..a020bf7 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -176,6 +176,8 @@ of a RAID logical volume will clear this flag if no additional discrepancies
 are found.  ("check" and "repair" of a RAID Logical Volume can be done via
 the 'lvchange' command.)  (w)ritemostly signifies the devices in a RAID 1
 logical volume that have been marked write-mostly.
+.IP 10 3
+(n)o activation: this volume is flagged to be skipped during activation.
 .RE
 .TP
 .BR \-O ", " \-\-sort


