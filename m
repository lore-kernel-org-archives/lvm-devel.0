From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:55:22 +0000 (UTC)
Subject: master - dmstats: rename 'aux_data' to 'user_data'
Message-ID: <20160705185522.0C9A060F23@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=14b74c360f22c21ca54b04c7520ef50109132bd1
Commit:        14b74c360f22c21ca54b04c7520ef50109132bd1
Parent:        fef4832a8509560293409a254c6a4e2ef39deb27
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Jul 5 15:30:31 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:53:17 2016 +0100

dmstats: rename 'aux_data' to 'user_data'

Make it clear that the "aux data" presented in reports is the user
data stored in the field (and does not include any library-internal
state such as group descriptors) by renaming the field to user_data
and changing the heading to "UserData".
---
 man/dmstats.8.in |   16 +++++++++-------
 tools/dmsetup.c  |   26 +++++++++++++-------------
 2 files changed, 22 insertions(+), 20 deletions(-)

diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index 5d8e910..2175097 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -271,8 +271,10 @@ optional suffix selects units of:
 .BR \-\-auxdata
 .IR aux_data
 .br
-Specify auxilliary data (a string) to be stored with a new region.
-.
+Specify user data (a word) to be stored with a new region. The value
+is added to any internal auxilliary data (for example, group
+information), and stored with the region in the aux_data field provided
+by the kernel. Whitespace is not permitted.
 .HP
 .BR \-\-clear
 .br
@@ -501,9 +503,9 @@ one milisecond can only be used when precise timestamps are enabled: if
 \fB\-\-precise\fP is not given and values less than one milisecond are
 used it will be enabled automatically.
 
-An optional \fBprogram_id\fP or \fBaux_data\fP string may be associated
+An optional \fBprogram_id\fP or \fBuser_data\fP string may be associated
 with the region. A \fBprogram_id\fP may then be used to select regions
-for subsequent list, print, and report operations. The \fBaux_data\fP
+for subsequent list, print, and report operations. The \fBuser_data\fP
 stores an arbitrary string and is not used by dmstats or the
 device-mapper kernel statistics subsystem.
 
@@ -724,7 +726,7 @@ when this value is close to 100%.
 Meta fields provide information about the groups, regions, or areas that
 the statistics values relate to. This includes the region and area
 identifier, start, length, and counts, as well as the program ID and
-auxiliary data values.
+user data values.
 .TP
 .B region_id
 Region identifier. This is a non-negative integer returned by the kernel
@@ -761,8 +763,8 @@ The number of areas in this region.
 .B program_id
 The program ID value associated with this region.
 .TP
-.B aux_data
-The auxiliary data value associated with this region.
+.B user_data
+The user data value associated with this region.
 .TP
 .B group_id
 Group identifier. This is a non-negative integer returned by the dmstats
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index d48e423..b468fee 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -3482,16 +3482,16 @@ static int _dm_stats_program_id_disp(struct dm_report *rh,
 	return dm_report_field_string(rh, field, (const char * const *) &program_id);
 }
 
-static int _dm_stats_aux_data_disp(struct dm_report *rh,
-				     struct dm_pool *mem __attribute__((unused)),
-				     struct dm_report_field *field, const void *data,
-				     void *private __attribute__((unused)))
+static int _dm_stats_user_data_disp(struct dm_report *rh,
+				    struct dm_pool *mem __attribute__((unused)),
+				    struct dm_report_field *field, const void *data,
+				    void *private __attribute__((unused)))
 {
 	const struct dm_stats *dms = (const struct dm_stats *) data;
-	const char *aux_data;
-	if (!(aux_data = dm_stats_get_current_region_aux_data(dms)))
+	const char *user_data;
+	if (!(user_data = dm_stats_get_current_region_aux_data(dms)))
 		return_0;
-	return dm_report_field_string(rh, field, (const char * const *) &aux_data);
+	return dm_report_field_string(rh, field, (const char * const *) &user_data);
 }
 
 static int _dm_stats_name_disp(struct dm_report *rh,
@@ -4280,7 +4280,7 @@ FIELD_F(STATS_META, SIZ, "ArOff", 5, dm_stats_area_offset, "area_offset", "Area
 FIELD_F(STATS_META, NUM, "#Areas", 6, dm_stats_area_count, "area_count", "Area count.")
 FIELD_F(STATS_META, NUM, "GrpID", 5, dm_stats_group_id, "group_id", "Group ID.")
 FIELD_F(STATS_META, STR, "ProgID", 6, dm_stats_program_id, "program_id", "Program ID.")
-FIELD_F(STATS_META, STR, "AuxDat", 6, dm_stats_aux_data, "aux_data", "Auxiliary data.")
+FIELD_F(STATS_META, STR, "UserData", 8, dm_stats_user_data, "user_data", "Auxiliary data.")
 FIELD_F(STATS_META, STR, "Precise", 7, dm_stats_precise, "precise", "Set if nanosecond precision counters are enabled.")
 FIELD_F(STATS_META, STR, "#Bins", 9, dm_stats_hist_bins, "hist_bins", "The number of histogram bins configured.")
 FIELD_F(STATS_META, STR, "Histogram Bounds", 16, dm_stats_hist_bounds, "hist_bounds", "Latency histogram bin boundaries.")
@@ -4760,7 +4760,7 @@ static int _do_stats_create_regions(struct dm_stats *dms,
 				    uint64_t len, int64_t step,
 				    int segments,
 				    const char *program_id,
-				    const char *aux_data)
+				    const char *user_data)
 {
 	uint64_t this_start = 0, this_len = len, region_id = UINT64_C(0);
 	const char *devname = NULL, *histogram = _string_args[BOUNDS_ARG];
@@ -4821,7 +4821,7 @@ static int _do_stats_create_regions(struct dm_stats *dms,
 			if (!dm_stats_create_region(dms, &region_id,
 						    this_start, this_len, step,
 						    precise, bounds,
-						    program_id, aux_data)) {
+						    program_id, user_data)) {
 				log_error("%s: Could not create statistics region.",
 					  devname);
 				goto out;
@@ -4844,7 +4844,7 @@ out:
 static int _stats_create(CMD_ARGS)
 {
 	struct dm_stats *dms;
-	const char *name, *aux_data = "", *program_id = DM_STATS_PROGRAM_ID;
+	const char *name, *user_data = "", *program_id = DM_STATS_PROGRAM_ID;
 	uint64_t start = 0, len = 0, areas = 0, area_size = 0;
 	int64_t step = 0;
 
@@ -4926,7 +4926,7 @@ static int _stats_create(CMD_ARGS)
 		program_id = DM_STATS_PROGRAM_ID;
 
 	if (_switches[AUX_DATA_ARG])
-		aux_data = _string_args[AUX_DATA_ARG];
+		user_data = _string_args[AUX_DATA_ARG];
 
 	if (!(dms = dm_stats_create(DM_STATS_PROGRAM_ID)))
 		return_0;
@@ -4956,7 +4956,7 @@ static int _stats_create(CMD_ARGS)
 
 	return _do_stats_create_regions(dms, name, start, len, step,
 					_switches[SEGMENTS_ARG],
-					program_id, aux_data);
+					program_id, user_data);
 
 bad:
 	dm_stats_destroy(dms);


