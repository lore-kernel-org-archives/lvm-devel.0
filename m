From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 22 Mar 2011 22:34:10 +0100
Subject: [PATCH 1/8] Optimise write of error to _lvm_errmsg
In-Reply-To: <cover.1300829383.git.zkabelac@redhat.com>
References: <cover.1300829383.git.zkabelac@redhat.com>
Message-ID: <c2e33d0c21e4146f166a607d617812a96c5bbb42.1300829383.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Isn't usually perfomance critical - but when used for debuging,
this code noticable slows down the processing.

I may also ask what is the purpose of having some large unbound buffer?
(clvmd getting some error could leak out of memory  I guess)

So added just 512KB limit.

TODO: create  _lvm_errmsg buffer only when lvm2api needs it.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/log/log.c |   31 +++++++++++++++++++++++--------
 1 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/lib/log/log.c b/lib/log/log.c
index ec72b7a..b84c604 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -43,6 +43,9 @@ static lvm2_log_fn_t _lvm2_log_fn = NULL;
 static int _lvm_errno = 0;
 static int _store_errmsg = 0;
 static char *_lvm_errmsg = NULL;
+static size_t _lvm_errmsg_size = 0;
+static size_t _lvm_errmsg_len = 0;
+#define MAX_ERRMSG_LEN (512 * 1024)  /* max size of error buffer 512KB */
 
 void init_log_fn(lvm2_log_fn_t log_fn)
 {
@@ -154,6 +157,7 @@ void reset_lvm_errno(int store_errmsg)
 	if (_lvm_errmsg) {
 		dm_free(_lvm_errmsg);
 		_lvm_errmsg = NULL;
+		_lvm_errmsg_size = _lvm_errmsg_len = 0;
 	}
 
 	_store_errmsg = store_errmsg;
@@ -189,6 +193,7 @@ void print_log(int level, const char *file, int line, int dm_errno,
 	int use_stderr = level & _LOG_STDERR;
 	int log_once = level & _LOG_ONCE;
 	int fatal_internal_error = 0;
+	size_t msglen;
 
 	level &= ~(_LOG_STDERR|_LOG_ONCE);
 
@@ -229,14 +234,24 @@ void print_log(int level, const char *file, int line, int dm_errno,
 		message = &buf2[0];
 	}
 
-	if (_store_errmsg && (level <= _LOG_ERR)) {
-		if (!_lvm_errmsg)
-			_lvm_errmsg = dm_strdup(message);
-		else if ((newbuf = dm_realloc(_lvm_errmsg,
- 					      strlen(_lvm_errmsg) +
-					      strlen(message) + 2))) {
-			_lvm_errmsg = strcat(newbuf, "\n");
-			_lvm_errmsg = strcat(newbuf, message);
+	if (_store_errmsg && (level <= _LOG_ERR) &&
+	    _lvm_errmsg_len < MAX_ERRMSG_LEN) {
+		msglen = strlen(message);
+		if ((_lvm_errmsg_len + msglen + 1) >= _lvm_errmsg_size) {
+			_lvm_errmsg_size = 2 * (_lvm_errmsg_len + msglen + 1);
+			if ((newbuf = dm_realloc(_lvm_errmsg,
+						 _lvm_errmsg_size)))
+				_lvm_errmsg = newbuf;
+			else
+				_lvm_errmsg_size = _lvm_errmsg_len;
+		}
+		if (_lvm_errmsg &&
+		    (_lvm_errmsg_len + msglen + 2) < _lvm_errmsg_size) {
+			/* prepend '\n' and copy with '\0' but do not count in */
+                        if (_lvm_errmsg_len)
+				_lvm_errmsg[_lvm_errmsg_len++] = '\n';
+			memcpy(_lvm_errmsg + _lvm_errmsg_len, message, msglen + 1);
+			_lvm_errmsg_len += msglen;
 		}
 	}
 
-- 
1.7.4.1


