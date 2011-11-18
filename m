From: Petr Rockai <prockai@redhat.com>
Date: Fri, 18 Nov 2011 22:19:08 +0100
Subject: [PATCH] Fix RHBZ 754198 (multiple dmeventd snapshot extensions)
In-Reply-To: <87k46xw4z1.fsf@aldalome.int.mornfall.net.> (Petr Rockai's
	message of "Fri, 18 Nov 2011 21:28:02 +0100")
References: <87pqgtxczr.fsf@aldalome.int.mornfall.net.>
	<20111116012039.GB3294@agk-dp.fab.redhat.com>
	<87ehx8xv43.fsf@aldalome.int.mornfall.net.>
	<20111116105953.GD3294@agk-dp.fab.redhat.com>
	<20111116130734.GE3294@agk-dp.fab.redhat.com>
	<87y5vdwydx.fsf@aldalome.int.mornfall.net.>
	<4EC6927B.4000402@redhat.com>
	<87obw9w6vv.fsf@aldalome.int.mornfall.net.>
	<20111118195656.GX3294@agk-dp.fab.redhat.com>
	<87k46xw4z1.fsf@aldalome.int.mornfall.net.>
Message-ID: <87ehx5w2lv.fsf@aldalome.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Petr Rockai <prockai@redhat.com> writes:
> Which is exactly what I proposed two mails back as a workaround for not
> being able to use the exit code. So is that the preferred solution?

the attached patch implements this second approach.

Petr

-------------- next part --------------
A non-text attachment was scrubbed...
Name: dmeventd-snapshot-fix.diff
Type: text/x-diff
Size: 4528 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20111118/81ab7495/attachment.bin>
-------------- next part --------------

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined
