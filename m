From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Sun, 15 Oct 2023 12:55:00 +0000
Subject: [Git][lvmteam/lvm2][main] 2 commits: tests: shorting batch line output
Message-ID: <652be12442fa4_2ca5348490a5@gitlab-sidekiq-low-urgency-cpu-bound-v2-59d68cd46b-xgtwc.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
63885da5 by Zdenek Kabelac at 2023-10-15T14:42:14+02:00
tests: shorting batch line output

- - - - -
d5e58768 by Zdenek Kabelac at 2023-10-15T14:43:13+02:00
tests: check for blkid

When libblkid is not present (older systems) we can&#39;t use new -fs tests at
all so skip these tests.

- - - - -


2 changed files:

- test/lib/brick-shelltest.h
- test/shell/lvresize-fs.sh


Changes:

=====================================
test/lib/brick-shelltest.h
=====================================
@@ -999,7 +999,7 @@ struct TestCase {
             outb = (usage.ru_oublock + 1024) / 2048; // to MiB
 
         ss << wall << " wall " << user << " user " << system << " sys "
-            << std::setw( 4 ) << std::setfill( ' ' ) << rss << " M RSS | IOPS: "
+            << std::setw( 4 ) << std::setfill( ' ' ) << rss << " M mem "
             << std::setw( 5 ) << inb << " M in "
             << std::setw( 5 ) << outb << " M out";
 
@@ -1086,10 +1086,15 @@ struct TestCase {
         journal->done( id(), r, ru );
 
         if ( options.batch ) {
-            int spaces = std::max( int(journal->name_size_max()) - int(pretty().length()), 0 );
-
-            progress( Last ) << " " << std::string( spaces, '.' ) << " "
-                << std::left << std::setw( 9 ) << std::setfill( ' ' ) << r;
+            int spaces = std::max( 4 + int(journal->name_size_max()) - int(pretty().length()), 0 );
+            std::string sp;
+            sp.reserve( spaces );
+            if ( spaces % 2 )
+                sp += " ";
+            for ( int i = 0; i < spaces / 2; ++i )
+                sp += " .";
+            progress( Last ) << sp << " "
+                << std::left << std::setw( 8 ) << std::setfill( ' ' ) << r;
             if ( r != Journal::SKIPPED )
                 progress( First ) << "   " << ru;
             progress( Last ) << std::endl;
@@ -1203,9 +1208,9 @@ struct Main {
                         continue;
                 }
 
-                journal.check_name_size( options.testdir + *i );
                 cases.push_back( TestCase( journal, options, options.testdir + *i, *i, *flav ) );
                 cases.back().options = options;
+                journal.check_name_size( cases.back().id() );
             }
         }
 


=====================================
test/shell/lvresize-fs.sh
=====================================
@@ -15,11 +15,11 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-aux prepare_vg 2 100
-
 which mkfs.ext4 || skip
 which resize2fs || skip
 
+aux prepare_vg 2 100
+
 #
 # Blkid is not able to detected 'running' filesystem after resize
 # freeeing and unfreezing stores fs metadata on disk
@@ -81,6 +81,9 @@ check lv_field $vg/$lv lv_size "60.00m"
 
 lvremove -f $vg
 
+# Without blkid being linked - no more tests
+test "1" = "$(lvm lvmconfig --typeconfig default --valuesonly allocation/use_blkid_wiping)" || exit 0
+
 
 ###################
 #



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/5cc54458b71eaf9878f9b78b3bd3d99cd3e19251...d5e58768aaa6312124d344e3c44ada9eacf94811

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/5cc54458b71eaf9878f9b78b3bd3d99cd3e19251...d5e58768aaa6312124d344e3c44ada9eacf94811
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20231015/9118f84f/attachment-0001.htm>
