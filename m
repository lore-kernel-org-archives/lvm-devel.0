From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 30 Jan 2015 11:35:15 +0000 (UTC)
Subject: master - cleanup: indent tabs
Message-ID: <20150130113515.430F260FA9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2055b04c111eb5df3a445a9b544aff7a17b411a1
Commit:        2055b04c111eb5df3a445a9b544aff7a17b411a1
Parent:        2e35c681222c18980ea818951bf41199f895ccda
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 30 12:27:16 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 30 12:33:52 2015 +0100

cleanup: indent tabs

---
 lib/metadata/metadata.h |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index f8a11c9..75abf63 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -434,8 +434,9 @@ int for_each_sub_lv_except_pools(struct logical_volume *lv,
 				 int (*fn)(struct logical_volume *lv, void *data),
 				 void *data);
 int for_each_sub_lv(struct logical_volume *lv,
-                    int (*fn)(struct logical_volume *lv, void *data),
-                    void *data);
+		    int (*fn)(struct logical_volume *lv, void *data),
+		    void *data);
+
 int move_lv_segments(struct logical_volume *lv_to,
 		     struct logical_volume *lv_from,
 		     uint64_t set_status, uint64_t reset_status);


