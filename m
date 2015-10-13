From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:04:05 +0000 (UTC)
Subject: master - cleanup: always set nsec
Message-ID: <20151013140405.49E04602BE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=842a7a17e3c0ffc0467ef23a3b59e4e8af2c8d74
Commit:        842a7a17e3c0ffc0467ef23a3b59e4e8af2c8d74
Parent:        f4fb97c85082b964397a4e7930d7aa809ffd58f9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 13 09:39:18 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 15:22:57 2015 +0200

cleanup: always set nsec

---
 daemons/dmeventd/dmeventd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index e2daef4..7ad30b3 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -568,12 +568,12 @@ static void *_timeout_thread(void *unused __attribute__((unused)))
 	time_t curr_time;
 
 	DEBUGLOG("Timeout thread starting.");
-	timeout.tv_nsec = 0;
 	pthread_cleanup_push(_exit_timeout, NULL);
 	pthread_mutex_lock(&_timeout_mutex);
 
 	while (!dm_list_empty(&_timeout_registry)) {
 		timeout.tv_sec = 0;
+		timeout.tv_nsec = 0;
 		curr_time = time(NULL);
 
 		dm_list_iterate_items_gen(thread, &_timeout_registry, timeout_list) {


