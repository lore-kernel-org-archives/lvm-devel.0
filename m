From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Mar 2011 12:53:05 -0000
Subject: LVM2/lib/log log.c
Message-ID: <20110330125305.31253.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-30 12:53:04

Modified files:
	lib/log        : log.c 

Log message:
	Optimise error message write to _lvm_errmsg
	
	Isn't usually perfomance critical - but log_error is used i.e.for debuging,
	this code noticable slows down the processing.
	
	Added 512KB limit to avoid memory exhastions in case of some endless loop.
	
	TODO: use _lvm_errmsg buffer only when lvm2api needs it.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62

--- LVM2/lib/log/log.c	2011/02/18 14:16:12	1.61
+++ LVM2/lib/log/log.c	2011/03/30 12:53:04	1.62
@@ -43,6 +43,9 @@
 static int _lvm_errno = 0;
 static int _store_errmsg = 0;
 static char *_lvm_errmsg = NULL;
+static size_t _lvm_errmsg_size = 0;
+static size_t _lvm_errmsg_len = 0;
+#define MAX_ERRMSG_LEN (512 * 1024)  /* Max size of error buffer 512KB */
 
 void init_log_fn(lvm2_log_fn_t log_fn)
 {
@@ -154,6 +157,7 @@
 	if (_lvm_errmsg) {
 		dm_free(_lvm_errmsg);
 		_lvm_errmsg = NULL;
+		_lvm_errmsg_size = _lvm_errmsg_len = 0;
 	}
 
 	_store_errmsg = store_errmsg;
@@ -189,6 +193,7 @@
 	int use_stderr = level & _LOG_STDERR;
 	int log_once = level & _LOG_ONCE;
 	int fatal_internal_error = 0;
+	size_t msglen;
 
 	level &= ~(_LOG_STDERR|_LOG_ONCE);
 
@@ -229,14 +234,24 @@
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
 


