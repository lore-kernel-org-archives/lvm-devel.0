From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:41:12 +0000 (UTC)
Subject: master - test: Fix handling of envvars in the runner.
Message-ID: <20150205134112.CDFF160794@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f3bf89ebcc98a1e03c1687d6b292be3274a9bc8a
Commit:        f3bf89ebcc98a1e03c1687d6b292be3274a9bc8a
Parent:        0bd2a9b7b10640d9d16cceb9e753acff6356d5df
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Jun 27 01:03:08 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:17 2015 +0100

test: Fix handling of envvars in the runner.

---
 test/lib/runner.cpp |   15 ++++++++++++---
 1 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/test/lib/runner.cpp b/test/lib/runner.cpp
index 287b8f9..14c7d9f 100644
--- a/test/lib/runner.cpp
+++ b/test/lib/runner.cpp
@@ -391,6 +391,15 @@ struct Args {
 	}
 };
 
+bool hasenv( const char *name ) {
+	const char *v = getenv( name );
+	if ( !v )
+		return false;
+	if ( strlen( v ) == 0 || !strcmp( v, "0" ) )
+		return false;
+	return true;
+}
+
 int main(int argc, char **argv)
 {
 	Args args( argc, argv );
@@ -399,17 +408,17 @@ int main(int argc, char **argv)
 	if ( args.has( "--continue" ) )
 		opt.cont = true;
 
-	if ( args.has( "--quiet" ) || getenv( "QUIET" ) ) {
+	if ( args.has( "--quiet" ) || hasenv( "QUIET" ) ) {
 		opt.verbose = false;
 		opt.quiet = true;
 	}
 
-	if ( args.has( "--verbose" ) || getenv( "VERBOSE" ) ) {
+	if ( args.has( "--verbose" ) || hasenv( "VERBOSE" ) ) {
 		opt.quiet = false;
 		opt.verbose = true;
 	}
 
-	if ( args.has( "--interactive" ) || getenv( "INTERACTIVE" ) ) {
+	if ( args.has( "--interactive" ) || hasenv( "INTERACTIVE" ) ) {
 		opt.verbose = false;
 		opt.quiet = false;
 		opt.interactive = true;


