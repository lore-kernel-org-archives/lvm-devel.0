From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 20 May 2020 14:03:21 +0000 (GMT)
Subject: master - cov: lvconvert: missing check for function failure
Message-ID: <20200520140321.2186B395CC34@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cf74123830250984743d28687e66a0954510b4fa
Commit:        cf74123830250984743d28687e66a0954510b4fa
Parent:        ce8277b47ed95e71e31c933b5c6a35b24dd52756
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun May 17 18:29:54 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 20 15:55:39 2020 +0200

cov: lvconvert: missing check for function failure

---
 tools/lvconvert.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index e969b4459..cf935385f 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5589,7 +5589,8 @@ static struct logical_volume *_lv_writecache_create(struct cmd_context *cmd,
 
 	memcpy(&seg->writecache_settings, settings, sizeof(struct writecache_settings));
 
-	add_seg_to_segs_using_this_lv(lv_fast, seg);
+	if (!add_seg_to_segs_using_this_lv(lv_fast, seg))
+		return_NULL;
 
 	return lv_wcorig;
 }


