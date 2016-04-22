From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Apr 2016 12:16:18 +0000 (UTC)
Subject: master - coverity: keep expression using 64bit
Message-ID: <20160422121618.D082160DFC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d12ba022c8082de2d804010992c6ee1076b9f571
Commit:        d12ba022c8082de2d804010992c6ee1076b9f571
Parent:        d564d9f39c73bdbb32413256586991993ad869ef
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 22 14:05:03 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 22 14:15:36 2016 +0200

coverity: keep expression using 64bit

Use 64bit input to remain with whole evaluation in 64bit.
---
 daemons/lvmlockd/lvmlockd-sanlock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index c6534d8..b47c7f0 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -206,7 +206,7 @@ int lm_data_size_sanlock(void)
 #define VG_LOCK_BEGIN UINT64_C(66)
 #define LV_LOCK_BEGIN UINT64_C(67)
 
-static unsigned int daemon_test_lv_count;
+static uint64_t daemon_test_lv_count;
 
 static int lock_lv_name_from_args(char *vg_args, char *lock_lv_name)
 {


