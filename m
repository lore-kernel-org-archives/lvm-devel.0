From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:39:07 +0000 (UTC)
Subject: dev-dct-process-latest - cleanup: update message
Message-ID: <20140922153907.0896860C1A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=34bdb83c52ddc3533b16d923953435e576699877
Commit:        34bdb83c52ddc3533b16d923953435e576699877
Parent:        6d21438d0c64267ac11b4825ad719c458b80059e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 18 00:53:42 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 18 00:53:42 2014 +0200

cleanup: update message

---
 tools/lvconvert.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index b6ef1bf..2cd5ba6 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3075,7 +3075,7 @@ static int _lvconvert_cache(struct cmd_context *cmd,
 	if (lv_is_external_origin(origin) || lv_is_origin(origin) || lv_is_thin_type(origin) ||
 	    lv_is_mirror_type(origin) || lv_is_cache_origin(origin) || lv_is_virtual(origin) ||
 	    lv_is_cow(origin) || lv_is_merging_origin(origin) || lv_is_merging_cow(origin)) {
-		log_error("Cache is not supported with origin LV type.",
+		log_error("Cache is not supported with origin LV %s type.",
 			  display_lvname(origin));
 		return 0;
 	}


