From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 5 Mar 2019 08:53:19 -0500
Subject: stable-2.02 - cov: split check for type assignment
Message-ID: <201903051353.x25DrJNM006700@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c9e5e6800c3225c9eb6cd54f143624c20eda44be
Commit:        c9e5e6800c3225c9eb6cd54f143624c20eda44be
Parent:        f0f68791f31c8cf0ca2c4f0bbee86dd37a69494f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 1 15:33:34 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Mar 5 12:16:07 2019 +0100

cov: split check for type assignment

Check that type is always defined, if not make it explicit internal
error (although logged as debug - so catched only with proper lvm.conf
setting).
This ensures later type being NULL can't be dereferenced with coredump.

(cherry picked from commit 79879bd201d4156312bb03fc0b7228ce34a3bf38)
---
 libdm/libdm-report.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 0401f9c..b58e3fe 100644
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


