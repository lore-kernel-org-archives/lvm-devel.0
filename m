From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 22 Nov 2016 13:04:51 +0100
Subject: pending clvmd patches
In-Reply-To: <87a8crampc.fsf@lant.ki.iif.hu>
References: <87a8crampc.fsf@lant.ki.iif.hu>
Message-ID: <cf050105-a0bb-fc5f-d938-67b3ae0e4cd0@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 22.11.2016 v 10:27 Ferenc W?gner napsal(a):
> Hi,
>
> Last year there were (at least) two clvmd patches sent to this list
> which haven't received any review or comment:
>


Hi

Here are my comments:

> clvmd: send readiness notification to systemd
> (https://www.redhat.com/archives/lvm-devel/2015-October/msg00080.html)

I think on RHEL products the clmvd is controlled by pacemaker now, thus
activation of clvmd is not handled/maintained by systemd at all.
It's also quite nontrivial since automatic restarts in case of crashes
might not be 'wanted'

It's also unclear about which timeout is this trying to resolve,
normally clvmd is not linked with with systemd.

Could you more closely describe the workflow progress you try to resolved.
And if it would be really needed - extra configure option likely would
be useful to control 'linkage' with systemd library.

>
> and
>
> clvmd: fix memory corruption
> (https://www.redhat.com/archives/lvm-devel/2015-December/msg00056.html)
>
> Both apply cleanly to current master.  As I depend on clvmd in some
> setups, I'd be grateful to hear some upstream comments about these.


Hmm, could you please provide the actual 'valgrind' report?

If there is a design flow it should likely be addressed on locking level. 
Cleanup zombie was introduced to not touch memory in-use. So adding 'extra' 
dm_list looks like hiding some other bug on the first sight.


Regards

Zdenek





