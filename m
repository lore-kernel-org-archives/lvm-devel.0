From: Eric Ren <zren@suse.com>
Date: Wed, 9 Aug 2017 18:11:24 +0800
Subject: lvmlockd: adopt locks always failed
In-Reply-To: <20170808142815.GA29769@redhat.com>
References: <107b2602-3918-fdbe-6645-da7a2c29e0e9@suse.com>
	<20170807154739.GB4875@redhat.com>
	<59570f35-a284-dca3-983b-22bf3addf4f7@suse.com>
	<20170808142815.GA29769@redhat.com>
Message-ID: <a2869716-d1c9-868f-0e70-134852b25404@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,


On 08/08/2017 10:28 PM, David Teigland wrote:
> On Tue, Aug 08, 2017 at 10:03:58AM +0800, Eric Ren wrote:
>> I add a resource agent for lvmlockd. It would be great if you can give some
>> review and comments there ;-P  The PR is here:
>>
>> https://github.com/ClusterLabs/resource-agents/pull/1013
> Hi, thanks for working on that, resource agents have always seemed mostly
> redundant to me, so I'm not one to give the best feedback.

Yeah, agree. But, many resource agents are still created for daemons
that already have systemd service though, like dlm, clvm, etc. It seems
HA software wants to manage these daemons itself. Anyway, just provide
a another option for HA users who used to stack resource agents ;-P

> You could simplify things by just starting lvmlockd from systemd during
> system startup using
> https://sourceware.org/git/?p=lvm2.git;a=blob_plain;f=scripts/lvm2_lvmlockd_systemd_red_hat.service.in;hb=HEAD
>
> since there's no clustering dependency on doing that, i.e. no problem
> starting the daemon before clustering components are started.  It doesn't
> actually do anything until you start shared VGs.

Thanks, I didn't notice this point before.

>
> I think we could make lock-adoption the default during startup.  I may
> change the default in lvmlockd itself.  You always want to adopt locks if
> they exist; things aren't going to work if you restart lvmlockd without
> adopting locks when previous orphaned locks exist.  However, I'm not sure
> that resource agents will be sophisticated enough to restart lvmlockd and
> adopt locks after a previous instance failed; they've always seemed eager
> to just reset the node.

Yes, I also realized that. In the resource agent, I've added "-A 1" when 
starting the daemon.

>
> Once the clustering system is running (in particular the dlm), you can
> then start and use shared VGs.  You could use or copy this unit file for
> that:
>
> https://sourceware.org/git/?p=lvm2.git;a=blob_plain;f=scripts/lvm2_lvmlocking_systemd_red_hat.service.in;hb=HEAD
>
> For activation, you need to use vgchange -aay to specify auto-activation.

OK, thanks.  For the resource agent, we can select "-aay" way as 
default, while providing the option to
activate all shared VGs when users have many shared VGs and they don't 
want to add them into
lvm.conf manually.

> You're also including 's' to activate LVs with a shared lock, but it's
> only safe to do that if you have a cluster file system on the LV.  If you
> don't have a way to know that, I've thought in the past that we could add
> a new lvm.conf list, similar to auto_activation_volume_list, that
> specifies which LVs should be activated with shared locks.  For
> deactivation, use -an, (the 'l' was a clvm-ism, and is meaningless with
> lvmlockd.)
Got it, thanks. I will change that ;-)

Regards,
Eric


