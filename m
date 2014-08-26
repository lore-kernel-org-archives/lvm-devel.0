From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 26 Aug 2014 12:17:34 +0000 (UTC)
Subject: master - cleanup: never return uninitialized buffer
Message-ID: <20140826121734.A462060994@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e5356eeba10858c2bb0f57891c262f77707b19bc
Commit:        e5356eeba10858c2bb0f57891c262f77707b19bc
Parent:        8f518cf1979e4cbfce40f6ae1bed02bd5b9a5b35
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 21 15:35:29 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 26 14:13:06 2014 +0200

cleanup: never return uninitialized buffer

Coverity noticed this function may return untouched buffer,
however in this state can't really happen, but anyway
ensure on error path the buffer will have zero lenght string.
---
 lib/config/config.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index a71cbdc..58efb31 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -602,8 +602,10 @@ static int _cfg_def_make_path(char *buf, size_t buf_size, int id, cfg_def_item_t
 	int parent_id = item->parent;
 	int count, n;
 
-	if (id == parent_id)
+	if (id == parent_id) {
+		buf[0] = '\0';
 		return 0;
+	}
 
 	count = _cfg_def_make_path(buf, buf_size, parent_id, cfg_def_get_item_p(parent_id), xlate);
 	if ((n = dm_snprintf(buf + count, buf_size - count, "%s%s%s%s",


