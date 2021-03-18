From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 18 Mar 2021 18:15:03 +0000 (GMT)
Subject: main - segtypes: macros for error and zero segtypes
Message-ID: <20210318181503.83B6A3848011@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b35ef9d67cabd23f65e2ee2113af46bea095138c
Commit:        b35ef9d67cabd23f65e2ee2113af46bea095138c
Parent:        22554c3ff0807f62f8fa71faab153958c475028b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 18 13:13:38 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 18 18:34:57 2021 +0100

segtypes: macros for error and zero segtypes

---
 lib/metadata/segtype.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 676f37e3c..d7cfc2b72 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -115,6 +115,8 @@ struct dev_manager;
 #define SEG_TYPE_NAME_RAID6_N_6		"raid6_n_6"
 
 #define segtype_is_linear(segtype)	(!strcmp((segtype)->name, SEG_TYPE_NAME_LINEAR))
+#define segtype_is_error(segtype)	(!strcmp((segtype)->name, SEG_TYPE_NAME_ERROR))
+#define segtype_is_zero(segtype)	(!strcmp((segtype)->name, SEG_TYPE_NAME_ZERO))
 #define segtype_is_striped_target(segtype)	((segtype)->flags & SEG_STRIPED_TARGET ? 1 : 0)
 #define segtype_is_cache(segtype)	((segtype)->flags & SEG_CACHE ? 1 : 0)
 #define segtype_is_cache_pool(segtype)	((segtype)->flags & SEG_CACHE_POOL ? 1 : 0)


