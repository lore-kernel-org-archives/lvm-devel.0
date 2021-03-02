From: David Teigland <teigland@redhat.com>
Date: Mon, 1 Mar 2021 18:40:51 -0600
Subject: [PATCH LVM2 v1 2/2] lvmlockctl: Automatically handle failure
In-Reply-To: <20210225110451.175956-2-leo.yan@linaro.org>
References: <20210225110451.175956-1-leo.yan@linaro.org>
	<20210225110451.175956-2-leo.yan@linaro.org>
Message-ID: <20210302004051.GA20678@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Feb 25, 2021 at 07:04:51PM +0800, Leo Yan wrote:
> From: Zhang Huan <zhanghuan@huayun.com>
> 
> When the lock manager detects drive failure, it invokes command
> "lvmlockctl" to handle the faiulre; in this case, lvmlockctl
> automatically calls "blkdeactivate -l forcevg" to deactivate VG
> and calls drop_vg() to cleanup the lockspace.

Hi, I have a couple commits to replace this one, which make it
configurable.  There are a couple small things left to look at.
See this branch:

https://sourceware.org/git/?p=lvm2.git;a=shortlog;h=refs/heads/dev-dct-lvmlockctl-kill-1

I've been testing this by just setting lvm.conf
	lvmlockctl_kill_command="vgchange -an"
and running lvmlockctl --kill <vgname>

We'll likely leave lvmlockctl_kill_command empty (disabled) by default for
now, with a suggestion to consider the blkdeactivate command.

Dave


