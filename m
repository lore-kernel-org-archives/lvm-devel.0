From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:41:00 +0000 (UTC)
Subject: master - test: Implement a file-backed IO sink in the runner.
Message-ID: <20150205134100.4FC26602FC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f53fcc0746184d2d221a3c37e71769b4accabf19
Commit:        f53fcc0746184d2d221a3c37e71769b4accabf19
Parent:        bdd0bc83ebc3b753b45f2e7465a40c2b6b7bac27
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Jun 27 00:53:36 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:17 2015 +0100

test: Implement a file-backed IO sink in the runner.

---
 test/lib/io.h |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/test/lib/io.h b/test/lib/io.h
index 28e40d8..c96382c 100644
--- a/test/lib/io.h
+++ b/test/lib/io.h
@@ -95,6 +95,8 @@ struct FdSink : Sink {
 	}
 
 	virtual void sync() {
+		if ( killed )
+			return;
 		while ( !stream.empty() )
 			outline( true );
 	}
@@ -107,6 +109,26 @@ struct FdSink : Sink {
 	FdSink( int _fd ) : fd( _fd ), killed( false ) {}
 };
 
+struct FileSink : FdSink {
+	std::string file;
+	FileSink( std::string n ) : FdSink( -1 ), file( n ) {}
+
+	void sync() {
+		if ( fd < 0 && !killed ) {
+			fd = open( file.c_str(), O_WRONLY | O_CREAT | O_TRUNC | O_CLOEXEC, 0644 );
+			if ( fd < 0 )
+				killed = true;
+		}
+		FdSink::sync();
+	}
+	~FileSink() {
+		if ( fd >= 0 ) {
+			fsync( fd );
+			close( fd );
+		}
+	}
+};
+
 struct Observer : Sink {
 	Observer() {}
 	void push( std::string ) {}


