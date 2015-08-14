From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri, 14 Aug 2015 12:56:28 +0000 (UTC)
Subject: master - dmstats: add 'interval' and 'interval_ns' report fields
Message-ID: <20150814125628.0C2C660AA7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9b3dc725060a243b7b6d849de9bafbdf3e9f5140
Commit:        9b3dc725060a243b7b6d849de9bafbdf3e9f5140
Parent:        4534f0fbcf6b83d29baf4af78f9027ff76fe0a7a
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Aug 13 17:29:15 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Aug 14 13:36:50 2015 +0100

dmstats: add 'interval' and 'interval_ns' report fields

Add a pair of fields to expose the current per-interval duation
estimate. The 'interval' field provides a real value in units of
seconds and the 'interval_ns' field provides the same quantity
expressed as a whole number of nanoseconds.
---
 man/dmstats.8.in |   14 ++++++++++++++
 tools/dmsetup.c  |   35 +++++++++++++++++++++++++++++++++++
 2 files changed, 49 insertions(+), 0 deletions(-)

diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index 3b9f032..f8d2949 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -501,6 +501,20 @@ The program ID value associated with this region.
 .br
 The auxiliary data value associated with this region.
 .br
+.HP
+.B interval_ns
+.br
+The estimated interval over which the current counter values have
+accumulated. The vaulue is reported as an interger expressed in units
+of nanoseconds.
+.br
+.HP
+.B interval
+.br
+The estimated interval over which the current counter values have
+accumulated. The value is reported as a real number in units of
+seconds.
+.br
 .SS Basic counters
 Basic counters provide access to the raw counter data from the kernel,
 allowing further processing to be carried out by another program.
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index c5be193..6e75e28 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -3376,6 +3376,39 @@ static int _dm_stats_aux_data_disp(struct dm_report *rh,
 	return dm_report_field_string(rh, field, (const char * const*) &aux_data);
 }
 
+static int _dm_stats_sample_interval_ns_disp(struct dm_report *rh,
+					     struct dm_pool *mem __attribute__((unused)),
+					     struct dm_report_field *field, const void *data,
+					     void *private __attribute__((unused)))
+{
+	/* FIXME: use internal interval estimate when supported by libdm */
+	return dm_report_field_uint64(rh, field, &_last_interval);
+}
+
+static int _dm_stats_sample_interval_disp(struct dm_report *rh,
+					  struct dm_pool *mem __attribute__((unused)),
+					  struct dm_report_field *field, const void *data,
+					  void *private __attribute__((unused)))
+{
+	char buf[64];
+	char *repstr;
+	double *sortval;
+
+	if (!(sortval = dm_pool_alloc(mem, sizeof(*sortval))))
+		return_0;
+
+	*sortval = (double)_last_interval / (double) NSEC_PER_SEC;
+
+	if (!dm_snprintf(buf, sizeof(buf), "%2.6f", *sortval))
+		return_0;
+
+	if (!(repstr = dm_pool_strdup(mem, buf)))
+		return_0;
+
+	dm_report_field_set_value(field, repstr, sortval);
+	return 1;
+}
+
 static int _dm_stats_rrqm_disp(struct dm_report *rh,
 			       struct dm_pool *mem __attribute__((unused)),
 			       struct dm_report_field *field, const void *data,
@@ -3917,6 +3950,8 @@ FIELD_F(STATS, SIZ, "ASize", 5, dm_stats_area_len, "area_len", "Area length.")
 FIELD_F(STATS, NUM, "#Areas", 6, dm_stats_area_count, "area_count", "Area count.")
 FIELD_F(STATS, STR, "ProgID", 6, dm_stats_program_id, "program_id", "Program ID.")
 FIELD_F(STATS, STR, "AuxDat", 6, dm_stats_aux_data, "aux_data", "Auxiliary data.")
+FIELD_F(STATS, NUM, "IntervalNSec", 10, dm_stats_sample_interval_ns, "interval_ns", "Sampling interval in nanoseconds.")
+FIELD_F(STATS, NUM, "Interval", 8, dm_stats_sample_interval, "interval", "Sampling interval.")
 
 /* Stats derived metrics */
 FIELD_F(STATS, NUM, "RRqM/s", 8, dm_stats_rrqm, "rrqm", "Read requests merged per second.")


