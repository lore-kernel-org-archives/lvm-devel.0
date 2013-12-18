From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 18 Dec 2013 09:57:06 +0000 (UTC)
Subject: master - tests: clear inactive table before resuming in teardown
Message-ID: <20131218095706.CA0DA60D38@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=434d95cef31c4d95b6468e02397e1fedbdca9928
Commit:        434d95cef31c4d95b6468e02397e1fedbdca9928
Parent:        3776832499862ce6896b598487e79b02e7432326
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Dec 18 10:40:36 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Dec 18 10:40:36 2013 +0100

tests: clear inactive table before resuming in teardown

---
 test/lib/aux.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 92385c8..ac6e111 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -98,6 +98,7 @@ teardown_devs_prefixed() {
 	# Resume suspended devices first
 	for dm in $(dm_info suspended,name | grep "^Suspended:.*$prefix"); do
 		echo "dmsetup resume \"${dm#Suspended:}\""
+		dmsetup clear "${dm#Suspended:}"
 		dmsetup resume "${dm#Suspended:}" &
 	done
 


