From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Wed, 26 Oct 2016 15:54:54 +0000 (UTC)
Subject: master - raid_manip: fix typo
Message-ID: <20161026155455.04D9860EB5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0468f5da6d2542a2a9c03df2c9e5adf3fed2131d
Commit:        0468f5da6d2542a2a9c03df2c9e5adf3fed2131d
Parent:        021715e897016212beb4123b25239338ab49707e
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Oct 26 17:46:53 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Oct 26 17:53:55 2016 +0200

raid_manip: fix typo

Related to rhbz1386184
---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 39d27f1..25547c4 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -3056,7 +3056,7 @@ static int _raid456_to_raid0_or_striped_wrapper(TAKEOVER_FN_ARGS)
 		return 0;
 
 	if (!yes && yes_no_prompt("Are you sure you want to convert \"%s\" LV %s to \"%s\" "
-				  "type using all resilience? [y/n]: ",
+				  "type losing all resilience? [y/n]: ",
 				  lvseg_name(seg), display_lvname(lv), new_segtype->name) == 'n') {
 		log_error("Logical volume %s NOT converted to \"%s\"",
 			  display_lvname(lv), new_segtype->name);


