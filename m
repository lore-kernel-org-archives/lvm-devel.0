From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 16:05:59 +0000 (UTC)
Subject: master - lvmlockd: enforce 64bit arithmetic
Message-ID: <20151109160559.45EDB60D27@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b1215b7f8c60f9484b0d6c032b24ea7e029505b0
Commit:        b1215b7f8c60f9484b0d6c032b24ea7e029505b0
Parent:        d6767d753f19cc4bb94f50e19ef22a591ebe280e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 9 16:47:57 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 17:04:10 2015 +0100

lvmlockd: enforce 64bit arithmetic

Coverity suggest to stay on the 'safe' side and widen operators early
so 64bit offset is made from 64bit arithmentic.
---
 daemons/lvmlockd/lvmlockd-sanlock.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index 7cdaf85..3f1f3e9 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -202,9 +202,9 @@ int lm_data_size_sanlock(void)
  */
 
 #define LS_BEGIN 0
-#define GL_LOCK_BEGIN 65
-#define VG_LOCK_BEGIN 66
-#define LV_LOCK_BEGIN 67
+#define GL_LOCK_BEGIN UINT64_C(65)
+#define VG_LOCK_BEGIN UINT64_C(66)
+#define LV_LOCK_BEGIN UINT64_C(67)
 
 static int lock_lv_name_from_args(char *vg_args, char *lock_lv_name)
 {


