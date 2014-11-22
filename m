From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 22 Nov 2014 23:50:51 +0000 (UTC)
Subject: master - cleanup: warning: declaration of 'remove' shadows a global declaration
Message-ID: <20141122235051.C5F5C60B35@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ccdea661fa2aab07fbd73bfd7f8fe5273acd71c0
Commit:        ccdea661fa2aab07fbd73bfd7f8fe5273acd71c0
Parent:        678cc4e3752ec74c7647a23eb3131439c37b3328
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 22 20:14:42 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Nov 23 00:49:04 2014 +0100

cleanup: warning: declaration of 'remove' shadows a  global declaration

Don't shadow stdio.h declaration.
---
 libdm/libdm-config.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index 91aa970..1ec604f 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -1386,11 +1386,11 @@ struct dm_config_tree *dm_config_flatten(struct dm_config_tree *cft)
 	return res;
 }
 
-int dm_config_remove_node(struct dm_config_node *parent, struct dm_config_node *remove)
+int dm_config_remove_node(struct dm_config_node *parent, struct dm_config_node *rem_node)
 {
 	struct dm_config_node *cn = parent->child, *last = NULL;
 	while (cn) {
-		if (cn == remove) {
+		if (cn == rem_node) {
 			if (last)
 				last->sib = cn->sib;
 			else


