From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Oct 2018 11:55:39 -0400
Subject: master - cov: ensure vars are set
Message-ID: <201810151555.w9FFtd4E020649@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=251366146727aac97af5de2eef855860d14910ca
Commit:        251366146727aac97af5de2eef855860d14910ca
Parent:        cbbdace00610ae25a5db8a7156b7d3a2779e4e0b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 15:27:45 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 17:49:44 2018 +0200

cov: ensure vars are set

Make sure, tmp_begin and tmp_end are always set, even for blind
coverity.
---
 device_mapper/libdm-report.c |    2 +-
 libdm/libdm-report.c         |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/device_mapper/libdm-report.c b/device_mapper/libdm-report.c
index cbd0d16..85d3d0f 100644
--- a/device_mapper/libdm-report.c
+++ b/device_mapper/libdm-report.c
@@ -2381,7 +2381,7 @@ static const char *_get_reserved(struct dm_report *rh, unsigned type,
 {
 	const struct dm_report_reserved_value *iter = implicit ? NULL : rh->reserved_values;
 	const struct dm_report_field_reserved_value *frv;
-	const char *tmp_begin, *tmp_end, *tmp_s = s;
+	const char *tmp_begin = NULL, *tmp_end = NULL, *tmp_s = s;
 	const char *name = NULL;
 	char c;
 
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 01255b4..a447017 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -2380,7 +2380,7 @@ static const char *_get_reserved(struct dm_report *rh, unsigned type,
 {
 	const struct dm_report_reserved_value *iter = implicit ? NULL : rh->reserved_values;
 	const struct dm_report_field_reserved_value *frv;
-	const char *tmp_begin, *tmp_end, *tmp_s = s;
+	const char *tmp_begin = NULL, *tmp_end = NULL, *tmp_s = s;
 	const char *name = NULL;
 	char c;
 


