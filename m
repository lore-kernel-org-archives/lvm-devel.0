From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 5 Oct 2011 12:49:15 +0100
Subject: [PATCH v3 01/18] fsadm: Add new commands create, list, add and remove
In-Reply-To: <alpine.LFD.2.00.1110051254330.4423@dhcp-27-109.brq.redhat.com>
References: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
	<1317130971-24173-2-git-send-email-lczerner@redhat.com>
	<4E8AD4CF.3080609@redhat.com>
	<alpine.LFD.2.00.1110041336440.4206@dhcp-27-109.brq.redhat.com>
	<4E8B3DE5.2080803@redhat.com>
	<alpine.LFD.2.00.1110050932530.4423@dhcp-27-109.brq.redhat.com>
	<4E8C1E02.9090308@redhat.com>
	<alpine.LFD.2.00.1110051107420.4423@dhcp-27-109.brq.redhat.com>
	<20111005102750.GE32692@agk-dp.fab.redhat.com>
	<alpine.LFD.2.00.1110051254330.4423@dhcp-27-109.brq.redhat.com>
Message-ID: <20111005114915.GF32692@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Oct 05, 2011 at 01:21:17PM +0200, Lukas Czerner wrote:
> On Wed, 5 Oct 2011, Alasdair G Kergon wrote:
> >   --force is meant to mean 'permit operations that might not always be wise but
> > sometimes do need to be done - assume the user knows what they are doing'.
> > Normally a warning of what will happen is issued and confirmation is required,
> > but --yes can be used to avoid that confirmation.
 
> Do you mean --force in the last sentence ?
 
No, I meant --yes.

It works like this:

  If you use --yes, you will not be asked any questions.
  Where the code would otherwise have issued a question, it proceeds as if you
answered 'yes, do it'.

If you use --force, it can open up *extra* things the code allows to happen.
Without it, the code would just give an error 'I'm not going to let you do that'.


So, the number of --force options supplied controls *what* the code lets you do.

--yes just controls whether or not you get interactive prompts advising you
what will happen and giving you chances to bail out.

> The first misunderstanding was the use of -f in lvm toos. Because I can
> not see -y|--yes in the documentation I simply used force for not asking
> questions about active volumes to be removed. This can be fixed, if '-y'
> really works.
 
I can see things missing from the man pages...

> The other is, that using -y option to answer yes to umount mounted file
> system to be checked is ok, but then running fsck with that '-y' option
> does not make sense and it is also dangerous. But Zdenek is convinced
> that it has to stay there (I say it is a bug).

Well what we could do there is:
  --yes  only:  we do NOT supply -y to fsck.  (Ideally we'd like to choose
non-interactive options though i.e. if it hits something that would
normally require an interactive response, then instead of prompting,
fail the operation.  Perhaps -y should map to 'fsck -n' OR 'fsck -p'?
It should be non-interactive AND safe.)

  --force --yes: This could perhaps map to -y, if there's a case
for that.  Or perhaps '--force --force --yes'

> lvresize as well, where you have to use "--nofsck" (which is broken btw).
 
The reason for --nofsck is if you *know* the filesystem is ok because you
already ran a check (for example).  But if the fs is indeed ok, won't a basic
fsck be fast anyway, (just checking fs state in superblock rather than
performing a full check) such that it doesn't matter if it gets run again?

Alasdair


