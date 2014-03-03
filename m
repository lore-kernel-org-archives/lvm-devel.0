From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Mon,  3 Mar 2014 07:34:05 +0000 (UTC)
Subject: master - test: Remove incorrect evaluation
Message-ID: <20140303073405.A416660F88@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=445c0a5585e196e29cfaef1447e3729ae925751f
Commit:        445c0a5585e196e29cfaef1447e3729ae925751f
Parent:        6df716332c25a49ca41f9d68e10afca68dc5dd62
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Mar 3 08:31:33 2014 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Mar 3 08:31:33 2014 +0100

test: Remove incorrect evaluation

---
 test/shell/lvchange-raid.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index b6107b9..84c47f2 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -252,7 +252,7 @@ run_recovery_rate_check() {
 	local vg=$1
 	local lv=${2}${THIN_POSTFIX}
 
-	printf "#\n#\n#\n# %s/%s $(%s): run_recovery_rate_check\n#\n#\n#\n" \
+	printf "#\n#\n#\n# %s/%s %s: run_recovery_rate_check\n#\n#\n#\n" \
 		 $vg $lv $(get lv_field $vg/$lv segtype -a)
 	lvchange --minrecoveryrate 50 $vg/$lv
 	lvchange --maxrecoveryrate 100 $vg/$lv


