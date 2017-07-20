From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 20 Jul 2017 06:18:48 -0400
Subject: master - cleanup: constify used parameter
Message-ID: <201707201018.v6KAImod016465@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b37e4e3f90b005e116b46949d55f95b9d1470f5b
Commit:        b37e4e3f90b005e116b46949d55f95b9d1470f5b
Parent:        e769e3d3bfd5eaccd5a9043b5641bc73550e5528
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 19 16:15:15 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 20 11:18:29 2017 +0200

cleanup: constify used parameter

---
 libdm/libdm-deptree.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 6ea710d..cf4fd62 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2365,7 +2365,7 @@ static int _2_if_value(unsigned p)
 }
 
 /* Return number of bits passed in @bits assuming 2 * 64 bit size */
-static int _get_params_count(uint64_t *bits)
+static int _get_params_count(const uint64_t *bits)
 {
 	int r = 0;
 	int i = RAID_BITMAP_SIZE;


