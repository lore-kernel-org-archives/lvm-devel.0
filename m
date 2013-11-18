From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 18 Nov 2013 17:01:48 +0000 (UTC)
Subject: master - lvmetad: Set up device pointers in synthetic lvmcache_infos.
Message-ID: <20131118170148.0982961109@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=03d3e1d9c17e959dc78a5bfa82cd69878653a9d2
Commit:        03d3e1d9c17e959dc78a5bfa82cd69878653a9d2
Parent:        b8a6b8f467fadd5334fdb0c4a149753916e097db
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Nov 18 17:53:45 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Nov 18 17:53:45 2013 +0100

lvmetad: Set up device pointers in synthetic lvmcache_infos.

---
 lib/cache/lvmetad.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 8940704..5119ab1 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -277,6 +277,7 @@ static struct lvmcache_info *_pv_populate_lvmcache(
 		return_NULL;
 
 	lvmcache_get_label(info)->sector = label_sector;
+	lvmcache_get_label(info)->dev = dev;
 	lvmcache_set_device_size(info, devsize);
 	lvmcache_del_das(info);
 	lvmcache_del_mdas(info);


