From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon, 19 Jul 2010 15:02:50 -0500
Subject: [PATCH] check for running cluster log daemon, not just log module
In-Reply-To: <20100716161656.GA6506@agk-dp.fab.redhat.com>
References: <1279291187.4957.2.camel@hydrogen.msp.redhat.com>
	<20100716161656.GA6506@agk-dp.fab.redhat.com>
Message-ID: <1F3F1266-F403-4350-8669-F3186B4EA0B9@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Jul 16, 2010, at 11:16 AM, Alasdair G Kergon wrote:

> On Fri, Jul 16, 2010 at 09:39:47AM -0500, Jon Brassow wrote:
>> +int dm_daemon_is_running(const char* lockfile)
>
>> +	/* Should we also read and check pid? */
>
> Yes - check /proc/<pid>/fd/*  if available?
>
> (cf. _get_filename in tools/lvmcmdline.c)


I'm not certain how best to go about this, because the function takes  
a generic argument - it doesn't specifically look for 'cmirrord'.  So,  
unless the PID filename is guaranteed to follow a convention that  
includes the executable name, I'm not sure how to do more than just  
validate that /a/ process is running and has the appropriate lock.   
Sure, I could look-up a pid to see the cmdline and check that against  
the name of a daemon, but that isn't what we have available.  I could  
check that at least the pid in the file is in the system, but that  
doesn't gain us anything.

One possible solution is to be less generic and simply make a function  
called 'dm_cmirrord_is_running', or something.  Then I could correlate  
pid, cmdline, and executable name.

I am considering checking in the patch 'as is' and adding any  
additional testing in a separate commit if it proves useful.

  brassow


