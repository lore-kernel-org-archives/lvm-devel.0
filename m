From: David Teigland <teigland@fedoraproject.org>
Date: Mon,  9 Nov 2015 18:18:53 +0000 (UTC)
Subject: master - lvmetad: change recent cleanups
Message-ID: <20151109181853.CF1C960BDB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cd937efa77dcd8713aa7679728001c11e20fab70
Commit:        cd937efa77dcd8713aa7679728001c11e20fab70
Parent:        d2d5191b788cb75c541d00ffd75d8add3b77a9ad
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 9 12:17:06 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Nov 9 12:18:43 2015 -0600

lvmetad: change recent cleanups

with better alternatives.
---
 daemons/lvmetad/lvmetad-core.c |   20 ++++++++++++++------
 1 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index c17caa7..781cfc6 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -932,7 +932,7 @@ static int remove_metadata(lvmetad_state *s, const char *vgid, int update_pvids)
 
 	/* update_pvid_to_vgid will clear/free the pvid_to_vgid hash */
 	if (update_pvids && meta_lookup)
-		(void) _update_pvid_to_vgid(s, meta_lookup, "#orphan", 0);
+		_update_pvid_to_vgid(s, meta_lookup, "#orphan", 0);
 
 	/* free the unmapped data */
 
@@ -1347,7 +1347,7 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 	int retval = 0;
 
 	DEBUGLOG(s, "update_metadata begin arg_vgid %s arg_name %s pvid %s",
-		 arg_vgid, arg_name, pvid ?: "none");
+		 arg_vgid ?: "none", arg_name ?: "none", pvid ?: "none");
 
 	/*
 	 * Begin by figuring out what has changed:
@@ -1378,7 +1378,7 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 	 * A lookup of the name arg was successful in finding arg_vgid_lookup,
 	 * but that resulting vgid doesn't match the arg_vgid.
 	 */
-	if (arg_vgid_lookup && strcmp(arg_vgid_lookup, arg_vgid)) {
+	if (arg_vgid_lookup && arg_vgid && strcmp(arg_vgid_lookup, arg_vgid)) {
 		if (arg_name_lookup) {
 			/*
 			 * This shouldn't happen.
@@ -1419,7 +1419,7 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 	 * A lookup of the vgid arg was successful in finding arg_name_lookup,
 	 * but that resulting name doesn't match the arg_name.
 	 */
-	if (arg_name_lookup && strcmp(arg_name_lookup, arg_name)) {
+	if (arg_name_lookup && arg_name && strcmp(arg_name_lookup, arg_name)) {
 		if (arg_vgid_lookup) {
 			/*
 			 * This shouldn't happen.
@@ -1459,7 +1459,15 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 	 * An existing VG has unchanged name and vgid.
 	 */
 	if (!new_vgid && !new_name) {
-		if (arg_name_lookup && strcmp(arg_name_lookup, arg_name)) {
+		if (!arg_vgid_lookup || !arg_name_lookup) {
+			/* This shouldn't happen. */
+			ERROR(s, "update_metadata arg_vgid %s arg_name %s missing lookups vgid %s name %s",
+			      arg_vgid ?: "none", arg_name ?: "none", arg_vgid_lookup ?: "none", arg_name_lookup ?: "none");
+			needs_repair = 1;
+			goto update;
+		}
+
+		if (strcmp(arg_name_lookup, arg_name)) {
 			/* This shouldn't happen. */
 			ERROR(s, "update_metadata arg_vgid %s arg_name %s mismatch arg_name_lookup %s",
 			      arg_vgid, arg_name, arg_name_lookup);
@@ -1467,7 +1475,7 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 			goto update;
 		}
 
-		if (arg_vgid_lookup && strcmp(arg_vgid_lookup, arg_vgid)) {
+		if (strcmp(arg_vgid_lookup, arg_vgid)) {
 			/*
 			 * This shouldn't usually happen, but could when
 			 * disks are moved (or filters are changed?)


