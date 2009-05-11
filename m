From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 11 May 2009 09:01:31 -0400
Subject: [PATCH 18/30] Update pv_pe_count and pv_pe_alloc_count fields to call liblvm 'get' functions.
In-Reply-To: <1242046903-15133-18-git-send-email-dwysocha@redhat.com>
References: <1242046903-15133-1-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-2-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-3-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-4-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-5-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-6-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-7-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-8-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-9-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-10-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-11-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-12-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-13-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-14-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-15-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-16-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-17-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-18-git-send-email-dwysocha@redhat.com>
Message-ID: <1242046903-15133-19-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Implement specific 'disp' functions for these two fields, and call into
already generated liblvm 'get' functions.

Should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/columns.h |    4 ++--
 lib/report/report.c  |   26 ++++++++++++++++++++++++++
 2 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 22b6ee0..f8d3516 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -89,8 +89,8 @@ FIELD(PVS, pv, NUM, "PSize", id, 5, pvsize, "pv_size", "Size of PV in current un
 FIELD(PVS, pv, NUM, "PFree", id, 5, pvfree, "pv_free", "Total amount of unallocated space in current units.")
 FIELD(PVS, pv, NUM, "Used", id, 4, pvused, "pv_used", "Total amount of allocated space in current units.")
 FIELD(PVS, pv, STR, "Attr", status, 4, pvstatus, "pv_attr", "Various attributes - see man page.")
-FIELD(PVS, pv, NUM, "PE", pe_count, 3, uint32, "pv_pe_count", "Total number of Physical Extents.")
-FIELD(PVS, pv, NUM, "Alloc", pe_alloc_count, 5, uint32, "pv_pe_alloc_count", "Total number of allocated Physical Extents.")
+FIELD(PVS, pv, NUM, "PE", id, 3, pecount, "pv_pe_count", "Total number of Physical Extents.")
+FIELD(PVS, pv, NUM, "Alloc", id, 5, pealloccount, "pv_pe_alloc_count", "Total number of allocated Physical Extents.")
 FIELD(PVS, pv, STR, "PV Tags", tags, 7, tags, "pv_tags", "Tags, if any.")
 FIELD(PVS, pv, NUM, "#PMda", id, 5, pvmdas, "pv_mda_count", "Number of metadata areas on this device.")
 
diff --git a/lib/report/report.c b/lib/report/report.c
index d2a5c0a..bb0c906 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -819,6 +819,32 @@ static int _pestart_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _size64_disp(rh, mem, field, &value, private);
 }
 
+static int _pecount_disp(struct dm_report *rh, struct dm_pool *mem,
+			 struct dm_report_field *field,
+			 const void *data, void *private)
+{
+	const struct physical_volume *pv =
+	    (const struct physical_volume *) data;
+	uint32_t value;
+
+	value = lvm_pv_get_pe_count(pv);
+
+	return _uint32_disp(rh, mem, field, &value, private);
+}
+
+static int _pealloccount_disp(struct dm_report *rh, struct dm_pool *mem,
+			      struct dm_report_field *field,
+			      const void *data, void *private)
+{
+	const struct physical_volume *pv =
+	    (const struct physical_volume *) data;
+	uint32_t value;
+
+	value = lvm_pv_get_pe_alloc_count(pv);
+
+	return _uint32_disp(rh, mem, field, &value, private);
+}
+
 static int _pvsize_disp(struct dm_report *rh, struct dm_pool *mem,
 			struct dm_report_field *field,
 			const void *data, void *private)
-- 
1.6.0.6


