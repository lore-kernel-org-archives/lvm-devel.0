From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 15 Aug 2014 11:29:00 +0000 (UTC)
Subject: master - report: lvs: properly display 'o' for volume type bit and 'C' for target type bit in lv_attr field for cache origin LVs
Message-ID: <20140815112900.1FF1D60703@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1cd622d98ba837886fb70d33b1eda920b14ae405
Commit:        1cd622d98ba837886fb70d33b1eda920b14ae405
Parent:        8eba33510f95572316a743d6b68d5c7c31743672
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Aug 15 13:21:29 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Aug 15 13:28:43 2014 +0200

report: lvs: properly display 'o' for volume type bit and 'C' for target type bit in lv_attr field for cache origin LVs

Before this patch:
LV                 VG     Attr
[cache_orig_corig] vg     -wi-ao----

With this patch applied:
LV                 VG     Attr
[cache_orig_corig] vg     owi-aoC---
---
 lib/metadata/lv.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 9539369..0fbdfff 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -673,6 +673,8 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 		repstr[0] = 'l';
 	else if (lv_is_cow(lv))
 		repstr[0] = (lv_is_merging_cow(lv)) ? 'S' : 's';
+	else if (lv_is_cache_origin(lv))
+		repstr[0] = 'o';
 	else
 		repstr[0] = '-';
 
@@ -737,7 +739,7 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 
 	if (lv_is_thin_pool(lv) || lv_is_thin_volume(lv))
 		repstr[6] = 't';
-	else if (lv_is_cache_pool(lv) || lv_is_cache(lv))
+	else if (lv_is_cache_pool(lv) || lv_is_cache(lv) || lv_is_cache_origin(lv))
 		repstr[6] = 'C';
 	else if (lv_is_raid_type(lv))
 		repstr[6] = 'r';


