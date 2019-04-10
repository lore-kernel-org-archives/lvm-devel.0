From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Apr 2019 07:31:31 -0400
Subject: stable-2.02 - gcc: cleanup const warning
Message-ID: <201904101131.x3ABVVRO014128@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6064b9f1b283c63cc3710555a04d2df0c6357cb0
Commit:        6064b9f1b283c63cc3710555a04d2df0c6357cb0
Parent:        6d4f36c2c7f782af31eca7eca63310791a4f8e93
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 10 12:56:23 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 10 13:30:34 2019 +0200

gcc: cleanup const warning

---
 lib/filters/filter-persistent.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 1d24af8..0586942 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -50,8 +50,8 @@ struct pfilter {
  * by default.  The old code for it should be removed.
  */
 
-static char* _good_device = "good";
-static char* _bad_device = "bad";
+static const char* _good_device = "good";
+static const char* _bad_device = "bad";
 
 /*
  * The hash table holds one of these two states


