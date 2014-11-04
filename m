From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  4 Nov 2014 16:59:59 +0000 (UTC)
Subject: master - dmeventd: Remove redundant checks.
Message-ID: <20141104165959.A3901607A5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6b25faa218fc5cd1601e5418ce1481400386ecce
Commit:        6b25faa218fc5cd1601e5418ce1481400386ecce
Parent:        cebbda0931e43097a148bbf2c4b8a1de1c77d9fa
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Nov 4 16:55:42 2014 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Nov 4 16:55:42 2014 +0000

dmeventd: Remove redundant checks.

The status of threads in _thread_registry is always DM_THREAD_RUNNING
(zero).

DM_EVENT_REGISTRATION_PENDING is never stored in thread->events.
---
 daemons/dmeventd/dmeventd.c |   14 ++++----------
 1 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index dcde7b1..faae5ba 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1136,26 +1136,20 @@ static int _registered_device(struct message_data *message_data,
 }
 
 static int _want_registered_device(char *dso_name, char *device_uuid,
-				  struct thread_status *thread)
+				   struct thread_status *thread)
 {
 	/* If DSO names and device paths are equal. */
 	if (dso_name && device_uuid)
 		return !strcmp(dso_name, thread->dso_data->dso_name) &&
-		    !strcmp(device_uuid, thread->device.uuid) &&
-			(thread->status == DM_THREAD_RUNNING ||
-			 (thread->events & DM_EVENT_REGISTRATION_PENDING));
+		    !strcmp(device_uuid, thread->device.uuid);
 
 	/* If DSO names are equal. */
 	if (dso_name)
-		return !strcmp(dso_name, thread->dso_data->dso_name) &&
-			(thread->status == DM_THREAD_RUNNING ||
-			 (thread->events & DM_EVENT_REGISTRATION_PENDING));
+		return !strcmp(dso_name, thread->dso_data->dso_name);
 
 	/* If device paths are equal. */
 	if (device_uuid)
-		return !strcmp(device_uuid, thread->device.uuid) &&
-			(thread->status == DM_THREAD_RUNNING ||
-			 (thread->events & DM_EVENT_REGISTRATION_PENDING));
+		return !strcmp(device_uuid, thread->device.uuid);
 
 	return 1;
 }


