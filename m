From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:41:02 +0000 (UTC)
Subject: master - test: Add a buffer-backed IO sink (for interactive runs).
Message-ID: <20150205134102.61D9E602FC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=df27c6404197dd07f1a8a260736111bf5615cf26
Commit:        df27c6404197dd07f1a8a260736111bf5615cf26
Parent:        f53fcc0746184d2d221a3c37e71769b4accabf19
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Jun 27 00:54:36 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:17 2015 +0100

test: Add a buffer-backed IO sink (for interactive runs).

---
 test/lib/io.h |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/test/lib/io.h b/test/lib/io.h
index c96382c..7f71208 100644
--- a/test/lib/io.h
+++ b/test/lib/io.h
@@ -55,6 +55,23 @@ struct Sink {
 	virtual void sync() {}
 };
 
+struct BufSink : Sink {
+	std::vector< char > data;
+	virtual void push( std::string x ) {
+		std::copy( x.begin(), x.end(), std::back_inserter( data ) );
+	}
+
+	void dump( std::ostream &o ) {
+		std::vector< char >::iterator b = data.begin(), e = data.begin();
+		o << std::endl;
+		while ( e != data.end() ) {
+			e = std::find( b, data.end(), '\n' );
+			o << "| " << std::string( b, e ) << std::endl;
+			b = (e == data.end() ? e : e + 1);
+		}
+	}
+};
+
 struct FdSink : Sink {
 	int fd;
 


