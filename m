From: Piter PUNK <piterpunk@unitednerds.org>
Date: Thu, 20 May 2010 18:38:06 -0300
Subject: [PATCH]: Remove the need of libdlm when using clvmd with OpenAIS
Message-ID: <4BF5ABBE.8040008@unitednerds.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I am compiling LVM with clustering support (clvmd) using
OpenAIS. The ./configure runs OK but, when doing the
compilation, I got a lot of errors about missing libdlm.h

clvmd-openais.c doesn't have any use of libdlm or libdlm
functions (the clvmd-cman.c and clvmd-corosync.c uses).

But the compilation stops because clvmd-command.c and
lvm-functions.c includes libdlm.h only to use some defined
constants, like LKM_EXMODE and LKF_NOQUEUE.

All these constants are defined on dlmconstants.h with
other names: LKM_EXMODE -> DLM_LOCK_EX.

This patch changes the constants found in clvmd-command.c
and lvm-functions.c to use the names in dlmconstants.h.
And to include linux/dlm.h instead libdlm.h.

With that, clvmd can compiles using OpenAIS locking
mechanism and without the need of libdlm (needed by the
other cluster managers).

I hope this patch are OK and can help other LVM users.

Thanks

Piter PUNK
-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: lvm-include_dlm.patch
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100520/1ed7747a/attachment.ksh>
