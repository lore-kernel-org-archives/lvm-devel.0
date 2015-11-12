From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 12 Nov 2015 15:36:43 +0000 (UTC)
Subject: master - lvmetad: tail chasing to shut up coverity
Message-ID: <20151112153643.8DACD60E7F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=43777b551d840a55d70e862bff751e7208c8eaf4
Commit:        43777b551d840a55d70e862bff751e7208c8eaf4
Parent:        058725c72149e9f852390ca1d52e932ddb745a82
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Nov 12 09:35:41 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Nov 12 09:35:41 2015 -0600

lvmetad: tail chasing to shut up coverity

---
 daemons/lvmetad/lvmetad-core.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 781cfc6..f7df5fd 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -1346,8 +1346,14 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 	int abort_daemon = 0;
 	int retval = 0;
 
+	if (!arg_vgid || !arg_name) {
+		ERROR(s, "update_metadata missing args arg_vgid %s arg_name %s pvid %s",
+		      arg_vgid ?: "none", arg_name ?: "none", pvid ?: "none");
+		return 0;
+	}
+
 	DEBUGLOG(s, "update_metadata begin arg_vgid %s arg_name %s pvid %s",
-		 arg_vgid ?: "none", arg_name ?: "none", pvid ?: "none");
+		 arg_vgid, arg_name, pvid ?: "none");
 
 	/*
 	 * Begin by figuring out what has changed:
@@ -1378,7 +1384,7 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 	 * A lookup of the name arg was successful in finding arg_vgid_lookup,
 	 * but that resulting vgid doesn't match the arg_vgid.
 	 */
-	if (arg_vgid_lookup && arg_vgid && strcmp(arg_vgid_lookup, arg_vgid)) {
+	if (arg_vgid_lookup && strcmp(arg_vgid_lookup, arg_vgid)) {
 		if (arg_name_lookup) {
 			/*
 			 * This shouldn't happen.
@@ -1419,7 +1425,7 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 	 * A lookup of the vgid arg was successful in finding arg_name_lookup,
 	 * but that resulting name doesn't match the arg_name.
 	 */
-	if (arg_name_lookup && arg_name && strcmp(arg_name_lookup, arg_name)) {
+	if (arg_name_lookup && strcmp(arg_name_lookup, arg_name)) {
 		if (arg_vgid_lookup) {
 			/*
 			 * This shouldn't happen.


