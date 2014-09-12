From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 12 Sep 2014 12:45:18 +0000 (UTC)
Subject: master - cleanup: avoid strlen() we know max size
Message-ID: <20140912124518.AD15760DC7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=07b3e6cd746ed7633c6ce2540c675797c04a34b9
Commit:        07b3e6cd746ed7633c6ce2540c675797c04a34b9
Parent:        ab7977de7b0c3d4586c40eca0179fbae24bc23ba
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 12 11:35:51 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 12 13:51:31 2014 +0200

cleanup: avoid strlen() we know max size

Just use max NAME_LEN size buffer and copy the name.
---
 lib/metadata/raid_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 6883a68..b72b839 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -492,7 +492,7 @@ static int _alloc_rmeta_for_lv(struct logical_volume *data_lv,
 	struct dm_list allocatable_pvs;
 	struct alloc_handle *ah;
 	struct lv_segment *seg = first_seg(data_lv);
-	char *p, base_name[strlen(data_lv->name) + 1];
+	char *p, base_name[NAME_LEN];
 
 	dm_list_init(&allocatable_pvs);
 
@@ -502,7 +502,7 @@ static int _alloc_rmeta_for_lv(struct logical_volume *data_lv,
 		return 0;
 	}
 
-	sprintf(base_name, "%s", data_lv->name);
+	(void) dm_strncpy(base_name, data_lv->name, sizeof(base_name));
 	if ((p = strstr(base_name, "_mimage_")))
 		*p = '\0';
 


