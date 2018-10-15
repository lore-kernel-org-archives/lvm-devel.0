From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Oct 2018 11:55:12 -0400
Subject: master - cov: add at least ASSERT
Message-ID: <201810151555.w9FFtCgL020562@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=30b1b575067bcab27ab1788247754b183387f55e
Commit:        30b1b575067bcab27ab1788247754b183387f55e
Parent:        eed8715e1d891665a6c9b8a39850e61f40ea453e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 14:53:36 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 17:49:44 2018 +0200

cov: add at least ASSERT

Seems lot of code here can't handle failing allocation.
Meanwhile before bigger fix put in asserts in place.
---
 base/data-struct/radix-tree-adaptive.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/base/data-struct/radix-tree-adaptive.c b/base/data-struct/radix-tree-adaptive.c
index cbe8302..f5a8606 100644
--- a/base/data-struct/radix-tree-adaptive.c
+++ b/base/data-struct/radix-tree-adaptive.c
@@ -564,6 +564,8 @@ static void _degrade_to_n4(struct node16 *n16, struct value *result)
 {
         struct node4 *n4 = zalloc(sizeof(*n4));
 
+	assert(n4 != NULL);
+
         n4->nr_entries = n16->nr_entries;
         memcpy(n4->keys, n16->keys, n16->nr_entries * sizeof(*n4->keys));
         memcpy(n4->values, n16->values, n16->nr_entries * sizeof(*n4->values));
@@ -578,6 +580,8 @@ static void _degrade_to_n16(struct node48 *n48, struct value *result)
 	unsigned i, count = 0;
         struct node16 *n16 = zalloc(sizeof(*n16));
 
+	assert(n16 != NULL);
+
         n16->nr_entries = n48->nr_entries;
         for (i = 0; i < 256; i++) {
 	        if (n48->keys[i] < 48) {
@@ -598,6 +602,8 @@ static void _degrade_to_n48(struct node256 *n256, struct value *result)
         unsigned i, count = 0;
         struct node48 *n48 = zalloc(sizeof(*n48));
 
+	assert(n48 != NULL);
+
         n48->nr_entries = n256->nr_entries;
         for (i = 0; i < 256; i++) {
 		if (n256->values[i].type == UNSET)


