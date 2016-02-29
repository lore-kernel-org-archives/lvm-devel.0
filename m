From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 29 Feb 2016 18:44:13 +0000 (UTC)
Subject: master - tests: check [unknown] in lvmetad-pvscan-cache
Message-ID: <20160229184413.6589E613D5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e3b904fd08712cf71a2248f72dd2be5b42039282
Commit:        e3b904fd08712cf71a2248f72dd2be5b42039282
Parent:        250b915364735a7a9a5e476b542041eb93f5017f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 29 12:43:07 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 29 12:43:07 2016 -0600

tests: check [unknown] in lvmetad-pvscan-cache

Update test for new [unknown] VG name from
commit 250b9153.
---
 test/shell/lvmetad-pvscan-cache.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvmetad-pvscan-cache.sh b/test/shell/lvmetad-pvscan-cache.sh
index 22c9b5e..501eec5 100644
--- a/test/shell/lvmetad-pvscan-cache.sh
+++ b/test/shell/lvmetad-pvscan-cache.sh
@@ -32,7 +32,7 @@ vgs | grep $vg1
 pvchange --metadataignore y "$dev1"
 aux disable_dev "$dev2"
 pvscan --cache
-check pv_field "$dev1" vg_name ""
+check pv_field "$dev1" vg_name "[unknown]"
 aux enable_dev "$dev2"
 pvscan --cache
 check pv_field "$dev1" vg_name "$vg1"


