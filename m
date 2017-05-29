From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 29 May 2017 08:55:23 -0400
Subject: master - tests: wait for raid in sync
Message-ID: <201705291255.v4TCtNeW002328@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=597b3576c7399d76ab4da5dccf505f2f2cc4fce2
Commit:        597b3576c7399d76ab4da5dccf505f2f2cc4fce2
Parent:        223c594f0e9e0248739a3bbb1c98fbf509140e6b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 25 15:06:57 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 29 14:41:53 2017 +0200

tests: wait for raid in sync

Lvchange needs synchronized raid.
---
 test/shell/lvchange-raid.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index 34a40dc..7418cd5 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -42,6 +42,7 @@ run_writemostly_check() {
 
 	printf "#\n#\n#\n# %s/%s (%s): run_writemostly_check\n#\n#\n#\n" \
 		$vg $lv $segtype
+	aux wait_for_sync $vg $lv
 
 	# No writemostly flag should be there yet.
 	check lv_attr_bit health $vg/${lv}_rimage_0 "-"


