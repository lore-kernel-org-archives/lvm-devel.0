From: Leo Yan <leo.yan@linaro.org>
Date: Wed, 3 Mar 2021 11:48:50 +0800
Subject: [PATCH LVM2 v1 2/2] lvmlockctl: Automatically handle failure
In-Reply-To: <20210302175201.GA27341@redhat.com>
References: <20210225110451.175956-1-leo.yan@linaro.org>
	<20210225110451.175956-2-leo.yan@linaro.org>
	<20210302004051.GA20678@redhat.com>
	<20210302175201.GA27341@redhat.com>
Message-ID: <20210303034811.GA12320@leoy-ThinkPad-X240s>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi David,

On Tue, Mar 02, 2021 at 11:52:01AM -0600, David Teigland wrote:
> After some more changes this seems to be about done, please let me know if
> this works for you.  I'm thinking about holding off on the blkdeactivate
> change for a while to see if we can get a better alternative in the near
> term (to avoid carrying the temporary forcevg option.)
> 
> https://sourceware.org/git/?p=lvm2.git;a=shortlog;h=refs/heads/dev-dct-lvmlockctl-kill-2

I verified the patches on the branch "dev-dct-lvmlockctl-kill-2",
below is the testing result.

With setting the lvm.conf with config:

  lvmlockctl_kill_command = "blkdeactivate -l forcevg"

After the failure happened, the device-mapper will be set to "error"
target and the lockspace for the failed VG will be removed.  So I
can confirm the failure handling is expected.

But I found the building failure which is caused by the patch
"lvmlockctl: use lvm.conf lvmlockctl_kill_command", you should include
below change:

diff --git a/include/configure.h.in b/include/configure.h.in
index 812cacc..9e7b127 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -643,6 +643,9 @@
 /* Path to lvm binary. */
 #undef LVM_PATH
 
+/* Path to lvm binary dir. */
+#undef LVM_DIR
+
 /* Define to 1 if `major', `minor', and `makedev' are declared in <mkdev.h>.
    */
 #undef MAJOR_IN_MKDEV


Thank you a lot!

Leo


