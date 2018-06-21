From: David Teigland <teigland@sourceware.org>
Date: Thu, 21 Jun 2018 11:55:00 -0400
Subject: master - filter: use pointers to real addresses
Message-ID: <201806211555.w5LFt0wc024120@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dd7ebec12028a65081f676b5f52215b012c75c88
Commit:        dd7ebec12028a65081f676b5f52215b012c75c88
Parent:        15826214f94da5a447f34ae9d237f1f018d3bac3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 21 10:52:35 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 21 10:54:43 2018 -0500

filter: use pointers to real addresses

instead of casting values 1 and 2 to pointers
which gcc optimization can have problems with.
---
 lib/filters/filter-persistent.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 1782bfa..130b1e5 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -43,12 +43,15 @@ struct pfilter {
  * do this.
  */
 
+static int _good_device;
+static int _bad_device;
+
 /*
  * The hash table holds one of these two states
  * against each entry.
  */
-#define PF_BAD_DEVICE ((void *) 1)
-#define PF_GOOD_DEVICE ((void *) 2)
+#define PF_BAD_DEVICE ((void *) &_good_device)
+#define PF_GOOD_DEVICE ((void *) &_bad_device)
 
 static int _init_hash(struct pfilter *pf)
 {


