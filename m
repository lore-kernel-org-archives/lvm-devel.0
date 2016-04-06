From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  6 Apr 2016 21:37:14 +0000 (UTC)
Subject: master - lvmdump: Allow dir to exist already if it is empty
Message-ID: <20160406213714.D1B2E60AA2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=55001ae9ec2c00a070f8dfa8541f4f17a6e2a284
Commit:        55001ae9ec2c00a070f8dfa8541f4f17a6e2a284
Parent:        307ab2c179073d28d1c9ec9f995f2849aeab07c6
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Apr 6 22:36:42 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Apr 6 22:36:42 2016 +0100

lvmdump: Allow dir to exist already if it is empty

---
 WHATS_NEW          |    1 +
 scripts/lvmdump.sh |    8 ++++++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 98168a1..b1da1b0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.150 -
 =================================
+  Allow the lvmdump directory to exist already provided it is empty.
 
 Version 2.02.149 - 1st April 2016
 =================================
diff --git a/scripts/lvmdump.sh b/scripts/lvmdump.sh
index 1e91a9d..19b36d3 100755
--- a/scripts/lvmdump.sh
+++ b/scripts/lvmdump.sh
@@ -99,8 +99,12 @@ else
 	dir="$HOME/$dirbase"
 fi
 
-test -e $dir && die 3 "Fatal: $dir already exists"
-$MKDIR -p $dir || die 4 "Fatal: could not create $dir"
+if test -d $dir ; then
+	(shopt -s nullglob dotglob; cd $dir && files=(*) && ((${#files[@]}))) && die 5 "Fatal: directory $dir already exists and is not empty"
+else
+	test -e $dir && die 3 "Fatal: $dir already exists"
+	$MKDIR -p $dir || die 4 "Fatal: could not create $dir"
+fi
 
 log="$dir/lvmdump.log"
 


