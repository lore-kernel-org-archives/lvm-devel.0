From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:42:35 +0000 (UTC)
Subject: master - test: Update brick-shelltest.h.
Message-ID: <20150205134235.0E931601D3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7ed8fc8f7d007ac8c2ad77e4c6799056490329bc
Commit:        7ed8fc8f7d007ac8c2ad77e4c6799056490329bc
Parent:        f9df76f8b3f322f0fcefcc6861796476af1bbb18
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Jul 22 18:44:32 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:20 2015 +0100

test: Update brick-shelltest.h.

---
 test/lib/brick-shelltest.h |  161 +++++++++++++++++++++++++++++++-------------
 1 files changed, 114 insertions(+), 47 deletions(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index ea3aa45..9b0afe0 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -386,8 +386,9 @@ struct BufSink : Sink {
     }
 
     void dump( std::ostream &o ) {
+        o << std::endl;
         while ( !data.empty( true ) )
-            o << "| " << fmt.format( data.shift( true ) ) << std::endl;
+            o << "| " << fmt.format( data.shift( true ) );
     }
 };
 
@@ -432,6 +433,7 @@ struct FileSink : FdSink {
         }
         FdSink::sync();
     }
+
     ~FileSink() {
         if ( fd >= 0 ) {
             fsync( fd );
@@ -440,12 +442,60 @@ struct FileSink : FdSink {
     }
 };
 
+#define BRICK_SYSLOG_ACTION_READ           2
 #define BRICK_SYSLOG_ACTION_READ_CLEAR     4
 #define BRICK_SYSLOG_ACTION_CLEAR          5
 
-struct KMsg {
+struct Source {
     int fd;
 
+    virtual void sync( Sink *sink ) {
+        ssize_t sz;
+        char buf[ 128 * 1024 ];
+        while ( (sz = read(fd, buf, sizeof(buf) - 1)) > 0 )
+            sink->push( std::string( buf, sz ) );
+        if ( sz < 0 && errno != EAGAIN )
+            throw syserr( "reading pipe" );
+    }
+
+    virtual void reset() {}
+
+    virtual int fd_set( fd_set *set ) {
+        if ( fd >= 0 ) {
+            FD_SET( fd, set );
+            return fd;
+        } else
+            return -1;
+    }
+
+    Source( int fd = -1 ) : fd( fd ) {}
+    virtual ~Source() {
+        if ( fd >= 0 )
+            ::close( fd );
+    }
+};
+
+struct FileSource : Source {
+    std::string file;
+    FileSource( std::string n ) : Source( -1 ), file( n ) {}
+
+    int fd_set( ::fd_set * ) { return -1; } /* reading a file is always non-blocking */
+    void sync( Sink *s ) {
+        if ( fd < 0 ) {
+            fd = open( file.c_str(), O_RDONLY | O_CLOEXEC | O_NONBLOCK );
+            if ( fd >= 0 )
+                lseek( fd, 0, SEEK_END );
+        }
+        if ( fd >= 0 )
+            Source::sync( s );
+    }
+};
+
+struct KMsg : Source {
+    bool can_clear;
+
+    KMsg() : can_clear( true ) {}
+
     bool dev_kmsg() {
         return fd >= 0;
     }
@@ -461,14 +511,14 @@ struct KMsg {
             } else if (lseek(fd, 0L, SEEK_END) == (off_t) -1)
                 perror("lseek /dev/kmsg");
         } else
-            klogctl( BRICK_SYSLOG_ACTION_CLEAR, 0, 0 );
+            if ( klogctl( BRICK_SYSLOG_ACTION_CLEAR, 0, 0 ) < 0 )
+                can_clear = false;
 #endif
     }
 
-    void read( Sink *s ) {
+    void sync( Sink *s ) {
 #ifdef __unix
         int sz;
-
         char buf[ 128 * 1024 ];
 
         if ( dev_kmsg() ) {
@@ -476,16 +526,17 @@ struct KMsg {
                 s->push( std::string( buf, sz ) );
             if ( sz < 0 ) {
                 fd = -1;
-                read( s );
+                sync( s );
             }
-        } else {
-            while ( (sz = klogctl( BRICK_SYSLOG_ACTION_READ_CLEAR, buf, sizeof(buf) - 1 )) > 0 )
+        } else if ( can_clear ) {
+            while ( (sz = klogctl( BRICK_SYSLOG_ACTION_READ_CLEAR, buf,
+                                   sizeof(buf) - 1 )) > 0 )
                 s->push( std::string( buf, sz ) );
+            if ( sz < 0 && errno == EPERM )
+                can_clear = false;
         }
 #endif
     }
-
-    KMsg() : fd( -1 ) {}
 };
 
 struct Observer : Sink {
@@ -495,11 +546,12 @@ struct Observer : Sink {
 
 struct IO : Sink {
     typedef std::vector< Sink* > Sinks;
+    typedef std::vector< Source* > Sources;
+
     mutable Sinks sinks;
-    Observer *_observer;
+    mutable Sources sources;
 
-    KMsg kmsg;
-    int fd;
+    Observer *_observer;
 
     virtual void push( std::string x ) {
         for ( Sinks::iterator i = sinks.begin(); i != sinks.end(); ++i )
@@ -507,39 +559,43 @@ struct IO : Sink {
     }
 
     void sync() {
-        ssize_t sz;
-        char buf[ 128 * 1024 ];
+        for ( Sources::iterator i = sources.begin(); i != sources.end(); ++i )
+            (*i)->sync( this );
 
-        while ( (sz = read(fd, buf, sizeof(buf) - 1)) > 0 )
-            push( std::string( buf, sz ) );
+        for ( Sinks::iterator i = sinks.begin(); i != sinks.end(); ++i )
+            (*i)->sync();
+    }
 
-        if ( sz < 0 && errno != EAGAIN )
-            throw syserr( "reading pipe" );
+    void close() {
+        for ( Sources::iterator i = sources.begin(); i != sources.end(); ++i )
+            delete *i;
+        sources.clear();
+    }
 
-        kmsg.read( this );
+    int fd_set( fd_set *set ) {
+        int max = -1;
 
-        for ( Sinks::iterator i = sinks.begin(); i != sinks.end(); ++i )
-            (*i)->sync();
+        for ( Sources::iterator i = sources.begin(); i != sources.end(); ++i )
+            max = std::max( (*i)->fd_set( set ), max );
+        return max + 1;
     }
 
-    void close() { ::close( fd ); }
     Observer &observer() { return *_observer; }
 
-    IO() : fd( -1 ) {
+    IO() {
         sinks.push_back( _observer = new Observer );
     }
 
-    IO( const IO &io ) {
-        fd = io.fd;
-        sinks = io.sinks;
+    /* a stealing copy constructor */
+    IO( const IO &io ) : sinks( io.sinks ), sources( io.sources )
+    {
         io.sinks.clear();
+        io.sources.clear();
     }
 
     IO &operator= ( const IO &io ) {
-        fd = io.fd;
-        sinks = io.sinks;
-        io.sinks.clear();
-        return *this;
+        this->~IO();
+        return *new (this) IO( io );
     }
 
     void clear() {
@@ -548,7 +604,7 @@ struct IO : Sink {
         sinks.clear();
     }
 
-    ~IO() { clear(); }
+    ~IO() { close(); clear(); }
 
 };
 
@@ -559,12 +615,12 @@ bool interrupt = false;
 }
 
 struct Options {
-    bool verbose, batch, interactive, cont, fatal_timeouts;
+    bool verbose, batch, interactive, cont, fatal_timeouts, kmsg;
     std::string testdir, outdir, workdir, heartbeat;
-    std::vector< std::string > flavours, filter;
+    std::vector< std::string > flavours, filter, watch;
     std::string flavour_envvar;
     Options() : verbose( false ), batch( false ), interactive( false ),
-                cont( false ), fatal_timeouts( false ) {}
+                cont( false ), fatal_timeouts( false ), kmsg( false ) {}
 };
 
 struct TestProcess
@@ -576,7 +632,12 @@ struct TestProcess
     void exec() {
         assert( fd >= 0 );
         if ( !interactive ) {
-            close( STDIN_FILENO );
+            int devnull = ::open( "/dev/null", O_RDONLY );
+            if ( devnull >= 0 ) { /* gcc really doesn't like to not have stdin */
+                dup2( devnull, STDIN_FILENO );
+                close( devnull );
+            } else
+                close( STDIN_FILENO );
             dup2( fd, STDOUT_FILENO );
             dup2( fd, STDERR_FILENO );
             close( fd );
@@ -633,7 +694,7 @@ struct TestCase {
             exit(202);
         }
 
-        io.fd = fds[0];
+        io.sources.push_back( new Source( fds[0] ) );
         child.fd = fds[1];
         child.interactive = options.interactive;
     }
@@ -661,7 +722,7 @@ struct TestCase {
                 kill( pid, SIGINT );
                 sleep( 5 ); /* wait a bit for a reaction */
                 if ( waitpid( pid, &status, WNOHANG ) == 0 ) {
-                    system( "echo t > /proc/sysrq-trigger" );
+                    system( "echo t > /proc/sysrq-trigger 2> /dev/null" );
                     kill( -pid, SIGKILL );
                     waitpid( pid, &status, 0 );
                 }
@@ -674,7 +735,7 @@ struct TestCase {
         fd_set set;
 
         FD_ZERO( &set );
-        FD_SET( io.fd, &set );
+        int nfds = io.fd_set( &set );
         wait.tv_sec = 0;
         wait.tv_usec = 500000; /* timeout 0.5s */
 
@@ -686,7 +747,7 @@ struct TestCase {
             }
         }
 
-        if ( select( io.fd + 1, &set, NULL, NULL, &wait ) > 0 )
+        if ( select( nfds, &set, NULL, NULL, &wait ) > 0 )
             silent_start = end; /* something happened */
 
         io.sync();
@@ -798,6 +859,7 @@ struct TestCase {
                 progress( First ) << "   " << rusage() << std::endl;
         } else
             progress( Last ) << tag( r ) << pretty() << std::endl;
+
         io.clear();
     }
 
@@ -829,6 +891,12 @@ struct TestCase {
         std::replace( n.begin(), n.end(), '/', '_' );
         std::string fn = options.outdir + "/" + n + ".txt";
         io.sinks.push_back( new FileSink( fn ) );
+
+        for ( std::vector< std::string >::iterator i = options.watch.begin();
+              i != options.watch.end(); ++i )
+            io.sources.push_back( new FileSource( *i ) );
+        if ( options.kmsg )
+            io.sources.push_back( new KMsg );
     }
 
     TestCase( Journal &j, Options opt, std::string path, std::string name, std::string flavour )
@@ -941,13 +1009,6 @@ void setup_handlers() {
         }
 }
 
-int64_t get_time_us(void)
-{
-    struct timeval tv;
-    (void) gettimeofday(&tv, 0);
-    return (int64_t) tv.tv_sec * 1000000 + (int64_t) tv.tv_usec;
-}
-
 }
 
 /* TODO remove in favour of brick-commandline.h */
@@ -1035,6 +1096,12 @@ int run( int argc, const char **argv, std::string fl_envvar = "TEST_FLAVOUR" )
     else
         opt.flavours.push_back( "vanilla" );
 
+    if ( args.has( "--watch" ) )
+        split( args.opt( "--watch" ), opt.watch );
+
+    if ( args.has( "--kmsg" ) )
+        opt.kmsg = true;
+
     opt.outdir = args.opt( "--outdir" );
     opt.testdir = args.opt( "--testdir" );
     opt.workdir = args.opt( "--workdir" );


