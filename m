From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:41:46 +0000 (UTC)
Subject: master - test: Fix loading of an append-mode journal.
Message-ID: <20150205134146.745F460F11@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a8eb70209322f4344b9b11d190f64a9184fe23eb
Commit:        a8eb70209322f4344b9b11d190f64a9184fe23eb
Parent:        d74c1472233e29b9168966334315dc012ee915ce
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Jun 30 00:38:07 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:18 2015 +0100

test: Fix loading of an append-mode journal.

---
 test/lib/journal.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/lib/journal.h b/test/lib/journal.h
index 458d1ee..8913d7c 100644
--- a/test/lib/journal.h
+++ b/test/lib/journal.h
@@ -157,7 +157,8 @@ struct Journal {
 	void read( std::string n ) {
 		std::ifstream ifs( n.c_str() );
 		typedef std::istream_iterator< std::pair< std::string, R > > It;
-		std::copy( It( ifs ), It(), std::inserter( status, status.begin() ) );
+		for ( It i( ifs ); i != It(); ++i )
+			status[ i->first ] = i->second;
 	}
 
 	void read() { read( location ); }


