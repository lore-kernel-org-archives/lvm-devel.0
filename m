From: okozina <okozina@fedoraproject.org>
Date: Mon, 11 May 2015 17:08:55 +0000 (UTC)
Subject: master - tests: remove forgotten set -v in aux
Message-ID: <20150511170855.2C8E160222@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f5199a1cbddf9fbfaba54635c12b7ebd6e4dd0a8
Commit:        f5199a1cbddf9fbfaba54635c12b7ebd6e4dd0a8
Parent:        d7581157861722b832afd17f83a71f993a9e44a0
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Mon May 11 18:49:24 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Mon May 11 19:08:19 2015 +0200

tests: remove forgotten set -v in aux

---
 test/lib/aux.sh |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index ef25117..fedf726 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -137,7 +137,6 @@ notify_lvmetad() {
 }
 
 prepare_lvmpolld() {
-	set -x
 	rm -f debug.log
 	# skip if we don't have our own lvmpolld...
 	(which lvmpolld 2>/dev/null | grep "$abs_builddir") || skip


