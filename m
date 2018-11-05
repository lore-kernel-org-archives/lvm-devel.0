From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 5 Nov 2018 11:27:05 -0500
Subject: master - cov: split check for type assignment
Message-ID: <201811051627.wA5GR5IC005331@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=79879bd201d4156312bb03fc0b7228ce34a3bf38
Commit:        79879bd201d4156312bb03fc0b7228ce34a3bf38
Parent:        6235861e64e9567493e14c6f227a6cc5ce609e07
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 1 15:33:34 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 3 16:09:36 2018 +0100

cov: split check for type assignment

Check that type is always defined, if not make it explicit internal
error (although logged as debug - so catched only with proper lvm.conf
setting).
This ensures later type being NULL can't be dereferenced with coredump.
---
 libdm/libdm-report.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index a447017..b0c89ab 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -748,10 +748,11 @@ static void _display_fields_more(struct dm_report *rh,
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


