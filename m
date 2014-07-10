From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 10 Jul 2014 14:22:48 +0000 (UTC)
Subject: master - libdm: report: fix string list internal representation if delimiter is composed of more than one char
Message-ID: <20140710142248.16C25611D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e38af4e28fba0c6854f4bc2dc3842d74a11d199e
Commit:        e38af4e28fba0c6854f4bc2dc3842d74a11d199e
Parent:        1e5ec893c7d9cf243a6ecb17ed6320d37e9a147c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 10 16:09:58 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jul 10 16:18:05 2014 +0200

libdm: report: fix string list internal representation if delimiter is composed of more than one char

---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-report.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 852d313..ab94bc4 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.87 -
 ================================
+  Fix dm_report_field_string_list to handle delimiter with multiple chars.
   Add dm_report_field_reserved_value for per-field reserved value definition.
 
 Version 1.02.86 - 23rd June 2014
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 9b4ea87..b94cc00 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -420,7 +420,7 @@ int dm_report_field_string_list(struct dm_report *rh,
 		 */
 		sort_value->items[i].pos = pos;
 		sort_value->items[i].len = len;
-		pos = i == list_size ? pos+len : pos+len+1;
+		pos = i == list_size ? pos+len : pos+len+delimiter_len;
 	}
 
 	if (!dm_pool_grow_object(rh->mem, "\0", 1)) {


