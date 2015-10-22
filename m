From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Oct 2015 21:34:10 +0000 (UTC)
Subject: master - cleanup: declare vars before code
Message-ID: <20151022213410.EECC26057E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=39cffa4e9b027162430ea7f3c288256b232a1ed7
Commit:        39cffa4e9b027162430ea7f3c288256b232a1ed7
Parent:        2af696c32f99b2951bcc7e2a73130e46dc4f383f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 22 10:33:01 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 22 22:46:10 2015 +0200

cleanup: declare vars before code

---
 libdm/libdm-config.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index b2082c8..c8984b2 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -157,21 +157,18 @@ struct dm_config_tree *dm_config_insert_cascaded_tree(struct dm_config_tree *fir
 
 static struct dm_config_node *_config_reverse(struct dm_config_node *head)
 {
-	if (!head)
-		return NULL;
-
 	struct dm_config_node *left = head, *middle = NULL, *right = NULL;
 
-	do {
+	while (left) {
 		right = middle;
 		middle = left;
 		left = left->sib;
 		middle->sib = right;
 		middle->child = _config_reverse(middle->child);
-	} while (left);
+	}
 
 	return middle;
-};
+}
 
 int dm_config_parse(struct dm_config_tree *cft, const char *start, const char *end)
 {


