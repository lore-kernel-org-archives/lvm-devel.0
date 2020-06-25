From: David Teigland <teigland@redhat.com>
Date: Thu, 25 Jun 2020 14:11:00 -0500
Subject: Question: LVM2 testing with sanlock lock manager
In-Reply-To: <20200625145523.GA23434@redhat.com>
References: <20200625093411.GB19777@leoy-ThinkPad-X240s>
	<20200625145523.GA23434@redhat.com>
Message-ID: <20200625191100.GA27855@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Jun 25, 2020 at 09:55:23AM -0500, David Teigland wrote:
> with sanlock.  I will try component-cache.sh to see if that's the issue,
> or something else.

I suspect that test is hitting an issue where a stray lock is being left
behind and blocking the test cleanup.  The test is using some unusual
commands, activating internal LVs that are usually disallowed.

I couldn't get the GL_DEV/GL_FILE stuff to work, with or without your
patches.  I removed all that and specified a literal sd device.  I'd
suggest we do that instead of the complicated attempt to automate it; i.e.
require a path to an unused device that the test will use for glvg.

Dave


