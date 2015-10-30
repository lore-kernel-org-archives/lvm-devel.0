From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 30 Oct 2015 14:52:19 +0000 (UTC)
Subject: master - str_list: also allow memory allocation without memory pool
Message-ID: <20151030145219.B8209609F7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=097d14e64e845bdb1c0b8106e33f38f775e54fe5
Commit:        097d14e64e845bdb1c0b8106e33f38f775e54fe5
Parent:        17196103e018a34eda016f6bdcd74395210cb114
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Oct 20 14:09:09 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Oct 30 15:47:55 2015 +0100

str_list: also allow memory allocation without memory pool

---
 lib/datastruct/str_list.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/datastruct/str_list.c b/lib/datastruct/str_list.c
index 1d3f08a..25ffddd 100644
--- a/lib/datastruct/str_list.c
+++ b/lib/datastruct/str_list.c
@@ -20,7 +20,8 @@ struct dm_list *str_list_create(struct dm_pool *mem)
 {
 	struct dm_list *sl;
 
-	if (!(sl = dm_pool_alloc(mem, sizeof(struct dm_list)))) {
+	if (!(sl = mem ? dm_pool_alloc(mem, sizeof(struct dm_list))
+		       : dm_malloc(sizeof(struct dm_list)))) {
 		log_errno(ENOMEM, "str_list allocation failed");
 		return NULL;
 	}
@@ -37,7 +38,8 @@ static int _str_list_add_no_dup_check(struct dm_pool *mem, struct dm_list *sll,
 	if (!str)
 		return_0;
 
-	if (!(sln = dm_pool_alloc(mem, sizeof(*sln))))
+	if (!(sln = mem ? dm_pool_alloc(mem, sizeof(*sln))
+			: dm_malloc(sizeof(*sln))))
 		return_0;
 
 	sln->str = str;


