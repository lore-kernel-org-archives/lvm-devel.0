From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 16 Nov 2015 00:17:04 +0000 (UTC)
Subject: master - libdm: check for passed custom time value
Message-ID: <20151116001704.25C5A60645@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=96d73dc6ea3016a80b5041ee0252e8473481b91e
Commit:        96d73dc6ea3016a80b5041ee0252e8473481b91e
Parent:        d4288c9bdfa104bef1e31185da0b773924218f35
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 16 00:41:25 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 16 01:16:11 2015 +0100

libdm: check for passed custom time value

Coverity reports custom should be checked before derefernce.
---
 libdm/libdm-report.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 37fcc40..790f84f 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -3545,6 +3545,10 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 					if (rvw->reserved->type & DM_REPORT_FIELD_RESERVED_VALUE_RANGE)
 						fs->value->next->v.t = (((const time_t *) rvw->value)[1]);
 				} else {
+					if (!custom) {
+						log_error(INTERNAL_ERROR "Custom time value is undefined.");
+						goto error;
+					}
 					tval = (struct time_value *) custom;
 					fs->value->v.t = tval->t1;
 					if (tval->range)


