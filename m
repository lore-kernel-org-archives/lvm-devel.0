From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 21 Dec 2010 16:41:51 +0100
Subject: [PATCH 19/23] Warning - dead code problem elimination
In-Reply-To: <cover.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
Message-ID: <2e3abc21f31d172f75c96f74e483dfbee6d9dd07.1292945707.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Original code assign  ret = DM_WAIT_INTR and immediately
reassing this value with result code from dm_task_get_info.

It's not quite clear how such result code is supposed to
fit DM_WAIT defines used in this function (maybe wrong merge?)

Maybe it's actually wrong to assing ret with dm_task_get_info.
So reather then removing line:  ret = DM_WAIT_INTR
patch removes later assignment.

CHECKME!!!

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/dmeventd/dmeventd.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 2b454f9..e5adc4d 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -653,8 +653,7 @@ static int _event_wait(struct thread_status *thread, struct dm_task **task)
 	if (dm_task_run(dmt)) {
 		thread->current_events |= DM_EVENT_DEVICE_ERROR;
 		ret = DM_WAIT_INTR;
-
-		if ((ret = dm_task_get_info(dmt, &info)))
+		if (dm_task_get_info(dmt, &info))
 			thread->event_nr = info.event_nr;
 	} else if (thread->events & DM_EVENT_TIMEOUT && errno == EINTR) {
 		thread->current_events |= DM_EVENT_TIMEOUT;
-- 
1.7.3.4


