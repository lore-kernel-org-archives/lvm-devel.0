From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 23:19:38 +0000 (GMT)
Subject: main - tests: settle after wiping
Message-ID: <20210310231938.865583858001@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4bbaff1fa621353d0d2adbbf86dd26284b8a11e3
Commit:        4bbaff1fa621353d0d2adbbf86dd26284b8a11e3
Parent:        2cbe88d6a1e9e6f637ee1b5ccdc7b78712d46998
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 10 23:36:03 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 11 00:18:01 2021 +0100

tests: settle after wiping

Add call to settle after wiping device so there is reduced
change to meet watch rule race during tests.
---
 test/lib/aux.sh | 1 +
 1 file changed, 1 insertion(+)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 0e10a06dd..2e6191d70 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -837,6 +837,7 @@ wipefs_a() {
 		lvmdevices --adddev $dev || true
 	fi
 
+	udev_wait
 }
 
 prepare_backing_dev() {


