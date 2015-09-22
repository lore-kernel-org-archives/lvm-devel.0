From: Marian Csontos <mcsontos@redhat.com>
Date: Tue, 22 Sep 2015 13:16:09 +0200
Subject: [PATCH 3/4] dmeventd: Remove an useless _lock_mutex
In-Reply-To: <1442920570-29969-1-git-send-email-mcsontos@redhat.com>
References: <1442920570-29969-1-git-send-email-mcsontos@redhat.com>
Message-ID: <1442920570-29969-4-git-send-email-mcsontos@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

One of the branches was locking a mutex only to unlock it later.
---
This may be more esthetic than performance issue.

Definitely trading a little performance gain for clarity.

 daemons/dmeventd/dmeventd.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index ff11625..82c8cc3 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1088,6 +1088,7 @@ static int _register_for_event(struct message_data *message_data)
 		}
 
 		LINK_THREAD(thread);
+		_unlock_mutex();
 	} else {
 		/* Or event # into events bitfield. */
 		orig_events = thread->events;
@@ -1100,13 +1101,12 @@ static int _register_for_event(struct message_data *message_data)
 				 * consistency. */
 				_lock_mutex();
 				thread->events &= ~DM_EVENT_TIMEOUT;
-			} else
-				_lock_mutex();
-		}
+				_unlock_mutex();
+			}
+		} else
+			_unlock_mutex();
 	}
 
-	_unlock_mutex();
-
       out:
 	/*
 	 * Deallocate thread status after releasing
-- 
1.8.3.1


