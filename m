From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat,  9 May 2015 07:18:29 +0000 (UTC)
Subject: master - tests: missed conversion
Message-ID: <20150509071829.6B4DB61AA7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e3ccf980236a842cfc13be11726be651b127afb0
Commit:        e3ccf980236a842cfc13be11726be651b127afb0
Parent:        abcab54cca4b4f9ff157a5f51718c69ffdf34c7a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 9 09:15:29 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 9 09:17:26 2015 +0200

tests: missed conversion

Assuming it should test same number as other functions.
---
 test/shell/pvmove-resume-1.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/pvmove-resume-1.sh b/test/shell/pvmove-resume-1.sh
index e8564fa..0070826 100644
--- a/test/shell/pvmove-resume-1.sh
+++ b/test/shell/pvmove-resume-1.sh
@@ -112,7 +112,7 @@ lvchange_single() {
 		aux check_lvmpolld_init_rq_count 1 "$vg/pvmove0"
 		aux check_lvmpolld_init_rq_count 1 "$vg1/pvmove0"
 	else
-		check_spawned_bg_procs_count $1
+		test $(aux count_processes_with_tag) -eq $1
 	fi
 }
 


