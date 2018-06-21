From: David Teigland <teigland@sourceware.org>
Date: Thu, 21 Jun 2018 11:54:17 -0400
Subject: 2018-06-01-stable - filter: use pointers to real addresses
Message-ID: <201806211554.w5LFsHr0024093@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4afb5971b93af79f81dfb3fff33b25fec270ac37
Commit:        4afb5971b93af79f81dfb3fff33b25fec270ac37
Parent:        dd075e93c1fa0f5686432b71290ffa340f74c28d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 21 10:52:35 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 21 10:52:35 2018 -0500

filter: use pointers to real addresses

instead of casting values 1 and 2 to pointers
which gcc optimization can have problems with.
---
 lib/filters/filter-persistent.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index e4659aa..bbfd858 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -50,12 +50,15 @@ struct pfilter {
  * by default.  The old code for it should be removed.
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


