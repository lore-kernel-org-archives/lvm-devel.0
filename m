From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  8 May 2015 13:16:42 +0000 (UTC)
Subject: master - cleanup: indent mismatch
Message-ID: <20150508131642.8AFD060759@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b8dfd7a53d6ef203ca6204d00f7c26c0baea99f6
Commit:        b8dfd7a53d6ef203ca6204d00f7c26c0baea99f6
Parent:        28f18404a7a2fe64f3c7918d8d543f913515651b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 7 11:00:23 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 8 15:15:10 2015 +0200

cleanup: indent mismatch

Aling break (Coverity).
---
 libdm/libdm-report.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 2fe9300..def72fe 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1270,7 +1270,7 @@ static int _do_check_value_is_reserved(unsigned type, const void *reserved_value
 			if ((*(uint64_t *)value1 == *(uint64_t *) reserved_value) ||
 			    (value2 && (*(uint64_t *)value2 == *(uint64_t *) reserved_value)))
 				return 1;
-				break;
+			break;
 		case DM_REPORT_FIELD_TYPE_STRING:
 			if ((!strcmp((const char *)value1, (const char *) reserved_value)) ||
 			    (value2 && (!strcmp((const char *)value2, (const char *) reserved_value))))


