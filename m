From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:32:53 +0000 (UTC)
Subject: master - toollib: validate also name
Message-ID: <20141006133253.7E62A609E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4e9fbb4b96ad4beed5dd004f221cdbfb874e1094
Commit:        4e9fbb4b96ad4beed5dd004f221cdbfb874e1094
Parent:        68bf974769ff2491f90620d15fd76c42244190a1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 30 21:45:10 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:18:05 2014 +0200

toollib: validate also name

In validate_lvname_param() call also validate_name().
---
 tools/toollib.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 721c727..69c1c39 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1539,6 +1539,12 @@ int validate_lvname_param(struct cmd_context *cmd, const char **vg_name,
 	if (!apply_lvname_restrictions(*lv_name))
 		return_0;
 
+	if (!validate_name(*lv_name)) {
+		log_error("Logical volume name \"%s\" is invalid.",
+			  *lv_name);
+		return 0;
+	}
+
 	return 1;
 }
 


