From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 22 Jun 2010 06:36:48 -0400
Subject: [PATCH 25/35] Make vg->mda_copies persistent in on disk vg metadata.
In-Reply-To: <4C2071F0.1030204@redhat.com>
References: <1277175968-9661-1-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-11-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-12-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-13-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-14-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-15-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-16-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-17-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-18-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-19-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-20-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-21-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-22-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-23-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-24-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-25-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-26-git-send-email-dwysocha@redhat.com>
	<4C2071F0.1030204@redhat.com>
Message-ID: <1277203009.2484.66.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, 2010-06-22 at 10:18 +0200, Zdenek Kabelac wrote:
> Dne 22.6.2010 05:05, Dave Wysochanski napsal(a):
> > This patch adds the ability to read/write the vg->mda_copies values
> > from/to the vg metadata.
> >
> > If we read the VG metadata and this field does not exist, we set
> > mda_copies to the default value of 0.  Later in the code, we use
> > this special '0' value to indicate a disable of metadata balancing.
> > This should preserve existing LVM behavior and ensure metadata balancing
> > can be turned off should the need arise.
> >
> > Signed-off-by: Dave Wysochanski<dwysocha@redhat.com>
> > ---
> >   lib/format_text/export.c      |    1 +
> >   lib/format_text/import_vsn1.c |    5 +++++
> >   2 files changed, 6 insertions(+), 0 deletions(-)
> >
> > diff --git a/lib/format_text/export.c b/lib/format_text/export.c
> > index 5f02b5d..52ae11c 100644
> > --- a/lib/format_text/export.c
> > +++ b/lib/format_text/export.c
> > @@ -397,6 +397,7 @@ static int _print_vg(struct formatter *f, struct volume_group *vg)
> >   		outf(f, "allocation_policy = \"%s\"",
> >   		     get_alloc_string(vg->alloc));
> >   	}
> > +	outf(f, "metadata_copies = %u", vg->mda_copies);
> >
> >   	return 1;
> 
> 
> Hmm - so we add a new element to the metadata format with the same version 
> number? If the user will update metadata with older tools which do not know 
> about this parameter - will he get at least a warning that he will miss some 
> information ?
> 

LVM ignores unknown fields in the vg metadata, and if older tools are
used after metadata is written with new tools and this value, yes,
you'll lose this field (it will go back to default value of "disabled
metadata balance").

If we update FORMAT_VERSION_VALUE, older tools will just refuse to parse
the metadata completely and the tools are useless.  I don't think this
is what users would want.  Perhaps there should be a warning of sorts
when unknown fields are encountered, though I've not looked into such a
patch.

It's not clear what process (if any) we are using when updating on-disk
metadata and fields.  Another case is my first few patches, where I take
a previously unused area of the LVM header area and use it for flags.  I
have not tested whether older tools would wipe the value of the
"ignored" flag or whether it would be preserved.

Was someone working on patches or rules for updating on-disk
fields/metadata?  It does not seem like we test these types of scenarios
but I guess so far it has "just worked".


