From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 20 Jun 2014 15:48:58 +0000 (UTC)
Subject: master - locking: fix cluster locking
Message-ID: <20140620154858.0AB2661295@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c1c2e838e88c56ef38d590007ca3b588ca06f1fd
Commit:        c1c2e838e88c56ef38d590007ca3b588ca06f1fd
Parent:        78533f72d30f6e840f66e0aae89126ef139c1f2c
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jun 20 16:38:48 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jun 20 16:38:48 2014 +0100

locking: fix cluster locking

Hunk missed from last commit 78533f72d30f6e840f66e0aae89126ef139c1f2c.
---
 lib/locking/cluster_locking.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/locking/cluster_locking.c b/lib/locking/cluster_locking.c
index 86e6c77..8070014 100644
--- a/lib/locking/cluster_locking.c
+++ b/lib/locking/cluster_locking.c
@@ -425,6 +425,8 @@ static int _lock_resource(struct cmd_context *cmd, const char *resource,
 	assert(resource);
 
 	switch (flags & LCK_SCOPE_MASK) {
+	case LCK_ACTIVATION:
+		return 1;
 	case LCK_VG:
 		if (!strcmp(resource, VG_SYNC_NAMES)) {
 			log_very_verbose("Requesting sync names.");


