From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  8 Oct 2012 10:17:11 +0000 (UTC)
Subject: master - test: check snap_percent returns invalid
Message-ID: <20121008101711.D9C7A169F@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=40182cbd82430a127bfeac5d93f98e642c94e06b
Commit:        40182cbd82430a127bfeac5d93f98e642c94e06b
Parent:        ff13206c7e6f8a4246afb562338aaba879d579ad
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 8 12:07:35 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 8 12:16:54 2012 +0200

test: check snap_percent returns invalid

For thin_volumes snap_percent is meaningless.
---
 test/api/thin_percent.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/test/api/thin_percent.c b/test/api/thin_percent.c
index 952346f..5338164 100644
--- a/test/api/thin_percent.c
+++ b/test/api/thin_percent.c
@@ -53,6 +53,10 @@ int main(int argc, char *argv[])
 	assert(v.is_valid);
 	assert(v.value.integer == 75 * PERCENT_1);
 
+	v = lvm_lv_get_property(lv, "snap_percent");
+	assert(v.is_valid);
+	assert(v.value.integer == PERCENT_INVALID);
+
 	lvm_vg_close(vg);
 	lvm_quit(handle);
 


