From: David Teigland <teigland@redhat.com>
Date: Tue, 8 Aug 2017 09:28:15 -0500
Subject: lvmlockd: adopt locks always failed
In-Reply-To: <59570f35-a284-dca3-983b-22bf3addf4f7@suse.com>
References: <107b2602-3918-fdbe-6645-da7a2c29e0e9@suse.com>
	<20170807154739.GB4875@redhat.com>
	<59570f35-a284-dca3-983b-22bf3addf4f7@suse.com>
Message-ID: <20170808142815.GA29769@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Aug 08, 2017 at 10:03:58AM +0800, Eric Ren wrote:
> I add a resource agent for lvmlockd. It would be great if you can give some
> review and comments there ;-P  The PR is here:
> 
> https://github.com/ClusterLabs/resource-agents/pull/1013

Hi, thanks for working on that, resource agents have always seemed mostly
redundant to me, so I'm not one to give the best feedback.

You could simplify things by just starting lvmlockd from systemd during
system startup using
https://sourceware.org/git/?p=lvm2.git;a=blob_plain;f=scripts/lvm2_lvmlockd_systemd_red_hat.service.in;hb=HEAD

since there's no clustering dependency on doing that, i.e. no problem
starting the daemon before clustering components are started.  It doesn't
actually do anything until you start shared VGs.

I think we could make lock-adoption the default during startup.  I may
change the default in lvmlockd itself.  You always want to adopt locks if
they exist; things aren't going to work if you restart lvmlockd without
adopting locks when previous orphaned locks exist.  However, I'm not sure
that resource agents will be sophisticated enough to restart lvmlockd and
adopt locks after a previous instance failed; they've always seemed eager
to just reset the node.

Once the clustering system is running (in particular the dlm), you can
then start and use shared VGs.  You could use or copy this unit file for
that:

https://sourceware.org/git/?p=lvm2.git;a=blob_plain;f=scripts/lvm2_lvmlocking_systemd_red_hat.service.in;hb=HEAD

For activation, you need to use vgchange -aay to specify auto-activation.
You're also including 's' to activate LVs with a shared lock, but it's
only safe to do that if you have a cluster file system on the LV.  If you
don't have a way to know that, I've thought in the past that we could add
a new lvm.conf list, similar to auto_activation_volume_list, that
specifies which LVs should be activated with shared locks.  For
deactivation, use -an, (the 'l' was a clvm-ism, and is meaningless with
lvmlockd.)

Dave


