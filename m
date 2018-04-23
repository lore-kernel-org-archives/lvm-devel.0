From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 23 Apr 2018 16:43:28 -0400
Subject: master - debug: more explanatory error message
Message-ID: <201804232043.w3NKhSkp005004@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c492fbb51ce783ca32efd7ed8414d809daaf4ca5
Commit:        c492fbb51ce783ca32efd7ed8414d809daaf4ca5
Parent:        66f4f8c27f6520edc79bafe4aa829d75b3d5e854
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 23 22:11:38 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 23 22:42:18 2018 +0200

debug: more explanatory error message

---
 lib/metadata/lv_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 160943f..7f9cf0b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3805,7 +3805,7 @@ int lv_add_mirror_lvs(struct logical_volume *lv,
 			return_0;
 
 	if (region_size && region_size != seg->region_size) {
-		log_error("Conflicting region_size.");
+		log_error("Conflicting region_size %u != %u.", region_size, seg->region_size);
 		return 0;
 	}
 


