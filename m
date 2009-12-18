From: malahal@us.ibm.com <malahal@us.ibm.com>
Date: Fri, 18 Dec 2009 10:35:40 -0800
Subject: [PATCH 2 of 4] Handle transient secondary mirror leg failures
In-Reply-To: <178B089F-0B8A-47B5-9DA8-75AC3ACE86EA@redhat.com>
References: <patchbomb.1260695922@localhost>
	<1e369d480df09d0fac6c.1260695924@localhost>
	<178B089F-0B8A-47B5-9DA8-75AC3ACE86EA@redhat.com>
Message-ID: <20091218183540.GA23597@us.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jonathan Brassow [jbrassow at redhat.com] wrote:
> hmmm, I wonder how well this is going to work.
> 
> 1) I've seen code ('dm_task_suppress_identical_reload') that  
> suppresses table reloads if the tables are identical - will that  
> obstruct what you are trying to do here?
> 
> 2) If you don't get a new table loaded, it will behave as a suspend/ 
> resume only.  Recent code changes in dm-raid1.c are causing  
> 'log_failure' and 'leg_failure' to not be reset in those cases.  IOW,  
> all these steps could be for nothing.  :(

Initially I did test with a modified dm-raid1.c that reset the device
status (error count too) in resume() function. I wasn't using "dmsetup
reload" at that time. Later, I did add "dmsetup reload" and removed my
patch in dm-raid1.c.

It worked fine, so either I am not hitting
dm_task_suppress_identical_reload or some how I failed to revert my
patch in the kernel.

> 3) How does this work in a cluster?  dmsetup is not cluster-aware.  If  
> you don't go through the LVM commands (I recognize the additional  
> pain), none of this will be coordinated.

Tried to use "lvchange --refresh" and that didn't work too well. In the
last call, Alasdair indicated I should add something like
"--top-layer-only" option to "lvchange --refresh" command.

Thank you for the review.

--Malahal.


