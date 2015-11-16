From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 16 Nov 2015 12:14:25 +0000 (UTC)
Subject: master - libdm: fix check of pointer
Message-ID: <20151116121425.58D0F60B40@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b6a45963e341d85196fcb070026180b3c62d608f
Commit:        b6a45963e341d85196fcb070026180b3c62d608f
Parent:        2a2487f02fb2ddb72106f922dcbf0ddda6959b2f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 16 11:51:43 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 16 13:10:24 2015 +0100

libdm: fix check of pointer

Ahhh being blind here - wanted to check the pointer before dereference
not a dereferenced one.
---
 libdm/libdm-report.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 790f84f..2457335 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -2692,14 +2692,14 @@ static const char *_tok_value_string_list(const struct dm_report_field_type *ft,
 	dm_free(arr);
 out:
 	*end = s;
-        if (*sel_str_list)
+        if (sel_str_list)
 		*sel_str_list = ssl;
 	return s;
 bad:
 	*end = s;
 	if (ssl)
 		dm_pool_free(mem, ssl);
-        if (*sel_str_list)
+        if (sel_str_list)
 		*sel_str_list = NULL;
 	return s;
 }


