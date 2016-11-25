From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 25 Nov 2016 14:04:12 +0000 (UTC)
Subject: master - gcc: quiet warning about unused function
Message-ID: <20161125140412.ED9F460BAE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b7cf7b1d3a81749811bc33e1c0840e8f608af991
Commit:        b7cf7b1d3a81749811bc33e1c0840e8f608af991
Parent:        108d9a63fde1608aff815359d58da641fc9a18af
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 25 15:02:36 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 25 15:02:36 2016 +0100

gcc: quiet warning about unused function

Once this function will need to be used, git revert.
---
 lib/metadata/raid_manip.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 9c8ba82..7e591e9 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -34,6 +34,7 @@ static int _check_restriping(uint32_t new_stripes, struct logical_volume *lv)
 	return 1;
 }
 
+__attribute__ ((__unused__))
 /* Check that all lv has segments have exactly the required number of areas */
 static int _check_num_areas_in_lv_segments(struct logical_volume *lv, unsigned num_areas)
 {


