From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 23 Feb 2023 15:48:52 +0000 (GMT)
Subject: main - aux: lvmdbus checks for JSONDecodeError
Message-ID: <20230223154852.563963858C5E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c1cecc3dc5164856f27e08e5d031315785be2c9f
Commit:        c1cecc3dc5164856f27e08e5d031315785be2c9f
Parent:        d11e12264fcbca9af84a954fff773b720e471eb6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 23 16:25:10 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 23 16:46:35 2023 +0100

aux: lvmdbus checks for JSONDecodeError

Skip lvmdbus testing with too old python.
---
 test/lib/aux.sh | 1 +
 1 file changed, 1 insertion(+)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index c15fd5baa..9412a20af 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -315,6 +315,7 @@ prepare_lvmdbusd() {
 	which python3 >/dev/null || skip "Missing python3"
 
 	python3 -c "import pyudev, dbus, gi.repository" || skip "Missing python modules"
+	python3 -c "from json.decoder import JSONDecodeError" || skip "Python json module is missing JSONDecodeError"
 
 	# Copy the needed file to run on the system bus if it doesn't
 	# already exist

