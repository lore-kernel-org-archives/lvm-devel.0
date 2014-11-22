From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 22 Nov 2014 17:52:04 +0000 (UTC)
Subject: master - libdm: fix reporting of empty string list
Message-ID: <20141122175204.7C2B260A2C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fc935495c813b7577ac8237459a2cc65ea291ac2
Commit:        fc935495c813b7577ac8237459a2cc65ea291ac2
Parent:        75d79f3dad99106c2ecb68c67507f9c367893ec1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 22 18:13:21 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 22 18:50:53 2014 +0100

libdm: fix reporting of empty string list

Don't write behind the allocated array when list is empty.
Use index 0 for the allocated element.

Error triggered by i.e.:  lvs -a -o all,lv_modules
---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-report.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index a89696f..0de5b89 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.92 - 
 ====================================
+  Fix memory corruption with sorting empty string lists (1.02.86).
   Fix man dmsetup.8 syntax warning of Groff
 
 Version 1.02.91 - 11th November 2014
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index bf64cc3..f768750 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -378,8 +378,8 @@ static int _report_field_string_list(struct dm_report *rh,
 	/* zero items */
 	if (!list_size) {
 		sort_value->value = field->report_string = "";
-		sort_value->items[1].pos = 0;
-		sort_value->items[1].len = 0;
+		sort_value->items[0].pos = 0;
+		sort_value->items[0].len = 0;
 		field->sort_value = sort_value;
 		return 1;
 	}


