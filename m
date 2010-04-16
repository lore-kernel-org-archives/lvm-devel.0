From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 16 Apr 2010 07:07:27 -0400
Subject: [PATCH] Add creation of dev/mapper/control to nightly tests.
In-Reply-To: <20100416005830.GS13021@agk-dp.fab.redhat.com>
References: <1271363998-4897-1-git-send-email-dwysocha@redhat.com>
	<20100416005830.GS13021@agk-dp.fab.redhat.com>
Message-ID: <1271416047.2472.0.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, 2010-04-16 at 01:58 +0100, Alasdair G Kergon wrote:
> On Thu, Apr 15, 2010 at 04:39:58PM -0400, Dave Wysochanski wrote:
> > +	minor=`cat /proc/misc | grep device-mapper | awk '{print $1}'`
> > +	mknod $DM_DEV_DIR/mapper/control c 10 $minor
>   
> Just to be clear, I don't want to see this hack enter the tree, and the problem
> is in the machine's configuration, not the test scripts.  At this stage we are
> not trying to test the selinux policy through these scripts. Maybe we can
> do that soon: I don't think it would be very hard to do.
> 
> If you enable selinux, then you abide by its restrictions.
> If you really don't like the default policy (which sensibly doesn't let
> you run tests like these in /tmp) you change it ('semanage fcontext' on
> the top-level testing dir).
> 

Sure - I will work on a better patch.


