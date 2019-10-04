From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 4 Oct 2019 11:33:14 -0400
Subject: master - vdo: raise VDO default bio threads to 4
Message-ID: <201910041533.x94FXEmI031015@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=aad91330fecd7718fe5eb66a258feabc42f73c26
Commit:        aad91330fecd7718fe5eb66a258feabc42f73c26
Parent:        98419e06670493523ee08ea8e10b222deb253f7c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 4 14:52:40 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 4 17:31:55 2019 +0200

vdo: raise VDO default bio threads to 4

Since 'vdo create' tends to use this setting,
update lvm2 to provide same default.
---
 lib/config/defaults.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 6a0d686..be4f5ff 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -164,7 +164,7 @@
 #define DEFAULT_VDO_INDEX_MEMORY_SIZE_MB	(DM_VDO_INDEX_MEMORY_SIZE_MINIMUM_MB)
 #define DEFAULT_VDO_SLAB_SIZE_MB	(2 * 1024)  // 2GiB ... 19 slabbits
 #define DEFAULT_VDO_ACK_THREADS		(1)
-#define DEFAULT_VDO_BIO_THREADS		(1)
+#define DEFAULT_VDO_BIO_THREADS		(4)
 #define DEFAULT_VDO_BIO_ROTATION	(64)
 #define DEFAULT_VDO_CPU_THREADS		(2)
 #define DEFAULT_VDO_HASH_ZONE_THREADS	(1)


