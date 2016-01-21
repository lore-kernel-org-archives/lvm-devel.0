From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 21 Jan 2016 12:29:54 +0000 (UTC)
Subject: master - cleanup: add missing prototype
Message-ID: <20160121122954.7F2A4614E8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=22810155a65e1f2984e04a7f3984eec01d07b7b9
Commit:        22810155a65e1f2984e04a7f3984eec01d07b7b9
Parent:        347575df1d801425b1f1f8ed7106ffe74ce6c8c7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 21 13:25:56 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 21 13:29:08 2016 +0100

cleanup: add missing prototype

Commit 2304286f68debd4755b44fa8b779b762142bfada
missed to add function prototype.
---
 lib/activate/activate.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 22f3cd2..74afb95 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -189,6 +189,7 @@ int lvs_in_vg_opened(const struct volume_group *vg);
 
 int lv_is_active(const struct logical_volume *lv);
 int lv_is_active_locally(const struct logical_volume *lv);
+int lv_is_active_remotely(const struct logical_volume *lv);
 int lv_is_active_but_not_locally(const struct logical_volume *lv);
 int lv_is_active_exclusive(const struct logical_volume *lv);
 int lv_is_active_exclusive_locally(const struct logical_volume *lv);


