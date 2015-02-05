From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:42:24 +0000 (UTC)
Subject: master - test: Update brick-shelltest, adding timestamps to logs.
Message-ID: <20150205134224.247F26036E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=19bb62e2ece4d2455bd2a06cb02dda59856382ee
Commit:        19bb62e2ece4d2455bd2a06cb02dda59856382ee
Parent:        f9dfc5f8a4e50bf78e6c9d01266482ddbd33dda8
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Jul 6 16:22:23 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:20 2015 +0100

test: Update brick-shelltest, adding timestamps to logs.

---
 test/lib/brick-shelltest.h |  137 +++++++++++++++++++++++++++++++-------------
 1 files changed, 96 insertions(+), 41 deletions(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index 236ede8..ea3aa45 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -287,6 +287,51 @@ struct Journal {
     {}
 };
 
+struct TimedBuffer {
+    typedef std::pair< time_t, std::string > Line;
+
+    std::deque< Line > data;
+    Line incomplete;
+
+    Line shift( bool force = false ) {
+        Line result = std::make_pair( 0, "" );
+        if ( force && data.empty() )
+            std::swap( result, incomplete );
+        else {
+            result = data.front();
+            data.pop_front();
+        }
+        return result;
+    }
+
+    void push( std::string buf ) {
+        time_t now = time( 0 );
+        std::string::iterator b = buf.begin(), e = buf.begin();
+
+        while ( e != buf.end() )
+        {
+            e = std::find( b, buf.end(), '\n' );
+            incomplete.second += std::string( b, e );
+
+            if ( !incomplete.first )
+                incomplete.first = now;
+
+            if ( e != buf.end() ) {
+                incomplete.second += "\n";
+                data.push_back( incomplete );
+                incomplete = std::make_pair( now, "" );
+            }
+            b = (e == buf.end() ? e : e + 1);
+        }
+    }
+
+    bool empty( bool force = false ) {
+        if ( force && !incomplete.second.empty() )
+            return false;
+        return data.empty();
+    }
+};
+
 struct Sink {
     virtual void outline( bool ) {}
     virtual void push( std::string x ) = 0;
@@ -294,72 +339,82 @@ struct Sink {
     virtual ~Sink() {}
 };
 
+struct Substitute {
+    typedef std::map< std::string, std::string > Map;
+    Map _map;
+
+    std::string map( std::string line ) {
+        if ( std::string( line, 0, 9 ) == "@TESTDIR=" )
+            _map[ "@TESTDIR@" ] = std::string( line, 9, std::string::npos );
+        else if ( std::string( line, 0, 8 ) == "@PREFIX=" )
+            _map[ "@PREFIX@" ] = std::string( line, 8, std::string::npos );
+        else {
+            int off;
+            for ( Map::iterator s = _map.begin(); s != _map.end(); ++s )
+                while ( (off = line.find( s->first )) != std::string::npos )
+                    line.replace( off, s->first.length(), s->second );
+        }
+        return line;
+    }
+};
+
+struct Format {
+    time_t start;
+    bool stamp;
+    Substitute subst;
+
+    std::string format( TimedBuffer::Line l ) {
+        std::stringstream result;
+        if ( stamp ) {
+            int rel = l.first - start;
+            result << "[" << std::setw( 2 ) << std::setfill( ' ' ) << rel / 60
+                   << ":" << std::setw( 2 ) << std::setfill( '0' ) << rel % 60 << "] ";
+        }
+        result << subst.map( l.second );
+        return result.str();
+    }
+
+    Format() : start( time( 0 ) ), stamp( true ) {}
+};
+
 struct BufSink : Sink {
-    std::vector< char > data;
+    TimedBuffer data;
+    Format fmt;
+
     virtual void push( std::string x ) {
-        std::copy( x.begin(), x.end(), std::back_inserter( data ) );
+        data.push( x );
     }
 
     void dump( std::ostream &o ) {
-        std::vector< char >::iterator b = data.begin(), e = data.begin();
-        o << std::endl;
-        while ( e != data.end() ) {
-            e = std::find( b, data.end(), '\n' );
-            o << "| " << std::string( b, e ) << std::endl;
-            b = (e == data.end() ? e : e + 1);
-        }
+        while ( !data.empty( true ) )
+            o << "| " << fmt.format( data.shift( true ) ) << std::endl;
     }
 };
 
 struct FdSink : Sink {
     int fd;
 
-    typedef std::deque< char > Stream;
-    typedef std::map< std::string, std::string > Subst;
-
-    Stream stream;
-    Subst subst;
+    TimedBuffer stream;
+    Format fmt;
     bool killed;
 
     virtual void outline( bool force )
     {
-        Stream::iterator nl = std::find( stream.begin(), stream.end(), '\n' );
-        if ( nl == stream.end() ) {
-            if ( !force )
-                return;
-        } else
-            force = false;
-
-        assert( nl != stream.end() || force );
-
-        std::string line( stream.begin(), nl );
-        stream.erase( stream.begin(), force ? nl : nl + 1 );
-
-        if ( std::string( line, 0, 9 ) == "@TESTDIR=" )
-            subst[ "@TESTDIR@" ] = std::string( line, 9, std::string::npos );
-        else if ( std::string( line, 0, 8 ) == "@PREFIX=" )
-            subst[ "@PREFIX@" ] = std::string( line, 8, std::string::npos );
-        else {
-            int off;
-            for ( Subst::iterator s = subst.begin(); s != subst.end(); ++s )
-                while ( (off = line.find( s->first )) != std::string::npos )
-                    line.replace( off, s->first.length(), s->second );
-            write( fd, line.c_str(), line.length() );
-            if ( !force )
-                write( fd, "\n", 1 );
-        }
+        TimedBuffer::Line line = stream.shift( force );
+        std::string out = fmt.format( line );
+        write( fd, out.c_str(), out.length() );
     }
 
     virtual void sync() {
         if ( killed )
             return;
-        while ( !stream.empty() )
+        while ( !stream.empty( true ) )
             outline( true );
     }
 
     virtual void push( std::string x ) {
         if ( !killed )
-            std::copy( x.begin(), x.end(), std::back_inserter( stream ) );
+            stream.push( x );
     }
 
     FdSink( int _fd ) : fd( _fd ), killed( false ) {}


