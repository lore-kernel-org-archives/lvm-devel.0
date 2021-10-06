From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  6 Oct 2021 13:47:53 +0000 (GMT)
Subject: main - cleanup: always initialize historical ptr
Message-ID: <20211006134753.3B97F385C404@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5ccb373d869ca23afc10416c2319331eb108e16b
Commit:        5ccb373d869ca23afc10416c2319331eb108e16b
Parent:        a841babaf7f0108797ef18af0777721742c8656c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 1 13:53:28 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 6 15:43:31 2021 +0200

cleanup: always initialize historical ptr

Set ptr for all paths.
---
 lib/metadata/metadata.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index d5ef7f7cb..ad908634a 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1701,17 +1701,19 @@ struct generic_logical_volume *find_historical_glv(const struct volume_group *vg
 
 int lv_name_is_used_in_vg(const struct volume_group *vg, const char *name, int *historical)
 {
-	int found = 0;
+	int found;
 
-	if (find_lv(vg, name)) {
+	if (historical)
+		*historical = 0;
+
+	if (find_lv(vg, name))
 		found = 1;
-		if (historical)
-			*historical = 0;
-	} else if (find_historical_glv(vg, name, 0, NULL)) {
+	else if (find_historical_glv(vg, name, 0, NULL)) {
 		found = 1;
 		if (historical)
 			*historical = 1;
-	}
+	} else
+		found = 0;
 
 	return found;
 }


