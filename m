From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri,  2 Oct 2020 20:28:02 +0000 (GMT)
Subject: master - debug: drop vgid from debug
Message-ID: <20201002202802.78C633945C25@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=73a3a0d3476bd55358348bb95ddcdfe9ff1e809e
Commit:        73a3a0d3476bd55358348bb95ddcdfe9ff1e809e
Parent:        117fc64e6ef0905e6474d2bf67a890e97d6da450
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 2 22:22:25 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 2 22:27:00 2020 +0200

debug: drop vgid from debug

>From the code can be seen the VGID will be always NULL here
as vgid != NULL is already handled before.
Thus drop from being displayed.
---
 lib/cache/lvmcache.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index a2fa0e3fb..ef0f4c391 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -326,7 +326,7 @@ static struct lvmcache_vginfo *_vginfo_lookup(const char *vgname, const char *vg
 		if ((vginfo = dm_hash_lookup(_vgname_hash, vgname))) {
 			if (vginfo->has_duplicate_local_vgname) {
 				/* should never happen, found_duplicate_vgnames should be set */
-				log_error(INTERNAL_ERROR "vginfo_lookup %s %s has_duplicate_local_vgname", vgname, vgid);
+				log_error(INTERNAL_ERROR "vginfo_lookup %s has_duplicate_local_vgname.", vgname);
 				return NULL;
 			}
 			return vginfo;
@@ -336,7 +336,7 @@ static struct lvmcache_vginfo *_vginfo_lookup(const char *vgname, const char *vg
 	if (vgname && _found_duplicate_vgnames) {
 		if ((vginfo = _search_vginfos_list(vgname, vgid))) {
 			if (vginfo->has_duplicate_local_vgname) {
-				log_debug("vginfo_lookup %s %s has_duplicate_local_vgname return none", vgname, vgid);
+				log_debug("vginfo_lookup %s has_duplicate_local_vgname return none.", vgname);
 				return NULL;
 			}
 			return vginfo;


