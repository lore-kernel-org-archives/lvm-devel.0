From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 12 Oct 2012 15:17:09 +0000 (UTC)
Subject: master - lvmetad: release_token without lvmetad
Message-ID: <20121012151709.7BC04AAE24@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0f155e699c67b98cdf6613dcb9fad8d175af7077
Commit:        0f155e699c67b98cdf6613dcb9fad8d175af7077
Parent:        d9cc3f3acb47b698bb85dc24d3bfe890426c6d7b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 12 17:16:28 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 12 17:16:28 2012 +0200

lvmetad: release_token without lvmetad

Missing wrapper when not building with lvmetad support
---
 lib/cache/lvmetad.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index 98d9034..724922d 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -147,6 +147,7 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler)
 #    define lvmetad_active()	(0)
 #    define lvmetad_warning()	do { } while (0)
 #    define lvmetad_set_token(a)	do { } while (0)
+#    define lvmetad_release_token()	do { } while (0)
 #    define lvmetad_vg_update(vg)	(1)
 #    define lvmetad_vg_remove(vg)	(1)
 #    define lvmetad_pv_found(pvid, device, fmt, label_sector, vg, handler)	(1)


