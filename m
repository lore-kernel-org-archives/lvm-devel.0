From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 12 Apr 2010 17:21:29 +0200
Subject: [PATCH 01/22] Add dm_list_splice() for list join.
In-Reply-To: <cover.1271085009.git.zkabelac@redhat.com>
References: <cover.1271085009.git.zkabelac@redhat.com>
Message-ID: <d80e727dc920a3a77dc38a43125a2bc1b226a125.1271085009.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Introduce dm_list_splice to join two lists.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/.exported_symbols |    1 +
 libdm/datastruct/list.c |   12 ++++++++++++
 libdm/libdevmapper.h    |    5 +++++
 3 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/libdm/.exported_symbols b/libdm/.exported_symbols
index fd9d0b9..ea65c8b 100644
--- a/libdm/.exported_symbols
+++ b/libdm/.exported_symbols
@@ -153,6 +153,7 @@ dm_list_add
 dm_list_add_h
 dm_list_del
 dm_list_move
+dm_list_splice
 dm_list_empty
 dm_list_start
 dm_list_end
diff --git a/libdm/datastruct/list.c b/libdm/datastruct/list.c
index 3d9ca8b..a7f9324 100644
--- a/libdm/datastruct/list.c
+++ b/libdm/datastruct/list.c
@@ -144,3 +144,15 @@ unsigned int dm_list_size(const struct dm_list *head)
 
 	return s;
 }
+
+void dm_list_splice(struct dm_list *list, struct dm_list *head)
+{
+	struct dm_list *first = list->n;
+	struct dm_list *last = list->p;
+	struct dm_list *at = head->n;
+
+	first->p = head;
+	head->n = first;
+	last->n = at;
+	at->p = last;
+}
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 1ae930f..aa8ad5c 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -715,6 +715,11 @@ void dm_list_del(struct dm_list *elem);
 void dm_list_move(struct dm_list *head, struct dm_list *elem);
 
 /*
+ * Join 'list' to 'head'.
+ */
+void dm_list_splice(struct dm_list *list, struct dm_list *head);
+
+/*
  * Is the list empty?
  */
 int dm_list_empty(const struct dm_list *head);
-- 
1.7.0.1


