From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  2 Jul 2015 14:13:12 +0000 (UTC)
Subject: master - report: adjust shared flags based on expected type for reserved values
Message-ID: <20150702141312.56B0B60637@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a32d5a4afc5bdc4585132765fb02739a8f352e49
Commit:        a32d5a4afc5bdc4585132765fb02739a8f352e49
Parent:        eaa0d927a4490c632b02a223cb426d7e483d9055
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 2 16:05:25 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jul 2 16:12:01 2015 +0200

report: adjust shared flags based on expected type for reserved values

Generic numbers and time values share some operators so make sure
we have the flags correctly adjusted based on expected type if
we're using reserved values.
---
 libdm/libdm-report.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 3f68a9e..f8bd581 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -2962,6 +2962,14 @@ static const char *_tok_value(struct dm_report *rh,
 
 	s = _get_reserved(rh, expected_type, field_num, implicit, s, begin, end, rvw);
 	if (rvw->reserved) {
+		/*
+		 * FLD_CMP_NUMBER shares operators with FLD_CMP_TIME,
+		 * so adjust flags here based on expected type.
+		 */
+		if (expected_type == DM_REPORT_FIELD_TYPE_TIME)
+			*flags &= ~FLD_CMP_NUMBER;
+		else if (expected_type == DM_REPORT_FIELD_TYPE_NUMBER)
+			*flags &= ~FLD_CMP_TIME;
 		*flags |= expected_type;
 		return s;
 	}


