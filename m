From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Apr 2013 15:06:05 +0000 (UTC)
Subject: master - test: correct order
Message-ID: <20130423150605.EFF39167F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=320d7f3596f78972d5fa843b9d56510ff299a958
Commit:        320d7f3596f78972d5fa843b9d56510ff299a958
Parent:        23775c8fe8cdd82dee33cd397eeab5a84181380b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 23 17:05:19 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 23 17:05:19 2013 +0200

test: correct order

Call notify after resume (like in enable_dev()).
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index d500b37..4339ef4 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -413,8 +413,8 @@ error_dev() {
 		dmsetup create -u "TEST-$name" "$name" "$name.errtable"
 	fi
 	# using device name (since device path does not exists yet with udev)
-	notify_lvmetad "$dev"
 	dmsetup resume "$name"
+	notify_lvmetad "$dev"
 	finish_udev_transaction
 }
 


