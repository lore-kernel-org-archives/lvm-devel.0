From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 12 Jun 2014 09:56:44 +0000 (UTC)
Subject: master - libdm: dm_report_object avoid duplicat strlen call
Message-ID: <20140612095644.0DD9960EA2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3d9737442b97665aea1d03483f218806727a254d
Commit:        3d9737442b97665aea1d03483f218806727a254d
Parent:        922f884abeae010589fa775b022d284dfec9e075
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 12 11:36:51 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 12 11:56:06 2014 +0200

libdm: dm_report_object avoid duplicat strlen call

Remember strlen result.
---
 libdm/libdm-report.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index f3395a7..820fa2a 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -703,6 +703,7 @@ int dm_report_object(struct dm_report *rh, void *object)
 	struct row *row;
 	struct dm_report_field *field;
 	void *data = NULL;
+	int len;
 
 	if (!rh) {
 		log_error(INTERNAL_ERROR "dm_report handler is NULL.");
@@ -750,8 +751,9 @@ int dm_report_object(struct dm_report *rh, void *object)
 			return 0;
 		}
 
-		if (((int) strlen(field->report_string) > field->props->width))
-			field->props->width = (int) strlen(field->report_string);
+		len = (int) strlen(field->report_string);
+		if (len > field->props->width)
+			field->props->width = len;
 
 		if ((rh->flags & RH_SORT_REQUIRED) &&
 		    (field->props->flags & FLD_SORT_KEY)) {


