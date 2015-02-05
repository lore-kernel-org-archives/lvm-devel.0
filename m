From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:40:58 +0000 (UTC)
Subject: master - test: Make runner use bigger IO buffers, put them on stack.
Message-ID: <20150205134058.39AF1602FC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bdd0bc83ebc3b753b45f2e7465a40c2b6b7bac27
Commit:        bdd0bc83ebc3b753b45f2e7465a40c2b6b7bac27
Parent:        7957fc4a4449d301d2c0743e2037eadd4bcc4f9d
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Jun 27 00:52:07 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:17 2015 +0100

test: Make runner use bigger IO buffers, put them on stack.

---
 test/lib/io.h |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/test/lib/io.h b/test/lib/io.h
index 8ade281..28e40d8 100644
--- a/test/lib/io.h
+++ b/test/lib/io.h
@@ -114,7 +114,6 @@ struct Observer : Sink {
 
 struct KMsg {
 	int fd;
-	char buf[ 4096 ];
 
 	bool dev_kmsg() {
 		return fd >= 0;
@@ -136,6 +135,8 @@ struct KMsg {
 	void read( Sink *s ) {
 		int sz;
 
+		char buf[ 128 * 1024 ];
+
 		if ( dev_kmsg() ) {
 			while ( (sz = ::read(fd, buf, sizeof(buf) - 1)) > 0 )
 				s->push( std::string( buf, sz ) );
@@ -144,8 +145,7 @@ struct KMsg {
 				read( s );
 			}
 		} else {
-			sz = klogctl( SYSLOG_ACTION_READ_CLEAR, buf, sizeof(buf) - 1 );
-			if ( sz > 0 )
+			while ( (sz = klogctl( SYSLOG_ACTION_READ_CLEAR, buf, sizeof(buf) - 1 )) > 0 )
 				s->push( std::string( buf, sz ) );
 		}
 	}
@@ -160,7 +160,6 @@ struct IO : Sink {
 
 	KMsg kmsg;
 	int fd;
-	char buf[ 4096 ];
 
 	virtual void push( std::string x ) {
 		for ( Sinks::iterator i = sinks.begin(); i != sinks.end(); ++i )
@@ -169,6 +168,8 @@ struct IO : Sink {
 
 	void sync() {
 		ssize_t sz;
+		char buf[ 128 * 1024 ];
+
 		while ( (sz = read(fd, buf, sizeof(buf) - 1)) > 0 )
 			push( std::string( buf, sz ) );
 


