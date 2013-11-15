From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 15 Nov 2013 11:39:37 +0000 (UTC)
Subject: master - libdm: catch wrongly reported values
Message-ID: <20131115113937.193186135C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eb4b03768f3ae751518b77b69882539e0c864a90
Commit:        eb4b03768f3ae751518b77b69882539e0c864a90
Parent:        37b7c6707952b0cca2c583f2a48f997c94576a70
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 15 12:16:50 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 15 12:38:37 2013 +0100

libdm: catch wrongly reported values

Add internal error warning when string value is used
as sort value for numerical field.

Using log_warn since the function itself does not return error,
so we do not confuse log_error() checker.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-report.c |    4 ++++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index e3953e4..24d53af 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.84 -
 ====================================
+  Catch invalid use of string sort values when reporting numerical fields.
 
 Version 1.02.83 - 13th November 2013
 ====================================
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 0984416..7e8484e 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -240,6 +240,10 @@ void dm_report_field_set_value(struct dm_report_field *field, const void *value,
 {
 	field->report_string = (const char *) value;
 	field->sort_value = sortvalue ? : value;
+
+	if ((field->sort_value == value) &&
+	    (field->props->flags & DM_REPORT_FIELD_TYPE_NUMBER))
+		log_warn(INTERNAL_ERROR "Using string as sort value for numerical field.");
 }
 
 /*


