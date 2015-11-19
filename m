From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 19 Nov 2015 11:21:19 +0000 (UTC)
Subject: master - cleanup: cast resulting value explicitely
Message-ID: <20151119112119.51A9060E43@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0614c63579b9ab6ebf68b957b4de3806f231a14c
Commit:        0614c63579b9ab6ebf68b957b4de3806f231a14c
Parent:        0b2be6049730e8dbab3d715633e967b4b2992f78
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 19 11:59:19 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 19 11:59:19 2015 +0100

cleanup: cast resulting value explicitely

---
 libdm/libdm-report.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 27044c0..b5149b8 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -2310,7 +2310,7 @@ static const char *_reserved_name(struct dm_report *rh,
 	}
 
 	if (reserved->type & DM_REPORT_FIELD_RESERVED_VALUE_FUZZY_NAMES) {
-		handler = (dm_report_reserved_handler) frv ? frv->value : reserved->value;
+		handler = (dm_report_reserved_handler) (frv ? frv->value : reserved->value);
 		c = s[len];
 		tmp_s = (char *) s;
 		tmp_s[len] = '\0';


