From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  5 Oct 2012 08:38:13 +0000 (UTC)
Subject: master - lvm2api: fix data percent reporting for thin, snap
Message-ID: <20121005083813.0EAD8A0C55@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1da6c1495aea539ccd869b157162aaff9f96b385
Commit:        1da6c1495aea539ccd869b157162aaff9f96b385
Parent:        9efd3fb604ae34803bb2d4c94080c57d3efdba81
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 5 09:56:50 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 5 10:37:09 2012 +0200

lvm2api: fix data percent reporting for thin, snap

Use same logic for lvm2api as we use lvs reporting.
data_percent is meant to be superset for snap_percent.
---
 WHATS_NEW               |    1 +
 lib/report/properties.c |    6 ++++++
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 18e860c..44682a6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98 -
 =================================
+  Fix lvm2api data_percent reporting for thin volumes.
   Do not allow RAID LVs in a clustered volume group.
   Update lvconvert to support stacking of devs for thin meta/data devs.
   Support changes of permissions for thin snapshot volumes.
diff --git a/lib/report/properties.c b/lib/report/properties.c
index d2eac5e..4129b01 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -104,6 +104,12 @@ static percent_t _data_percent(const struct logical_volume *lv)
 {
 	percent_t perc;
 
+	if (lv_is_cow(lv))
+		return _snap_percent(lv);
+
+	if (lv_is_thin_volume(lv))
+		return lv_thin_percent(lv, 0, &perc) ? perc : PERCENT_INVALID;
+
 	return lv_thin_pool_percent(lv, 0, &perc) ? perc : PERCENT_INVALID;
 }
 


