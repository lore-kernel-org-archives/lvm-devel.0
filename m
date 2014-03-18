From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 18 Mar 2014 09:31:54 +0000 (UTC)
Subject: master - lvmcache: add mode debug prints
Message-ID: <20140318093154.61FF160DDE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=599a05f658326e8b683923e3255b3e05ccd54bb3
Commit:        599a05f658326e8b683923e3255b3e05ccd54bb3
Parent:        21b3c983fddac7e1365b4929dc02ddf04cf817bc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 18 10:24:32 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 18 10:28:08 2014 +0100

lvmcache: add mode debug prints

Decorate NULL returns with debug_cache output so the
debug log doesn't contain spurios <bactrace> line without
any reason for it.

Add internal errors when cache is misused.
---
 lib/cache/lvmcache.c |   20 ++++++++++++++++----
 1 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index d40bdce..f414aed 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -429,11 +429,15 @@ struct lvmcache_vginfo *lvmcache_vginfo_from_vgname(const char *vgname, const ch
 	if (!vgname)
 		return lvmcache_vginfo_from_vgid(vgid);
 
-	if (!_vgname_hash)
+	if (!_vgname_hash) {
+		log_debug_cache(INTERNAL_ERROR "Internal cache is no yet initialized.");
 		return NULL;
+	}
 
-	if (!(vginfo = dm_hash_lookup(_vgname_hash, vgname)))
+	if (!(vginfo = dm_hash_lookup(_vgname_hash, vgname))) {
+		log_debug_cache("Metadata cache has no info for vgname: \"%s\"", vgname);
 		return NULL;
+	}
 
 	if (vgid)
 		do
@@ -441,6 +445,10 @@ struct lvmcache_vginfo *lvmcache_vginfo_from_vgname(const char *vgname, const ch
 				return vginfo;
 		while ((vginfo = vginfo->next));
 
+	if  (!vginfo)
+		log_debug_cache("Metadata cache has not found vgname \"%s\" with vgid \"%s\"",
+				vgname, vgid);
+
 	return vginfo;
 }
 
@@ -514,15 +522,19 @@ struct lvmcache_vginfo *lvmcache_vginfo_from_vgid(const char *vgid)
 	struct lvmcache_vginfo *vginfo;
 	char id[ID_LEN + 1] __attribute__((aligned(8)));
 
-	if (!_vgid_hash || !vgid)
+	if (!_vgid_hash || !vgid) {
+		log_debug_cache(INTERNAL_ERROR "Internal cache cannot lookup vgid.");
 		return NULL;
+	}
 
 	/* vgid not necessarily NULL-terminated */
 	strncpy(&id[0], vgid, ID_LEN);
 	id[ID_LEN] = '\0';
 
-	if (!(vginfo = dm_hash_lookup(_vgid_hash, id)))
+	if (!(vginfo = dm_hash_lookup(_vgid_hash, id))) {
+		log_debug_cache("Metadata cache has no info for vgid \"%s\"", id);
 		return NULL;
+	}
 
 	return vginfo;
 }


