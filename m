From: Petr Rockai <prockai@redhat.com>
Date: Fri, 18 Nov 2011 21:28:02 +0100
Subject: [PATCH] Fix RHBZ 754198 (multiple dmeventd snapshot extensions)
In-Reply-To: <20111118195656.GX3294@agk-dp.fab.redhat.com> (Alasdair
	G. Kergon's message of "Fri, 18 Nov 2011 19:56:56 +0000")
References: <87pqgtxczr.fsf@aldalome.int.mornfall.net.>
	<20111116012039.GB3294@agk-dp.fab.redhat.com>
	<87ehx8xv43.fsf@aldalome.int.mornfall.net.>
	<20111116105953.GD3294@agk-dp.fab.redhat.com>
	<20111116130734.GE3294@agk-dp.fab.redhat.com>
	<87y5vdwydx.fsf@aldalome.int.mornfall.net.>
	<4EC6927B.4000402@redhat.com>
	<87obw9w6vv.fsf@aldalome.int.mornfall.net.>
	<20111118195656.GX3294@agk-dp.fab.redhat.com>
Message-ID: <87k46xw4z1.fsf@aldalome.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon <agk@redhat.com> writes:

> On Fri, Nov 18, 2011 at 08:46:44PM +0100, Peter Rockai wrote:
>> that lvconvert did
>> not change anything. We don't know 2 and wrongly assume that nothing
>> changes, ever (that's the bug).
>
> Yes, and we can detect 2 from the status line by checking whether the
> device size changed, avoiding the need for the new exit code.

Which is exactly what I proposed two mails back as a workaround for not
being able to use the exit code. So is that the preferred solution?

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined


