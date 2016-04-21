From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 21 Apr 2016 15:48:50 +0000 (UTC)
Subject: master - tests: GLIBC decided to obsolete readdir_r
Message-ID: <20160421154850.56F4C60DC9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=11dd36245450ed664c4a6bd177f17a8077c820a1
Commit:        11dd36245450ed664c4a6bd177f17a8077c820a1
Parent:        1134ab63240de66850c30fe1576bbb8b4f3e7052
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 21 15:30:14 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 21 17:48:19 2016 +0200

tests: GLIBC decided to obsolete readdir_r

Keep the code compilatible without warnings on newer glibc.
---
 test/lib/brick-shelltest.h |   18 +++++++++++++-----
 1 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index be7c3fe..b48253b 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -122,11 +122,17 @@ inline Listing listdir( std::string p, bool recurse = false, std::string prefix
     Listing r;
 
     dir d( p );
+#if !defined(__GLIBC__) || (__GLIBC__ < 2) || ((__GLIBC__ == 2) && (__GLIBC_MINOR__ < 23))
+    /* readdir_r is deprecated with newer GLIBC */
     struct dirent entry, *iter = 0;
-    int readerr;
-
-    while ( (readerr = readdir_r( d.d, &entry, &iter )) == 0 && iter ) {
+    while ( (errno = readdir_r( d.d, &entry, &iter )) == 0 && iter ) {
         std::string ename( entry.d_name );
+#else
+    struct dirent *entry;
+    errno = 0;
+    while ( (entry = readdir( d.d )) ) {
+        std::string ename( entry->d_name );
+#endif
 
         if ( ename == "." || ename == ".." )
             continue;
@@ -134,8 +140,10 @@ inline Listing listdir( std::string p, bool recurse = false, std::string prefix
         if ( recurse ) {
             struct stat64 stat;
             std::string s = p + "/" + ename;
-            if ( ::stat64( s.c_str(), &stat ) == -1 )
+            if ( ::stat64( s.c_str(), &stat ) == -1 ) {
+                errno = 0;
                 continue;
+            }
             if ( S_ISDIR(stat.st_mode) ) {
                 Listing sl = listdir( s, true, prefix + ename + "/" );
                 for ( Listing::iterator i = sl.begin(); i != sl.end(); ++i )
@@ -146,7 +154,7 @@ inline Listing listdir( std::string p, bool recurse = false, std::string prefix
             r.push_back( ename );
     };
 
-    if ( readerr != 0 )
+    if ( errno != 0 )
         throw syserr( "error reading directory", p );
 
     return r;


