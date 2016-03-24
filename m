From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 24 Mar 2016 17:43:29 +0000 (UTC)
Subject: master - libdm: Raid status region units are sectors
Message-ID: <20160324174329.0B12D60FE3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a5d53aec839e7fbe558b26e3195a8a18d3451ab5
Commit:        a5d53aec839e7fbe558b26e3195a8a18d3451ab5
Parent:        d243db5466591412a3c99bb5be84e338da9ba4c9
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Mar 24 17:42:36 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Mar 24 17:42:36 2016 +0000

libdm: Raid status region units are sectors

---
 libdm/libdevmapper.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index ac79a57..a90013f 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -321,8 +321,8 @@ int dm_get_status_mirror(struct dm_pool *mem, const char *params,
 /* Parse params from STATUS call for raid target */
 struct dm_status_raid {
 	uint64_t reserved;
-	uint64_t total_regions;
-	uint64_t insync_regions;
+	uint64_t total_regions;		/* sectors */
+	uint64_t insync_regions;	/* sectors */
 	uint64_t mismatch_count;
 	uint32_t dev_count;
 	char *raid_type;


