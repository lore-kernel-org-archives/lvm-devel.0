From: Ferenc Wágner <wferi@niif.hu>
Date: Tue, 22 Nov 2016 16:31:08 +0100
Subject: pending clvmd patches
In-Reply-To: <cf050105-a0bb-fc5f-d938-67b3ae0e4cd0@redhat.com> (Zdenek
	Kabelac's message of "Tue, 22 Nov 2016 13:04:51 +0100")
References: <87a8crampc.fsf@lant.ki.iif.hu>
	<cf050105-a0bb-fc5f-d938-67b3ae0e4cd0@redhat.com>
Message-ID: <87oa178rb7.fsf@lant.ki.iif.hu>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Zdenek Kabelac <zkabelac@redhat.com> writes:

> Dne 22.11.2016 v 10:27 Ferenc W?gner napsal(a):
>
>> Last year there were (at least) two clvmd patches sent to this list
>> which haven't received any review or comment:
>
> Here are my comments:

Thanks for the prompt and through reply, much appreciated!

>> clvmd: send readiness notification to systemd
>> (https://www.redhat.com/archives/lvm-devel/2015-October/msg00080.html)
>
> I think on RHEL products the clmvd is controlled by pacemaker now,
> thus activation of clvmd is not handled/maintained by systemd at all.

On RHEL 7 the supported configuration is indeed starting clvmd via an
appropriate resource agent.  I really wonder what's behind this
recommendation, and why lvm2_cluster_activation_systemd_red_hat.service
requires lvm2_clvmd regardless.

> It's also quite nontrivial since automatic restarts in case of crashes
> might not be 'wanted'

Well, that's exactly what the resource agent would do in such cases,
only with the added monitoring delay (over systemd).  Both are easy to
reconfigure if needed.  In what circumstances is restarting a crashed
clvmd not wanted?

> It's also unclear about which timeout is this trying to resolve,

I meant the start timeout (specified via -T) inside clvmd and the
TimeoutStartSec setting in the service file.  Both are 30 seconds in the
service file, which is a perfect race in itself and an arbitrary choice.
Using Type=notify simplifies many things (for example there's no need
for a PID file) enables disabling TimeoutStartSec (which is missing from
my patch, but forcibly killing clvmd usually means leaving behind
abandoned lock spaces requiring reboot to clean up) and gives systemd
correct feedback about the daemon status.

> normally clvmd is not linked with with systemd.

More precisely, libsystemd.  It shouldn't cause any problems, but the
notify function is simple to implement in-house if absolutely necessary.
(It used to be distrubuted in an additional .c file in the beginning.)

> Could you more closely describe the workflow progress you try to resolved.

In short, I'd like to make the resource manager optional in GFS2 setups.
This requires dependable ordering between the participating systemd
units (corosync, dlm and clvmd), and the simplifications enabled by
Type=notify come very useful for this.

> And if it would be really needed - extra configure option likely would
> be useful to control 'linkage' with systemd library.

That's no problem, just specify the required semantics.  Currently
libsystemd presence is detected automatically during configuration.  The
systemd service file also depends on this functionality (as illustrated
in my patch), so this must be handled as well.

>> clvmd: fix memory corruption
>> (https://www.redhat.com/archives/lvm-devel/2015-December/msg00056.html)
>
> Hmm, could you please provide the actual 'valgrind' report?

Unfortunately no, I'm not affiliated with this patch and report.  Shall
I resend your query to Andrew Elble <aweits@rit.edu>? 
-- 
Thanks,
Feri


