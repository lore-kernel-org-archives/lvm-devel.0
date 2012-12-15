From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Dec 2012 16:25:18 +0000 (UTC)
Subject: master - cleanup: use proper const in apply_lvname_restrictions
Message-ID: <20121215162518.DEB1AAAB83@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=575c4ed96412edf513dbd0263983520a15b3b8bc
Commit:        575c4ed96412edf513dbd0263983520a15b3b8bc
Parent:        21f6511bc200af434fb933a181f5334021b3ee08
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 14 14:03:58 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 15 14:57:40 2012 +0100

cleanup: use proper const in apply_lvname_restrictions

Better constness used for reserved prefixes and strings.
Also simplify a bit validate_name and use direct char
checks isntead of 2 strcmp() calls.
---
 lib/misc/lvm-string.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index 7e4bbdd..9dcdb3d 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -81,7 +81,7 @@ int validate_name(const char *n)
 	if (*n == '-')
 		return 0;
 
-	if (!strcmp(n, ".") || !strcmp(n, ".."))
+	if ((*n == '.') && (!n[1] || (n[1] == '.' && !n[2]))) /* ".", ".." */
 		return 0;
 
 	while ((len++, c = *n++))
@@ -96,13 +96,13 @@ int validate_name(const char *n)
 
 int apply_lvname_restrictions(const char *name)
 {
-	const char *reserved_prefixes[] = {
+	static const char * const _reserved_prefixes[] = {
 		"snapshot",
 		"pvmove",
 		NULL
 	};
 
-	const char *reserved_strings[] = {
+	static const char * const _reserved_strings[] = {
 		"_mlog",
 		"_mimage",
 		"_rimage",
@@ -116,7 +116,7 @@ int apply_lvname_restrictions(const char *name)
 	unsigned i;
 	const char *s;
 
-	for (i = 0; (s = reserved_prefixes[i]); i++) {
+	for (i = 0; (s = _reserved_prefixes[i]); i++) {
 		if (!strncmp(name, s, strlen(s))) {
 			log_error("Names starting \"%s\" are reserved. "
 				  "Please choose a different LV name.", s);
@@ -124,7 +124,7 @@ int apply_lvname_restrictions(const char *name)
 		}
 	}
 
-	for (i = 0; (s = reserved_strings[i]); i++) {
+	for (i = 0; (s = _reserved_strings[i]); i++) {
 		if (strstr(name, s)) {
 			log_error("Names including \"%s\" are reserved. "
 				  "Please choose a different LV name.", s);


