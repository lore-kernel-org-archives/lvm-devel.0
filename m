From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 16 Nov 2015 21:14:17 +0000 (UTC)
Subject: master - lvmetad: use lookup_withval in another location
Message-ID: <20151116211417.4349A60DE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=68c386cce71f5bf876cc9ed754d901f1ca9daeed
Commit:        68c386cce71f5bf876cc9ed754d901f1ca9daeed
Parent:        4a984cabc475160cf54274f0c822259a67bd8d1f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 16 14:44:32 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Nov 16 15:13:22 2015 -0600

lvmetad: use lookup_withval in another location

Simply use lookup_withval right away rather than doing a
standard lookup, checking for the wrong mapping, then
repeating with lookup_withval to get the right mapping.
---
 daemons/lvmetad/lvmetad-core.c |   43 +---------------------------------------
 1 files changed, 1 insertions(+), 42 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 08c4632..623e1df 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -1342,7 +1342,6 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 	const char *new_name = NULL;
 	const char *old_vgid = NULL;
 	const char *new_vgid = NULL;
-	const char *arg_vgid2 = NULL;
 	const char *old_vgid2 = NULL;
 	const char *new_metadata_vgid;
 	int old_seq = -1;
@@ -1370,47 +1369,7 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 
 	lock_vgid_to_metadata(s);
 	arg_name_lookup = dm_hash_lookup(s->vgid_to_vgname, arg_vgid);
-	arg_vgid_lookup = dm_hash_lookup(s->vgname_to_vgid, arg_name);
-
-	/*
-	 * A new PV has been found with a VG that:
-	 * has a vgid we don't know about (null arg_name_lookup),
-	 * has a name we do know about (non-null arg_vgid_lookup).
-	 * This happens when there are two different VGs with the
-	 * same name.
-	 */
-	if (pvid && !arg_name_lookup && arg_vgid_lookup &&
-	    strcmp(arg_vgid_lookup, arg_vgid)) {
-		if ((arg_vgid2 = dm_hash_lookup_withval(s->vgname_to_vgid, arg_name, arg_vgid, strlen(arg_vgid) + 1))) {
-			/* This VG already exists in the cache. */
-			DEBUGLOG(s, "update_metadata arg_vgid %s arg_name %s found VG with same name as %s",
-				 arg_vgid, arg_name, arg_vgid_lookup);
-			arg_vgid_lookup = arg_vgid2;
-		} else {
-			/* This VG doesn't exist in cache yet. */
-			DEBUGLOG(s, "update_metadata arg_vgid %s arg_name %s found VG with same name as %s",
-				 arg_vgid, arg_name, arg_vgid_lookup);
-			arg_vgid_lookup = NULL;
-		}
-	}
-
-	/*
-	 * Updated VG metadata has been sent from a command
-	 * for a VG but we have two VGs with this same name,
-	 * so we need to figure out which of the VGs it is.
-	 */
-	if (!pvid && arg_name_lookup && arg_vgid_lookup &&
-	    !strcmp(arg_name_lookup, arg_name) &&
-	     strcmp(arg_vgid_lookup, arg_vgid)) {
-		if ((arg_vgid2 = dm_hash_lookup_withval(s->vgname_to_vgid, arg_name, arg_vgid, strlen(arg_vgid) + 1))) {
-			/* The first lookup found the another VG with the same name. */
-			DEBUGLOG(s, "update_metadata arg_vgid %s arg_name %s update VG with same name as %s",
-				 arg_vgid, arg_name, arg_vgid_lookup);
-			arg_vgid_lookup = arg_vgid2;
-		} else {
-			/* This case is detected as an error below. */
-		}
-	}
+	arg_vgid_lookup = dm_hash_lookup_withval(s->vgname_to_vgid, arg_name, arg_vgid, strlen(arg_vgid) + 1);
 
 	/*
 	 * A new VG when there is no existing record of the name or vgid args.


