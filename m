From: Takahiro Yasui <tyasui@redhat.com>
Date: Mon, 22 Feb 2010 04:09:29 -0500
Subject: [PATCH 0 of 13] LVM add 'mirrored' log type
In-Reply-To: <1266429310.29358.35.camel@hydrogen.msp.redhat.com>
References: <1266429310.29358.35.camel@hydrogen.msp.redhat.com>
Message-ID: <4B8249C9.9060602@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jonathan Brassow wrote:
> I've fixed the segfaults Taka reported.  I've also begun to go through
> and fix the remaining issues with handling device failures in the
> various different scenarios.  I could use some help testing all the
> different variations.  I've described below some of the different
> permutations that will now exist.  I will be going through and testing
> these as well.

'lvconvert --repair' doen't work and canuses *deadlock*. when a VG contains
two PVs and one of PVs failed; This is a situation that a mirror leg and
one of mirrored logs broke at the same time.

When one of mirrored logs broke, I/Os to mirrored log are blocked and
kmirrord can't make forward until the log is fixed. However, lvocnvert
command tries to fix mirror legs before a mirrored log if a mirror leg
also broke.

During the procedure to fix a mirror leg, lv_suspend() is called in
_remove_mirror_images() and lv_suspend() which calls kernel function,
dm_suspend(), doesn't finish. Rough call trace is as follows:

  dm_suspend()
    mirror_presuspend()
      flush_workqueue()
        -> waiting kmirrored
           -> waiting I/O to its log

I think that an error recovery of a log device should be done before
mirror legs are recovered.

Thanks,
Taka


