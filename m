From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 20 Sep 2017 09:14:58 -0400
Subject: master - libdm: fix parentheses in assignment + comparison
Message-ID: <201709201314.v8KDEwjE009484@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a02db1c45ab571d0c614d269a713b56cd47c2e1e
Commit:        a02db1c45ab571d0c614d269a713b56cd47c2e1e
Parent:        a65649b45d0d0a417b64bf9918b2aeedb7f3993b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 20 14:21:38 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 20 15:14:16 2017 +0200

libdm: fix parentheses in assignment + comparison

As reported, fix incorrect placement of parentheses.
TODO: add testing code.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-report.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 5f71327..2a351a4 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.144 - 
 ======================================
+  Correct return value testing when get reserved values for reporting.
   Take -S with dmsetup suspend/resume/clear/wipe_table/remove/deps/status/table.
 
 Version 1.02.143 - 13th September 2017
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index d2371db..05f5ea0 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -3414,7 +3414,7 @@ static int _get_reserved_value(struct dm_report *rh, uint32_t field_num,
 		handler = (dm_report_reserved_handler) tmp_value;
 		if ((r = handler(rh, rh->selection->mem, field_num,
 				 DM_REPORT_RESERVED_GET_DYNAMIC_VALUE,
-				 rvw->matched_name, &tmp_value) <= 0)) {
+				 rvw->matched_name, &tmp_value)) <= 0) {
 			if (r == -1)
 				log_error(INTERNAL_ERROR "%s reserved value handler for field %s has missing"
 					  "implementation of DM_REPORT_RESERVED_GET_DYNAMIC_VALUE action",


