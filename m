From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Apr 2014 09:02:42 +0000 (UTC)
Subject: master - raid: use internal variables for array alloc
Message-ID: <20140408090242.D40F660040@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=96cf9dc0170d8a807ecac3956a80c3f51cfe48c0
Commit:        96cf9dc0170d8a807ecac3956a80c3f51cfe48c0
Parent:        89615af349056e3a34788a8b6c0842100389d2b8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 4 21:19:58 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 8 11:00:13 2014 +0200

raid: use internal variables for array alloc

Don't use passed pointer when allocating policies' array.
(In case policy_argc would be NULL, this would have caused
NULL dereference).
---
 lib/activate/activate.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 6667dfc..4d3f8fe 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1121,9 +1121,9 @@ int lv_cache_policy_info(struct logical_volume *lv,
 		*policy_argc = status->policy_argc;
 	if (policy_argv) {
 		if (!(*policy_argv =
-		      dm_pool_zalloc(mem, sizeof(char *) * *policy_argc)))
+		      dm_pool_zalloc(mem, sizeof(char *) * status->policy_argc)))
 			return_0;
-		for (i = 0; i < *policy_argc; i++)
+		for (i = 0; i < status->policy_argc; ++i)
 			if (!((*policy_argv)[i] =
 			      dm_pool_strdup(mem, status->policy_argv[i])))
 				return_0;


