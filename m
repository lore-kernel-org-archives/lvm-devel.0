From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Fri, 09 Jul 2010 15:20:07 +0200
Subject: [PATCH] pid files cleanup
In-Reply-To: <20100709131139.GY22664@agk-dp.fab.redhat.com>
References: <4C36E604.6090106@redhat.com>
	<20100709131139.GY22664@agk-dp.fab.redhat.com>
Message-ID: <4C372207.9060107@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 7/9/2010 3:11 PM, Alasdair G Kergon wrote:
> On Fri, Jul 09, 2010 at 11:04:04AM +0200, Fabio M. Di Nitto wrote:
>> - I had some issues to build dmeventd that I need to investigate
>> locally. dmeventd also needs to be ported (if possible) to use the
>> library implementation of create_lockfile().
>  
> dmeventd is part of dm not lvm so has no access to lvm_internal!
> 
> For dmeventd to use the code, you need to move it into libdevmapper.
> The function then needs a dm_ prefix and goes into libdm-file.c

Ok. Unless there is more than one dm-daemon, there is no benefit to move
it there.

Fabio


