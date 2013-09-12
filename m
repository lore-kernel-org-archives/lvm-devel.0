From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Thu, 12 Sep 2013 18:28:04 +0000 (UTC)
Subject: master - TEST: Unaccounted possible output causing failure
Message-ID: <20130912182804.34CC761457@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1d068682404c7af35c0b40586a6e5479443fc851
Commit:        1d068682404c7af35c0b40586a6e5479443fc851
Parent:        e2268aeb92779580d3da4c5c400a1c353f955571
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Thu Sep 12 13:23:53 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Thu Sep 12 13:23:53 2013 -0500

TEST: Unaccounted possible output causing failure

lvchange-raid.sh checks to ensure that the 'p'artial flag takes
precedence over the 'w'ritemostly flag by disabling and reenabling
a device in the array.  Most of the time this works fine, but
sometimes the kernel can notice the device failure before it is
reenabled.  In that case, the attr flag will not return to 'w', but
to 'r'efresh.  This is because 'r'efresh also takes precedence over
the 'w'ritemostly flag.  So, we also do a quick check for 'r' and
not just 'w'.
---
 test/shell/lvchange-raid.sh |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index f1b8d72..91c8e8d 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -105,7 +105,15 @@ run_writemostly_check() {
 	# Partial flag supercedes writemostly flag
 	aux disable_dev $d0
 	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*p.$'
+
+	# It is possible for the kernel to detect the failed device before
+	# we re-enable it.  If so, the field will be set to 'r'efresh since
+	# that also takes precedence over 'w'ritemostly.  If this has happened,
+	# we refresh the LV and then check for 'w'.
 	aux enable_dev $d0
+	if lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*r.$'; then
+		lvchange --refresh $vg/$lv
+	fi
 	lvs -a --noheadings -o lv_attr $vg/${lv}_rimage_0 | grep '.*w.$'
 
 	# Catch Bad writebehind values


