From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  6 Nov 2013 13:56:35 +0000 (UTC)
Subject: master - corosync: fix some gcc warnings
Message-ID: <20131106135635.6EF5F60D90@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b6b5299d1e1f6bdddb9bda30c4f37aaccbe3df44
Commit:        b6b5299d1e1f6bdddb9bda30c4f37aaccbe3df44
Parent:        fc144a3fc5389db11c3c34c9c240a763cc850cc7
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Nov 6 14:55:18 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Nov 6 14:55:18 2013 +0100

corosync: fix some gcc warnings

warning: function declaration isn't a prototype [-Wstrict-prototypes]
warning: old-style function definition [-Wold-style-definition]
---
 daemons/clvmd/clvmd-corosync.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/clvmd/clvmd-corosync.c b/daemons/clvmd/clvmd-corosync.c
index 9092c8a..e68cb73 100644
--- a/daemons/clvmd/clvmd-corosync.c
+++ b/daemons/clvmd/clvmd-corosync.c
@@ -388,7 +388,7 @@ static int _name_from_csid(const char *csid, char *name)
 	return 0;
 }
 
-static int _get_num_nodes()
+static int _get_num_nodes(void)
 {
 	DEBUGLOG("num_nodes = %d\n", num_nodes);
 	return num_nodes;
@@ -505,7 +505,7 @@ static int _unlock_resource(const char *resource, int lockid)
 	return 0;
 }
 
-static int _is_quorate()
+static int _is_quorate(void)
 {
 	int quorate;
 	if (quorum_getquorate(quorum_handle, &quorate) == CS_OK)


