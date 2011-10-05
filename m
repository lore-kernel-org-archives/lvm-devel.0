From: Lukas Czerner <lczerner@redhat.com>
Date: Wed, 5 Oct 2011 13:26:16 +0200 (CEST)
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
Message-ID: <alpine.LFD.2.00.1110051324250.4423@dhcp-27-109.brq.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, 5 Oct 2011, Lukas Czerner wrote:

> On Wed, 5 Oct 2011, Alasdair G Kergon wrote:
> 
> > On Wed, Oct 05, 2011 at 11:46:45AM +0200, Lukas Czerner wrote:
> > > On Wed, 5 Oct 2011, Zdenek Kabelac wrote:
> > > > Dne 5.10.2011 10:02, Lukas Czerner napsal(a):
> > > > > On Tue, 4 Oct 2011, Zdenek Kabelac wrote:
> > > > > > Dne 4.10.2011 14:13, Lukas Czerner napsal(a):
> > > > > > > On Tue, 4 Oct 2011, Zdenek Kabelac wrote:
> >  
> 
> Hi Alasdair,
> 
> > You both lost me several messages ago!
> > 
> > For *changes* to functionality, what I'm looking for is:
> > 
> >   Description of how it works today in *all* relevant code paths/option
> > combinations/invocation methods;
> > 
> >   Description/explanation of how it will work *after* the change has been made
> > in all the same cases as now plus any new ones
> > 
> > Explanation of/justification for the difference.
> > 
> > Currently in lvm:
> > 
> >   --yes is meant to mean 'answer yes to all questions'
> > These are generally informative questions telling the user what the tool will do
> > and seeking confirmation.  On its own, they should not be dangerous or risk
> > corruption.  Example: removing an LV that is active but not currently being used.
> > The idea of such questions is to point out to the user the actual consequences
> > of the command to help to make sure they understand what will happen.

Btw, there is no such option in lvm. It is not documented and it does
not work, at least for vgremove and lvremove. However it does work in
pvremove, also it is documented there.

> > 
> >   --force is meant to mean 'permit operations that might not always be wise but
> > sometimes do need to be done - assume the user knows what they are doing'.
> > Normally a warning of what will happen is issued and confirmation is required,
> > but --yes can be used to avoid that confirmation.
> 
> Do you mean --force in the last sentence ?
> 
> > 
> > For dangerous things that wouldn't normally make sense but occasionally can be
> > justified, like destroying PVs while they are in (inactive) VGs, --force can be
> > required to be repeated twice.
> > 
> > 
> > Now, let's try to understand:
> >   How these options are currently used in fsadm-related tools;
> >   What's good/bad here and perhaps ought to change.
> > 
> > Alasdair
> > 
> 
> The first misunderstanding was the use of -f in lvm toos. Because I can
> not see -y|--yes in the documentation I simply used force for not asking
> questions about active volumes to be removed. This can be fixed, if '-y'
> really works.
> 
> The other is, that using -y option to answer yes to umount mounted file
> system to be checked is ok, but then running fsck with that '-y' option
> does not make sense and it is also dangerous. But Zdenek is convinced
> that it has to stay there (I say it is a bug).
> 
> And lastly, the problem with using --force to skip the fsck before
> attempt to resize the file system. Using force in my opinion does not
> imply skipping fsck, and I believe that is how it is implemented in
> lvresize as well, where you have to use "--nofsck" (which is broken btw).
> 
> I believe that fscking file system before the resize is the right thing
> to do and I do not see any reason to allow it to be overridden in fsadm,
> although we probably should check for 'last mount' and 'last check' fs
> attributes to see if it was checked after the last mount and fsck it
> otherwise.
> 
> Generally the problem is that we could not agree on almost anything and
> due to 'it stays as it is, deal with it' altitude it seems to be that
> even the discussion is not allowed.
> 
> Honestly, when I started to poke the fsadm I quickly realized that if I
> am going to improve the functionality in the bigger scale, it will be
> more and more painful to do this in Bash. So maybe it will be easier for
> both sides to just forget about fsadm and make a separate project for
> example in Python. Because after all I would like this tool to be able
> to manage btrfs as well someday and since that does not have anything to
> do with lvm, I fear that it will be a major problem to get this into
> upstream fsadm. So what people think ?
> 
> Thanks!
> -Lukas
> 

-- 


