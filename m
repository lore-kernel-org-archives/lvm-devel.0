From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 19 Feb 2010 16:30:08 +0000
Subject: lvm and locales memory issue
In-Reply-To: <4B7EB81D.6090405@redhat.com>
References: <4B7D063A.7070601@redhat.com> <4B7D372D.4060608@redhat.com>
	<4B7D4014.3010205@redhat.com> <4B7EB81D.6090405@redhat.com>
Message-ID: <20100219163008.GR27427@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Feb 19, 2010 at 05:11:09PM +0100, Zdenek Kabelac wrote:
> Jakub suggest solution to use  a tiny small forked() process with very limited
> funcionality to handle mlockall() task  without any usage of locales.

Nack.  It's not tiny - it's most of the code - and it's a *state* of usage of
the code - a way of using the *same* code as we also use without mlockall at
other times - the code knows to behave slightly differently depending whether
or not it is in this state.

Surely most people don't need most of the locales - they should be able to
choose which ones to cache in the archive file - the ones they regularly use -
and take the performance hit on the occasions (if any) they want to use the
non-cached ones.

I notice the code to build the archive is in a 'fedora' subdir in the spec file
with hard-coded pathnames.  Is there an 'upstream' approach here or do different
distributions handle this differently and if so why?

> Eventually error reports, debugs and other things should be handled in
> surrounding environment - just like we have discussed already as a one
> potential solution.
 
Opposite way around.  The hack would be to push all the things that attempt to
access that locale archive file out into a subprocess.  That would first require
an audit of all the the glibc functions we use to determine which ones can attempt
to access that file.  Then we'd have to place wrappers around those functions 
to push them into a subprocess and avoid using them synchronously when in this
'mlocked' state.

Alasdair


