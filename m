From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:30:15 +0000 (GMT)
Subject: main - cov: validate syscall result
Message-ID: <20210920133015.7F8513858C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=055406bb398ddf60f18c545baffcec4ee4d5646e
Commit:        055406bb398ddf60f18c545baffcec4ee4d5646e
Parent:        9721f3e0ff6fd841b62b6bcccceee2ebb914e96b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 20 10:31:45 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 14:26:09 2021 +0200

cov: validate syscall result

---
 test/lib/brick-shelltest.h | 3 ++-
 test/lib/not.c             | 6 +++++-
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/test/lib/brick-shelltest.h b/test/lib/brick-shelltest.h
index 0b1f9dfee..6bc02e0d2 100644
--- a/test/lib/brick-shelltest.h
+++ b/test/lib/brick-shelltest.h
@@ -424,7 +424,8 @@ struct FdSink : Sink {
     {
         TimedBuffer::Line line = stream.shift( force );
         std::string out = fmt.format( line );
-        write( fd, out.c_str(), out.length() );
+        if ( write( fd, out.c_str(), out.length() ) < (int)out.length() )
+            perror( "short write" );
     }
 
     virtual void sync( bool force ) {
diff --git a/test/lib/not.c b/test/lib/not.c
index a5c52a8e6..0cff13062 100644
--- a/test/lib/not.c
+++ b/test/lib/not.c
@@ -86,7 +86,11 @@ int main(int args, char **argv) {
 		/* should not be accessible */
 		return FAILURE;
 	} else {		/* parent */
-		waitpid(pid, &status, 0);
+		if (waitpid(pid, &status, 0) < 0) {
+			fprintf(stderr, "Process %d failed on waitpid.\n", pid);
+			return FAILURE;
+		}
+
 		if (!WIFEXITED(status)) {
 			if (WIFSIGNALED(status))
 				fprintf(stderr,


