From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 24 Nov 2014 13:50:01 +0000 (UTC)
Subject: master - libdm: there is no element in item 0
Message-ID: <20141124135001.6294F613B6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8bc7b4f926c8ae24c99391c39fc8e2a9fa55d80a
Commit:        8bc7b4f926c8ae24c99391c39fc8e2a9fa55d80a
Parent:        fb220314ec787bd8f0855b055e1b3bba7368dd26
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 24 14:37:11 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 24 14:38:54 2014 +0100

libdm: there is no element in item 0

Items[0] holds only counter in .len.
So don't zero already zeroed items[0].len assigned above.

(finishing fc935495c813b7577ac8237459a2cc65ea291ac2)
---
 libdm/libdm-report.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 470c2d1..a1bab05 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -393,8 +393,6 @@ static int _report_field_string_list(struct dm_report *rh,
 	/* zero items */
 	if (!list_size) {
 		sort_value->value = field->report_string = "";
-		sort_value->items[0].pos = 0;
-		sort_value->items[0].len = 0;
 		field->sort_value = sort_value;
 		return 1;
 	}


