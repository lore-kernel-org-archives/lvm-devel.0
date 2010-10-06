From: Petr Rockai <prockai@redhat.com>
Date: Wed, 06 Oct 2010 16:07:13 +0200
Subject: [PATCH] dmeventd -R (restart; BZ 454618)
In-Reply-To: <20101005234945.GG1200@agk-dp.fab.redhat.com> (Alasdair
	G. Kergon's message of "Wed, 6 Oct 2010 00:49:45 +0100")
References: <87sk0kncit.fsf@twilight.int.mornfall.net.>
	<BCC2498C-1B82-4462-A9FE-27823E22DEA2@redhat.com>
	<20101005234945.GG1200@agk-dp.fab.redhat.com>
Message-ID: <87bp77l8j2.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Alasdair G Kergon <agk@redhat.com> writes:

>>> +	kill(pid, 9);
>
> I'm paranoid about code like that, and want to see everything reasonably
> possible done to ensure it can only kill the process it should and
> any possible races are clearly documented and defended against.

the attached version avoids the kill, instead relying on the remote end
committing suicide upon a special DIE message. It turns out to simplify
the code as well, at the expense of having to modify the lock-file
function slightly (it now tries a little harder, waiting for a couple
seconds before failing, periodically re-trying to grab the lock). This
also addresses some (all?) of the races.

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: dmeventd-restart.diff
Type: text/x-diff
Size: 13298 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20101006/6f8a6340/attachment.bin>
