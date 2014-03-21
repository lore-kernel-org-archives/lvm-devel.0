From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Mar 2014 21:31:23 +0000 (UTC)
Subject: master - lvmcache: fix debug trace
Message-ID: <20140321213123.6DC2F60B41@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e5382c063d2549d3a28b3182218b7978e0c22442
Commit:        e5382c063d2549d3a28b3182218b7978e0c22442
Parent:        fc280bcc42556ca1c78d897839d05b3688d9d65b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 19 23:35:36 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 21 22:29:22 2014 +0100

lvmcache: fix debug trace

Recent debug tracing commit introduce read of uninitialized memory,
since VGID is not really a proper string which ends with '\0'.
Enforce at most 32 (ID_LEN) chars are read from vgid.
(in release fix)
---
 lib/cache/lvmcache.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 0c49ccf..c61bb77 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -446,8 +446,8 @@ struct lvmcache_vginfo *lvmcache_vginfo_from_vgname(const char *vgname, const ch
 		while ((vginfo = vginfo->next));
 
 	if  (!vginfo)
-		log_debug_cache("Metadata cache has not found vgname \"%s\" with vgid \"%s\"",
-				vgname, vgid);
+		log_debug_cache("Metadata cache has not found vgname \"%s\" with vgid \"%."
+				DM_TO_STRING(ID_LEN) "s\".", vgname, vgid ? : "");
 
 	return vginfo;
 }


