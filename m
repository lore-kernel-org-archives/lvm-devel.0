From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:28:18 +0000 (UTC)
Subject: master - lvmetad: check for pointers not NULL
Message-ID: <20151109092818.57B0260DE7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=99def8f43912958bb8567a123b9725c0e3389048
Commit:        99def8f43912958bb8567a123b9725c0e3389048
Parent:        f66fe2c444a4a8c9dccf16ad8bf470a96de1305d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 9 09:25:12 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:19:19 2015 +0100

lvmetad: check for pointers not NULL

Check for  arg_vgid_lookup and arg_name_lookup not being NULL.
Drop checking arg_vgid and arg_name for NULL since they
are already dereference earlier - thus mostly must be NOT NULL.

(If that would be possible larger rework of this function would be
required).
---
 daemons/lvmetad/lvmetad-core.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 78af69b..eb343ab 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -1378,7 +1378,7 @@ static int update_metadata(lvmetad_state *s, const char *arg_name, const char *a
 	 * A lookup of the name arg was successful in finding arg_vgid_lookup,
 	 * but that resulting vgid doesn't match the arg_vgid.
 	 */
-	if (arg_vgid_lookup && arg_vgid && strcmp(arg_vgid_lookup, arg_vgid)) {
+	if (arg_vgid_lookup && strcmp(arg_vgid_lookup, arg_vgid)) {
 		if (arg_name_lookup) {
 			/*
 			 * This shouldn't happen.
@@ -1419,7 +1419,7 @@ static int update_metadata(lvmetad_state *s, const char *arg_name, const char *a
 	 * A lookup of the vgid arg was successful in finding arg_name_lookup,
 	 * but that resulting name doesn't match the arg_name.
 	 */
-	if (arg_name_lookup && arg_name && strcmp(arg_name_lookup, arg_name)) {
+	if (arg_name_lookup && strcmp(arg_name_lookup, arg_name)) {
 		if (arg_vgid_lookup) {
 			/*
 			 * This shouldn't happen.
@@ -1459,7 +1459,7 @@ static int update_metadata(lvmetad_state *s, const char *arg_name, const char *a
 	 * An existing VG has unchanged name and vgid.
 	 */
 	if (!new_vgid && !new_name) {
-		if (strcmp(arg_name_lookup, arg_name)) {
+		if (arg_name_lookup && strcmp(arg_name_lookup, arg_name)) {
 			/* This shouldn't happen. */
 			ERROR(s, "update_metadata arg_vgid %s arg_name %s mismatch arg_name_lookup %s",
 			      arg_vgid, arg_name, arg_name_lookup);
@@ -1467,7 +1467,7 @@ static int update_metadata(lvmetad_state *s, const char *arg_name, const char *a
 			goto update;
 		}
 
-		if (strcmp(arg_vgid_lookup, arg_vgid)) {
+		if (arg_vgid_lookup && strcmp(arg_vgid_lookup, arg_vgid)) {
 			/*
 			 * This shouldn't usually happen, but could when
 			 * disks are moved (or filters are changed?)


