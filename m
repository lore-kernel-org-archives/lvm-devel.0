From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:05:00 +0000 (UTC)
Subject: dev-mornfall-lvmcache - lvcreate: update snapshot test
Message-ID: <20130605120500.AB9766134E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e01fbd9d8d310c0b0ddcf58782ac2b871185ddd9
Commit:        e01fbd9d8d310c0b0ddcf58782ac2b871185ddd9
Parent:        562c678ee23e76b675a8f4682bd6d2447d1d0de7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 31 11:00:29 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 31 21:30:44 2013 +0200

lvcreate: update snapshot test

With last commit, there has been missing test for valid setting
of extents - there is no need to test max size when creating
thin snapshots.
---
 tools/lvcreate.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index f56cdbd..7beaf6c 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -300,7 +300,12 @@ static int _update_extents_params(struct volume_group *vg,
 			break;
 	}
 
-	if (lp->snapshot && lp->origin) {
+	if (lp->snapshot && lp->origin && lp->extents) {
+		if (!lp->chunk_size) {
+			log_error(INTERNAL_ERROR "Missing snapshot chunk size.");
+			return 0;
+		}
+
 		if (!origin && !(origin = find_lv(vg, lp->origin))) {
 			log_error("Couldn't find origin volume '%s'.",
 				  lp->origin);


