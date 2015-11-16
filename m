From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 16 Nov 2015 12:14:23 +0000 (UTC)
Subject: master - libdm: better error reporting from dm_split_lvm_name
Message-ID: <20151116121423.20D7B60B40@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

An embedded and charset-unspecified text was scrubbed...
Name: disclaimer.txt
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20151116/fa2ebe0e/attachment.txt>
-------------- next part --------------
Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2a2487f02fb2ddb72106f922dcbf0ddda6959b2f
Commit:        2a2487f02fb2ddb72106f922dcbf0ddda6959b2f
Parent:        5d4f5873a99c3ebe52e671f828580d4cd045e456
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 16 13:07:36 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 16 13:09:53 2015 +0100

libdm: better error reporting from dm_split_lvm_name

Report errors from all error paths correctly.
Validate passed args before dereferencing them.
---
 libdm/libdm-string.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/libdm/libdm-string.c b/libdm/libdm-string.c
index 9132832..79a969c 100644
--- a/libdm/libdm-string.c
+++ b/libdm/libdm-string.c
@@ -95,13 +95,18 @@ static char *_unquote(char *component)
 int dm_split_lvm_name(struct dm_pool *mem, const char *dmname,
 		      char **vgname, char **lvname, char **layer)
 {
-	if (mem && !(*vgname = dm_pool_strdup(mem, dmname))) {
-		log_error("Failed to duplicate dmname.");
+	if (!vgname || !lvname || !layer) {
+		log_error(INTERNAL_ERROR "dm_split_lvm_name: vgname, lvname nor layer could be NULL.");
 		return 0;
 	}
 
-	if (!*vgname)
+	if (mem && (!dmname || !(*vgname = dm_pool_strdup(mem, dmname)))) {
+		log_error("Failed to duplicate lvm name.");
 		return 0;
+	} else if (!*vgname) {
+		log_error("Missing lvm name for split.");
+		return 0;
+	}
 
 	_unquote(*layer = _unquote(*lvname = _unquote(*vgname)));
 
