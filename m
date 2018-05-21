From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 21 May 2018 06:00:41 -0400
Subject: master - tests: use 4K extent size
Message-ID: <201805211000.w4LA0fg0002918@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=25a66737e3c9fee218c84a659d5d9b7a34347e47
Commit:        25a66737e3c9fee218c84a659d5d9b7a34347e47
Parent:        a9f2c1e1f568d7fc7ffba7ec702b584f34f678c6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 21 11:56:45 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 21 11:58:10 2018 +0200

tests: use 4K extent size

To work with for 4k backend devices.
---
 test/api/vgtest.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/api/vgtest.c b/test/api/vgtest.c
index da04dda..97f0d2c 100644
--- a/test/api/vgtest.c
+++ b/test/api/vgtest.c
@@ -28,7 +28,7 @@ vg_t vg;
 const char *vg_name;
 #define MAX_DEVICES 16
 const char *device[MAX_DEVICES];
-uint64_t size = 1024;
+uint64_t size = 4096;
 
 #define vg_create(vg_name) \
 	printf("Creating VG %s\n", vg_name); \


