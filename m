From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  2 Jul 2013 13:33:02 +0000 (UTC)
Subject: master - lv: add lv_config_profile fn
Message-ID: <20130702133302.9279060DA8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6f0427cc56b1ef3ca63ba20b0ac8c0764d38632a
Commit:        6f0427cc56b1ef3ca63ba20b0ac8c0764d38632a
Parent:        e8832917f68f5d130f1f69e73d60f06f6f707363
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jun 27 11:17:16 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 2 15:22:11 2013 +0200

lv: add lv_config_profile fn

Returns LV's profile if it exists, VG's profile otherwise
(LV inherits VG's profile).
---
 lib/metadata/lv.c |    5 +++++
 lib/metadata/lv.h |    1 +
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 6215e1a..93ae92d 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -816,3 +816,8 @@ const struct logical_volume *lv_lock_holder(const struct logical_volume *lv)
 
 	return lv;
 }
+
+struct profile *lv_config_profile(const struct logical_volume *lv)
+{
+	return lv->profile ? : lv->vg->profile;
+}
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index b123109..6831f67 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -92,4 +92,5 @@ int lv_active_change(struct cmd_context *cmd, struct logical_volume *lv,
 char *lv_active_dup(struct dm_pool *mem, const struct logical_volume *lv);
 const struct logical_volume *lv_lock_holder(const struct logical_volume *lv);
 struct logical_volume *lv_ondisk(struct logical_volume *lv);
+struct profile *lv_config_profile(const struct logical_volume *lv);
 #endif /* _LVM_LV_H */


