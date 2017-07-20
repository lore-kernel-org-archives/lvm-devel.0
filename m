From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 20 Jul 2017 06:19:15 -0400
Subject: master - tidy: name all parameters
Message-ID: <201707201019.v6KAJFOr016540@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4a2994b7b1ff4a09f250f6389894a3072d7e3acd
Commit:        4a2994b7b1ff4a09f250f6389894a3072d7e3acd
Parent:        1fd8785ff30261d25cce2f98a8e5c566d34d3151
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 20 10:30:00 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 20 11:20:26 2017 +0200

tidy: name all parameters

---
 lib/metadata/metadata.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index d8f993c..ce2e3cc 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2389,7 +2389,7 @@ struct _lv_postorder_baton {
 	void *data;
 };
 
-static int _lv_postorder_visit(struct logical_volume *,
+static int _lv_postorder_visit(struct logical_volume *lv,
 			       int (*fn)(struct logical_volume *lv, void *data),
 			       void *data);
 


