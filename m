From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 15 Nov 2013 11:39:43 +0000 (UTC)
Subject: master - tests: indent
Message-ID: <20131115113943.62E1A611A2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3716e9535455c5fb012511f820d0525e4aa48bc8
Commit:        3716e9535455c5fb012511f820d0525e4aa48bc8
Parent:        89a8c7bea6df1d52818837f5a6778d7ae3e9626c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 4 15:06:55 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 15 12:38:37 2013 +0100

tests: indent

---
 test/api/vglist.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/api/vglist.c b/test/api/vglist.c
index 3d23369..01f52ec 100644
--- a/test/api/vglist.c
+++ b/test/api/vglist.c
@@ -46,7 +46,7 @@ int main(int argc, char *argv[])
 	lvm_str_list_t *str;
 	int i = 0;
 	struct dm_list *vgnames;
-        struct dm_list *vgids;
+	struct dm_list *vgids;
 
 	if (argc != 3)
 		abort();


