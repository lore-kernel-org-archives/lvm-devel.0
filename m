From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:40:49 +0000 (UTC)
Subject: master - test: Clean up fds properly in the runner.
Message-ID: <20150205134049.D5627602BB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bf1693786905777d0ad0857797fe742889eebcd4
Commit:        bf1693786905777d0ad0857797fe742889eebcd4
Parent:        d2dbc65f00abe5ccf44af3545a1ec1ddd5ebdad7
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Jun 26 01:08:57 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:16 2015 +0100

test: Clean up fds properly in the runner.

---
 test/lib/runner.cpp |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/test/lib/runner.cpp b/test/lib/runner.cpp
index 0875b02..a0f9fbd 100644
--- a/test/lib/runner.cpp
+++ b/test/lib/runner.cpp
@@ -75,6 +75,7 @@ struct TestProcess
 			close( STDIN_FILENO );
 			dup2( fd, STDOUT_FILENO );
 			dup2( fd, STDERR_FILENO );
+			close( fd );
 		}
 
 		environment();
@@ -225,7 +226,7 @@ struct TestCase {
 		else
 			r = Journal::FAILED;
 
-		::close( io.fd );
+		io.close();
 
 		/*
 		if ((fd_debuglog = open(testdirdebug, O_RDONLY)) != -1) {
@@ -247,6 +248,7 @@ struct TestCase {
 			io.close();
 			child.exec();
 		} else {
+			::close( child.fd );
 			journal->started( name );
 			progress( First ) << tag( "running" ) << name << std::flush;
 			if ( options.verbose || options.interactive )


