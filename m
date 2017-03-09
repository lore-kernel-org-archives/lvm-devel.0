From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 8 Mar 2017 20:16:29 -0500
Subject: master - raid: fix function description
Message-ID: <201703090116.v291GTYa023818@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=90ed3d5e8c977d632911746c2faf09f60ddbeacc
Commit:        90ed3d5e8c977d632911746c2faf09f60ddbeacc
Parent:        921b496fff51822a851447d3e8f3b93a192b4aea
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 9 02:16:03 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 9 02:16:03 2017 +0100

raid: fix function description

---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 2f30252..68b1b85 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2087,7 +2087,7 @@ static int _activate_sub_lvs_excl_local(struct logical_volume *lv, uint32_t star
 	return 1;
 }
 
-/* Helper: function to activate any sub LVs of @lv exclusively local starting with area indexed by @start_idx */
+/* Helper: function to activate any LVs on @lv_list */
 static int _activate_sub_lvs_excl_local_list(struct logical_volume *lv, struct dm_list *lv_list)
 {
 	int r = 1;


