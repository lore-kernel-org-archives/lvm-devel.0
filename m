From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 10 Sep 2015 15:30:04 +0000 (UTC)
Subject: master - tests: fix check lv_not_exist
Message-ID: <20150910153004.3AB0C60F0B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e94ab01940828f471a9498f112d2023c3bf06ffd
Commit:        e94ab01940828f471a9498f112d2023c3bf06ffd
Parent:        54c982081fa6617c511e2a7d61dbe3b4e9c7d315
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 10 17:19:30 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 10 17:28:47 2015 +0200

tests: fix check lv_not_exist

Use 'not' to set proper 'expected return status'
so we do not 'leak' debug logs printed for failing case.
---
 test/lib/check.sh |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index 9d48851..b47bc8b 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -268,8 +268,7 @@ lv_not_exists() {
 	else
 		while [ $# -gt 1 ]; do
 			shift
-			lvl $vg/$1 &>/dev/null || continue
-			die "$vg/$1 expected to not exist but it does!"
+			not lvl $vg/$1 &>/dev/null || die "$vg/$1 expected to not exist but it does!"
 		done
 	fi
 	rm -f debug.log


