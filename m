From: Jim Meyering <jim@meyering.net>
Date: Thu, 14 Feb 2008 14:26:28 +0100
Subject: [PATCH] Remove redundant if-before-free tests.
In-Reply-To: <871w7fit3o.fsf@rho.meyering.net> (Jim Meyering's message of
	"Thu, 14 Feb 2008 14:07:55 +0100")
References: <871w7fit3o.fsf@rho.meyering.net>
Message-ID: <87lk5nhdob.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

[as I just wrote to lvm-devel:
  http://www.redhat.com/archives/lvm-devel/2008-February/msg00017.html ]

Jim Meyering <jim@meyering.net> wrote:
> Since "free (NULL);" is universally safe these days, I propose
> to remove all of lvm's redundant "if-before-free" tests.
> If no one objects, I'll commit it tonight.
>
> In case you need more justification than "POSIX requires it",
> (understandable, that :-), the following was enough for Wine
> development a year and a half ago:
>
>     http://www.winehq.org/pipermail/wine-patches/2006-October/031544.html
>
> Sure, the extra test is not a big deal, but removing it does make the
> code slightly smaller, and maybe even more readable (people won't wonder
> about the test of such a pointer, when they know that free can handle
> a NULL pointer).

Same for dm, but here there are only 3:

---
 dmeventd/old/dmevent.c               |    6 ++----
 multilog/pthread_lock/pthread_lock.c |    3 +--
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/dmeventd/old/dmevent.c b/dmeventd/old/dmevent.c
index 6e9eb46..5d80410 100644
--- a/dmeventd/old/dmevent.c
+++ b/dmeventd/old/dmevent.c
@@ -220,10 +220,8 @@ int main(int argc, char **argv)
    out:
 	multilog_del_type(standard);

-	if (device)
-		free(device);
-	if (dso_name)
-		free(dso_name);
+	free(device);
+	free(dso_name);

 	exit(ret);
 }
diff --git a/multilog/pthread_lock/pthread_lock.c b/multilog/pthread_lock/pthread_lock.c
index b782301..c52050b 100644
--- a/multilog/pthread_lock/pthread_lock.c
+++ b/multilog/pthread_lock/pthread_lock.c
@@ -62,7 +62,6 @@ int unlock_fn(void *handle)
 void destroy_locking(void *handle)
 {
         pthread_mutex_t *mutex = (pthread_mutex_t *)handle;
-	if(mutex)
-		free(mutex);
+	free(mutex);
 }

--
1.5.4.1.98.gf3293


