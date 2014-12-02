From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  2 Dec 2014 14:27:27 +0000 (UTC)
Subject: master - mirror: Restrict region size to power of 2.
Message-ID: <20141202142727.0FD2961297@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=de53e0955dc43d5f069604553b038fa672463da9
Commit:        de53e0955dc43d5f069604553b038fa672463da9
Parent:        9258e57a50451fbbabd72a197e6a78a2a5d898db
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Dec 2 14:24:21 2014 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Dec 2 14:24:21 2014 +0000

mirror: Restrict region size to power of 2.

---
 WHATS_NEW             |    1 +
 lib/metadata/mirror.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 645450c..54e46d9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.115 -
 =====================================
+  Still restrict mirror region size to power of 2 when VG extent size is not.
 
 Version 2.02.114 - 28th November 2014
 =====================================
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index ba3ff6b..d0b1ebf 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -164,7 +164,7 @@ uint32_t adjusted_mirror_region_size(uint32_t extent_size, uint32_t extents,
 {
 	uint64_t region_max;
 
-	region_max = (1 << (ffs((int)extents) - 1)) * (uint64_t) extent_size;
+	region_max = (1 << (ffs((int)extents) - 1)) * (uint64_t) (1 << (ffs((int)extent_size) - 1));
 
 	if (region_max < UINT32_MAX && region_size > region_max) {
 		region_size = (uint32_t) region_max;


