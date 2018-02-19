From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Feb 2018 10:46:00 -0500
Subject: master - sanlock: set proper return value
Message-ID: <201802191546.w1JFk00Y025784@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e87fa7c9cef53013efa46033ad037822c70c1bb9
Commit:        e87fa7c9cef53013efa46033ad037822c70c1bb9
Parent:        1671b83585a6ee49448376c20834a9e89936a7f3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 17 11:23:19 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 19 16:44:10 2018 +0100

sanlock: set proper return value

In last patch one error path missed to assign correct return value.
Assing it directly to 'ret' as log_error was already reported.
---
 daemons/lvmlockd/lvmlockd-sanlock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index dd88d24..a91218b 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -1121,7 +1121,7 @@ int lm_prepare_lockspace_sanlock(struct lockspace *ls)
 		goto fail;
 	}
 
-	if ((rv = build_dm_path(disk_path, SANLK_PATH_LEN, ls->vg_name, lock_lv_name)))
+	if ((ret = build_dm_path(disk_path, SANLK_PATH_LEN, ls->vg_name, lock_lv_name)))
 		goto fail;
 
 	/*


