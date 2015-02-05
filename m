From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:40:45 +0000 (UTC)
Subject: master - test: Split up the new runner into multiple files.
Message-ID: <20150205134045.AAFFB602BB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9dfbce0aa72735048a788dd23f91f76fbc21dd23
Commit:        9dfbce0aa72735048a788dd23f91f76fbc21dd23
Parent:        b726d6688260e1e1e98500809eee014b7ceb92b5
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Jun 25 21:34:34 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:16 2015 +0100

test: Split up the new runner into multiple files.

---
 test/Makefile.in      |    4 +-
 test/lib/filesystem.h |   86 ++++++++++++++++
 test/lib/io.h         |  211 +++++++++++++++++++++++++++++++++++++++
 test/lib/journal.h    |   58 +++++++++++
 test/lib/runner.cpp   |  265 ++++++++-----------------------------------------
 test/lib/util.h       |   39 +++++++
 6 files changed, 437 insertions(+), 226 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index c88d07a..88644f3 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -38,7 +38,6 @@ export LVM_TEST_CACHE_RESTORE_CMD?=@CACHE_RESTORE_CMD@
 SUBDIRS = api unit
 SOURCES = lib/not.c lib/harness.c
 CXXSOURCES = lib/runner.cpp
-CXXFLAGS = -std=c++11
 
 include $(top_builddir)/make.tmpl
 
@@ -137,10 +136,11 @@ lib/invalid: lib/not
 lib/fail: lib/not
 	ln -sf not lib/fail
 
-
 lib/runner: lib/runner.o .lib-dir-stamp
 	$(CXX) $(LDFLAGS) -o $@ $<
 
+lib/runner.o: $(wildcard $(srcdir)/lib/*.h)
+
 lib/%: lib/%.o .lib-dir-stamp
 	$(CC) $(LDFLAGS) -o $@ $<
 
diff --git a/test/lib/filesystem.h b/test/lib/filesystem.h
new file mode 100644
index 0000000..718c433
--- /dev/null
+++ b/test/lib/filesystem.h
@@ -0,0 +1,86 @@
+/* -*- C++ -*- copyright (c) 2014 Red Hat, Inc.
+ *
+ * This file is part of LVM2.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright notice,
+ *    this list of conditions and the following disclaimer.
+ *
+ * 2. Redistributions in binary form must reproduce the above copyright notice,
+ *    this list of conditions and the following disclaimer in the documentation
+ *    and/or other materials provided with the distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
+ * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
+ * POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include "util.h"
+
+#include <vector>
+#include <string>
+
+#include <dirent.h>
+#include <sys/stat.h>
+
+#ifndef RUNNER_FILESYSTEM_H
+#define RUNNER_FILESYSTEM_H
+
+struct dir {
+	DIR *d;
+	dir( std::string p ) {
+		d = opendir( p.c_str() );
+		if ( !d )
+			throw syserr( "error opening directory", p );
+	}
+	~dir() { closedir( d ); }
+};
+
+typedef std::vector< std::string > Listing;
+
+inline Listing listdir( std::string p, bool recurse = false, std::string prefix = "" )
+{
+	Listing r;
+
+	dir d( p );
+	struct dirent entry, *iter = 0;
+	int readerr;
+
+	while ( (readerr = readdir_r( d.d, &entry, &iter )) == 0 && iter ) {
+		std::string ename( entry.d_name );
+
+		if ( ename == "." || ename == ".." )
+			continue;
+
+		if ( recurse ) {
+			struct stat64 stat;
+			std::string s = p + "/" + ename;
+			if ( ::stat64( s.c_str(), &stat ) == -1 )
+				continue;
+			if ( S_ISDIR(stat.st_mode) ) {
+				Listing sl = listdir( s, true, prefix + ename + "/" );
+				for ( Listing::iterator i = sl.begin(); i != sl.end(); ++i )
+					r.push_back( prefix + *i );
+			} else
+				r.push_back( prefix + ename );
+		} else
+			r.push_back( ename );
+	};
+
+	if ( readerr != 0 )
+		throw syserr( "error reading directory", p );
+
+	return r;
+}
+
+#endif
diff --git a/test/lib/io.h b/test/lib/io.h
new file mode 100644
index 0000000..8ade281
--- /dev/null
+++ b/test/lib/io.h
@@ -0,0 +1,211 @@
+/* -*- C++ -*- copyright (c) 2014 Red Hat, Inc.
+ *
+ * This file is part of LVM2.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright notice,
+ *    this list of conditions and the following disclaimer.
+ *
+ * 2. Redistributions in binary form must reproduce the above copyright notice,
+ *    this list of conditions and the following disclaimer in the documentation
+ *    and/or other materials provided with the distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
+ * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
+ * POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include "util.h"
+
+#include <deque>
+#include <map>
+#include <vector>
+#include <string>
+#include <cstdio>
+#include <cassert>
+#include <algorithm>
+
+#include <unistd.h>
+#include <fcntl.h>
+#include <errno.h>
+
+#include <sys/klog.h>
+
+#include <iostream>
+
+#ifndef RUNNER_IO_H
+#define RUNNER_IO_H
+
+#define SYSLOG_ACTION_READ_CLEAR     4
+#define SYSLOG_ACTION_CLEAR          5
+
+struct Sink {
+	virtual void outline( bool ) {}
+	virtual void push( std::string x ) = 0;
+	virtual void sync() {}
+};
+
+struct FdSink : Sink {
+	int fd;
+
+	typedef std::deque< char > Stream;
+	typedef std::map< std::string, std::string > Subst;
+
+	Stream stream;
+	Subst subst;
+	bool killed;
+
+	virtual void outline( bool force )
+	{
+		Stream::iterator nl = std::find( stream.begin(), stream.end(), '\n' );
+		if ( nl == stream.end() ) {
+			if ( !force )
+				return;
+		} else
+			force = false;
+
+		assert( nl != stream.end() || force );
+
+		std::string line( stream.begin(), nl );
+		stream.erase( stream.begin(), force ? nl : nl + 1 );
+
+		if ( std::string( line, 0, 9 ) == "@TESTDIR=" )
+			subst[ "@TESTDIR@" ] = std::string( line, 9, std::string::npos );
+		else if ( std::string( line, 0, 8 ) == "@PREFIX=" )
+			subst[ "@PREFIX@" ] = std::string( line, 8, std::string::npos );
+		else {
+			int off;
+			for ( Subst::iterator s = subst.begin(); s != subst.end(); ++s )
+				while ( (off = line.find( s->first )) != std::string::npos )
+					line.replace( off, s->first.length(), s->second );
+			write( fd, line.c_str(), line.length() );
+			if ( !force )
+				write( fd, "\n", 1 );
+		}
+	}
+
+	virtual void sync() {
+		while ( !stream.empty() )
+			outline( true );
+	}
+
+	virtual void push( std::string x ) {
+		if ( !killed )
+			std::copy( x.begin(), x.end(), std::back_inserter( stream ) );
+	}
+
+	FdSink( int _fd ) : fd( _fd ), killed( false ) {}
+};
+
+struct Observer : Sink {
+	Observer() {}
+	void push( std::string ) {}
+};
+
+struct KMsg {
+	int fd;
+	char buf[ 4096 ];
+
+	bool dev_kmsg() {
+		return fd >= 0;
+	}
+
+	void reset() {
+		int sz;
+
+		if ( dev_kmsg() ) {
+			if ( (fd = open("/dev/kmsg", O_RDONLY | O_NONBLOCK)) < 0 ) {
+				if (errno != ENOENT) /* Older kernels (<3.5) do not support /dev/kmsg */
+					perror("opening /dev/kmsg");
+			} else if (lseek(fd, 0L, SEEK_END) == (off_t) -1)
+				perror("lseek /dev/kmsg");
+		} else
+			klogctl( SYSLOG_ACTION_CLEAR, 0, 0 );
+	}
+
+	void read( Sink *s ) {
+		int sz;
+
+		if ( dev_kmsg() ) {
+			while ( (sz = ::read(fd, buf, sizeof(buf) - 1)) > 0 )
+				s->push( std::string( buf, sz ) );
+			if ( sz < 0 ) {
+				fd = -1;
+				read( s );
+			}
+		} else {
+			sz = klogctl( SYSLOG_ACTION_READ_CLEAR, buf, sizeof(buf) - 1 );
+			if ( sz > 0 )
+				s->push( std::string( buf, sz ) );
+		}
+	}
+
+	KMsg() : fd( -1 ) {}
+};
+
+struct IO : Sink {
+	typedef std::vector< Sink* > Sinks;
+	mutable Sinks sinks;
+	Observer *_observer;
+
+	KMsg kmsg;
+	int fd;
+	char buf[ 4096 ];
+
+	virtual void push( std::string x ) {
+		for ( Sinks::iterator i = sinks.begin(); i != sinks.end(); ++i )
+			(*i)->push( x );
+	}
+
+	void sync() {
+		ssize_t sz;
+		while ( (sz = read(fd, buf, sizeof(buf) - 1)) > 0 )
+			push( std::string( buf, sz ) );
+
+		if ( sz < 0 && errno != EAGAIN )
+			throw syserr( "reading pipe" );
+
+		kmsg.read( this );
+
+		for ( Sinks::iterator i = sinks.begin(); i != sinks.end(); ++i )
+			(*i)->sync();
+	}
+
+	void close() { ::close( fd ); }
+	Observer &observer() { return *_observer; }
+
+	IO() : fd( -1 ) {
+		sinks.push_back( _observer = new Observer );
+	}
+
+	IO( const IO &io ) {
+		fd = io.fd;
+		sinks = io.sinks;
+		io.sinks.clear();
+	}
+
+	IO &operator= ( const IO &io ) {
+		fd = io.fd;
+		sinks = io.sinks;
+		io.sinks.clear();
+		return *this;
+	}
+
+	~IO() {
+		for ( Sinks::iterator i = sinks.begin(); i != sinks.end(); ++i )
+			delete *i;
+	}
+
+};
+
+#endif
diff --git a/test/lib/journal.h b/test/lib/journal.h
new file mode 100644
index 0000000..ff662f3
--- /dev/null
+++ b/test/lib/journal.h
@@ -0,0 +1,58 @@
+// -*- C++ -*-
+
+#include <map>
+#include <iostream>
+
+#ifndef RUNNER_JOURNAL_H
+#define RUNNER_JOURNAL_H
+
+struct Journal {
+	enum R {
+		STARTED,
+		UNKNOWN,
+		FAILED,
+		INTERRUPTED,
+		KNOWNFAIL,
+		PASSED,
+		SKIPPED,
+		TIMEOUT,
+		WARNED,
+	};
+
+	friend std::ostream &operator<<( std::ostream &o, R r ) {
+		switch ( r ) {
+			case STARTED: return o << "started";
+			case FAILED: return o << "failed";
+			case INTERRUPTED: return o << "interrupted";
+			case PASSED: return o << "passed";
+			case SKIPPED: return o << "skipped";
+			case TIMEOUT: return o << "timeout";
+			case WARNED: return o << "warnings";
+			default: return o << "unknown";
+		}
+	}
+
+	typedef std::map< std::string, R > Status;
+	Status status;
+
+	int count( R r ) {
+		int c = 0;
+		for ( Status::iterator i = status.begin(); i != status.end(); ++i )
+			if ( i->second == r )
+				++ c;
+		return c;
+	}
+
+	void banner() {
+		std::cout << std::endl << "### " << status.size() << " tests: "
+			  << count( PASSED ) << " passed" << std::endl;
+	}
+
+	void details() {
+		for ( Status::iterator i = status.begin(); i != status.end(); ++i )
+			if ( i->second != PASSED )
+				std::cout << i->second << ": " << i->first << std::endl;
+	}
+};
+
+#endif
diff --git a/test/lib/runner.cpp b/test/lib/runner.cpp
index bcc98ba..4180de3 100644
--- a/test/lib/runner.cpp
+++ b/test/lib/runner.cpp
@@ -1,24 +1,40 @@
-/*
- * Copyright (C) 2010-2014 Red Hat, Inc. All rights reserved.
+/* -*- C++ -*- copyright (c) 2014 Red Hat, Inc.
  *
  * This file is part of LVM2.
  *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU General Public License v.2.
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
  *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ * 1. Redistributions of source code must retain the above copyright notice,
+ *    this list of conditions and the following disclaimer.
+ *
+ * 2. Redistributions in binary form must reproduce the above copyright notice,
+ *    this list of conditions and the following disclaimer in the documentation
+ *    and/or other materials provided with the distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
+ * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
+ * POSSIBILITY OF SUCH DAMAGE.
  */
 
+#include "io.h"
+#include "journal.h"
+#include "filesystem.h"
+
 #include <iostream>
 #include <vector>
 #include <deque>
 #include <map>
 #include <sstream>
 #include <cassert>
-#include <system_error>
 #include <algorithm>
 
 #include <fcntl.h>
@@ -29,7 +45,6 @@
 #include <sys/resource.h> /* rusage */
 #include <sys/select.h>
 #include <sys/socket.h>
-#include <sys/stat.h>
 #include <sys/time.h>
 #include <sys/types.h>
 #include <sys/wait.h>
@@ -37,226 +52,21 @@
 #include <time.h>
 #include <unistd.h>
 #include <stdint.h>
-#include <dirent.h>
-
-#define SYSLOG_ACTION_READ_CLEAR     4
-#define SYSLOG_ACTION_CLEAR          5
 
 pid_t kill_pid = 0;
 bool fatal_signal = false;
 
-std::system_error syserr( std::string msg, std::string ctx = "" ) {
-	return std::system_error( errno, std::generic_category(), msg + " " + ctx );
-}
-
-struct dir {
-	DIR *d;
-	dir( std::string p ) {
-		d = opendir( p.c_str() );
-		if ( !d )
-			throw syserr( "error opening directory", p );
-	}
-	~dir() { closedir( d ); }
-};
-
-typedef std::vector< std::string > Listing;
-
-Listing listdir( std::string p, bool recurse = false, std::string prefix = "" ) {
-	Listing r;
-
-	dir d( p );
-	struct dirent entry, *iter = 0;
-	int readerr;
-
-	while ( (readerr = readdir_r( d.d, &entry, &iter )) == 0 && iter ) {
-		std::string ename( entry.d_name );
-
-		if ( ename == "." || ename == ".." )
-			continue;
-
-		if ( recurse ) {
-			struct stat64 stat;
-			std::string s = p + "/" + ename;
-			if ( ::stat64( s.c_str(), &stat ) == -1 )
-				throw syserr( "stat error", s );
-			if ( S_ISDIR(stat.st_mode) ) {
-				Listing sl = listdir( s, true, prefix + ename + "/" );
-				for ( Listing::iterator i = sl.begin(); i != sl.end(); ++i )
-					r.push_back( prefix + *i );
-			} else
-				r.push_back( prefix + ename );
-		} else
-			r.push_back( ename );
-	};
-
-	if ( readerr != 0 )
-		throw syserr( "error reading directory", p );
-
-	return r;
-}
-
 struct Options {
 	bool verbose, quiet, interactive;
 	std::string testdir, outdir;
-};
-
-struct Journal {
-	enum R {
-		STARTED,
-		UNKNOWN,
-		FAILED,
-		INTERRUPTED,
-		KNOWNFAIL,
-		PASSED,
-		SKIPPED,
-		TIMEOUT,
-		WARNED,
-	};
-
-	friend std::ostream &operator<<( std::ostream &o, R r ) {
-		switch ( r ) {
-			case STARTED: return o << "started";
-			case FAILED: return o << "failed";
-			case INTERRUPTED: return o << "interrupted";
-			case PASSED: return o << "passed";
-			case SKIPPED: return o << "skipped";
-			case TIMEOUT: return o << "timeout";
-			case WARNED: return o << "warnings";
-			default: return o << "unknown";
-		}
-	}
-
-	typedef std::map< std::string, R > Status;
-	Status status;
-
-	int count( R r ) {
-		int c = 0;
-		for ( Status::iterator i = status.begin(); i != status.end(); ++i )
-			if ( i->second == r )
-				++ c;
-		return c;
-	}
-
-	void banner() {
-		std::cout << std::endl << "### " << status.size() << " tests: "
-			  << count( PASSED ) << " passed" << std::endl;
-	}
-
-	void details() {
-		for ( Status::iterator i = status.begin(); i != status.end(); ++i )
-			if ( i->second != PASSED )
-				std::cout << i->second << ": " << i->first << std::endl;
-	}
-};
-
-struct Sink {
-	int fd;
-
-	typedef std::deque< char > Stream;
-	typedef std::map< std::string, std::string > Subst;
-
-	Stream stream;
-	Subst subst;
-	bool killed;
-
-	virtual void outline( bool force )
-	{
-		Stream::iterator nl = std::find( stream.begin(), stream.end(), '\n' );
-		if ( nl == stream.end() && !force )
-			return;
-
-		std::string line( stream.begin(), nl );
-		stream.erase( stream.begin(), nl + 1 );
-
-		if ( std::string( line, 0, 9 ) == "@TESTDIR=" )
-			subst[ "@TESTDIR@" ] = std::string( line, 9, std::string::npos );
-		else if ( std::string( line, 0, 8 ) == "@PREFIX=" )
-			subst[ "@PREFIX@" ] = std::string( line, 8, std::string::npos );
-		else {
-			int off;
-			for ( Subst::iterator s = subst.begin(); s != subst.end(); ++s )
-				while ( (off = line.find( s->first )) != std::string::npos )
-					line.replace( off, s->first.length(), s->second );
-			write( fd, line.c_str(), line.length() );
-		}
-	}
-
-	void sync() {
-		while ( !stream.empty() )
-			outline( true );
-	}
-
-	void push( std::string x ) {
-		if ( !killed )
-			std::copy( x.begin(), x.end(), std::back_inserter( stream ) );
-	}
-
-	Sink( int fd ) : fd( fd ), killed( false ) {}
-};
-
-struct Observer : Sink {
-	Observer() : Sink( -1 ) {}
-};
-
-struct IO {
-	typedef std::vector< Sink* > Sinks;
-	mutable Sinks sinks;
-	Observer *_observer;
-
-	int fd;
-	char buf[ 4097 ];
-
-	void sink( std::string x ) {
-		for ( Sinks::iterator i = sinks.begin(); i != sinks.end(); ++i )
-			(*i)->push( x );
-	}
-
-	void sync() {
-		ssize_t sz;
-		while ((sz = read(fd, buf, sizeof(buf) - 1)) > 0)
-			sink( std::string( buf, sz ) );
-
-		if ( sz < 0 && errno != EAGAIN )
-			throw syserr( "reading pipe" );
-
-		/* get the kernel ring buffer too */
-		sz = klogctl( SYSLOG_ACTION_READ_CLEAR, buf, sizeof(buf) - 1 );
-		if ( sz > 0 )
-			sink( std::string( buf, sz ) );
-	}
-
-	void close() { ::close( fd ); }
-	Observer &observer() { return *_observer; }
-
-	IO() : fd( -1 ) {
-		sinks.push_back( _observer = new Observer );
-	}
-
-	IO( const IO &io ) {
-		fd = io.fd;
-		sinks = io.sinks;
-		io.sinks.clear();
-	}
-
-	IO &operator= ( const IO &io ) {
-		fd = io.fd;
-		sinks = io.sinks;
-		io.sinks.clear();
-		return *this;
-	}
-
-	~IO() {
-		for ( Sinks::iterator i = sinks.begin(); i != sinks.end(); ++i )
-			delete *i;
-	}
-
+	Options() : verbose( false ), quiet( false ), interactive( false ) {}
 };
 
 struct TestProcess
 {
-	int fd;
-	bool interactive;
 	std::string filename;
+	bool interactive;
+	int fd;
 
 	void exec() {
 		assert( fd >= 0 );
@@ -269,7 +79,6 @@ struct TestProcess
 		environment();
 
 		setpgid( 0, 0 );
-		klogctl( SYSLOG_ACTION_CLEAR, 0, 0 );
 
 		execlp( "bash", "bash", "-noprofile", "-norc", filename.c_str(), NULL );
 		perror( "execlp" );
@@ -433,13 +242,19 @@ struct TestCase {
 			child.exec();
 		} else {
 			progress( First ) << tag( "running" ) << name << std::flush;
+			if ( options.verbose || options.interactive )
+				progress() << std::endl;
 			start = time( 0 );
 			parent();
 		}
 	}
 
-	TestCase( std::string path, std::string name )
-		: timeout( false ), silent_ctr( 0 ), child( path ), name( name ) {}
+	TestCase( Options opt, std::string path, std::string name )
+		: timeout( false ), silent_ctr( 0 ), child( path ), name( name ), options( opt )
+	{
+		if ( opt.verbose )
+			io.sinks.push_back( new FdSink( 1 ) );
+	}
 };
 
 struct Main {
@@ -461,7 +276,7 @@ struct Main {
 				continue;
 			if ( i->substr( 0, 4 ) == "lib/" )
 				continue;
-			cases.push_back( TestCase( options.testdir + *i, *i ) );
+			cases.push_back( TestCase( options, options.testdir + *i, *i ) );
 			cases.back().options = options;
 		}
 
@@ -470,11 +285,13 @@ struct Main {
 	void run() {
 		setup();
 		start = time( 0 );
+		std::cerr << "running " << cases.size() << " tests" << std::endl;
+
 		for ( Cases::iterator i = cases.begin(); i != cases.end(); ++i ) {
 			i->run();
 
 			if ( time(0) - start > 3 * 3600 ) {
-				printf("3 hours passed, giving up...\n");
+				std::cerr << "3 hours passed, giving up..." << std::endl;
 				die = 1;
 			}
 
@@ -487,7 +304,7 @@ struct Main {
 			exit( 1 );
 	}
 
-	Main( Options o ) : options( o ) {}
+	Main( Options o ) : die( false ), options( o ) {}
 };
 
 static void handler( int sig ) {
diff --git a/test/lib/util.h b/test/lib/util.h
new file mode 100644
index 0000000..1450ab4
--- /dev/null
+++ b/test/lib/util.h
@@ -0,0 +1,39 @@
+/* -*- C++ -*- copyright (c) 2014 Red Hat, Inc.
+ *
+ * This file is part of LVM2.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright notice,
+ *    this list of conditions and the following disclaimer.
+ *
+ * 2. Redistributions in binary form must reproduce the above copyright notice,
+ *    this list of conditions and the following disclaimer in the documentation
+ *    and/or other materials provided with the distribution.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
+ * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
+ * POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <stdexcept>
+#include <cstring>
+#include <errno.h>
+
+#ifndef RUNNER_UTIL_H
+#define RUNNER_UTIL_H
+
+inline std::runtime_error syserr( std::string msg, std::string ctx = "" ) {
+	return std::runtime_error( std::string( strerror( errno ) ) + " " + msg + " " + ctx );
+}
+
+#endif


