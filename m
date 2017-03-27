From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 27 Mar 2017 14:51:00 -0400
Subject: master - build: fix x32 arch
Message-ID: <201703271851.v2RIp0Ah004582@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=78d004efa8a1809cea68283e6204edfa9d7c1091
Commit:        78d004efa8a1809cea68283e6204edfa9d7c1091
Parent:        36cac41115cca875f5d120631933b5dfb3c3c524
Author:        Mikulas Patocka <mpatocka@redhat.com>
AuthorDate:    Wed Feb 15 11:01:49 2017 -0500
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 27 20:50:19 2017 +0200

build: fix x32 arch

This patch fixed lvm2 compilation running on x32 arch.
(Using 64bit x86 cpu features but running on 32b address space,
so consuming less mem in VM).

On x32 arch 'time_t' is 64bit while 'long' is 32bit.
---
 lib/format1/import-export.c |    4 ++--
 lib/format_text/export.c    |    2 +-
 lib/report/report.c         |   10 +++++-----
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/lib/format1/import-export.c b/lib/format1/import-export.c
index c174031..c29527b 100644
--- a/lib/format1/import-export.c
+++ b/lib/format1/import-export.c
@@ -128,8 +128,8 @@ int import_pv(const struct format_type *fmt, struct dm_pool *mem,
 int generate_lvm1_system_id(struct cmd_context *cmd, char *s, const char *prefix)
 {
 
-	if (dm_snprintf(s, NAME_LEN, "%s%s%lu",
-			 prefix, cmd->hostname, time(NULL)) < 0) {
+	if (dm_snprintf(s, NAME_LEN, "%s%s" FMTu64,
+			prefix, cmd->hostname, (uint64_t)time(NULL)) < 0) {
 		log_error("Generated LVM1 format system_id too long");
 		return 0;
 	}
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 899ff45..473275d 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -350,7 +350,7 @@ static int _print_header(struct cmd_context *cmd, struct formatter *f,
 	     _utsname.version, _utsname.machine);
 	if (cmd->system_id && *cmd->system_id)
 		outf(f, "creation_host_system_id = \"%s\"", cmd->system_id);
-	outf(f, "creation_time = %lu\t# %s", t, ctime(&t));
+	outf(f, "creation_time = " FMTu64 "\t# %s", (uint64_t)t, ctime(&t));
 
 	return 1;
 }
diff --git a/lib/report/report.c b/lib/report/report.c
index 1421b31..d9880b2 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1008,7 +1008,7 @@ static int _translate_time_items(struct dm_report *rh, struct time_info *info,
 	dm_pool_free(info->mem, info->ti_list);
 	info->ti_list = NULL;
 
-	if (dm_snprintf(buf, sizeof(buf), "@%ld:@%ld", t1, t2) == -1) {
+	if (dm_snprintf(buf, sizeof(buf), "@" FMTd64 ":@" FMTd64, (int64_t)t1, (int64_t)t2) == -1) {
 		log_error("_translate_time_items: dm_snprintf failed");
 		return 0;
 	}
@@ -1063,10 +1063,10 @@ static void *_lv_time_handler_get_dynamic_value(struct dm_report *rh,
 						struct dm_pool *mem,
 						const char *data_in)
 {
-	time_t t1, t2;
+	int64_t t1, t2;
 	time_t *result;
 
-	if (sscanf(data_in, "@%ld:@%ld", &t1, &t2) != 2) {
+	if (sscanf(data_in, "@" FMTd64 ":@" FMTd64, &t1, &t2) != 2) {
 		log_error("Failed to get value for parsed time specification.");
 		return NULL;
 	}
@@ -1076,8 +1076,8 @@ static void *_lv_time_handler_get_dynamic_value(struct dm_report *rh,
 		return NULL;
 	}
 
-	result[0] = t1;
-	result[1] = t2;
+	result[0] = (time_t) t1; /* Validate range for 32b arch ? */
+	result[1] = (time_t) t2;
 
 	return result;
 }


