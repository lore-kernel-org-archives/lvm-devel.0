From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu, 20 Nov 2014 15:52:58 +0000 (UTC)
Subject: master - libdm-config: Re-link config trees to reflect file order of keys/sections.
Message-ID: <20141120155258.CE18960D28@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=956c19284195f3200a1370166bd8847e5d159588
Commit:        956c19284195f3200a1370166bd8847e5d159588
Parent:        687029cbbd5b97d545363b4f7448b5a1fe71f3c5
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Nov 18 23:39:11 2014 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Nov 20 16:51:06 2014 +0100

libdm-config: Re-link config trees to reflect file order of keys/sections.

---
 libdm/libdm-config.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index 4965e32..c026385 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -154,6 +154,24 @@ struct dm_config_tree *dm_config_insert_cascaded_tree(struct dm_config_tree *fir
 	return first_cft;
 }
 
+static struct dm_config_node *_config_reverse(struct dm_config_node *head)
+{
+	if (!head)
+		return NULL;
+
+	struct dm_config_node *left = head, *middle = NULL, *right = NULL;
+
+	do {
+		right = middle;
+		middle = left;
+		left = left->sib;
+		middle->sib = right;
+		middle->child = _config_reverse(middle->child);
+	} while (left);
+
+	return middle;
+};
+
 int dm_config_parse(struct dm_config_tree *cft, const char *start, const char *end)
 {
 	/* TODO? if (start == end) return 1; */
@@ -172,6 +190,8 @@ int dm_config_parse(struct dm_config_tree *cft, const char *start, const char *e
 	if (!(cft->root = _file(p)))
 		return_0;
 
+	cft->root = _config_reverse(cft->root);
+
 	return 1;
 }
 


