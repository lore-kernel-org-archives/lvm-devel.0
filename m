From: Takahiro Yasui <tyasui@redhat.com>
Date: Fri, 18 Dec 2009 13:25:38 -0500
Subject: [PATCH 2 of 4] Handle transient secondary mirror leg failures
In-Reply-To: <178B089F-0B8A-47B5-9DA8-75AC3ACE86EA@redhat.com>
References: <patchbomb.1260695922@localhost>	<1e369d480df09d0fac6c.1260695924@localhost>
	<178B089F-0B8A-47B5-9DA8-75AC3ACE86EA@redhat.com>
Message-ID: <4B2BC922.8040506@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 12/18/09 12:10, Jonathan Brassow wrote:
> 2) If you don't get a new table loaded, it will behave as a suspend/ 
> resume only.  Recent code changes in dm-raid1.c are causing  
> 'log_failure' and 'leg_failure' to not be reset in those cases.  IOW,  
> all these steps could be for nothing.  :(

I would like to know how effective the retry is. As Jon explained
above, recent upstream kernel blocks all write I/Os on NOSYNC regions.
This means that those write I/Os are kept blocked for a long time.
For example, mirror retry interval in your patch #4 is 30 seconds and
application or  filesystem will be waited for 30 seconds (330 seconds
if retry count is 10). Can your application wait for more than 5 minutes?

This behaviour will not been solved even if kernel is fixed so that
log_failure and leg_failure are reset. The write I/Os blocked will
be re-queued in the kernel when suspend/resume are done, but they
will be put in the hold queue again if the device failure is not
transient but permanent.

I would like to know the use case of this patch set.

Thanks,
Taka


