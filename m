From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 27 Mar 2014 12:15:25 +0000 (UTC)
Subject: master - tests: cover more commands
Message-ID: <20140327121525.EFCF060D90@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=04a6918518d9c74b761a5ca74e8f67cf2b170d71
Commit:        04a6918518d9c74b761a5ca74e8f67cf2b170d71
Parent:        fc8185601d09d7a9725f3519f9acf5f43e40f844
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 27 11:22:23 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 27 13:13:09 2014 +0100

tests: cover more commands

Visit more code lines.
---
 test/shell/covercmd.sh |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/test/shell/covercmd.sh b/test/shell/covercmd.sh
index 06a9082..e5773ad 100644
--- a/test/shell/covercmd.sh
+++ b/test/shell/covercmd.sh
@@ -123,6 +123,10 @@ pvresize "$dev1"
 
 # test various errors and obsoleted tools
 not lvmchange
+not lvmsadc
+not lvmsar
+not pvdata
+
 not lvrename $vg
 not lvrename $vg-xxx
 not lvrename $vg  $vg/$lv-rename $vg/$lv


