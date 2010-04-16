From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 16 Apr 2010 01:58:30 +0100
Subject: [PATCH] Add creation of dev/mapper/control to nightly tests.
In-Reply-To: <1271363998-4897-1-git-send-email-dwysocha@redhat.com>
References: <1271363998-4897-1-git-send-email-dwysocha@redhat.com>
Message-ID: <20100416005830.GS13021@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Apr 15, 2010 at 04:39:58PM -0400, Dave Wysochanski wrote:
> +	minor=`cat /proc/misc | grep device-mapper | awk '{print $1}'`
> +	mknod $DM_DEV_DIR/mapper/control c 10 $minor
  
Just to be clear, I don't want to see this hack enter the tree, and the problem
is in the machine's configuration, not the test scripts.  At this stage we are
not trying to test the selinux policy through these scripts. Maybe we can
do that soon: I don't think it would be very hard to do.

If you enable selinux, then you abide by its restrictions.
If you really don't like the default policy (which sensibly doesn't let
you run tests like these in /tmp) you change it ('semanage fcontext' on
the top-level testing dir).

Alasdair


