From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 13 Jan 2016 15:44:11 +0000 (UTC)
Subject: master - cleanup: rename 'invisible devices' to 'hidden devices'
Message-ID: <20160113154411.8691F60972@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=04d1a8a5e41bd9fbcaa885b0b13faba85db532d9
Commit:        04d1a8a5e41bd9fbcaa885b0b13faba85db532d9
Parent:        939d29652579e4759d445c87dc21d1a6b37fd97d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jan 13 16:43:25 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 13 16:43:25 2016 +0100

cleanup: rename 'invisible devices' to 'hidden devices'

---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 51dba36..439d79e 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -880,7 +880,7 @@ log/level = 9
 log/overwrite = 1
 log/syslog = 0
 log/verbose = 0
-report/mark_invisible_devices=0
+report/mark_hidden_devices=0
 EOF
 	}
 


