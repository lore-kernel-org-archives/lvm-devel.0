From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Sep 2015 21:36:22 +0000 (UTC)
Subject: master - cleanup: avoid printing -0.00
Message-ID: <20150903213622.0464D60F7F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0a389691dcf9a31bb0da26089febb0bdd93545d7
Commit:        0a389691dcf9a31bb0da26089febb0bdd93545d7
Parent:        32d6ca9196591d7f4d820e373fd14fd0f2301914
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 3 22:51:15 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 3 23:34:37 2015 +0200

cleanup: avoid printing -0.00

Nice trick to not print -0.00 for some percent values.
---
 libdm/libdm-report.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 2ebb69e..6416f18 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -2309,7 +2309,8 @@ static const char *_get_reserved(struct dm_report *rh, unsigned type,
 
 float dm_percent_to_float(dm_percent_t percent)
 {
-	return (float) percent / DM_PERCENT_1;
+	/* Add 0.f to prevent returning -0.00 */
+	return (float) percent / DM_PERCENT_1 + 0.f;
 }
 
 dm_percent_t dm_make_percent(uint64_t numerator, uint64_t denominator)


