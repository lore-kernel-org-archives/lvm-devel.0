From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 5 Oct 2011 11:27:50 +0100
Subject: [PATCH v3 01/18] fsadm: Add new commands create, list, add and remove
In-Reply-To: <alpine.LFD.2.00.1110051107420.4423@dhcp-27-109.brq.redhat.com>
References: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
	<1317130971-24173-2-git-send-email-lczerner@redhat.com>
	<4E8AD4CF.3080609@redhat.com>
	<alpine.LFD.2.00.1110041336440.4206@dhcp-27-109.brq.redhat.com>
	<4E8B3DE5.2080803@redhat.com>
	<alpine.LFD.2.00.1110050932530.4423@dhcp-27-109.brq.redhat.com>
	<4E8C1E02.9090308@redhat.com>
	<alpine.LFD.2.00.1110051107420.4423@dhcp-27-109.brq.redhat.com>
Message-ID: <20111005102750.GE32692@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Oct 05, 2011 at 11:46:45AM +0200, Lukas Czerner wrote:
> On Wed, 5 Oct 2011, Zdenek Kabelac wrote:
> > Dne 5.10.2011 10:02, Lukas Czerner napsal(a):
> > > On Tue, 4 Oct 2011, Zdenek Kabelac wrote:
> > > > Dne 4.10.2011 14:13, Lukas Czerner napsal(a):
> > > > > On Tue, 4 Oct 2011, Zdenek Kabelac wrote:
 
You both lost me several messages ago!

For *changes* to functionality, what I'm looking for is:

  Description of how it works today in *all* relevant code paths/option
combinations/invocation methods;

  Description/explanation of how it will work *after* the change has been made
in all the same cases as now plus any new ones

Explanation of/justification for the difference.

Currently in lvm:

  --yes is meant to mean 'answer yes to all questions'
These are generally informative questions telling the user what the tool will do
and seeking confirmation.  On its own, they should not be dangerous or risk
corruption.  Example: removing an LV that is active but not currently being used.
The idea of such questions is to point out to the user the actual consequences
of the command to help to make sure they understand what will happen.

  --force is meant to mean 'permit operations that might not always be wise but
sometimes do need to be done - assume the user knows what they are doing'.
Normally a warning of what will happen is issued and confirmation is required,
but --yes can be used to avoid that confirmation.

For dangerous things that wouldn't normally make sense but occasionally can be
justified, like destroying PVs while they are in (inactive) VGs, --force can be
required to be repeated twice.


Now, let's try to understand:
  How these options are currently used in fsadm-related tools;
  What's good/bad here and perhaps ought to change.

Alasdair


