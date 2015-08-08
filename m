From: Bryn Reeves <bmr@fedoraproject.org>
Date: Sat,  8 Aug 2015 10:49:42 +0000 (UTC)
Subject: master - libdm: fix report rows and headings memory and state leaks
Message-ID: <20150808104942.AD5AA601D5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cafe145ba2c77138b5b2c8832b4c784e4c9b5e76
Commit:        cafe145ba2c77138b5b2c8832b4c784e4c9b5e76
Parent:        974e7b9220f26154c5f491ca8ec49f57dd834c66
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Aug 7 17:08:54 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Sat Aug 8 11:35:10 2015 +0100

libdm: fix report rows and headings memory and state leaks

Not releasing objects back to the pool is fine for short-lived
pools since the memory will be freed when dm_pool_destroy() is
called.

Any pool that may be long-lived needs to be more careful to free
objects back to the pool to avoid leaking memory that will not be
reclaimed until the pool is destroyed at process exit time.

The report pool currently leaks each headings line and some row
data.

Although dm_report_output() tries to free the first allocated row
this may end up freeing a later row due to sorting of the row list
while reporting. Store a pointer to the first allocated row from
_do_report_obect() instead and free this at the end of
_output_as_columns(), _output_as_rows(), and dm_report_clear().

Also make sure to call dm_pool_free() for the headings line built
in _report_headings().

When dmstats is introduced it will maintain dm_report objects for
the whole lifetime of the process: without these changes a stats
report could leak around 600k in 10m (exact rate depends on field
selection and data values):

 top - 12:11:32 up 4 days,  3:16, 15 users,  load average: 0.01, 0.12, 0.14
  PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
 6473 root      20   0  130196   3124   2792 S   0.0  0.0   0:00.00 dmstats

 top - 12:22:04 up 4 days,  3:26, 15 users,  load average: 0.06, 0.11, 0.13
  PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
 6498 root      20   0  130836   3712   2752 S   0.0  0.0   0:00.60 dmstats

With this patch no increase in RSS is seen:

 top - 13:54:58 up 4 days,  4:59, 15 users,  load average: 0.12, 0.14, 0.14
  PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
13962 root      20   0  130196   2996   2688 S   0.0  0.0   0:00.00 dmstats

 top - 14:04:31 up 4 days,  5:09, 15 users,  load average: 1.02, 0.67, 0.36
  PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
13962 root      20   0  130196   2996   2688 S   0.3  0.0   0:00.32 dmstats

This also affects report output for repeating reports in the
DM_REPORT_OUTPUT_COLUMNS_AS_ROWS case; row state is not fully cleared for
the next iteration leading to progressive growth of the heading width:

vg_hex-lv_home:vg_hex-lv_swap:vg_hex-lv_root:luks-79733921-3f68-4c92-9eb7-d0aca4c6ba3e:vg_hex-lv_images
253:253:253:253:253
2:0:1:4:3
L--w:L--w:L--w:L--w:L--w
1:2:1:1:1
3:1:1:1:2
0:0:0:0:0
LVM-9t8ITqLZa6AuuyVoz5Olp1KwF9ZDBfOiv08BCGvF4WsJSqWUDUt7qtf2hEmjtVvo:LVM-9t8ITqLZa6AuuyVoz5Olp1KwF9ZDBfOiKf7XIiwdAYOJfaGhQe9fu26cTEICGgFS:LVM-9t8ITqLZa6AuuyVoz5Olp1KwF9ZDBfOiEZj7ZXbmrWDuGhd7vvi88VF0NdTMG8iA:CRYPT-LUKS1-797339213f684c929eb7d0aca4c6ba3e-luks-79733921-3f68-4c92-9eb7-d0aca4c6ba3e:LVM-9t8ITqLZa6AuuyVoz5Olp1KwF9ZDBfOi2rKredlBPnw2X7v1BiCuEpFo6gaE7BRw

:::::vg_hex-lv_home:vg_hex-lv_swap:vg_hex-lv_root:luks-79733921-3f68-4c92-9eb7-d0aca4c6ba3e:vg_hex-lv_images
:::::253:253:253:253:253
:::::2:0:1:4:3
:::::L--w:L--w:L--w:L--w:L--w
:::::1:2:1:1:1
:::::3:1:1:1:2
:::::0:0:0:0:0
:::::LVM-9t8ITqLZa6AuuyVoz5Olp1KwF9ZDBfOiv08BCGvF4WsJSqWUDUt7qtf2hEmjtVvo:LVM-9t8ITqLZa6AuuyVoz5Olp1KwF9ZDBfOiKf7XIiwdAYOJfaGhQe9fu26cTEICGgFS:LVM-9t8ITqLZa6AuuyVoz5Olp1KwF9ZDBfOiEZj7ZXbmrWDuGhd7vvi88VF0NdTMG8iA:CRYPT-LUKS1-797339213f684c929eb7d0aca4c6ba3e-luks-79733921-3f68-4c92-9eb7-d0aca4c6ba3e:LVM-9t8ITqLZa6AuuyVoz5Olp1KwF9ZDBfOi2rKredlBPnw2X7v1BiCuEpFo6gaE7BRw
---
 libdm/libdm-report.c |   35 +++++++++++++++++++++++++++++++----
 1 files changed, 31 insertions(+), 4 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 1c4d221..edb3fe2 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -35,6 +35,12 @@ struct selection {
 struct dm_report {
 	struct dm_pool *mem;
 
+	/**
+	 * Cache the first row allocated so that all rows and fields
+	 * can be disposed of in a single dm_pool_free() call.
+	 */
+	struct row *first_row;
+
 	/* To report all available types */
 #define REPORT_TYPES_ALL	UINT32_MAX
 	uint32_t report_types;
@@ -791,7 +797,7 @@ static struct field_properties * _add_field(struct dm_report *rh,
 {
 	struct field_properties *fp;
 
-	if (!(fp = dm_pool_zalloc(rh->mem, sizeof(struct field_properties)))) {
+	if (!(fp = dm_pool_zalloc(rh->mem, sizeof(*fp)))) {
 		log_error("dm_report: struct field_properties allocation "
 			  "failed");
 		return NULL;
@@ -1879,6 +1885,9 @@ static int _do_report_object(struct dm_report *rh, void *object, int do_output,
 		return 0;
 	}
 
+	if (!rh->first_row)
+		rh->first_row = row;
+
 	row->rh = rh;
 
 	if ((rh->flags & RH_SORT_REQUIRED) &&
@@ -3972,8 +3981,12 @@ static int _report_headings(struct dm_report *rh)
 		log_error("dm_report: Failed to generate report headings for printing");
 		goto bad;
 	}
-	log_print("%s", (char *) dm_pool_end_object(rh->mem));
 
+	/* print all headings */
+	heading = (char *) dm_pool_end_object(rh->mem);
+	log_print("%s", heading);
+
+	dm_pool_free(rh->mem, (void *)heading);
 	dm_free(buf);
 
 	return 1;
@@ -4162,6 +4175,19 @@ bad:
 	return 0;
 }
 
+static void _destroy_rows(struct dm_report *rh)
+{
+	/*
+	 * free the first row allocated to this report: since this is a
+	 * pool allocation this will also free all subsequently allocated
+	 * rows from the report and any associated string data.
+	 */
+	if(rh->first_row)
+		dm_pool_free(rh->mem, rh->first_row);
+	rh->first_row = NULL;
+	dm_list_init(&rh->rows);
+}
+
 static int _output_as_rows(struct dm_report *rh)
 {
 	const struct dm_report_field_type *fields;
@@ -4217,6 +4243,8 @@ static int _output_as_rows(struct dm_report *rh)
 		log_print("%s", (char *) dm_pool_end_object(rh->mem));
 	}
 
+	_destroy_rows(rh);
+
 	return 1;
 
       bad:
@@ -4265,8 +4293,7 @@ static int _output_as_columns(struct dm_report *rh)
 		dm_list_del(&row->list);
 	}
 
-	if (row)
-		dm_pool_free(rh->mem, row);
+	_destroy_rows(rh);
 
 	return 1;
 


