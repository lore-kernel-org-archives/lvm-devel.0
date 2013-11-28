From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 28 Nov 2013 12:28:06 +0000 (UTC)
Subject: master - tests: initialize signature wiping
Message-ID: <20131128122806.4F59B603A6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c24b558c8c3e8f877e7cf216369e3415be8dbc6f
Commit:        c24b558c8c3e8f877e7cf216369e3415be8dbc6f
Parent:        6a1957badcb95a5f2815436e64798b48ed85ca0c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Nov 28 13:23:45 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Nov 28 13:27:52 2013 +0100

tests: initialize signature wiping

Do not use signature wiping for newly created LVs in tests - we're
reusing the devs in tests and such detection could just interfere
inappropriately. We'd need to modify all tests to anwer the prompt
whether any signature found should be removed or not or we'd need
to use "-y" option for all lvcreates in tests. It's better to disable
this feature then and let's do a separate test to test this signature
wiping functionality.
---
 test/lib/aux.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 4ef1132..d1ae524 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -563,6 +563,7 @@ activation/polling_interval = 0
 activation/snapshot_autoextend_percent = 50
 activation/snapshot_autoextend_threshold = 50
 activation/monitoring = 0
+allocation/wipe_signatures_on_new_logical_volumes_when_zeroing = 0
 EOF
 	}
 


