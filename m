From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:41:04 +0000 (UTC)
Subject: master - test: Fix IO sink destructors in the runner.
Message-ID: <20150205134104.76B87602FC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9752ee8ed2322b9f35f16e259c87b525796d4b2d
Commit:        9752ee8ed2322b9f35f16e259c87b525796d4b2d
Parent:        df27c6404197dd07f1a8a260736111bf5615cf26
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Jun 27 00:54:56 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:17 2015 +0100

test: Fix IO sink destructors in the runner.

---
 test/lib/io.h |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/test/lib/io.h b/test/lib/io.h
index 7f71208..c93b401 100644
--- a/test/lib/io.h
+++ b/test/lib/io.h
@@ -53,6 +53,7 @@ struct Sink {
 	virtual void outline( bool ) {}
 	virtual void push( std::string x ) = 0;
 	virtual void sync() {}
+	virtual ~Sink() {}
 };
 
 struct BufSink : Sink {
@@ -241,11 +242,14 @@ struct IO : Sink {
 		return *this;
 	}
 
-	~IO() {
+	void clear() {
 		for ( Sinks::iterator i = sinks.begin(); i != sinks.end(); ++i )
 			delete *i;
+		sinks.clear();
 	}
 
+	~IO() { clear(); }
+
 };
 
 #endif


