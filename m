From: Alasdair Kergon <agk@sourceware.org>
Date: Tue, 2 Jan 2018 13:20:16 -0500
Subject: master - label: Add mempool.
Message-ID: <201801021820.w02IKGEa014755@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e6b4b41881b6070b24353496dd32cccc270fe9ce
Commit:        e6b4b41881b6070b24353496dd32cccc270fe9ce
Parent:        0bf1cc2320cb96cde9be742bed2aa391c998588a
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jan 2 13:37:12 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jan 2 13:37:12 2018 +0000

label: Add mempool.

---
 lib/label/label.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index b90fff3..fa44f2c 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -26,6 +26,8 @@
 
 /* FIXME Allow for larger labels?  Restricted to single sector currently */
 
+static struct dm_pool *_labeller_mem;
+
 /*
  * Internal labeller struct.
  */
@@ -58,7 +60,13 @@ static struct labeller_i *_alloc_li(const char *name, struct labeller *l)
 
 int label_init(void)
 {
+	if (!(_labeller_mem = dm_pool_create("label scan", 128))) {
+		log_error("Labeller pool creation failed.");
+		return 0;
+	}
+
 	dm_list_init(&_labellers);
+
 	return 1;
 }
 
@@ -73,6 +81,8 @@ void label_exit(void)
 	}
 
 	dm_list_init(&_labellers);
+
+	dm_pool_destroy(_labeller_mem);
 }
 
 int label_register_handler(struct labeller *handler)


