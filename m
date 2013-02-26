From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 26 Feb 2013 14:18:22 +0000 (UTC)
Subject: master - report: add reporting fields for Embedding Area start and size
Message-ID: <20130226141822.E21CAA0C57@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ea69cda4b089f96b89c178bcef3ed44df86cf825
Commit:        ea69cda4b089f96b89c178bcef3ed44df86cf825
Parent:        86f65a3f2bf994a23aed7b29aae9bbab833d485a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Sat Feb 16 15:10:47 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 26 14:46:42 2013 +0100

report: add reporting fields for Embedding Area start and size

There are new reporting fields for Embedding Area: ea_start and ea_size.

An example of 1m Embedding Area and relevant reporting fields:
raw/~ # pvs -o pv_name,pe_start,ea_start,ea_size
  PV         1st PE  EA start EA size
  /dev/sda     2.00m    1.00m   1.00m
---
 lib/report/columns.h    |    2 ++
 lib/report/properties.c |    4 ++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 87b22ae..23d3e11 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -108,6 +108,8 @@ FIELD(PVS, pv, NUM, "Alloc", pe_alloc_count, 5, uint32, pv_pe_alloc_count, "Tota
 FIELD(PVS, pv, STR, "PV Tags", tags, 7, tags, pv_tags, "Tags, if any.", 0)
 FIELD(PVS, pv, NUM, "#PMda", id, 5, pvmdas, pv_mda_count, "Number of metadata areas on this device.", 0)
 FIELD(PVS, pv, NUM, "#PMdaUse", id, 8, pvmdasused, pv_mda_used_count, "Number of metadata areas in use on this device.", 0)
+FIELD(PVS, pv, NUM, "EA start", ea_start, 8, size64, ea_start, "Offset to the start of Embedding Area on the underlying device.", 0)
+FIELD(PVS, pv, NUM, "EA size", ea_size, 7, size64, ea_size, "Size of Embedding Area in current units.", 0)
 
 FIELD(VGS, vg, STR, "Fmt", cmd, 3, vgfmt, vg_fmt, "Type of metadata.", 0)
 FIELD(VGS, vg, STR, "VG UUID", id, 38, uuid, vg_uuid, "Unique identifier.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 6a4d960..08443d4 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -155,6 +155,10 @@ GET_PV_NUM_PROPERTY_FN(pv_mda_count, pv_mda_count(pv))
 #define _pv_mda_count_set _not_implemented_set
 GET_PV_NUM_PROPERTY_FN(pv_mda_used_count, pv_mda_used_count(pv))
 #define _pv_mda_used_count_set _not_implemented_set
+GET_PV_NUM_PROPERTY_FN(ea_start, SECTOR_SIZE * pv->ea_start)
+#define _ea_start_set _not_implemented_set
+GET_PV_NUM_PROPERTY_FN(ea_size, SECTOR_SIZE * pv->ea_size)
+#define _ea_size_set _not_implemented_set
 
 /* LV */
 GET_LV_STR_PROPERTY_FN(lv_uuid, lv_uuid_dup(lv))


