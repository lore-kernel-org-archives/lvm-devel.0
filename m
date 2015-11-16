From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 16 Nov 2015 00:16:59 +0000 (UTC)
Subject: master - libdm: check if passed return pointer is not NULL
Message-ID: <20151116001659.F1DD560645@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=422c7474ca97066ab92d145ac45bc4a9cd38e1b7
Commit:        422c7474ca97066ab92d145ac45bc4a9cd38e1b7
Parent:        dd9a05b5ae7fb12cf2efd779f3f2da44698805b5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 16 00:13:10 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 16 01:15:04 2015 +0100

libdm: check if passed return pointer is not NULL

Coverity: before storing return value, check passed space will
not dereference NULL pointer.
---
 libdm/libdm-report.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 38dde07..37fcc40 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -2692,13 +2692,15 @@ static const char *_tok_value_string_list(const struct dm_report_field_type *ft,
 	dm_free(arr);
 out:
 	*end = s;
-	*sel_str_list = ssl;
+        if (*sel_str_list)
+		*sel_str_list = ssl;
 	return s;
 bad:
 	*end = s;
 	if (ssl)
 		dm_pool_free(mem, ssl);
-	*sel_str_list = NULL;
+        if (*sel_str_list)
+		*sel_str_list = NULL;
 	return s;
 }
 


