From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 12 Feb 2015 14:42:13 +0000 (UTC)
Subject: master - tests: don't crash if checked string is shorter
Message-ID: <20150212144213.DC0376010E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=739b751046c17ba8e6225821446951e6742c16eb
Commit:        739b751046c17ba8e6225821446951e6742c16eb
Parent:        b1002e98e020e0a9e35bcf75eac5a991550fc0b2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 12 10:39:37 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 12 15:38:51 2015 +0100

tests: don't crash if checked string is shorter

Not really sure what is this testing - just avoid coredump if
the test cannot happen since the index would too high.
---
 test/lib/brick-shelltest.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index 335ef85..d67b164 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -958,7 +958,7 @@ struct Main {
               flav != options.flavours.end(); ++flav ) {
 
             for ( Listing::iterator i = l.begin(); i != l.end(); ++i ) {
-                if ( i->substr( i->length() - 3, i->length() ) != ".sh" )
+                if ( ( i->length() < 3 ) || ( i->substr( i->length() - 3, i->length() ) != ".sh" ) )
                     continue;
                 if ( i->substr( 0, 4 ) == "lib/" )
                     continue;


