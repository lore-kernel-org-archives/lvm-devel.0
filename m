From: Petr Rockai <prockai@redhat.com>
Date: Sun,  3 May 2009 13:39:01 +0200
Subject: [PATCH 9/9] All tools now handle inconsistent metadata the same way.
In-Reply-To: <1241350741-31349-9-git-send-email-prockai@redhat.com>
References: <1241350741-31349-1-git-send-email-prockai@redhat.com>
	<1241350741-31349-2-git-send-email-prockai@redhat.com>
	<1241350741-31349-3-git-send-email-prockai@redhat.com>
	<1241350741-31349-4-git-send-email-prockai@redhat.com>
	<1241350741-31349-5-git-send-email-prockai@redhat.com>
	<1241350741-31349-6-git-send-email-prockai@redhat.com>
	<1241350741-31349-7-git-send-email-prockai@redhat.com>
	<1241350741-31349-8-git-send-email-prockai@redhat.com>
	<1241350741-31349-9-git-send-email-prockai@redhat.com>
Message-ID: <1241350741-31349-10-git-send-email-prockai@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Sun May  3 13:25:10 CEST 2009  Petr Rockai <me@mornfall.net>
  * All tools now handle inconsistent metadata the same way.
diff -rN -u -p old-temp.31080/test/t-inconsistent-metadata.sh new-temp.31080/test/t-inconsistent-metadata.sh
--- old-temp.31080/test/t-inconsistent-metadata.sh	2009-05-03 13:29:41.594232457 +0200
+++ new-temp.31080/test/t-inconsistent-metadata.sh	2009-05-03 13:29:41.682234353 +0200
@@ -40,23 +40,26 @@ vgscan 2>&1 | tee cmd.out
 not grep "Inconsistent metadata found for VG $vg" cmd.out
 check
 
-# vgdisplay doesn't change anything
+# vgdisplay fixes up metadata
 init
 vgdisplay 2>&1 | tee cmd.out
-grep "Volume group \"$vg\" inconsistent" cmd.out
+grep "Inconsistent metadata found for VG $vg" cmd.out
 vgdisplay 2>&1 | tee cmd.out
-grep "Volume group \"$vg\" inconsistent" cmd.out
+not grep "Inconsistent metadata found for VG $vg" cmd.out
+check
 
 # lvs fixes up
 init
 lvs 2>&1 | tee cmd.out
-grep "Inconsistent metadata found for VG $vg - updating" cmd.out
+grep "Inconsistent metadata found for VG $vg" cmd.out
 vgdisplay 2>&1 | tee cmd.out
-not grep "Volume group \"$vg\" inconsistent" cmd.out
+not grep "Inconsistent metadata found for VG $vg" cmd.out
 check
 
-# vgs doesn't fix up... (why?)
+# vgs fixes up as well
 init
 vgs 2>&1 | tee cmd.out
-vgdisplay 2>&1 | tee cmd.out
-grep "Volume group \"$vg\" inconsistent" cmd.out
+grep "Inconsistent metadata found for VG $vg" cmd.out
+vgs 2>&1 | tee cmd.out
+not grep "Inconsistent metadata found for VG $vg" cmd.out
+check


