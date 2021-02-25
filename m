From: Leo Yan <leo.yan@linaro.org>
Date: Thu, 25 Feb 2021 19:11:47 +0800
Subject: Question: the failure handling for sanlock
In-Reply-To: <20210224182101.GD4136@redhat.com>
References: <20210214101303.GA399193@leoy-ThinkPad-X240s>
	<20210215163127.GA25608@redhat.com>
	<20210224031630.GB25715@leoy-ThinkPad-X240s>
	<20210224182101.GD4136@redhat.com>
Message-ID: <20210225111147.GB160939@leoy-ThinkPad-X240s>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Feb 24, 2021 at 12:21:01PM -0600, David Teigland wrote:

[...]

> Thanks for verifying that, please send the patches to the list and I'll
> take them from there.

Have sent out the patches for reviewing:
https://listman.redhat.com/archives/lvm-devel/2021-February/msg00143.html

Just remind, I saw Zhuang Huan mentioned in the original patch for
"disabling queueing on multipath device", this part I have no
knowledge for how to handle it, so I left it out in the latest patch.
Please note this when review the patch.

> Another part I now remember we need to address is
> making this configurable (blkdeactivate isn't an established command.)
> I'll need to come up with a solution to that before pushing them out.  The
> possible solutions I'm seeing are somewhat ugly, and this is one of the
> reasons we didn't finish the integration last time.

Seems to me, we need to add some configurations in lvm.conf and can
teach lvmlockctl to do automatic handling for failure or bypass the
relevant operations.   If need me to follow up anything for this, let
me know.

Thanks,
Leo


