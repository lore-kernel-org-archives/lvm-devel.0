From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Aug 2012 12:42:54 +0000 (UTC)
Subject: master - cleanup: add __attribute__ ((nonnull(1)))
Message-ID: <20120823124254.CC9C7A0D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=132306c8887ac7279edd515a9f5c5de75dfc463a
Commit:        132306c8887ac7279edd515a9f5c5de75dfc463a
Parent:        fd417db274e9a75f33f661b475aeebfd3d9eae45
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 23 23:45:50 2010 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 23 14:37:52 2012 +0200

cleanup: add __attribute__ ((nonnull(1)))

---
 lib/device/dev-cache.h |    1 +
 libdm/regex/ttree.c    |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index b684df6..f3511cc 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -42,6 +42,7 @@ int dev_cache_has_scanned(void);
 
 int dev_cache_add_dir(const char *path);
 int dev_cache_add_loopfile(const char *path);
+__attribute__((nonnull(1)))
 struct device *dev_cache_get(const char *name, struct dev_filter *f);
 
 // TODO
diff --git a/libdm/regex/ttree.c b/libdm/regex/ttree.c
index ec97c98..00b371e 100644
--- a/libdm/regex/ttree.c
+++ b/libdm/regex/ttree.c
@@ -28,6 +28,7 @@ struct ttree {
 	struct node *root;
 };
 
+__attribute__((nonnull(1)))
 static struct node **_lookup_single(struct node **c, unsigned int k)
 {
 	while (*c) {


