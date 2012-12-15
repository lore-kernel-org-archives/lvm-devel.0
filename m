From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Dec 2012 16:25:40 +0000 (UTC)
Subject: master - lvmetad: check id_read_format error status
Message-ID: <20121215162540.2409CAAB82@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e012d0635d34edd98652c9425abb618a9565077a
Commit:        e012d0635d34edd98652c9425abb618a9565077a
Parent:        ba3f37c9e4971ba4538cb74e9e7b60e3772da793
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 14 16:45:15 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 15 17:23:27 2012 +0100

lvmetad: check id_read_format error status

Detect error from id_read_format() function.
---
 WHATS_NEW           |    1 +
 lib/cache/lvmetad.c |    7 ++++---
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d535d10..2fc8acf 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Check for failing id_read_format() in _pv_populate_lvmcache.
   Fix memleak on error path for lvmetad's pv_found.
   Unlock vg mutex in error path when lvmetad tries to lock_vg.
   Add check for key string duplication in config_make_nodes_v.
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 3ce2804..67e083b 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -249,9 +249,10 @@ static struct lvmcache_info *_pv_populate_lvmcache(
 		return NULL;
 	}
 
-	if (vgid_txt)
-		id_read_format(&vgid, vgid_txt);
-	else
+	if (vgid_txt) {
+		if (!id_read_format(&vgid, vgid_txt))
+			return_NULL;
+	} else
 		strcpy((char*)&vgid, fmt->orphan_vg_name);
 
 	if (!vgname)


