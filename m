From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 14 Apr 2021 09:07:39 +0000 (GMT)
Subject: main - makefiles: fix replacing path for LVM_PATH
Message-ID: <20210414090739.D1A9B3989C82@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0004ffa73a1378993064a94e4ccb785699a2ed79
Commit:        0004ffa73a1378993064a94e4ccb785699a2ed79
Parent:        b75e26874e6ae5493933368786b92afb8aa29547
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 13 15:26:05 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 14 10:53:34 2021 +0200

makefiles: fix replacing path for LVM_PATH

Man pages were generated with incorrect LVM_PATH.
---
 man/Makefile.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index 01097c886..a6029bbe8 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -140,7 +140,7 @@ $(SED) -e "s+#VERSION#+$(LVM_VERSION)+" \
 	-e "s+#DEFAULT_PROFILE_DIR#+$(DEFAULT_PROFILE_DIR)+" \
 	-e "s+#DEFAULT_CACHE_DIR#+$(DEFAULT_CACHE_DIR)+" \
 	-e "s+#DEFAULT_LOCK_DIR#+$(DEFAULT_LOCK_DIR)+" \
-	-e "s+#LVM_PATH#+$(exec_prefix)/lvm+" \
+	-e "s+#LVM_PATH#+ at bindir@/lvm+" \
 	-e "s+#DEFAULT_RUN_DIR#+$(DEFAULT_RUN_DIR)+" \
 	-e "s+#DEFAULT_PID_DIR#+$(DEFAULT_PID_DIR)+" \
 	-e "s+#SYSTEMD_GENERATOR_DIR#+$(SYSTEMD_GENERATOR_DIR)+" \


