From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  2 Oct 2014 11:23:51 +0000 (UTC)
Subject: master - cleanup: remove compiler warning about possible uninitialized variable use
Message-ID: <20141002112351.2C21961079@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a976226e81c561d1123087d1d3dac10ce12e073f
Commit:        a976226e81c561d1123087d1d3dac10ce12e073f
Parent:        5011cac9cfe2845c52f132feb78d72aaee60ff7b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Oct 2 13:21:24 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Oct 2 13:21:24 2014 +0200

cleanup: remove compiler warning about possible uninitialized variable use

filters/filter-usable.c:22: warning: "ucp.check_..." may be used uninitialized in this function

This can't actually be hit in real, but let's clean this up for the compiler
to be happy again.
---
 lib/filters/filter-usable.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/filters/filter-usable.c b/lib/filters/filter-usable.c
index e91c3f3..2a7ef49 100644
--- a/lib/filters/filter-usable.c
+++ b/lib/filters/filter-usable.c
@@ -19,7 +19,7 @@
 static int _passes_usable_filter(struct dev_filter *f, struct device *dev)
 {
 	filter_mode_t mode = *((filter_mode_t *) f->private);
-	struct dev_usable_check_params ucp;
+	struct dev_usable_check_params ucp = {0};
 	int r;
 
 	/* filter only device-mapper devices */


