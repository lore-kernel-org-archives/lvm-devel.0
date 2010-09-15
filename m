From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 15 Sep 2010 11:36:02 -0400
Subject: [PATCH 10/19] Add vg_uuid, vg_attr, vg_tags 'get' functions.
In-Reply-To: <1284564971-26060-1-git-send-email-dwysocha@redhat.com>
References: <1284564971-26060-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1284564971-26060-11-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/properties.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/report/properties.c b/lib/report/properties.c
index fe867c0..1880ef7 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -142,11 +142,11 @@ static char *vg_system_id(const struct volume_group *vg)
 /* VG */
 GET_STR_PROPERTY_FN(vg_fmt, vg_fmt(vg))
 #define _vg_fmt_set _not_implemented
-#define _vg_uuid_get _not_implemented
+GET_STR_PROPERTY_FN(vg_uuid, vg_uuid(vg))
 #define _vg_uuid_set _not_implemented
 GET_STR_PROPERTY_FN(vg_name, vg_name(vg))
 #define _vg_name_set _not_implemented
-#define _vg_attr_get _not_implemented
+GET_STR_PROPERTY_FN(vg_attr, vg_attr(vg->vgmem, vg))
 #define _vg_attr_set _not_implemented
 GET_NUM_PROPERTY_FN(vg_size, (SECTOR_SIZE * vg_size(vg)))
 #define _vg_size_set _not_implemented
@@ -172,7 +172,7 @@ GET_NUM_PROPERTY_FN(snap_count, (snapshot_count(vg)))
 #define _snap_count_set _not_implemented
 GET_NUM_PROPERTY_FN(vg_seqno, vg->seqno)
 #define _vg_seqno_set _not_implemented
-#define _vg_tags_get _not_implemented
+GET_STR_PROPERTY_FN(vg_tags, vg_tags(vg))
 #define _vg_tags_set _not_implemented
 GET_NUM_PROPERTY_FN(vg_mda_count, (vg_mda_count(vg)))
 #define _vg_mda_count_set _not_implemented
-- 
1.7.2.1


