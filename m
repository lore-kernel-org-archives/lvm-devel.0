From: David Teigland <teigland@fedoraproject.org>
Date: Wed,  2 Dec 2015 00:08:20 +0000 (UTC)
Subject: master - lvmcache: change duplicate VG name warnings to verbose
Message-ID: <20151202000820.2632660AC7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3bcdf5d14b930ba71c4dc5b03fcde0b19a5c8515
Commit:        3bcdf5d14b930ba71c4dc5b03fcde0b19a5c8515
Parent:        88cef47b18cd8b03b090b4b17220b1ddf45aba03
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 30 15:28:22 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Dec 1 09:30:23 2015 -0600

lvmcache: change duplicate VG name warnings to verbose

When two different VGs with the same name exist,
they are both stored in lvmcache using the vginfo->next
list.  Previously, the code would print warnings (sometimes)
when adding VGs to this list.  Now the duplicate VG names
are handled by higher level code, so this list no longer
needs to print warnings about duplicate VG names being found.
---
 lib/cache/lvmcache.c |   53 +++++++++++++++++++++++++++++++------------------
 1 files changed, 33 insertions(+), 20 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index e375388..799de6f 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1259,6 +1259,15 @@ static int _insert_vginfo(struct lvmcache_vginfo *new_vginfo, const char *vgid,
 			return_0;
 
 		/*
+		 * vginfo is kept for each VG with the same name.
+		 * They are saved with the vginfo->next list.
+		 * These checks just decide the ordering of
+		 * that list.
+		 *
+		 * FIXME: it should no longer matter what order
+		 * the vginfo's are kept in, so we can probably
+		 * remove these comparisons and reordering entirely.
+		 *
 		 * If   Primary not exported, new exported => keep
 		 * Else Primary exported, new not exported => change
 		 * Else Primary has hostname for this machine => keep
@@ -1268,38 +1277,42 @@ static int _insert_vginfo(struct lvmcache_vginfo *new_vginfo, const char *vgid,
 		 */
 		if (!(primary_vginfo->status & EXPORTED_VG) &&
 		    (vgstatus & EXPORTED_VG))
-			log_warn("WARNING: Duplicate VG name %s: "
-				 "Existing %s takes precedence over "
-				 "exported %s", new_vginfo->vgname,
-				 uuid_primary, uuid_new);
+			log_verbose("Cache: Duplicate VG name %s: "
+				    "Existing %s takes precedence over "
+				    "exported %s", new_vginfo->vgname,
+				    uuid_primary, uuid_new);
 		else if ((primary_vginfo->status & EXPORTED_VG) &&
 			   !(vgstatus & EXPORTED_VG)) {
-			log_warn("WARNING: Duplicate VG name %s: "
-				 "%s takes precedence over exported %s",
-				 new_vginfo->vgname, uuid_new,
-				 uuid_primary);
+			log_verbose("Cache: Duplicate VG name %s: "
+				    "%s takes precedence over exported %s",
+				    new_vginfo->vgname, uuid_new,
+				    uuid_primary);
 			use_new = 1;
 		} else if (primary_vginfo->creation_host &&
 			   !strcmp(primary_vginfo->creation_host,
 				   primary_vginfo->fmt->cmd->hostname))
-			log_warn("WARNING: Duplicate VG name %s: "
-				 "Existing %s (created here) takes precedence "
-				 "over %s", new_vginfo->vgname, uuid_primary,
-				 uuid_new);
+			log_verbose("Cache: Duplicate VG name %s: "
+				    "Existing %s (created here) takes precedence "
+				    "over %s", new_vginfo->vgname, uuid_primary,
+				    uuid_new);
 		else if (!primary_vginfo->creation_host && creation_host) {
-			log_warn("WARNING: Duplicate VG name %s: "
-				 "%s (with creation_host) takes precedence over %s",
-				 new_vginfo->vgname, uuid_new,
-				 uuid_primary);
+			log_verbose("Cache: Duplicate VG name %s: "
+				    "%s (with creation_host) takes precedence over %s",
+				    new_vginfo->vgname, uuid_new,
+				    uuid_primary);
 			use_new = 1;
 		} else if (creation_host &&
 			   !strcmp(creation_host,
 				   primary_vginfo->fmt->cmd->hostname)) {
-			log_warn("WARNING: Duplicate VG name %s: "
-				 "%s (created here) takes precedence over %s",
-				 new_vginfo->vgname, uuid_new,
-				 uuid_primary);
+			log_verbose("Cache: Duplicate VG name %s: "
+				    "%s (created here) takes precedence over %s",
+				    new_vginfo->vgname, uuid_new,
+				    uuid_primary);
 			use_new = 1;
+		} else {
+			log_verbose("Cache: Duplicate VG name %s: "
+				    "Prefer existing %s vs new %s",
+				    new_vginfo->vgname, uuid_primary, uuid_new);
 		}
 
 		if (!use_new) {


