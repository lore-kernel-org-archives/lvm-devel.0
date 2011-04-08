From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Apr 2011 14:14:58 -0000
Subject: LVM2/lib/datastruct btree.c
Message-ID: <20110408141458.10572.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-04-08 14:14:58

Modified files:
	lib/datastruct : btree.c 

Log message:
	Better const cast logic
	
	(although still gcc gives const violation warning)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/btree.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/lib/datastruct/btree.c	2010/12/20 13:19:13	1.14
+++ LVM2/lib/datastruct/btree.c	2011/04/08 14:14:57	1.15
@@ -55,7 +55,7 @@
 #endif
 }
 
-static struct node **_lookup(struct node *const *c, uint32_t key,
+static struct node *const *_lookup(struct node *const *c, uint32_t key,
 			     struct node **p)
 {
 	*p = NULL;
@@ -71,20 +71,20 @@
 			c = &(*c)->r;
 	}
 
-	return (struct node **)c;
+	return c;
 }
 
 void *btree_lookup(const struct btree *t, uint32_t k)
 {
 	uint32_t key = _shuffle(k);
-	struct node *p, **c = _lookup(&t->root, key, &p);
+	struct node *p, *const *c = _lookup(&t->root, key, &p);
 	return (*c) ? (*c)->data : NULL;
 }
 
 int btree_insert(struct btree *t, uint32_t k, void *data)
 {
 	uint32_t key = _shuffle(k);
-	struct node *p, **c = _lookup(&t->root, key, &p), *n;
+	struct node *p, **c = (struct node **) _lookup(&t->root, key, &p), *n;
 
 	if (!*c) {
 		if (!(n = dm_pool_alloc(t->mem, sizeof(*n))))


