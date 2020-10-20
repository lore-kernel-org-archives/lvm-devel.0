From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 20 Oct 2020 20:34:13 +0000 (GMT)
Subject: master - cov: split check for type assignment
Message-ID: <20201020203413.ACA08395182E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3e06061d82dbcc2f464f0fdcd6610f25177bfa1f
Commit:        3e06061d82dbcc2f464f0fdcd6610f25177bfa1f
Parent:        a17ec7e0baa737b45900cc4f97823c95f9dd8c56
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 19 16:43:50 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 19 16:53:19 2020 +0200

cov: split check for type assignment

Check that type is always defined, if not make it explicit internal
error (although logged as debug - so catched only with proper lvm.conf
setting).
This ensures later type being NULL can't be dereferenced with coredump.
---
 device_mapper/libdm-report.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/device_mapper/libdm-report.c b/device_mapper/libdm-report.c
index 85d3d0f82..9279e3370 100644
--- a/device_mapper/libdm-report.c
+++ b/device_mapper/libdm-report.c
@@ -749,10 +749,11 @@ static void _display_fields_more(struct dm_report *rh,
 			id_len = strlen(type->prefix) + 3;
 
 	for (f = 0; fields[f].report_fn; f++) {
-		if ((type = _find_type(rh, fields[f].type)) && type->desc)
-			desc = type->desc;
-		else
-			desc = " ";
+		if (!(type = _find_type(rh, fields[f].type))) {
+			log_debug(INTERNAL_ERROR "Field type undefined.");
+			continue;
+		}
+		desc = (type->desc) ? : " ";
 		if (desc != last_desc) {
 			if (*last_desc)
 				log_warn(" ");


