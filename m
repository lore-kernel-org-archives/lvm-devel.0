From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 25 Oct 2013 08:45:03 +0000 (UTC)
Subject: master - tests: fix old-style gcc warning
Message-ID: <20131025084503.AE6E76005D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d4e5140b5284cac151d06615328dc8af21dc15c7
Commit:        d4e5140b5284cac151d06615328dc8af21dc15c7
Parent:        7943a13141a8379f7697ee9d8764e088a4f127c3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 25 10:37:30 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 25 10:37:30 2013 +0200

tests: fix old-style gcc warning

---
 test/api/vglist.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/test/api/vglist.c b/test/api/vglist.c
index 0a882dc..3d23369 100644
--- a/test/api/vglist.c
+++ b/test/api/vglist.c
@@ -22,7 +22,7 @@
 lvm_t handle;
 vg_t vg;
 
-static void start() {
+static void start(void) {
 	handle = lvm_init(NULL);
 	if (!handle) {
 		fprintf(stderr, "Unable to lvm_init\n");
@@ -43,15 +43,16 @@ static void done(int ok) {
 
 int main(int argc, char *argv[])
 {
-	if (argc != 3)
-		abort();
-
 	lvm_str_list_t *str;
-
 	int i = 0;
+	struct dm_list *vgnames;
+        struct dm_list *vgids;
+
+	if (argc != 3)
+		abort();
 
 	start();
-	struct dm_list *vgnames = lvm_list_vg_names(handle);
+	vgnames = lvm_list_vg_names(handle);
 	dm_list_iterate_items(str, vgnames) {
 		assert(++i <= 1);
 		assert(!strcmp(str->str, argv[1]));
@@ -61,7 +62,7 @@ int main(int argc, char *argv[])
 
 	i = 0;
 	start();
-	struct dm_list *vgids = lvm_list_vg_uuids(handle);
+	vgids = lvm_list_vg_uuids(handle);
 	dm_list_iterate_items(str, vgids) {
 		assert(++i <= 1);
 		assert(!strcmp(str->str, argv[2]));


