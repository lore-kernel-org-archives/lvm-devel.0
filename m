From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 8 Nov 2017 12:17:59 -0500
Subject: master - raid: reject message for 2-legged raid4/5 -> striped
Message-ID: <201711081717.vA8HHxuo027420@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9958c4192766edb2b0f6cf7b963b72121c50b7ad
Commit:        9958c4192766edb2b0f6cf7b963b72121c50b7ad
Parent:        763db8aab02d7df551a3e8500d261ef6c9651bdb
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Nov 8 18:17:26 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Nov 8 18:17:26 2017 +0100

raid: reject message for 2-legged raid4/5 -> striped

Commit 763db8aab02d7df551a3e8500d261ef6c9651bdb rejects 2-legged
conversions to striped/raid0 but different messages are displayed
for raid0 or striped. This commit provides the same rejection messages.
---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 816c6d4..a904666 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -6424,7 +6424,7 @@ int lv_raid_convert(struct logical_volume *lv,
 	stripe_size = new_stripe_size_supplied ? new_stripe_size : seg->stripe_size;
 
 	if (segtype_is_striped(new_segtype))
-		new_image_count = stripes ? : seg->area_count;
+		new_image_count = stripes > 1 ? stripes : seg->area_count;
 
 	if (!_check_max_raid_devices(new_image_count))
 		return_0;


