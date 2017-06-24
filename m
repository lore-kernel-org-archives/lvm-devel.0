From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 24 Jun 2017 11:59:40 -0400
Subject: master - libdm: implement dm_percent_to_round_float
Message-ID: <201706241559.v5OFxeXS026768@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2ef8da61eb968acb3c5c51cdfdc997e8bed90352
Commit:        2ef8da61eb968acb3c5c51cdfdc997e8bed90352
Parent:        0016b79c8b3223de7155fb4ec5fa799f7af1c811
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jun 24 13:24:26 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Jun 24 17:44:40 2017 +0200

libdm: implement dm_percent_to_round_float

Add function to adjust printing of percent values in better way.
Rounding here is going along following rules:

0% & 100% are always clearly reported with  .0 decimal points.

Values slightly above 0% we make sure a nearest bigger
non zero value with given precission is printed
(i.e. 0.01  for  %.2f  will be shown)

For values closely approaching 100% we again detect and adjust value
that is less then 100 when printed.
(i.e. 99.99  for %.2f will be shown).

For other values we are leaving them with standard rounding mechanism
since we care mainly about corner values 0 & 100 which need to be
printed precisely.
---
 WHATS_NEW_DM                        |    1 +
 libdm/.exported_symbols.DM_1_02_141 |    1 +
 libdm/libdevmapper.h                |   10 ++++++++++
 libdm/libdm-report.c                |   23 +++++++++++++++++++++++
 4 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 83df7cc..89f4a00 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.141 - 
 ===============================
+  Add dm_percent_to_round_float for adjusted percentage rounding.
   Reset array with dead rimage devices once raid gets in sync.
   Drop unneeded --config option from raid dmeventd plugin.
   dm_get_status_raid() handle better some incosistent md statuses.
diff --git a/libdm/.exported_symbols.DM_1_02_141 b/libdm/.exported_symbols.DM_1_02_141
new file mode 100644
index 0000000..8187642
--- /dev/null
+++ b/libdm/.exported_symbols.DM_1_02_141
@@ -0,0 +1 @@
+dm_percent_to_round_float
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 4bd32b4..5e77906 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -2836,6 +2836,16 @@ typedef enum {
 typedef int32_t dm_percent_t;
 
 float dm_percent_to_float(dm_percent_t percent);
+/*
+ * Return adjusted/rounded float for better percent value printing.
+ * Function ensures for given precision of digits:
+ * 100.0% returns only when the value is DM_PERCENT_100
+ *        for close smaller values rounds to nearest smaller value
+ * 0.0% returns only for value DM_PERCENT_0
+ *        for close bigger values rounds to nearest bigger value
+ * In all other cases returns same value as dm_percent_to_float()
+ */
+float dm_percent_to_round_float(dm_percent_t percent, unsigned digits);
 dm_percent_t dm_make_percent(uint64_t numerator, uint64_t denominator);
 
 /********************
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 7caba98..0a5d464 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -2425,6 +2425,29 @@ float dm_percent_to_float(dm_percent_t percent)
 	return (float) percent / DM_PERCENT_1 + 0.f;
 }
 
+float dm_percent_to_round_float(dm_percent_t percent, unsigned digits)
+{
+	static const float power10[] = {
+		1.f, .1f, .01f, .001f, .0001f, .00001f, .000001f,
+		.0000001f, .00000001f, .000000001f,
+		.0000000001f
+	};
+	float r;
+	float f = dm_percent_to_float(percent);
+
+	if (digits >= DM_ARRAY_SIZE(power10))
+		digits = DM_ARRAY_SIZE(power10) - 1; /* no better precision */
+
+	r = DM_PERCENT_1 * power10[digits];
+
+	if ((percent < r) && (percent > DM_PERCENT_0))
+		f = power10[digits];
+	else if ((percent > (DM_PERCENT_100 - r)) && (percent < DM_PERCENT_100))
+		f = (float) (DM_PERCENT_100 - r) / DM_PERCENT_1;
+
+	return f;
+}
+
 dm_percent_t dm_make_percent(uint64_t numerator, uint64_t denominator)
 {
 	dm_percent_t percent;


