From: David Teigland <teigland@redhat.com>
Date: Tue, 2 Mar 2021 11:52:01 -0600
Subject: [PATCH LVM2 v1 2/2] lvmlockctl: Automatically handle failure
In-Reply-To: <20210302004051.GA20678@redhat.com>
References: <20210225110451.175956-1-leo.yan@linaro.org>
	<20210225110451.175956-2-leo.yan@linaro.org>
	<20210302004051.GA20678@redhat.com>
Message-ID: <20210302175201.GA27341@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

After some more changes this seems to be about done, please let me know if
this works for you.  I'm thinking about holding off on the blkdeactivate
change for a while to see if we can get a better alternative in the near
term (to avoid carrying the temporary forcevg option.)

https://sourceware.org/git/?p=lvm2.git;a=shortlog;h=refs/heads/dev-dct-lvmlockctl-kill-2

Dave


