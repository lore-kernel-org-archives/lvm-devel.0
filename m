From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Apr 2014 14:55:39 +0000 (UTC)
Subject: master - cleanup: dmeventd set next_time when registering
Message-ID: <20140418145539.E60D660E56@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3febd2c9d47eb2af60a576a07c4042331930c2c1
Commit:        3febd2c9d47eb2af60a576a07c4042331930c2c1
Parent:        dc21bbfabd92a982712b4dafb7c3d7ede99f815f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 18 14:30:00 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 18 16:52:11 2014 +0200

cleanup: dmeventd set next_time when registering

Don't change next_time, when thread is already registered.
---
 daemons/dmeventd/dmeventd.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index e13afd2..f8b5470 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -572,9 +572,8 @@ static int _register_for_timeout(struct thread_status *thread)
 
 	pthread_mutex_lock(&_timeout_mutex);
 
-	thread->next_time = time(NULL) + thread->timeout;
-
 	if (dm_list_empty(&thread->timeout_list)) {
+		thread->next_time = time(NULL) + thread->timeout;
 		dm_list_add(&_timeout_registry, &thread->timeout_list);
 		if (_timeout_running)
 			pthread_cond_signal(&_timeout_cond);


