From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 27 Sep 2021 16:57:54 +0000 (GMT)
Subject: main - cov; matching enum type
Message-ID: <20210927165754.6724B385840B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=614d150a8c7387744804b90fddea99c7fb4511f2
Commit:        614d150a8c7387744804b90fddea99c7fb4511f2
Parent:        bf0d558067926e716a370165e323187cf44c050a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 24 22:14:53 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 27 18:56:14 2021 +0200

cov; matching enum type

---
 tools/lvconvert.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index a7fb848be..34b82ea02 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -95,7 +95,7 @@ struct convert_poll_id_list {
 };
 
 /* FIXME Temporary function until the enum replaces the separate variables */
-static void _set_conv_type(struct lvconvert_params *lp, int conv_type)
+static void _set_conv_type(struct lvconvert_params *lp, conversion_type_t conv_type)
 {
 	if (lp->conv_type != CONV_OTHER)
 		log_error(INTERNAL_ERROR "Changing conv_type from %d to %d.", lp->conv_type, conv_type);


