From: corubba <corubba@gmx.de>
Date: Tue, 1 Nov 2022 22:26:52 +0100
Subject: [PATCH v2 3/3] lvmlockd: Improve error handling
In-Reply-To: <ef4eac45-6e5e-06dd-fc9b-2794a261ab90@gmx.de>
References: <9002aa3d-a523-7283-3a53-c9499add0cd6@gmx.de>
 <ef4eac45-6e5e-06dd-fc9b-2794a261ab90@gmx.de>
Message-ID: <7f4cae3a-e290-1457-97c1-9eb4c96bca95@gmx.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In certain error cases the request to lvmlockd is send using a
uninitialized lvmlockd handle and its socket_fd 0, resulting in the
request payload being printed to stdout and then blocking the process
waiting to read the response from stdout. This is fixed by setting the
socket_fd and error members to values that trigger existing guards.

To prevent redundant and unnecessary error output, a short-circuit is
added to the send function.

Signed-off-by: corubba <corubba@gmx.de>
---
v2: New commit, not part of v1.

 lib/locking/lvmlockd.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 790dc70b7..b45ca72e6 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -88,8 +88,11 @@ void lvmlockd_connect(void)
 		log_error("lvmlockd is already connected.");
 	}

-	if (_lvmlockd_init_failed)
+	if (_lvmlockd_init_failed) {
+		_lvmlockd.socket_fd = -1;
+		_lvmlockd.error = -1;
 		return;
+	}

 	_lvmlockd = lvmlockd_open(_lvmlockd_socket);

@@ -195,6 +198,9 @@ static daemon_reply _lockd_send_with_pvs(const char *req_name,

 	req = daemon_request_make(req_name);

+	if (!_lvmlockd_connected)
+		goto bad;
+
 	va_start(ap, lock_pvs);
 	daemon_request_extend_v(req, ap);
 	va_end(ap);
--
2.38.1

