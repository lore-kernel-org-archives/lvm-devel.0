From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Feb 2014 18:01:27 +0000 (UTC)
Subject: master - cleanup: update clearing message
Message-ID: <20140211180127.B352B60FC3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bcd6b643be0aaef1df06a4df482a8e528d3cd36a
Commit:        bcd6b643be0aaef1df06a4df482a8e528d3cd36a
Parent:        40a9c443a925ff2fbc7c12972c3cfa726b880580
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 11 13:30:41 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 11 18:59:22 2014 +0100

cleanup: update clearing message

Since some targets are using this routine to setup
other values then 0 and also may clear much more data then
just disk header - add better message.
---
 lib/metadata/lv_manip.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 1b9a7ae..826dbb2 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5550,8 +5550,9 @@ int wipe_lv(struct logical_volume *lv, struct wipe_params wp)
 		if (zero_sectors > lv->size)
 			zero_sectors = lv->size;
 
-		log_verbose("Clearing start of logical volume \"%s/%s\"",
-			     lv->vg->name, lv->name);
+		log_verbose("Initializing %s of logical volume \"%s/%s\" with value %d.",
+			    display_size(lv->vg->cmd, zero_sectors),
+			    lv->vg->name, lv->name, wp.zero_value);
 
 		if (!dev_set(dev, UINT64_C(0), (size_t) zero_sectors << SECTOR_SHIFT, wp.zero_value))
 			stack;


