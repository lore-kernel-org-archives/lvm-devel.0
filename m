From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Tue, 19 Aug 2014 14:58:27 +0000 (UTC)
Subject: master - cleanup: Remove extra '; ' from the end of a line.
Message-ID: <20140819145827.8FDFA60F06@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4f05e55f84fc1d1c4f839b7f523392e369f681b0
Commit:        4f05e55f84fc1d1c4f839b7f523392e369f681b0
Parent:        c5f2c541f6b0ce5d9ef8a1eda66bd021c044e6d2
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Aug 19 09:57:30 2014 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Aug 19 09:57:30 2014 -0500

cleanup: Remove extra ';' from the end of a line.

---
 libdm/libdm-report.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 155ac60..261b436 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1278,7 +1278,7 @@ static int _cmp_field_string_list_subset_all(const struct str_list_sort_value *v
 					     const struct selection_str_list *sel)
 {
 	struct dm_str_list *sel_item;
-	unsigned int i, last_found = 1;;
+	unsigned int i, last_found = 1;
 	int r = 0;
 
 	/* if value has no items and selection has at leas one, it's clear there's no match */


