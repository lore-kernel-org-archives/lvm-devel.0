From: Marian Csontos <mcsontos@redhat.com>
Date: Tue, 22 Sep 2015 13:16:07 +0200
Subject: [PATCHv2 1/4] dmeventd: Fix segfault in _timeout_thread
In-Reply-To: <1442920570-29969-1-git-send-email-mcsontos@redhat.com>
References: <1442920570-29969-1-git-send-email-mcsontos@redhat.com>
Message-ID: <1442920570-29969-2-git-send-email-mcsontos@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In case thread was found or thread registration failed after
_register_for_timeout, thread_status was kept in timeout_list after
deallocation.
---
This should be the actual fix for the above mentioned BZ 1210514 and BZ 1220856.

*TODO* Any ideas how to test this? Is explicitly messaging dmeventd required?

 daemons/dmeventd/dmeventd.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 1ff5bf9..0f67206 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1081,6 +1081,7 @@ static int _register_for_event(struct message_data *message_data)
 		if ((ret = -_create_thread(thread))) {
 			_unlock_mutex();
 			_do_unregister_device(thread);
+			_unregister_for_timeout(thread);
 			_free_thread_status(thread);
 			goto out;
 		}
@@ -1097,8 +1098,10 @@ static int _register_for_event(struct message_data *message_data)
 	 * Deallocate thread status after releasing
 	 * the lock in case we haven't used it.
 	 */
-	if (thread_new)
+	if (thread_new) {
+		_unregister_for_timeout(thread);
 		_free_thread_status(thread_new);
+	}
 
 	return ret;
 }
-- 
1.8.3.1


