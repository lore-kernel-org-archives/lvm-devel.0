From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 28 Apr 2010 14:27:21 +0200
Subject: [PATCH 02/23] Add dm_list_splice() for list join.
In-Reply-To: <cover.1272457502.git.zkabelac@redhat.com>
References: <cover.1272457502.git.zkabelac@redhat.com>
Message-ID: <6816c6ac6cc95e8577b76cb8941303425467dc71.1272457502.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Introduce dm_list_splice() to join two lists.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/.exported_symbols |    1 +
 libdm/datastruct/list.c |   24 +++++++++++++++++++++++-
 libdm/libdevmapper.h    |    5 +++++
 3 files changed, 29 insertions(+), 1 deletions(-)

diff --git a/libdm/.exported_symbols b/libdm/.exported_symbols
index 73ee5bd..32f664d 100644
--- a/libdm/.exported_symbols
+++ b/libdm/.exported_symbols
@@ -155,6 +155,7 @@ dm_list_add
 dm_list_add_h
 dm_list_del
 dm_list_move
+dm_list_splice
 dm_list_empty
 dm_list_start
 dm_list_end
diff --git a/libdm/datastruct/list.c b/libdm/datastruct/list.c
index 3d9ca8b..c7a052f 100644
--- a/libdm/datastruct/list.c
+++ b/libdm/datastruct/list.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -144,3 +144,25 @@ unsigned int dm_list_size(const struct dm_list *head)
 
 	return s;
 }
+
+/*
+ * Join two lists together.
+ * This moves all the elements of the list 'head1' to the end of the list
+ * 'head', leaving 'head1' empty.
+ */
+void dm_list_splice(struct dm_list *head, struct dm_list *head1)
+{
+	assert(head->n);
+	assert(head1->n);
+
+	if (dm_list_empty(head1))
+	    return;
+
+	head1->p->n = head;
+	head1->n->p = head->p;
+
+	head->p->n = head1->n;
+	head->p = head1->p;
+
+	dm_list_init(head1);
+}
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 0ee23fb..781db12 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -718,6 +718,11 @@ void dm_list_del(struct dm_list *elem);
 void dm_list_move(struct dm_list *head, struct dm_list *elem);
 
 /*
+ * Join 'head1' to the of 'head'.
+ */
+void dm_list_splice(struct dm_list *head, struct dm_list *head1);
+
+/*
  * Is the list empty?
  */
 int dm_list_empty(const struct dm_list *head);
-- 
1.7.0.1


