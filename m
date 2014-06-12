From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 12 Jun 2014 09:56:46 +0000 (UTC)
Subject: master - libdm: dm_report_object report error for no data
Message-ID: <20140612095646.21EF960D83@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eb316fec33e3866b92357a8aab1dd7a3c4b86075
Commit:        eb316fec33e3866b92357a8aab1dd7a3c4b86075
Parent:        3d9737442b97665aea1d03483f218806727a254d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 12 11:38:04 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 12 11:56:06 2014 +0200

libdm: dm_report_object report error for no data

NULL data would cause problems....
---
 libdm/libdm-report.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 820fa2a..bdc293b 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -738,9 +738,11 @@ int dm_report_object(struct dm_report *rh, void *object)
 		}
 		field->props = fp;
 
-		data = _report_get_field_data(rh, fp, object);
-		if (!data)
+		if (!(data = _report_get_field_data(rh, fp, object))) {
+			log_error("dm_report_object: no data for field %s",
+				  rh->fields[fp->field_num].id);
 			return 0;
+		}
 
 		if (!rh->fields[fp->field_num].report_fn(rh, rh->mem,
 							 field, data,


